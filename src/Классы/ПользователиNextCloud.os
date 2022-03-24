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

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("GET", СтрокаЗапроса, ПараметрыЗапроса, Заголовки);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

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

// Функция - возвращает список доступных для изменения полей
//
// Параметры:
//   ПользовательИд    - Строка    - идентификатор пользователя NextCloud
//
// Возвращаемое значение:
//    Структура    - описание пользователя
//
Функция ИзменяемыеПоля() Экспорт

	СтрокаЗапроса = СтрШаблон("/ocs/v1.php/cloud/user/fields");

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("GET", СтрокаЗапроса, , Заголовки);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");
	РезультатЗапроса = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.data.element");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка изменяемых полей для пользователя ""%1"", код ошибки %2, статус ""%3"": %4%5",
		                            Подключение.ИмяПользователя(),
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

	Поля = ПоляПользователя();
	
	Результат = Новый Массив();

	Для Каждого ТекЭлемент Из РезультатЗапроса Цикл

		Если Поля.Свойство(ТекЭлемент) Тогда
			Результат.Добавить(Поля[ТекЭлемент].Имя);
		КонецЕсли;
	
	КонецЦикла;

	Возврат Результат;

КонецФункции // ИзменяемыеПоля()

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

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("GET", СтрокаЗапроса, , Заголовки);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");
	РезультатЗапроса = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.data");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения пользователя ""%1"", код ошибки %2, статус ""%3"": %4%5",
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

	Поля = ПоляПользователя();
	
	Результат = Новый Структура();

	Для Каждого ТекЭлемент Из РезультатЗапроса Цикл

		Ключ = ТекЭлемент.Ключ;

		ТипСтруктуры = Неопределено;

		Если Поля.Свойство(Ключ) Тогда
			Ключ = Поля[Ключ].Имя;
			ТипСтруктуры = Поля[Ключ].ТипСтруктуры;
		Иначе
			Продолжить;
		КонецЕсли;

		Если ТипСтруктуры = ТипыСтруктур().Массив Тогда
			Значение = Новый Массив();
			Если ТипЗнч(ТекЭлемент.Значение) = Тип("Соответствие") Тогда
				Для Каждого ТекЗначение Из ТекЭлемент.Значение Цикл
					Значение.Добавить(ТекЗначение.Значение);
				КонецЦикла;
			ИначеЕсли ТипЗнч(ТекЭлемент.Значение) = Тип("Массив") Тогда
				Для Каждого ТекСоответствие Из ТекЭлемент.Значение Цикл
					Для Каждого ТекЗначение Из ТекСоответствие.Значение Цикл
						Значение.Добавить(ТекЗначение.Значение);
					КонецЦикла;
				КонецЦикла;
			ИначеЕсли ЗначениеЗаполнено(ТекЭлемент.Значение) Тогда
				Значение.Добавить(ТекЭлемент.Значение);
			Иначе
				Значение = Неопределено;
			КонецЕсли;	
		ИначеЕсли ТипСтруктуры = ТипыСтруктур().Соответствие Тогда
			Значение = Новый Соответствие();
			Для Каждого ТекЗначение Из ТекЭлемент.Значение Цикл
				Значение.Вставить(ТекЗначение.Ключ, ТекЗначение.Значение);
			КонецЦикла;
		Иначе
			Значение = ТекЭлемент.Значение;
		КонецЕсли;

		Результат.Вставить(Ключ, Значение);
	
	КонецЦикла;

	Возврат Результат;

КонецФункции // ДанныеПользователя()

// Процедура - добавляет пользователя NextCloud
//
// Параметры:
//   ПользовательИд           - Строка    - идентификатор пользователя NextCloud
//   ПользовательПароль       - Строка    - пароль пользователя NextCloud
//   ПараметрыПользователя    - Строка    - параметры пользователя NextCloud
//
Процедура Добавить(Знач ПользовательИд,
	               Знач ПользовательПароль,
	               Знач ПараметрыПользователя = Неопределено) Экспорт

	СтрокаЗапроса = "/ocs/v1.php/cloud/users";

	Данные = Новый Структура();
	Данные.Вставить("userid"  , ПользовательИд);
	Данные.Вставить("password", ПользовательПароль);

	Поля = ПоляПользователя();

	Для Каждого ТекЭлемент Из ПараметрыПользователя Цикл
		Если Поля.Свойство(ТекЭлемент.Ключ) Тогда
			Если НЕ Поля[ТекЭлемент.Ключ].Добавление Тогда
				Продолжить;
			КонецЕсли;
			Данные.Вставить(Поля[ТекЭлемент.Ключ].ИмяВСервисе, ТекЭлемент.Значение);
		КонецЕсли;
	КонецЦикла;

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Content-Type"  , "application/x-www-form-urlencoded");
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("POST", СтрокаЗапроса, , Заголовки, Данные);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

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

КонецПроцедуры // Добавить()

// Процедура - изменяет значение указанного поля пользователя NextCloud
//
// Параметры:
//   ПользовательИд    - Строка    - идентификатор пользователя NextCloud
//   Поле              - Строка    - имя поля пользователя NextCloud
//   Значение          - Строка    - новое значение поля пользователя NextCloud
//
Процедура ИзменитьЗначениеПоля(Знач ПользовательИд,
	                           Знач Поле,
	                           Знач Значение) Экспорт

	СтрокаЗапроса = СтрШаблон("/ocs/v1.php/cloud/users/%1", ПользовательИД);

	Поля = ПоляПользователя();

	Если НЕ Поля.Свойство(Поле) Тогда
		ВызватьИсключение СтрШаблон("Поле ""%1"" не обнаружено!", Поле);
	КонецЕсли;

	Если НЕ Поля[Поле].Изменение Тогда
		ВызватьИсключение СтрШаблон("Поле ""%1"" не доступно для изменения!", Поле);
	КонецЕсли;

	Данные = Новый Структура();
	Данные.Вставить("key"     , Поля[Поле].ИмяВСервисе);
	Данные.Вставить("value"   , Значение);

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Content-Type"  , "application/x-www-form-urlencoded");
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("PUT", СтрокаЗапроса, , Заголовки, Данные);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения поля ""%1"" пользователя ""%2"", код ошибки %3, статус ""%4"": %5%6",
		                            Поле,
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

КонецПроцедуры // ИзменитьЗначениеПоля()

// Процедура - изменяет активность пользователя NextCloud
//
// Параметры:
//   ПользовательИд    - Строка    - идентификатор пользователя NextCloud
//   Активность        - Булево    - Истина - включить пользователями;
//                                   Ложь - отключить пользователя
//
Процедура ИзменитьАктивность(Знач ПользовательИд, Знач Активность = Истина) Экспорт

	СтрокаЗапроса = СтрШаблон("/ocs/v1.php/cloud/users/%1/%2",
	                          ПользовательИд,
	                          ?(Активность, "enable", "disable"));

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Content-Type"  , "application/x-www-form-urlencoded");
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("PUT", СтрокаЗапроса, , Заголовки);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");

	Если НЕ СтатусКод = "100" Тогда
		Действие = ?(Активность, "включения", "отключения");
		ВызватьИсключение СтрШаблон("Ошибка %1 пользователя ""%2"", код ошибки %3, статус ""%4"": %5%6",
		                            Действие,
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

КонецПроцедуры // ИзменитьАктивность()

// Процедура - удаляет пользователя NextCloud
//
// Параметры:
//   ПользовательИд    - Строка    - идентификатор пользователя NextCloud
//
Процедура Удалить(Знач ПользовательИд) Экспорт

	СтрокаЗапроса = СтрШаблон("/ocs/v1.php/cloud/users/%1", ПользовательИд);

	Заголовки = Новый Соответствие();
	Заголовки.Вставить("Content-Type"  , "application/x-www-form-urlencoded");
	Заголовки.Вставить("OCS-APIRequest", "true");
	
	РезультатЗапроса = Подключение.ВыполнитьЗапрос("DELETE", СтрокаЗапроса, , Заголовки);

	РезультатЗапроса = Служебный.ПрочитатьXMLВСтруктуру(РезультатЗапроса.Текст());

	Статус    = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.status");
	СтатусКод = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.statuscode");
	Сообщение = Служебный.ЗначениеЭлементаСтруктуры(РезультатЗапроса, "ocs.meta.message");

	Если НЕ СтатусКод = "100" Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления пользователя ""%1"", код ошибки %2, статус ""%3"": %4%5",
		                            ПользовательИд,
		                            СтатусКод,
		                            Статус,
		                            Символы.ПС,
		                            Сообщение);
	КонецЕсли;

КонецПроцедуры // Удалить()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

Функция ТипыСтруктур()

	ТипыСтруктур = Новый Структура();
	ТипыСтруктур.Вставить("Массив", "Массив");
	ТипыСтруктур.Вставить("Соответствие", "Соответствие");

	Возврат Новый ФиксированнаяСтруктура(ТипыСтруктур);

КонецФункции // ТипыСтруктур()

Процедура ДобавитьОписаниеПоля(Поля, Имя, ИмяВСервисе, Добавление = Ложь, Изменение = Ложь, ТипСтруктуры = Неопределено)

	ОписаниеПоля = Новый Структура();
	ОписаниеПоля.Вставить("Имя"         , Имя);
	ОписаниеПоля.Вставить("ИмяВСервисе" , ИмяВСервисе);
	ОписаниеПоля.Вставить("Добавление"  , Добавление);
	ОписаниеПоля.Вставить("Изменение"   , Изменение);
	ОписаниеПоля.Вставить("ТипСтруктуры", ТипСтруктуры);

	Поля.Вставить(Имя        , ОписаниеПоля);
	Поля.Вставить(ИмяВСервисе, ОписаниеПоля);
	
КонецПроцедуры // ДобавитьОписаниеПоля()

Функция ПоляПользователя()

	Поля = Новый Структура();

	ДобавитьОписаниеПоля(Поля, "Активность"            , "enabled"            , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "Ид"                    , "id"                 , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "Группы"                , "groups"             , Истина, Ложь, ТипыСтруктур().Массив);
	ДобавитьОписаниеПоля(Поля, "АдминистрируемыеГруппы", "subadmin"           , Истина, Ложь, ТипыСтруктур().Массив);
	ДобавитьОписаниеПоля(Поля, "Квоты"                 , "quota"              , Истина, Истина, ТипыСтруктур().Соответствие);
	ДобавитьОписаниеПоля(Поля, "Почта"                 , "email"              , Истина, Истина);
	ДобавитьОписаниеПоля(Поля, "ДополнительнаяПочта"   , "additional_mail"    , Истина, Истина);
	ДобавитьОписаниеПоля(Поля, "ПочтаДляОповещения"    , "notify_email"       , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "Имя"                   , "displayname"        , Истина, Истина);
	ДобавитьОписаниеПоля(Поля, "Телефон"               , "phone"              , Ложь, Истина);
	ДобавитьОписаниеПоля(Поля, "Адрес"                 , "address"            , Ложь, Истина);
	ДобавитьОписаниеПоля(Поля, "Сайт"                  , "website"            , Ложь, Истина);
	ДобавитьОписаниеПоля(Поля, "Твиттер"               , "twitter"            , Ложь, Истина);
	ДобавитьОписаниеПоля(Поля, "Язык"                  , "language"           , Истина, Ложь);
	ДобавитьОписаниеПоля(Поля, "РегиональныеУстановки" , "locale"             , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "РасположениеХранилища" , "storageLocation"    , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "Движок"                , "backend"            , Ложь, Ложь);
	ДобавитьОписаниеПоля(Поля, "ВозможностиДвижка"     , "backendCapabilities", Ложь, Ложь, ТипыСтруктур().Соответствие);
	ДобавитьОписаниеПоля(Поля, "ПоследнийВход"         , "lastLogin"          , Ложь, Ложь);

	Возврат Новый ФиксированнаяСтруктура(Поля);

КонецФункции // ПоляПользователя()

#КонецОбласти // СлужебныеПроцедурыИФункции

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
