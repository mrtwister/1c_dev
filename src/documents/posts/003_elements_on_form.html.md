---
layout: post
title: "Программное расположение элементов на форме"
date: 2012-09-07 00:13
categories: "develop1c"
description: "Упрощение программного расположения элементов управления на форме."
---
Иногда есть необходимость расположить табличное поле на форме программно, например когда нужно добавить неизвестное заранее количество закладок, хорошо если нужно просто добавить закладки, тогда можно просто отделаться :
<pre><p>ЭлементыФормы<font color=red>.</font>ПанельСЗакладками<font color=red>.</font>Страницы<font color=red>.</font>Добавить<font color=red>(</font><font color=black>"ЗакладкаСклад"</font><font color=red>+</font>Склад<font color=red>.</font>НомерСклада<font color=red>, </font>Склад<font color=red>.</font>Наименование<font color=red>);</font></p></pre>
но на закладках должно, что то располагаться и это что то, должно иметь размеры, располагаться в конкретно указанном месте у него,  у него должны быть привязки, определены какие то свойства(которых прошу заметить может быть много) и тд, конечно самый логичный способ это нарисовать образец на форме а потом смотря свойства, просто это все перетащить. Должен получиться какой то такой код:
<pre><p>ЭлементыФормы<font color=red>.</font>ПанельСЗакладками<font color=red>.</font>Страницы<font color=red>.</font>Добавить<font color=red>(</font><font color=black>"ЗакладкаСклад"</font><font color=red>+</font>Склад<font color=red>.</font>НомерСклада<font color=red>, </font>Склад<font color=red>.</font>Наименование<font color=red>);<br>
</font>ЭлементыФормы<font color=red>.</font>ПанельСЗакладками<font color=red>.</font>ТекущаяСтраница <font color=red>= </font>ЭлементыФормы<font color=red>.</font>ПанельСЗакладками<font color=red>.</font>Страницы<font color=red>[</font><font color=black>"ЗакладкаСклад"</font><font color=red>+</font>Склад<font color=red>.</font>НомерСклада<font color=red>];<br>
</font>ТабличноеПоле <font color=red>= </font>ЭлементыФормы<font color=red>.</font>Добавить<font color=red>(</font>Тип<font color=red>(</font><font color=black>"ТабличноеПоле"</font><font color=red>),</font><font color=black>"ТабличноеПоле"</font><font color=red>+</font>Склад<font color=red>.</font>НомерСклада<font color=red>,Истина,</font>ЭлементыФормы<font color=red>.</font>ПанельСЗакладками<font color=red>);<br>
</font>ТабличноеПоле<font color=red>.</font>Имя <font color=red>= </font><font color=black>"ТабличноеПоле"</font><font color=red>+</font>Склад<font color=red>.</font>НомерСклада<font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>Значение <font color=red>= </font>ДвиженияПоСкладам<font color=red>[</font>ТекущийСклад<font color=red>];<br>
</font>ТабличноеПоле<font color=red>.</font>Верх <font color=red>= </font><font color=black>6</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>Высота <font color=red>= </font><font color=black>566</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>Ширина <font color=red>= </font><font color=black>747</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>Лево <font color=red>= </font><font color=black>6</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>ВертикальнаяПолосаПрокрутки <font color=red>= </font>ИспользованиеПолосыПрокрутки<font color=red>.</font>Использоватьавтоматически<font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>Вывод <font color=red>= </font>ИспользованиеВывода<font color=red>.</font>Авто<font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>ВысотаПодвала <font color=red>= </font><font color=black>1</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>ВысотаШапки <font color=red>= </font><font color=black>1</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>ГоризонтальнаяПолосаПрокрутки <font color=red>= </font>ИспользованиеПолосыПрокрутки<font color=red>.</font>Использоватьавтоматически<font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>ГоризонтальныеЛинии <font color=red>= Истина;<br>
</font>ТабличноеПоле<font color=red>.</font>ПорядокОтображения <font color=red>= </font><font color=black>1</font><font color=red>;<br>
</font>ТабличноеПоле<font color=red>.</font>УстановитьПривязку<font color=red>(</font>ГраницаЭлементаУправления<font color=red>.</font>Низ<font color=red>,</font>ЭтаФорма<font color=red>.</font>Панель<font color=red>,</font>ГраницаЭлементаУправления<font color=red>.</font>Низ<font color=red>);<br>
</font>ТабличноеПоле<font color=red>.</font>УстановитьПривязку<font color=red>(</font>ГраницаЭлементаУправления<font color=red>.</font>Право<font color=red>,</font>ЭтаФорма<font color=red>.</font>Панель<font color=red>,</font>ГраницаЭлементаУправления<font color=red>.</font>Право<font color=red>);<br>
</font>ТабличноеПоле<font color=red>.</font>ТолькоПросмотр <font color=red>= Ложь;</font></p></pre>
&nbsp;&nbsp;&nbsp;&nbsp;Но тут есть один нюанс, переписывать параметры руками, это просто жесть, всегда можно, что то забыть, не учесть,
не заметить, да и не всегда удается угадать какой контрол, какой содержит элемент управления, но тут падам!
К нам на выручку спешит чудесная штука ДекомпиляцияИАнализФорм_4.epf делаем формочку, настраиваем поведение, размеры, стили и прочие нужности,
скармливаем обработке, она генерит нам нужный код, очень приятная вешь, про автора известно что это (MRAK) Роман Ершов, больше я про него ничего не знаю,
он пожелал не раскрывать деталей. Собственно на этом все а кому нужно, может скачать
[обработку](https://googledrive.com/host/0BxFnXEinPWUJckpLWkVCVjc0dUU/ДекомпиляцияИАнализФорм_4.epf) которая поможет вам в нелегких буднях 1сника.
