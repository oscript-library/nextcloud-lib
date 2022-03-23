// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/nextcloud-lib/
// ----------------------------------------------------------

Перем Подключение;    // - ПодключениеNextCloud    - подключение к сервису NextCloud

Перем Лог;            // логгер

#Область ПрограммныйИнтерфейс

// Возвращает адрес сервиса NextCloud
//
// Возвращаемое значение:
//   ПодключениеNextCloud    - подключение к сервису NextCloud
//
Функция Подключение() Экспорт

	Возврат Подключение;

КонецФункции // Подключение()

// Устанавливает новое подключение к сервису NextCloud
//
// Параметры:
//   НовоеПодключение    - ПодключениеNextCloud    - подключение к сервису NextCloud
//
Процедура УстановитьПодключение(НовоеПодключение) Экспорт

	Подключение = НовоеПодключение;

КонецПроцедуры // УстановитьПодключение()

// Функция - получает список пользователей сервиса NextCloud
//
// Параметры:
//   СтрокаПоиска    - Строка    - строка поиска идентификатора пользователя
//                                 (если не указано выводятся все существующие пользователи)
//   Количество      - Число     - количество элементов в результате
//                                 (если 0 - выводятся все найденные пользователи)
//   Смещение        - Число     - номер страницы результата
//                                 (если 0 - то с начала списка найденных пользователей)
//
// Возвращаемое значение:
//    Массив из Строка    - список идентификаторов найденных пользователей
//
Функция Список(Знач СтрокаПоиска = "", Знач Количество = 0, Знач Смещение = 0) Экспорт

	СтрокаЗапроса = "/ocs/v1.php/cloud/users";

	ПараметрыЗапроса = Новый Соответствие();
	Если ЗначениеЗаполнено(СтрокаПоиска) Тогда
		ПараметрыЗапроса.Вставить("search", СтрокаПоиска);
	КонецЕсли;

	Если Количество > 0 Тогда
		ПараметрыЗапроса.Вставить("limit", Количество);
	КонецЕсли;

	Если Смещение > 0 Тогда
		ПараметрыЗапроса.Вставить("offset", Смещение);
	КонецЕсли;

	РезультатЗапроса = Подключение.ВыполнитьЗапросGet(СтрокаЗапроса, ПараметрыЗапроса).Текст();

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса);

	Статус = "";

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");
	Элементы  = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.data.users.element");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка пользователей, код ошибки %1, статус ""%2"": %3%4",
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

	Результат = Новый Массив();

	Если ТипЗнч(Элементы) = Тип("Строка") Тогда
		Результат.Добавить(Элементы);
	Иначе
		Результат = Элементы;
	КонецЕсли;

	Возврат Результат;

КонецФункции // Список()

// Функция - возвращает описание пользователя NextCloud
//
// Параметры:
//   ПользовательИд    - Строка    - идентификатор пользователя NextCloud
//
// Возвращаемое значение:
//    Структура    - описание пользователя
//
Функция ДанныеПользователя(Знач ПользовательИд) Экспорт

	СтрокаЗапроса = СтрШаблон("/ocs/v1.php/cloud/users/%1", ПользовательИд);

	РезультатЗапроса = Подключение.ВыполнитьЗапросGet(СтрокаЗапроса).Текст();

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса);

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");
	Результат = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.data");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения пользователя ""%1"", код ошибки %2, статус ""%3"": %4%5",
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

	Возврат Результат;

КонецФункции // ДанныеПользователя()

// Процедура - добавляет пользователя NextCloud
//
// Параметры:
//   ПользовательИд           - Строка    - идентификатор пользователя NextCloud
//   ПользовательПароль       - Строка    - пароль пользователя NextCloud
//   ПараметрыПользователя    - Строка    - параметры пользователя NextCloud
//
Процедура ДобавитьПользователя(Знач ПользовательИд, Знач ПользовательПароль, ПараметрыПользователя = Неопределено) Экспорт

	СтрокаЗапроса = "/ocs/v1.php/cloud/users";

	Данные = Новый Структура();
	Данные.Вставить("userid"  , ПользовательИд);
	Данные.Вставить("password", ПользовательПароль);

	РезультатЗапроса = Подключение.ВыполнитьЗапросPost(СтрокаЗапроса, Данные).Текст();

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса);

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления пользователя ""%1"", код ошибки %2, статус ""%3"": %4%5",
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

КонецПроцедуры // ДобавитьПользователя()

#КонецОбласти // ПрограммныйИнтерфейс

#Область Инициализация

// Конструктор
//
// Параметры:
//   ПодключениеКСервису    - ПодключениеNextCloud    - подключение к сервису NextCloud
//
Процедура ПриСозданииОбъекта(Знач ПодключениеКСервису = Неопределено)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(ПодключениеКСервису) Тогда
		ПодключениеКСервису = Новый ПодключениеNextCloud();
	КонецЕсли;
	
	УстановитьПодключение(ПодключениеКСервису);

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // Инициализация
