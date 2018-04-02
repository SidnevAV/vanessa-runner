///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Запуск тестирования через фреймворк vanessa-behavior
//
// Пример строки запуска:
// 	oscript src/main.os vanessa --pathvanessa ".\vanessa-behavior\vanessa-behavior.epf" --ibconnection /F./build/ib --vanessasettings ./examples\.vb-conf.json
// 
// TODO добавить фичи для проверки команды
// 
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать v8runner
#Использовать asserts
#Использовать json
#Использовать vanessa-behavior

Перем Лог;
Перем МенеджерКонфигуратора;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     Запуск тестирования через фреймворк vanessa-behavior
		|     ";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().ТестироватьПоведение, 
		ТекстОписания);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--pathvanessa", 
		"[env RUNNER_PATHVANESSA] путь к внешней обработке, по умолчанию vendor/vanessa-behavior/vanessa-behavior.epf
		|           или переменная окружения RUNNER_PATHVANESSA");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--vanessasettings", 
		"[env RUNNER_VANESSASETTINGS] путь к файлу настроек");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--workspace", 
		"[env RUNNER_WORKSPACE] путь к папке, относительно которой будут определятся макросы $workspace.
		|                 по умолчанию текущий.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--additional", 
		"Дополнительные параметры для запуска предприятия.");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--no-wait", 
		"Не ожидать завершения запущенной команды/действия");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Попытка
		Лог = ДополнительныеПараметры.Лог;
	Исключение
		Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());
	КонецПопытки;

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	ЗапускатьТолстыйКлиент = ОбщиеМетоды.УказанПараметрТолстыйКлиент(ПараметрыКоманды["--ordinaryapp"], Лог);
	ОжидатьЗавершения = Не ПараметрыКоманды["--no-wait"];
	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;
	МенеджерКонфигуратора.Инициализация(
		ДанныеПодключения.СтрокаПодключения, ДанныеПодключения.Пользователь, ДанныеПодключения.Пароль,
		ПараметрыКоманды["--v8version"], ,
		ДанныеПодключения.КодЯзыка, ДанныеПодключения.КодЯзыкаСеанса
	);
	Попытка
		ЗапуститьТестироватьПоведение(ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--workspace"]),
			ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--vanessasettings"]), 
			ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["--pathvanessa"]),
			ЗапускатьТолстыйКлиент, ОжидатьЗавершения,
			ПараметрыКоманды["--additional"]
			);

	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();
	
	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

// Выполняем запуск тестов для vannessa 
//
//	Параметры:
//		РабочийКаталогПроекта - <Строка> - Путь к каталогу с проектом, по умолчанию каталог ./
//		ПутьКНастройкам - <Строка> - Путь к файлу настроек запуска тестов
//		ПутьКИнструментам - <Строка> - путь к инструментам, по умолчанию ./vendor/vanessa-behavior
//		ТолстыйКлиент - <Булево> - признак запуска толстого клиента
//		ОжидатьЗавершения - <Булево> - признак запуска ожидания, пока 1С завершиться, 
//				для разработки освобождения командной строки надо ставить Ложь;
//		ДопПараметры - <Строка> - дополнительные параметры для передачи в параметры запуска 1с, например /DebugURLtcp://localhost
//
Процедура ЗапуститьТестироватьПоведение(Знач РабочийКаталогПроекта = Неопределено, 
										Знач ПутьКНастройкам = "", Знач ПутьКИнструментам="", Знач ТолстыйКлиент = Ложь, 
										Знач ОжидатьЗавершения = Истина, Знач ДопПараметры="") 

	Лог.Информация("Тестирую поведение с помощью фреймворка vanessa-behavior");

	Конфигуратор = МенеджерКонфигуратора.УправлениеКонфигуратором();
	
	Если РабочийКаталогПроекта = Неопределено Тогда 
		РабочийКаталогПроекта = "./";
	КонецЕсли;
	РабочийКаталогПроекта = ОбщиеМетоды.ПолныйПуть(РабочийКаталогПроекта);
	
	Если ПустаяСтрока(ПутьКИнструментам) Тогда
		ПутьКИнструментам = Ванесса.ПутьВанесса();
		Лог.Отладка("Не задан путь к запускателю bdd-тестов. Использую путь по умолчанию %1", ПутьКИнструментам);
	КонецЕсли;

	ПутьКИнструментам = ОбщиеМетоды.ПолныйПуть(ПутьКИнструментам);
	Лог.Отладка("Путь к запускателю bdd-тестов. %1", ПутьКИнструментам);

	ФайлСуществует = Новый Файл(ПутьКИнструментам).Существует();
	Ожидаем.Что(ФайлСуществует, СтрШаблон("Ожидаем, что файл <%1> существует, а его нет!", ПутьКИнструментам)).ЭтоИстина();

	Настройки = НастройкиДля1С.ПрочитатьНастройки(ПутьКНастройкам);

	ПутьКФайлуСтатусаВыполнения = НастройкиДля1С.ПолучитьНастройку(Настройки, "ПутьКФайлуДляВыгрузкиСтатусаВыполненияСценариев", 
								"./build/buildstatus.log", РабочийКаталогПроекта, "путь к файлу статуса выполнения");

	ПутьЛогаВыполненияСценариев = НастройкиДля1С.ПолучитьНастройку(Настройки, "ИмяФайлаЛогВыполненияСценариев", 
								"./build/vanessaonline.txt", РабочийКаталогПроекта, "путь к лог-файлу выполнения");

	ОбщиеМетоды.УдалитьФайлЕслиОнСуществует(ПутьКФайлуСтатусаВыполнения);
	ОбщиеМетоды.УдалитьФайлЕслиОнСуществует(ПутьЛогаВыполненияСценариев);

	КлючЗапуска = """StartFeaturePlayer;VBParams=" + ПутьКНастройкам +";workspaceRoot=" + РабочийКаталогПроекта + """";
	Лог.Отладка(КлючЗапуска);

	ДополнительныеКлючи = " /TESTMANAGER " + ДопПараметры;
	
	Попытка
		МенеджерКонфигуратора.ЗапуститьВРежимеПредприятияСЛогФайлом(
			КлючЗапуска, ПутьКИнструментам, 
			ПутьЛогаВыполненияСценариев,
			ТолстыйКлиент, ДополнительныеКлючи);

		Результат = ОбщиеМетоды.ПрочитатьФайлИнформации(ПутьКФайлуСтатусаВыполнения);
		Если СокрЛП(Результат) <> "0" Тогда
			ВызватьИсключение "Результат работы не равен 0 "+ Результат;
		КонецЕсли;

	Исключение
		Лог.Ошибка(Конфигуратор.ВыводКоманды());
		Лог.Ошибка("Ошибка:" + ОписаниеОшибки());
		ВызватьИсключение "ЗапуститьТестироватьПоведение";
	КонецПопытки;

	
	Лог.Информация("Тестирование поведения завершено");

КонецПроцедуры // ЗапуститьТестироватьПоведение()

// Функция ПрочитатьНастройки(Знач ПутьКНастройкам)
// 	Рез = Неопределено;

// 	Если Не ПустаяСтрока(ПутьКНастройкам) Тогда
// 		Лог.Отладка("Читаю настройки vanessa-behavior из файла %1", ПутьКНастройкам);

// 		ФайлНастроек = Новый Файл(ОбщиеМетоды.ПолныйПуть(ПутьКНастройкам));
// 		СообщениеОшибки = СтрШаблон("Ожидали, что файл настроек %1 существует, а его нет.");
// 		Ожидаем.Что(ФайлНастроек.Существует(), СообщениеОшибки).ЭтоИстина();

// 		ЧтениеТекста = Новый ЧтениеТекста(ФайлНастроек.ПолноеИмя, КодировкаТекста.UTF8);
		
// 		СтрокаJSON = ЧтениеТекста.Прочитать();
// 		ЧтениеТекста.Закрыть();

// 		ПарсерJSON = Новый ПарсерJSON();
// 		Рез = ПарсерJSON.ПрочитатьJSON(СтрокаJSON);
		
// 		Лог.Отладка("Успешно прочитали настройки");
// 		Лог.Отладка("Настройки из файла:");
// 		Для каждого КлючЗначение Из Рез Цикл
// 			Лог.Отладка("	%1 = %2", КлючЗначение.Ключ, КлючЗначение.Значение);
// 		КонецЦикла;
// 	Иначе
// 		Лог.Отладка("Файл настроек не передан. Использую значение по умолчанию.");
// 	КонецЕсли;
// 	Возврат Рез;
// КонецФункции

// Функция ПолучитьНастройку(Знач Настройки, Знач ИмяНастройки, Знач ЗначениеПоУмолчанию, 
// 		Знач РабочийКаталогПроекта, Знач ОписаниеНастройки, Знач ПолучатьПолныйПуть = Истина)

// 	Рез = ЗначениеПоУмолчанию;
// 	Если Настройки <> Неопределено Тогда
// 		Рез_Врем = Настройки.Получить(ИмяНастройки);
// 		Если Рез_Врем <> Неопределено Тогда
// 			Рез = Заменить_workspaceRoot_на_РабочийКаталогПроекта(Рез_Врем, РабочийКаталогПроекта);

// 			Лог.Отладка("В настройках нашли %1 %2", ОписаниеНастройки, Рез);
// 		КонецЕсли;
// 	КонецЕсли;
// 	Лог.Отладка("Использую %1 %2", ОписаниеНастройки, Рез);
	
// 	Если ПолучатьПолныйПуть Тогда
// 		Рез = ОбщиеМетоды.ПолныйПуть(Рез);
// 		Лог.Отладка("Использую %1 (полный путь) %2", ОписаниеНастройки, Рез);
// 	КонецЕсли;
// 	Возврат Рез;
// КонецФункции

// Функция Заменить_workspaceRoot_на_РабочийКаталогПроекта(Знач ИсходнаяСтрока, Знач РабочийКаталогПроекта)
// 	Возврат СтрЗаменить(ИсходнаяСтрока, "$workspaceRoot", РабочийКаталогПроекта);
// КонецФункции
