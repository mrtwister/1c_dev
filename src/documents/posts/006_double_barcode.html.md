---
layout: post
title: "Двойные штрихкода и история одной обработки"
date: 2013-09-08 22:03
categories: "develop1c"
description: "История разработки обработки. Поиск задвоенных штрихкодов запросом, работа с регистром штрихкодов, деревом значений и все все все."
---
###Преамбула
В какой то момент в базе встала проблема двойных штрихкодов. Причем ситация до того как на нее обратили внимание, приобрела катосторофический характер и имела полторы тысячи дублей штрихкодов (когда один штрихкод принадлежит нескольким товарам) и порядка 25ти тысяч дублей товаров (когда у одного товарам есть несколько штрихкодов). Что тому виной? На текущий момент уже сложно сказать. Возможно РИБ, когда одному и тому же товару присваивают штрихкод в разных базах. Возможно свою лепту внесли слияния нескольких баз с одинаковым товаром, но разными штрихкодами. Скорее всего все вместе + какой то еще фактор, который мы пока не можем найти. Слишком много вышло дублей, почти четверть базы. Так или иначе встала задача с этими штрихкодами что то сделать.
###Постановка задачи.
Необходимо найти задублирововашиеся штрихкода и показить пользователю в удобном виде. Дать возможность что то сделать сразу с этими штрихкодами без необходимости лазить по справочникам и регистрам. Если говорить конкретно, то у пользователя должна быть возможность:

1. Удалить все штрихкода у владельца, кроме выделенного.
2. Удалить конкретный лишний штрихкод.
3. Одним махом удалить все лишние дубли, оставив по одному на владельца.
4. Удалить все штрихкода которые засветились как задублированные.

###Приступим к реализации первой части.
Поиск лишних штрихкодов. Сам поиск достататочно банален: нужно воспользоваться функций КОЛИЧЕСТВО(РАЗЛИЧНЫЕ СюдаУказатьПолеДляГруппировки). В самом простом случае, запрос будет выглядеть вот так:

<p style="text-align: left; font-family: courier new,courier; color: black">
<font color=blue>ВЫБРАТЬ<br>
&nbsp; &nbsp; </font>Штрихкоды.Штрихкод<font color=blue>,<br>
&nbsp; &nbsp; </font><font color=brown>КОЛИЧЕСТВО</font><font color=blue>(РАЗЛИЧНЫЕ </font>Штрихкоды.Владелец<font color=blue>) КАК </font>Владелец<br>
<font color=blue>ИЗ<br>
&nbsp; &nbsp; </font>РегистрСведений.Штрихкоды <font color=blue>КАК </font>Штрихкоды<br>
<br>
<font color=blue>СГРУППИРОВАТЬ ПО<br>
&nbsp; &nbsp; </font>Штрихкоды.Штрихкод</p>
Для того, что бы отфильтровать результаты запроса необходимо его обернуть во вложеный запрос и тогда уже можно накладывать условия на результат его работы. В целом нормально, но как то неудобно, для удобства наверно не помешает сгруппировать результаты по штрихкодам. В результате мы можем получить вот такой запрос. Вот результат его работы в консоли.
![Результат работы запроса](https://api.monosnap.com/image/download?id=5e8qdGdh0ss6sMzCTYOarse6J "Результат работы запроса в консоли")
Этот вариант удобен для первого варианта поиска, сделать запрос для второго варианта по аналогии не должно составить труда. Запросы готовы, но не будет же пользователь смотреть на результат его работы из консоли. Здесь нам и поможет дерево значений. Смысл работы с деревом следующий: дерево содержит колекцию колонок и строк. Коллекция колонок не отличается от коллекции колонок в таблице значений и нас не интересует. Коллекция строк немного инетереснее, каждая строка ее может содержать такую же коллекцию строк, каждая строка которой... вообщем я думаю мысль понятна, таким образом и организуется иерархия. Используем обход результатов запроса по группировкам, для того что сформировать удобное дерево:
<pre><p>&nbsp; &nbsp; Выборка <font color=red>= </font>Запрос<font color=red>.</font>Выполнить<font color=red>().</font>Выбрать<font color=red>(</font>ОбходРезультатаЗапроса<font color=red>.</font>ПоГруппировкам<font color=red>);<br>
&nbsp; &nbsp; </font>ЭтаФорма<font color=red>.</font>Заголовок <font color=red>= </font><font color=black>"Найдено " </font><font color=red>+ </font>Выборка<font color=red>.</font>Количество<font color=red>();<br>
&nbsp; &nbsp; Пока </font>Выборка<font color=red>.</font>Следующий<font color=red>() Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаТП <font color=red>= </font>ТабличноеПоле<font color=red>.</font>Строки<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаТП<font color=red>.</font>Номенклатура <font color=red>= </font>Выборка<font color=red>.</font>Штрихкод<font color=red>;<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>ВыборкаШтрихКода <font color=red>= </font>Выборка<font color=red>.</font>Выбрать<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; Пока </font>ВыборкаШтрихКода<font color=red>.</font>Следующий<font color=red>() Цикл<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаВладелец <font color=red>= </font>НоваяСтрокаТП<font color=red>.</font>Строки<font color=red>.</font>Добавить<font color=red>();<br>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </font>НоваяСтрокаВладелец<font color=red>.</font>Номенклатура <font color=red>= </font>ВыборкаШтрихКода<font color=red>.</font>Владелец<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; КонецЦикла;<br>
&nbsp; &nbsp; КонецЦикла;</font></p></pre>

Как следствие мы можем получить вот такую форму:
![Форма обработки](https://api.monosnap.com/image/download?id=wDPn9V8vDlujcauOfMSIonqUr "Сгруппированные штрихкода на форме")

###Работа с регистром штрихкодов
Когда есть все нужные данные можно начинать работать с регистром штрихкодов. Так как у нас ищутся не только штрихкода с несколькими владельцами, но и владельцы с несколькими штрихкодами, то состав табличного поля может быть разным, это необходимо учитывать. Приступим к реализации п1 - Удалить все штрихкода кроме выделенного. Для этого подготовим данные для записи в регистр. Выделим значение отобора и штрихкод который нам надо оставить:

<pre><p>&nbsp; &nbsp; СтруктураВРегистр <font color=red>= Новый </font>Структура<font color=red>(</font><font color=black>"КлючОтбора, ЗначениеОтбора, ШтрихКод, Владелец"</font><font color=red>);<br>
<br>
&nbsp; &nbsp; Если </font>ТипЗнч<font color=red>(</font>СтрокаДерева<font color=red>.</font>Номенклатура<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"СправочникСсылка.Номенклатура"</font><font color=red>)<br>
&nbsp; &nbsp; &nbsp; &nbsp; ИЛИ </font>ТипЗнч<font color=red>(</font>СтрокаДерева<font color=red>.</font>Номенклатура<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"СправочникСсылка.ИнформационныеКарты"</font><font color=red>) Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>КлючОтбора <font color=red>= </font><font color=black>"Штрихкод"</font><font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>ЗначениеОтбора <font color=red>= </font>СтрокаДерева<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>Штрихкод <font color=red>= </font>СтрокаДерева<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>Владелец <font color=red>= </font>СтрокаДерева<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; Иначе<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>КлючОтбора <font color=red>= </font><font color=black>"Владелец"</font><font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>ЗначениеОтбора <font color=red>= </font>СтрокаДерева<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>Штрихкод <font color=red>= </font>СтрокаДерева<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>СтруктураВРегистр<font color=red>.</font>Владелец <font color=red>= </font>СтрокаДерева<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; КонецЕсли;<br></font></p></pre>

Теперь надо удалить все "лишние" штрихкода кроме конкретного, того на который указал пользователь. Я решил этот вопрос просто: я очищаю набор по указанному отбору и добавляю нужный штрихкод. По моему это самый простой и быстрый способ. Вот код:

<pre><p>
НаборЗаписей <font color=red>= </font>РегистрыСведений<font color=red>.</font>Штрихкоды<font color=red>.</font>СоздатьНаборЗаписей<font color=red>();<br>
</font>НаборЗаписей<font color=red>.</font>Отбор<font color=red>[</font>СтруктураСДанными<font color=red>.</font>КлючОтбора<font color=red>].</font>Установить<font color=red>(</font>СтруктураСДанными<font color=red>.</font>ЗначениеОтбора<font color=red>);<br>
</font>НаборЗаписей<font color=red>.</font>Записать<font color=red>();<br>
<br>
</font>НоваяЗаписьНабора <font color=red>= </font>НаборЗаписей<font color=red>.</font>Добавить<font color=red>();<br>
</font>НоваяЗаписьНабора<font color=red>.</font>Владелец <font color=red>= </font>СтруктураСДанными<font color=red>.</font>Владелец<font color=red>;<br>
</font>НоваяЗаписьНабора<font color=red>.</font>ЕдиницаИзмерения <font color=red>= </font>СтруктураСДанными<font color=red>.</font>Владелец<font color=red>.</font>ЕдиницаХраненияОстатков<font color=red>;<br>
</font>НоваяЗаписьНабора<font color=red>.</font>ТипШтрихкода <font color=red>= </font>ПланыВидовХарактеристик<font color=red>.</font>ТипыШтрихкодов<font color=red>.</font>EAN13<font color=red>;<br>
</font>НоваяЗаписьНабора<font color=red>.</font>Штрихкод <font color=red>= </font>СтруктураСДанными<font color=red>.</font>ШтрихКод<font color=red>;<br>
</font>НоваяЗаписьНабора<font color=red>.</font>Качество <font color=red>= </font>Справочники<font color=red>.</font>Качество<font color=red>.</font>Новый<font color=red>;<br>
<br>
</font>НаборЗаписей<font color=red>.</font>Записать<font color=red>();</font></p></pre>

Перебирая строки дерева значений можно реализовать и п.3. Мы же идем дальше и приступаем к п.2. Для этих целей я использовал менеджер записи, в целом тут все просто до безобразия:
<pre><p>&nbsp; &nbsp; <font color=red>Если </font>ТипЗнч<font color=red>(</font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущиеДанные<font color=red>.</font>Номенклатура<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"СправочникСсылка.Номенклатура"</font><font color=red>)<br>
&nbsp; &nbsp; &nbsp; &nbsp; ИЛИ </font>ТипЗнч<font color=red>(</font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущиеДанные<font color=red>.</font>Номенклатура<font color=red>) = </font>Тип<font color=red>(</font><font color=black>"СправочникСсылка.ИнформационныеКарты"</font><font color=red>) Тогда<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Штрихкод <font color=red>= </font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущаяСтрока<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Владелец <font color=red>= </font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущиеДанные<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; Иначе<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Штрихкод <font color=red>= </font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущиеДанные<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; &nbsp; &nbsp; </font>Владелец <font color=red>= </font>ЭлементыФормы<font color=red>.</font>ТабличноеПоле<font color=red>.</font>ТекущаяСтрока<font color=red>.</font>Родитель<font color=red>.</font>Номенклатура<font color=red>;<br>
&nbsp; &nbsp; КонецЕсли;<br>
<br>
</font>МенеджерЗаписи <font color=red>= </font>РегистрыСведений<font color=red>.</font>Штрихкоды<font color=red>.</font>СоздатьМенеджерЗаписи<font color=red>();<br>
</font>МенеджерЗаписи<font color=red>.</font>Штрихкод <font color=red>= </font>Штрихкод<font color=red>;<br>
</font>МенеджерЗаписи<font color=red>.</font>Владелец <font color=red>= </font>Владелец<font color=red>;<br>
</font>МенеджерЗаписи<font color=red>.</font>ТипШтрихкода <font color=red>= </font>ПланыВидовХарактеристик<font color=red>.</font>ТипыШтрихкодов<font color=red>.</font>EAN13<font color=red>;<br>
</font>МенеджерЗаписи<font color=red>.</font>ЕдиницаИзмерения <font color=red>= </font>Владелец<font color=red>.</font>ЕдиницаХраненияОстатков<font color=red>;<br>
</font>МенеджерЗаписи<font color=red>.</font>Качество <font color=red>= </font>Справочники<font color=red>.</font>Качество<font color=red>.</font>Новый<font color=red>;<br>
</font>МенеджерЗаписи<font color=red>.</font>Прочитать<font color=red>();<br>
</font>МенеджерЗаписи<font color=red>.</font>Удалить<font color=red>();</font></p></pre>
Остался последний самый простой пункт. Я думаю тут даже код не нужен. Все и так просто. Делаем отбор в наборе и записываем не читая. Вот такая получилась обработка. Почти весь нужный код для работы обработки в этой статье есть. За бортом осталась косметика, украшательства и тд, то, что каждый настраивает по своему вкусу, но если все таки у вас не вышло собрать обработку, то обработку можно [скачать на инфостарте](http://infostart.ru/public/200131/).
