---
layout: post
title: "Анализ списка инвентаризаций одним махом."
date: 2014-10-28 23:07
categories: "develop1c"
description: "В статье описываются: <ul> <li>Программное заполнение дерева значений</li><li>Добавление картинки к тексту в строке табличного поля на форме</li><li>Формирование печатной формы отчета на основании существующего макета СКД из внешней обработки</li><li>Передача и обработка расшфировки в другой форме</li></ul>"
---

###Постановка задачи
После того как мы сделали ряд инвентаризаций и по результатам ввели документы, оказалось, что найти документ какую то конкретную инвентаризацию, что бы потом быстро что то поправить, в оприходованиях или списаниях целая задача. Было решено набросать набросать обработку которая будет:
* показывать все инвентаризации
* документы которые введены на ее основании
* номенклатуру остаток которой был исправлен этими документами.
При двойном щелчке по документу получаем сам документ, двойном щелчке по номенклатуре получаем историю движению по регистру хранения остатков. Цели ясны, задачи определены, приступаем.

###Получение нужных данных.
Вот сам запрос:
<pre><p style="text-align: left; font-family: courier new,courier; color: black">
<font color=blue>ВЫБРАТЬ<br>
&nbsp; &nbsp; </font>ОприходованиеТоваров.<font color=brown>Ссылка </font><font color=blue>КАК </font><font color=brown>Ссылка</font><font color=blue>,<br>
&nbsp; &nbsp; </font>ОприходованиеТоваров.ИнвентаризацияТоваровНаСкладе <font color=blue>КАК </font>ИнвентаризацияТоваровНаСкладе<font color=blue>,<br>
&nbsp; &nbsp; </font>ОприходованиеТоваров.ИнвентаризацияТоваровНаСкладе.Дата <font color=blue>КАК </font>ИнвентаризацияТоваровНаСкладеДата<br>
<font color=blue>ИЗ<br>
&nbsp; &nbsp; </font>Документ.ОприходованиеТоваров <font color=blue>КАК </font>ОприходованиеТоваров<br>
<br>
<font color=blue>ОБЪЕДИНИТЬ ВСЕ<br>
<br>
ВЫБРАТЬ<br>
&nbsp; &nbsp; </font>СписаниеТоваров.Ссылка<font color=blue>,<br>
&nbsp; &nbsp; </font>СписаниеТоваров.ИнвентаризацияТоваровНаСкладе<font color=blue>,<br>
&nbsp; &nbsp; </font>СписаниеТоваров.ИнвентаризацияТоваровНаСкладе.Дата<br>
<font color=blue>ИЗ<br>
&nbsp; &nbsp; </font>Документ.СписаниеТоваров <font color=blue>КАК </font>СписаниеТоваров<br>
<br>
<font color=blue>УПОРЯДОЧИТЬ ПО<br>
&nbsp; &nbsp; </font>ИнвентаризацияТоваровНаСкладеДата <font color=blue>УБЫВ<br>
ИТОГИ ПО<br>
&nbsp; &nbsp; </font>ИнвентаризацияТоваровНаСкладе</p></pre>

Далее мы выполняем запрос и обходим его по группировкам.
<pre><p>
Выборка <font color=red>= </font>Запрос<font color=red>.</font>Выполнить<font color=red>().</font>Выбрать<font color=red>(</font>ОбходРезультатаЗапроса<font color=red>.</font>ПоГруппировкам<font color=red>);<br>
Пока </font>Выборка<font color=red>.</font>Следующий<font color=red>() Цикл<br>
&nbsp; &nbsp; </font>СтрокаИнвентаризация <font color=red>= </font>СписокДокументов<font color=red>.</font>Строки<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; </font>СтрокаИнвентаризация<font color=red>.</font>Док <font color=red>= </font>Выборка<font color=red>.</font>ИнвентаризацияТоваровНаСкладе<font color=red>;<br>
&nbsp; &nbsp; </font>СтрокаИнвентаризация<font color=red>.</font>Картинко <font color=red>= ?(</font>СтрокаИнвентаризация<font color=red>.</font>Док<font color=red>.</font>Проведен<font color=red>, </font><font color=black>1</font><font color=red>, ?(</font>СтрокаИнвентаризация<font color=red>.</font>Док<font color=red>.</font>ПометкаУдаления<font color=red>, </font><font color=black>2</font><font color=red>, </font><font color=black>0</font><font color=red>));<br>
<br>
&nbsp; &nbsp; </font>СкладскиеДокументы <font color=red>= </font>Выборка<font color=red>.</font>Выбрать<font color=red>();<br>
&nbsp; &nbsp; Пока </font>СкладскиеДокументы<font color=red>.</font>Следующий<font color=red>() Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСклад <font color=red>= </font>СтрокаИнвентаризация<font color=red>.</font>Строки<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСклад<font color=red>.</font>Док <font color=red>= </font>СкладскиеДокументы<font color=red>.</font>Ссылка<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСклад<font color=red>.</font>Картинко <font color=red>= ?(</font>СтрокаСклад<font color=red>.</font>Док<font color=red>.</font>Проведен<font color=red>, </font><font color=black>1</font><font color=red>, ?(</font>СтрокаСклад<font color=red>.</font>Док<font color=red>.</font>ПометкаУдаления<font color=red>, </font><font color=black>2</font><font color=red>, </font><font color=black>0</font><font color=red>));<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ВсегоПройдетПоДокументу <font color=red>= </font><font color=black>0</font><font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; Для Каждого </font>СтрокаДокумента <font color=red>Из </font>СтрокаСклад<font color=red>.</font>Док<font color=red>.</font>Товары <font color=red>Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСТоваром <font color=red>= </font>СтрокаСклад<font color=red>.</font>Строки<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСТоваром<font color=red>.</font>Док <font color=red>= </font>СтрокаДокумента<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСТоваром<font color=red>.</font>Количество <font color=red>= </font>СтрокаДокумента<font color=red>.</font>Количество<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>ВсегоПройдетПоДокументу <font color=red>= </font>ВсегоПройдетПоДокументу <font color=red>+ </font>СтрокаДокумента<font color=red>.</font>Количество<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; КонецЦикла;<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтрокаСклад<font color=red>.</font>Количество <font color=red>= </font>ВсегоПройдетПоДокументу<font color=red>;<br>
&nbsp; &nbsp; КонецЦикла;<br>
КонецЦикла;<br>
</font></p></pre> Готово! Теперь у нас есть вот такого вида форма
![Дерево на форме](http://i.imgur.com/LoUtLYg.png)

###Вывод картинки отображающей статус для каждого документа.
Следует заметить, что для наглядности в дереве отмечается статус документов(проведен, не проведен, помечен на удаление), как вы поняли в выше приведенном коде за этот момент отвечает вот эта строка:
<pre><p>СтрокаСклад<font color=red>.</font>Картинко <font color=red>= ?(</font>СтрокаСклад<font color=red>.</font>Док<font color=red>.</font>Проведен<font color=red>, </font><font color=black>1</font><font color=red>, ?(</font>СтрокаСклад<font color=red>.</font>Док<font color=red>.</font>ПометкаУдаления<font color=red>, </font><font color=black>2</font><font color=red>, </font><font color=black>0</font><font color=red>));<br>
</font></p></pre>
Для начала определимся с самой картинкой, вот она: ![Статус проведенности документа](http://i.imgur.com/PD7usod.png)
Для того, что бы увидеть эту картинку в одной из колонок нужно:
1. Добавить эту картинку в свойство `КартинкиСтрок` у колонки для которой мы хотим отображать эту картинку.
1. Указать у нужной колонки свойство `ДанныеКартинки`. Указав данное свойство, мы фактически добавили еще одну колонку в которой будет храниться индекс отображаемой картинки
1. Заполнить свойство `ДанныеКартинки` при добавлении строки.

###Формирование отчета СКД из существующего макета.
Так как у нас просто есть схема которая лежит в макете, внешней обработки, то нам надо програмно:
* Загрузить схему в компоновщик макета.
* Инициализировать настройки на основании, нашей схемы.
* Установить параметры отчета.

Вроде бы все достаточно просто, но на понимание того как это должно происходить, может уйти достаточно много времени. После детального изучения вопроса, была найдена [статья](http://infostart.ru/public/80164/) откуда была выдернута вот эта процедура
<pre><p><font color=red>Процедура </font>ПолучитьДанныеНаОснованииСКД<font color=red>(</font>СКД<font color=red>, </font>ОбъектДляЗагрузки<font color=red>, </font>ИсполняемыеНастройки <font color=red>= Неопределено, </font>СтруктураПараметров <font color=red>= Неопределено, </font>РасшифровкаСКД <font color=red>= Неопределено, </font>МакетКомпоновки <font color=red>= Неопределено, </font>ВнешниеНаборыДанных <font color=red>= Неопределено) Экспорт<br>
<br>
&nbsp; &nbsp; </font>КомпоновщикМакета <font color=red>= Новый </font>КомпоновщикМакетаКомпоновкиДанных<font color=red>;<br>
<br>
&nbsp; &nbsp; Если </font>ТипЗнч<font color=red>(</font>ОбъектДляЗагрузки<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"ПолеТабличногоДокумента"</font><font color=red>) ИЛИ </font>ТипЗнч<font color=red>(</font>ОбъектДляЗагрузки<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"ТабличныйДокумент"</font><font color=red>) Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ТипГенератора <font color=red>= </font>Тип<font color=red>(</font><font color=black>"ГенераторМакетаКомпоновкиДанных"</font><font color=red>);<br>
&nbsp; &nbsp; Иначе<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ТипГенератора <font color=red>= </font>Тип<font color=red>(</font><font color=black>"ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"</font><font color=red>);<br>
&nbsp; &nbsp; КонецЕсли;<br>
&nbsp; &nbsp; Если </font>ИсполняемыеНастройки <font color=red>= Неопределено Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ИсполняемыеНастройки <font color=red>= </font>СКД<font color=red>.</font>НастройкиПоУмолчанию<font color=red>;<br>
&nbsp; &nbsp; КонецЕсли;<br>
<br>
&nbsp; &nbsp; Если </font>СтруктураПараметров <font color=red><> Неопределено Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>КоллекцияЗначенийПараметров <font color=red>= </font>ИсполняемыеНастройки<font color=red>.</font>ПараметрыДанных<font color=red>.</font>Элементы<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; Для каждого </font>Параметр <font color=red>Из </font>СтруктураПараметров <font color=red>Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>НайденноеЗначениеПараметра <font color=red>= </font>КоллекцияЗначенийПараметров<font color=red>.</font>Найти<font color=red>(</font>Параметр<font color=red>.</font>Ключ<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Если </font>НайденноеЗначениеПараметра <font color=red><> Неопределено Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>НайденноеЗначениеПараметра<font color=red>.</font>Использование <font color=red>= Истина;<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>НайденноеЗначениеПараметра<font color=red>.</font>Значение <font color=red>= </font>Параметр<font color=red>.</font>Значение<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; КонецЕсли;<br>
&nbsp; &nbsp; &nbsp; &nbsp; КонецЦикла;<br>
&nbsp; &nbsp; КонецЕсли;<br>
<br>
&nbsp; &nbsp; </font>МакетКомпоновкиСКД <font color=red>= </font>КомпоновщикМакета<font color=red>.</font>Выполнить<font color=red>(</font>СКД<font color=red>, </font>ИсполняемыеНастройки<font color=red>, </font>РасшифровкаСКД<font color=red>, </font>МакетКомпоновки<font color=red>, </font>ТипГенератора<font color=red>);<br>
&nbsp; &nbsp; </font>ПроцессорКомпоновки <font color=red>= Новый </font>ПроцессорКомпоновкиДанных<font color=red>;<br>
&nbsp; &nbsp; </font>ПроцессорКомпоновки<font color=red>.</font>Инициализировать<font color=red>(</font>МакетКомпоновкиСКД<font color=red>, </font>ВнешниеНаборыДанных<font color=red>, </font>РасшифровкаСКД<font color=red>);<br>
<br>
&nbsp; &nbsp; Если </font>ТипЗнч<font color=red>(</font>ОбъектДляЗагрузки<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"ПолеТабличногоДокумента"</font><font color=red>) ИЛИ </font>ТипЗнч<font color=red>(</font>ОбъектДляЗагрузки<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"ТабличныйДокумент"</font><font color=red>) Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ПроцессорВывода <font color=red>= Новый </font>ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ПроцессорВывода<font color=red>.</font>УстановитьДокумент<font color=red>(</font>ОбъектДляЗагрузки<font color=red>);<br>
&nbsp; &nbsp; Иначе<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ПроцессорВывода <font color=red>= Новый </font>ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ПроцессорВывода<font color=red>.</font>УстановитьОбъект<font color=red>(</font>ОбъектДляЗагрузки<font color=red>);<br>
&nbsp; &nbsp; КонецЕсли;<br>
<br>
&nbsp; &nbsp; </font>ПроцессорВывода<font color=red>.</font>ОтображатьПроцентВывода <font color=red>= Истина;<br>
&nbsp; &nbsp; </font>ПроцессорВывода<font color=red>.</font>Вывести<font color=red>(</font>ПроцессорКомпоновки<font color=red>, Истина);<br>
КонецПроцедуры</font></p></pre>
ее суть проста: на входе макет, на выходе табличный документ. Теперь когда мы умеем формировать табличный документ на основе макета, мы можем одним легким движением, добавить расшифровку движений по складу для номенклатуры которая есть в нашем отчете. Приступаем.

###Формирование истории движений конкретной номенклатуру по событию ни форме.
огда возникают вопросы: "А в чем дело, почему у меня тосола -15 банок, я ведь все правильно делал", самое время пожать плечами и молча ткнуть пользователя в историю движений. Тут нам и поможет наш отчет на СКД. Мысль следующая: когда мы щелкаем на поле два раза по какой то номенклатуре, инициализируется простейший отчет на СКД который выводит все движения по таблице остатки и обороты регистра `ТоварыВРознице`. Отчет достаточно простой постороенный вот на таком запросе.
<pre><p style="text-align: left; font-family: courier new,courier; color: black"><font color=blue>ВЫБРАТЬ<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.Период<font color=blue>,<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.Регистратор<font color=blue>,<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.КоличествоНачальныйОстаток<font color=blue>,<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.КоличествоПриход<font color=blue>,<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.КоличествоРасход<font color=blue>,<br>
&nbsp; &nbsp; </font>ТоварыВРозницеОстаткиИОбороты.КоличествоКонечныйОстаток<br>
<font color=blue>ИЗ<br>
&nbsp; &nbsp; </font>РегистрНакопления.ТоварыВРознице.ОстаткиИОбороты<font color=blue>(<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>Регистратор<font color=blue>,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ,<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>Номенклатура <font color=blue>= </font><font color=#008b8b>&Номенклатура<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font><font color=brown>И </font>Склад <font color=blue>= </font><font color=#008b8b>&Склад</font><font color=blue>) КАК </font>ТоварыВРозницеОстаткиИОбороты</p></pre> я думаю вы натыкаете его мышкой за 2 минуты.
*Перед тем как продолжить, я хотел бы попросить читателя если он еще не разобрался, понять что табличное поле и табличный документ это абсолютно разные сущности. Табличное поле, может быть списком значений, таблицей значений или деревом значений. Табличный документ это объект для формирования печатных форм, он имеет структуру схожую с excel но похожесть чисто внешняя.*
####Подготовительные действия.
Добавляем макет в обработку, указываем тип макета "Схема компоновки данных". Теперь можно им пользоваться в самой обработке. Можно сразу вывести отчет в табличный документ и на этом расслабиться, но тогда в нем не будет работать расшифровка, что бы в отчете работала расшифровка, табличный документ должен находиться на какой нибудь форме. Поэтому нам нужна форма и мы ее добавим как произвольную форму для обработки и поместим на нее табличный документ куда и будем выводить наш отчет. На этом все подготовительные действия закончены.

####Вывод отчета из подготовленного макета в подготоваленную форму.
Далее нам нужен план действий, приблизительно следующего вида, когда пользователь щелкает по строке табличного поля на форме, то:
1. Если он щелкает по строке указывающей на документ, от открывается форма документа.
1. Если он щелкает по номенклатуре, то нам нужно
  1. Загрузить макет формирующий историю движений.
  1. Получить форму отчета, с табличным документом куда мы будем грузить отчет и реквизитом `ОбработчикРасшифровки` произвольного типа куда мы будем передавать расшифровку.
  1. Вывести на основании макета отчет в полученную форму и настроить обработку расшифровки.

Вешаем на событие 'Выбор' табличного поля, следующую процедуру:
<pre><p><font color=red>Процедура </font>СписокДокументовВыбор<font color=red>(</font>Элемент<font color=red>, </font>ВыбраннаяСтрока<font color=red>, </font>Колонка<font color=red>, </font>СтандартнаяОбработка<font color=red>)<br>
&nbsp; &nbsp; </font>СтандартнаяОбработка <font color=red>= Ложь;<br>
&nbsp; &nbsp; Если </font>Документы<font color=red>.</font>ТипВсеСсылки<font color=red>().</font>СодержитТип<font color=red>(</font>ТипЗнч<font color=red>(</font>ВыбраннаяСтрока<font color=red>.</font>Док<font color=red>)) Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ВыбраннаяСтрока<font color=red>.</font>Док<font color=red>.</font>ПолучитьФорму<font color=red>().</font>Открыть<font color=red>();<br>
&nbsp; &nbsp; Иначе<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СхемаКомпоновкиДанных <font color=red>= </font>ПолучитьМакет<font color=red>(</font><font color=black>"ОтчетПоДвижениямНоменклатуры"</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураПараметров <font color=red>= Новый </font>Структура<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураПараметров<font color=red>.</font>Вставить<font color=red>(</font><font color=black>"НачалоПериода"</font><font color=red>, </font>ТекущаяДата<font color=red>() - </font><font color=black>31556926</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураПараметров<font color=red>.</font>Вставить<font color=red>(</font><font color=black>"КонецПериода"</font><font color=red>, </font>ТекущаяДата<font color=red>());<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураПараметров<font color=red>.</font>Вставить<font color=red>(</font><font color=black>"Номенклатура"</font><font color=red>, </font>ЭлементыФормы<font color=red>.</font>СписокДокументов<font color=red>.</font>ТекущаяСтрока<font color=red>.</font>Док<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураПараметров<font color=red>.</font>Вставить<font color=red>(</font><font color=black>"Склад"</font><font color=red>, </font>ЭлементыФормы<font color=red>.</font>СписокДокументов<font color=red>.</font>ТекущаяСтрока<font color=red>.</font>Родитель<font color=red>.</font>Док<font color=red>.</font>Склад<font color=red>);<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Расшифровка <font color=red>= Новый </font>ДанныеРасшифровкиКомпоновкиДанных<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ФормаОтчета <font color=red>= </font>ПолучитьФорму<font color=red>(</font><font color=black>"ИсторияДвижений"</font><font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ПолучитьДанныеНаОснованииСКД<font color=red>(</font>СхемаКомпоновкиДанных<font color=red>, </font>ФормаОтчета<font color=red>.</font>ЭлементыФормы<font color=red>.</font>ПолеТабличногоДокумента1<font color=red>, </font>СхемаКомпоновкиДанных<font color=red>.</font>НастройкиПоУмолчанию<font color=red>, </font>СтруктураПараметров<font color=red>, </font>Расшифровка<font color=red>);<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ФормаОтчета<font color=red>.</font>ОбработчикРасшифровки <font color=red>= Новый </font>ОбработкаРасшифровкиКомпоновкиДанных<font color=red>(</font>Расшифровка<font color=red>, Новый </font>ИсточникДоступныхНастроекКомпоновкиДанных<font color=red>(</font>СхемаКомпоновкиДанных<font color=red>));<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ФормаОтчета<font color=red>.</font>Открыть<font color=red>();<br>
&nbsp; &nbsp; КонецЕсли;<br>
КонецПроцедуры<br></font></p></pre>
которая реализует почти все кроме пункта 2.3. Остался последний штрих, добавить в открываюмую форму обработку расшифровки. Для этого используем событие `ОбработкаРасшифровки` где укажем следующий код:
<pre><p>
ОбработчикРасшифровки<font color=red>.</font>Выполнить<font color=red>(</font>Расшифровка<font color=red>);<br>
</font>СтандартнаяОбработка <font color=red>= Ложь;<br>
</font></p></pre>
Теперь расшифровка должна работать как и собственно сама обработка.

###Заключение
как обычно почти весь код приведен и снабжен комментариями, но если у вас не получается собрать аленький цветочек [можно скачать обработку на инфостарте](http://infostart.ru/public/171476/)
