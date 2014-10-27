---
layout: post
title: "Хранение остатков поставщика у себя в базе"
date: 2012-09-06 15:47
categories: "develop1c"
description: "В этой статье, я хотел бы рассказать об опыте настройки хранения остатков по складу поставщика. Почему именно об этом? Потому что, заодно мы рассмотрим:<ul><li>Механизм обработки в запросе таблицы значений. Что в целом может пригодиться.</li><li>Механизм формирования таблицы движений сразу в запросе.</li></ul>"
---
Заказчиком было поставлено условие: изменение конфигурации, должно быть обоснованным и не происходить без надобности. Были найдены и рассмотрены следующие варианты:

 1. Добавление регистра в базу. Загрузка туда остатков, да и вообще всего что можно загрузить.
 2. Загрузка данных из экселя (Именно в этом формате поставщик хранит свои данные) каждый раз при открытии подбора в документ отгрузки.
 3. Создание нового склада, и загрузка данных туда корректирующим документом.

&nbsp;&nbsp;&nbsp;&nbsp;Первые два способа подразумевают модификацию обработки подбора в документ реализации  а один из них еще и добавление регистра, что само по себе не страшно конечно, но для заказчика не желательно. А во втором случае, надо каждый раз читать эксель, что тоже не очень хорошо. После [консультаций с комьюнити](http://www.forum.mista.ru/topic.php?id=619127), было выяснено, что вроде как все считают, что хранить  остатки у себя в базе нельзя, но почему, никто сказать не может. Решили остановиться на третьем варианте.

&nbsp;&nbsp;&nbsp;&nbsp;И так что мы будем делать:
1. Загрузим из подсунутого экселя остатки поставщика
2. Подсчитаем дельту, на которую надо скорректировать остатки.
3. Создадим документ «КоорректировкаЗаписейРегистраНакопления» и в него зальем движения.

И так: Читаем эксель в таблицу значений.
<pre><p><font color=red>Функция </font>ПрочитатьЭксель<font color=red>()<br>
&nbsp; &nbsp; </font>КСАртикул <font color=red>= Новый </font>КвалификаторыСтроки<font color=red>(</font><font color=black>25</font><font color=red>);<br>
&nbsp; &nbsp; </font>Массив <font color=red>= Новый </font>Массив<font color=red>;<br>
&nbsp; &nbsp; </font>Массив<font color=red>.</font>Добавить<font color=red>(</font>Тип<font color=red>(</font><font color=black>"Строка"</font><font color=red>));<br>
&nbsp; &nbsp; </font>ОписаниеТиповАртикул <font color=red>= Новый </font>ОписаниеТипов<font color=red>(</font>Массив<font color=red>, , </font>КСАртикул<font color=red>);<br>
<br>
&nbsp; &nbsp; </font>Массив<font color=red>.</font>Очистить<font color=red>();<br>
&nbsp; &nbsp; </font>КЧ <font color=red>= Новый </font>КвалификаторыЧисла<font color=red>(</font><font color=black>10</font><font color=red>);<br>
&nbsp; &nbsp; </font>Массив<font color=red>.</font>Добавить<font color=red>(</font>Тип<font color=red>(</font><font color=black>"Число"</font><font color=red>));<br>
&nbsp; &nbsp; </font>ОписаниеТиповЧ <font color=red>= Новый </font>ОписаниеТипов<font color=red>(</font>Массив<font color=red>, , ,</font>КЧ<font color=red>);<br>
<br>
&nbsp; &nbsp; </font>ТЗ <font color=red>= Новый </font>ТаблицаЗначений<font color=red>;<br>
&nbsp; &nbsp; </font>ТЗ<font color=red>.</font>Колонки<font color=red>.</font>Добавить<font color=red>(</font><font color=black>"Артикул"</font><font color=red>, </font>ОписаниеТиповАртикул<font color=red>);<br>
&nbsp; &nbsp; </font>ТЗ<font color=red>.</font>Колонки<font color=red>.</font>Добавить<font color=red>(</font><font color=black>"Количество"</font><font color=red>, </font>ОписаниеТиповЧ<font color=red>);<br>
<br>
&nbsp; &nbsp; Попытка<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Excel <font color=red>= Новый </font>COMОбъект<font color=red>(</font><font color=black>"Excel.Application"</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font><font color=green>//Excel.WorkBooks.Open("D:\Базы\НомеенклатураРулевойОбрезан.xls");<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Excel<font color=red>.</font>WorkBooks<font color=red>.</font>Open<font color=red>(</font>ИмяФайла<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Состояние<font color=red>(</font><font color=black>"Обработка файла Microsoft Excel"</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ExcelЛист <font color=red>= </font>Excel<font color=red>.</font>Sheets<font color=red>(</font><font color=black>1</font><font color=red>);<br>
&nbsp; &nbsp; Исключение<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Сообщить<font color=red>(</font><font color=black>"Не удалось обработать файл!"</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; Возврат </font><font color=black>""</font><font color=red>;<br>
&nbsp; &nbsp; КонецПопытки;<br>
<br>
&nbsp; &nbsp; Для </font>СтрокаЭксель <font color=red>= </font>СтрокаНачало <font color=red>По </font>СтрокаОкончание <font color=red>Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Прогресс <font color=red>= (</font>СтрокаЭксель <font color=red>/ </font>СтрокаОкончание<font color=red>) * </font><font color=black>100</font><font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ЭлементыФормы<font color=red>.</font>СтрокаСтатуса<font color=red>.</font>Заголовок <font color=red>= </font><font color=black>"Считывается эксель в память " </font><font color=red>+ </font>СтрокаЭксель <font color=red>+ </font><font color=black>" из " </font><font color=red>+ </font>СтрокаОкончание<font color=red>;<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Зн <font color=red>= </font>ExcelЛист<font color=red>.</font>Cells<font color=red>(</font>СтрокаЭксель<font color=red>, </font>КолонкаАртикул<font color=red>).</font>Text<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>АртикулВДокумент <font color=red>= </font>СокрЛ<font color=red>(</font>ExcelЛист<font color=red>.</font>Cells<font color=red>(</font>СтрокаЭксель<font color=red>, </font>КолонкаАртикул<font color=red>).</font>Text<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>КолвоВДокумент <font color=red>= </font>СокрЛ<font color=red>(</font>ExcelЛист<font color=red>.</font>Cells<font color=red>(</font>СтрокаЭксель<font color=red>, </font>КолонкаКоличество<font color=red>).</font>Text<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>КолвоВДокумент <font color=red>= ?(</font>КолвоВДокумент <font color=red>= </font><font color=black>""</font><font color=red>, </font><font color=black>0</font><font color=red>, </font>Число<font color=red>(</font>КолвоВДокумент<font color=red>));<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаТЗ <font color=red>= </font>ТЗ<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаТЗ<font color=red>.</font>Артикул <font color=red>= </font>АртикулВДокумент<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаТЗ<font color=red>.</font>Количество <font color=red>= </font>КолвоВДокумент<font color=red>;<br>
&nbsp; &nbsp; КонецЦикла;<br>
<br>
&nbsp; &nbsp; </font>Excel<font color=red>.</font>WorkBooks<font color=red>.</font>Close<font color=red>();<br>
&nbsp; &nbsp; </font>Excel <font color=red>= </font><font color=black>0</font><font color=red>;<br>
&nbsp; &nbsp; Возврат </font>ТЗ<font color=red>;<br>
<br>
КонецФункции </font><font color=green>// ПрочитатьЭксель()</font></p></pre>
&nbsp;&nbsp;&nbsp;&nbsp;Я читаю эксель в типизизрованную таблицу значений, потому что для обработки таблицы запросом она должна быть типизирована. На форме есть надпись с названием "СтрокаСтатуса" которая рассказывает про текущий ход загрузки данных из экселя. Так же есть поля ввода в которых лежат номера колонок где артикул номенклатуры а где количество. Здесь вроде все настолько просто, что даже не знаю что тут прокомментировать. Ну раз с первым моментом нам все ясно, перейдем к вычислению дельты которую надо грузить в регистр. Для начала, что бы обращаться к этой таблице в запросе, надо ее поместить во временную таблицу, это не очень сложно и делается с помощью вот такого кода:
<pre><p>ТЗЭксель <font color=red>= </font>ПрочитатьЭксель<font color=red>();<br>
<br>
</font>МВТ <font color=red>= Новый </font>МенеджерВременныхТаблиц<font color=red>;<br>
</font>ТаблицаЭксель <font color=red>= Новый </font>Запрос<font color=red>;<br>
</font>ТаблицаЭксель<font color=red>.</font>МенеджерВременныхТаблиц <font color=red>= </font>МВТ<font color=red>;<br>
</font>ТаблицаЭксель<font color=red>.</font>Текст <font color=red>=<br>
&nbsp; &nbsp; </font><font color=black>"Выбрать<br>
&nbsp; &nbsp; |&nbsp;&nbsp; *<br>
&nbsp; &nbsp; |ПОМЕСТИТЬ ДокЭксель<br>
&nbsp; &nbsp; |ИЗ<br>
&nbsp; &nbsp; |&ТаблицаСДанными КАК Таблица"</font><font color=red>;<br>
</font>ТаблицаЭксель<font color=red>.</font>УстановитьПараметр<font color=red>(</font><font color=black>"ТаблицаСДанными"</font><font color=red>, </font>ТЗЭксель<font color=red>);<br>
</font>ТаблицаЭксель<font color=red>.</font>Выполнить<font color=red>();</font></p></pre>
Таблица есть, теперь перейдем к загрузке. Так как в экселе могут быть уже существующие записи или не быть тех которые есть в регистре, мы будем привязываться к справочнику номенклатура. Собственно вот он запрос:
<pre><p style="text-align: left; font-family: courier new,courier; color: black">
<font color=blue>ВЫБРАТЬ<br>
&nbsp; &nbsp; </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ТоварыНаСкладахОстатки.КоличествоОстаток<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) КАК </font>ОстатокНаСкладе<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ДокЭксель.Количество<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) КАК </font>КоличествоЭксель<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>ВЫБОР<br>
&nbsp; &nbsp; &nbsp; &nbsp; КОГДА ЕСТЬNULL</font><font color=blue>(</font>ДокЭксель.Количество<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) - </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ТоварыНаСкладахОстатки.КоличествоОстаток<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) < </font><font color=#ff00ff>0<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font><font color=brown>ТОГДА </font><font color=#ff00ff>0 </font><font color=blue>- (</font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ДокЭксель.Количество<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) - </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ТоварыНаСкладахОстатки.КоличествоОстаток<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>))<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font><font color=brown>ИНАЧЕ ЕСТЬNULL</font><font color=blue>(</font>ДокЭксель.Количество<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) - </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ТоварыНаСкладахОстатки.КоличествоОстаток<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>)<br>
&nbsp; &nbsp; </font><font color=brown>КОНЕЦ </font><font color=blue>КАК </font><font color=brown>Количество</font><font color=blue>,<br>
&nbsp; &nbsp; </font><font color=#008b8b>&Склад</font><font color=blue>,<br>
&nbsp; &nbsp; </font>Товар.<font color=brown>Ссылка </font><font color=blue>КАК </font>Номенклатура<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>ЗНАЧЕНИЕ</font><font color=blue>(</font>Справочник.Качество.Новый<font color=blue>) КАК </font>Качество<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>ВЫБОР<br>
&nbsp; &nbsp; &nbsp; &nbsp; КОГДА ЕСТЬNULL</font><font color=blue>(</font>ДокЭксель.Количество<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) - </font><font color=brown>ЕСТЬNULL</font><font color=blue>(</font>ТоварыНаСкладахОстатки.КоличествоОстаток<font color=blue>, </font><font color=#ff00ff>0</font><font color=blue>) > </font><font color=#ff00ff>0<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font><font color=brown>ТОГДА ЗНАЧЕНИЕ</font><font color=blue>(</font>ВидДвиженияНакопления.Приход<font color=blue>)<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font><font color=brown>ИНАЧЕ ЗНАЧЕНИЕ</font><font color=blue>(</font>ВидДвиженияНакопления.Расход<font color=blue>)<br>
&nbsp; &nbsp; </font><font color=brown>КОНЕЦ </font><font color=blue>КАК </font>ВидДвижения<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>ИСТИНА </font><font color=blue>КАК </font>Активность<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=#008b8b>&Период</font><font color=blue>,<br>
&nbsp; &nbsp; </font><font color=#008b8b>&Док </font><font color=blue>КАК </font>Регистратор<br>
<font color=blue>ИЗ<br>
&nbsp; &nbsp; </font>Справочник.Номенклатура <font color=blue>КАК </font>Товар<br>
&nbsp; &nbsp; &nbsp; &nbsp; <font color=blue>ЛЕВОЕ СОЕДИНЕНИЕ </font>РегистрНакопления.ТоварыНаСкладах.Остатки<font color=blue>(, </font>Склад <font color=blue>= </font><font color=#008b8b>&Склад</font><font color=blue>) КАК </font>ТоварыНаСкладахОстатки<br>
&nbsp; &nbsp; &nbsp; &nbsp; <font color=blue>ПО </font>Товар.<font color=brown>Ссылка </font><font color=blue>= </font>ТоварыНаСкладахОстатки.Номенклатура<br>
&nbsp; &nbsp; &nbsp; &nbsp; <font color=blue>ЛЕВОЕ СОЕДИНЕНИЕ </font>ДокЭксель <font color=blue>КАК </font>ДокЭксель<br>
&nbsp; &nbsp; &nbsp; &nbsp; <font color=blue>ПО </font>Товар.Артикул <font color=blue>= </font>ДокЭксель.Артикул<br>
<font color=blue>ГДЕ<br>
&nbsp; &nbsp; </font>Товар.Артикул <font color=blue><> </font><font color=red>""</font></p></pre>
Не забываем, что для того что бы обратиться к временной таблице, нам надо указать менеджер временных таблиц:
<pre><p>Запрос<font color=red>.</font>МенеджерВременныхТаблиц <font color=red>= </font>МВТ<font color=red>;</font></p></pre>

`ЕСТЬNULL` нам гарантирует возврат числа в случае работы соединений, разницу мы получаем в строках с 4 по 8, строки с 9й по 19ю формируют значения для загрузки данных в регистр, собственно все почти готово. Осталось выгрузить результат в таблицу и удалить те значения которые грузить не надо(количество = 0) :
<pre><p>ДвиженияВДокумент <font color=red>= </font>Запрос<font color=red>.</font>Выполнить<font color=red>().</font>Выгрузить<font color=red>();</font><font color=green>//"Склад,Номенклатура,Качество,Количество"<br>
</font>НулевыеДвижения <font color=red>= </font>ДвиженияВДокумент<font color=red>.</font>НайтиСтроки<font color=red>(Новый </font>Структура<font color=red>(</font><font color=black>"Количество"</font><font color=red>,</font><font color=black>0</font><font color=red>));<br>
Для Каждого </font>СтрокаТаблицы <font color=red>Из </font>НулевыеДвижения <font color=red>Цикл<br>
&nbsp; &nbsp; </font>ДвиженияВДокумент<font color=red>.</font>Удалить<font color=red>(</font>СтрокаТаблицы<font color=red>);<br>
КонецЦикла;</font></p></pre>
Создать документ корректировки и добавить строку в ТЧ которая укажет на регистр, это нужно для отображения документа и обеспечения возможности его редактировать.
<pre><p>НовыйДок <font color=red>= </font>Документы<font color=red>.</font>КорректировкаЗаписейРегистров<font color=red>.</font>СоздатьДокумент<font color=red>();<br>
</font>НовыйДок<font color=red>.</font>Дата <font color=red>= </font>ТекущаяДата<font color=red>();<br>
</font>СтрокаТЧ <font color=red>= </font>НовыйДок<font color=red>.</font>ТаблицаРегистровНакопления<font color=red>.</font>Добавить<font color=red>();<br>
</font>СтрокаТЧ<font color=red>.</font>Имя <font color=red>= </font><font color=black>"ТоварыНаСкладах"</font><font color=red>;<br>
</font>СтрокаТЧ<font color=red>.</font>Представление <font color=red>= </font><font color=black>"Товары на складах"</font><font color=red>;<br>
</font>НовыйДок<font color=red>.</font>Записать<font color=red>();<br>
</font>НовыйДок <font color=red>= </font>НовыйДок<font color=red>.</font>Ссылка<font color=red>;<br>
</font></p></pre>
И собственно загрузить данные в регистр
<pre><p>НаборВРегистр <font color=red>= </font>РегистрыНакопления<font color=red>.</font>ТоварыНаСкладах<font color=red>.</font>СоздатьНаборЗаписей<font color=red>();<br>
</font>НаборВРегистр<font color=red>.</font>Отбор<font color=red>.</font>Регистратор<font color=red>.</font>Значение <font color=red>= </font>НовыйДок<font color=red>;<br>
</font>НаборВРегистр<font color=red>.</font>Загрузить<font color=red>(</font>ДвиженияВДокумент<font color=red>.</font>Скопировать<font color=red>(,</font><font color=black>"Период,Регистратор,Активность,ВидДвижения,Склад,Номенклатура,Качество,Количество"</font><font color=red>));<br>
</font>НаборВРегистр<font color=red>.</font>Записать<font color=red>();<br>
</font></p></pre>
&nbsp;&nbsp;&nbsp;&nbsp;Как вы могли заметить документ мы уже не трогаем, его не надо, не записывать, не проводить, он просто является основанием для записи в регистр.
Собственно на этом все, внимательный читатель наверняка уже нашел ошибку а вы? ;)
Как обычно для тех кто дочитал или прокрутил до конца как обычно бонус: [Обработка про которую я рассказывал в этом посте.](https://googledrive.com/host/0BxFnXEinPWUJckpLWkVCVjc0dUU/ЗагрузкаВНовыйСклад.epf)
