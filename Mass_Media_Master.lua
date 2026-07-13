script_name('Mass Media Master')
script_version('v.3.000')
script_author('Adam_Rockwell && Mike_Rockwell')
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
local key = require "vkeys"
local rkeys = require 'rkeys'
local imgui = require 'imgui'
local encoding = require 'encoding'
local hk = require 'lib.imcustom.hotkey'
local gk = require 'game.keys'
local memory = require "memory"
local fa = require 'faIcons'
local dlstatus = require('moonloader').download_status
imgui.ShowCursor = false
encoding.default = 'CP1251'
u8 = encoding.UTF8
hk._SETTINGS.noKeysMessage = u8("Нет")
local goThenSobes = "[Alt + 1]: {CCCCCC}Продолжить. {FF7F50}[Alt + 9]: {CCCCCC}Отказать в собеседовании. {FF7F50}[F12]: {CCCCCC}Перезагрузить скрипт."
local goThenJob = "[Alt + 1]: {CCCCCC}Ответ положительный. {FF7F50}[Alt + 9]: {CCCCCC}Ответ отрицательный. {FF7F50}[F12]: {CCCCCC}Перезагрузить скрипт."
local Helper = "[F11]: {CCCCCC}Возможные дальнейшие действия."
local state_ON = "{FFFFFF}[{33AA33}Включено{FFFFFF}]"
local state_OFF = "{FFFFFF}[{CC0000}Выключено{FFFFFF}]"
local settings = inicfg.load({
	settings = {
		AutoScreen=true,
		WriteLog=true,
		LectionInR=true,
		CorrectChat=true,
		Emotions=true,
		TimeRP=false,
		Window=true,
		SexId=0,
		Structure=0,
		SleepRP=2200,
		SleepLection=4000,
		SleepEfir=3000,
		Accent="Американский акцент",
		Tag="LS |",
	},
})
local blanksfile = getWorkingDirectory() .. "\\Mass Media Master\\blanks.json"
if doesFileExist(blanksfile) then
	local f = io.open(blanksfile, "r")
	if f then
		blanks = decodeJson(f:read("a*"))
		f:close()
	end
else
	blanks = {
		{
			name = 'Погода',
			command,
			state = true,
			text = {
				'...::: Музыкальная заставка :::...',
				'Доброго времени суток, уважаемые граждане.',
				'Представляю вашему вниманию прогноз погоды.',
				'Итак. Начнём с понедельника:',
				'Весь день будет солнечно, но ближе к вечеру будет непродолжительный дождь.',
				'Вторник: Весь день будет солнечно.',
				'Среда: Весь день будет облачно.',
				'Четверг: Весь день будет солнечно, но вечером будет туманно.',
				'Пятница: Весь день будет облачно.',
				'Суббота: Весь день будет солнечно.',
				'Воскресенье: Весь день будет солнечно, ближе к вечеру набегут облака.',
				'На этом у меня всё. Благодарю за внимание.',
				'...::: Музыкальная заставка :::...'
			},
			type = 1
		},
		{
			name = 'Интервью',
			command,
			state = true,
			text = {
				'Доброго времени суток, уважаемые граждане.',
				'Сегодня мы берём интервью у директора радиоцентра г.Los-Santos - Mike Rockwell',
				'Mike, расскажите немного о себе.'
			},
			type = 2
		},
		{
			name = 'Собеседование',
			command,
			state = true,
			text = {
				'ММ | Уважаемые жители Штата, вещает Директор радиоцентра г.Los-Santos - Mike Rockwell.',
				'ММ | С этого момента начинается собеседование в наш замечательный Радиоцентр!',
				'ММ | Сотрудники нашего радиоцентра могут принять участие во множестве оплачиваемых подработках!'
			},
			type = 3
		},
		{
			name = 'Окончить собеседование',
			command,
			state = true,
			text = {
				'ММ | Cобеседование в Радиоцентр г.Los-Santos завершено. Благодарим за внимание!'
			},
			type = 3
		},
	}
end
local file = getWorkingDirectory() .. "\\Mass Media Master\\settings.bind"
local tEdit = {
	id = -1,
	inputActive = false
}
local sInputEdit = imgui.ImBuffer(128)

local tKeyList = {}
if doesFileExist(file) then
	local f = io.open(file, "r")
	if f then
		tKeyList = decodeJson(f:read("a*"))
		f:close()
	end
else
	tKeyList = {
		{
			v = {key.VK_F4}
		},
		{
			v = {key.VK_F12}
		},
		{
			v = {key.VK_DIVIDE}
		},
		{
			v = {key.VK_F9}
		},
		{
			v = {key.VK_F5}
		},
	}
end

if not doesDirectoryExist("moonloader\\DAP Helper") then
	createDirectory("moonloader\\DAP Helper")
end

if settings.settings.SexId == 0 then
   RP1 = ""
   RP2 = "ел"
   RP3 = "ся"
   RP4 = ""
elseif settings.settings.SexId == 1 then
   RP1 = "а"
   RP2 = "ла"
   RP3 = "ась"
   RP4 = "ла"
end
if Structure == "Штат" then
   Structure = 1
   Struct1 = "штат"
   Struct2 = "штата"
elseif Structure == "Республика" then
   Structure = 2
   Struct1 = "республика"
   Struct2 = "республики"
elseif Structure == "Федерация" then
   Structure = 3
   Struct1 = "федерация"
   Struct2 = "федерации"
end

local CommandText = [[
{00FF99}/testgnews {999999}[section] {FFFFFF}- Проверка гос. новости, содержищейся в данной секции. {cccccc}[Лидеру]
{00FF99}/gognewstime {999999}[section] [Час] [Минута] [Секунда] {FFFFFF}- Подача gnews по времени. {cccccc}[Лидеру]
{00FF99}/gognews {999999}[section] {FFFFFF}- Подача gnews из данной секции. {cccccc}[Лидеру]

{00FF99}/rangup {999999}[id] {FFFFFF}- Повысить сотрудника на следующую должность. {cccccc}[с 9 ранга]
{00FF99}/rangdown {999999}[id] {FFFFFF}- Понизить сотрудника на предыдущую должность. {cccccc}[с 9 ранга]
{00FF99}/proc {999999}[id] {FFFFFF}- Role-Play Invite/Uninvite/Rang/Fwarn/SetSkin. {cccccc}[с 8 ранга]
{00FF99}/cfind {FFFFFF}- Чекер отсутствующих сотрудников организации в зоне прорисовки. {cccccc}[c 7 ранга]
{00FF99}/sobes {999999}[id] {FFFFFF}- Начало собеседования.
{00FF99}/exam {999999}[id] {FFFFFF}- Начало экзамена.
{00FF99}/gotosobes {999999}[id] {FFFFFF}- Перейти на другой сценарий собеседования.
{00FF99}/gotoexam {999999}[id] {FFFFFF}- Перейти на другой сценарий приёма экзамена.
]]
local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}

local main_window_state = imgui.ImBool(false)

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	inicfg.save(settings)
	sampAddChatMessage("Script {B8DBB8}Mass Media Master {CCCCCC}запущен и находится в активном режиме.", 0xCCCCCC)
	wait(50)
	sampAddChatMessage("Полная навигация по скрипту: Клавиша {B8DBB8}" ..tostring(table.concat(rkeys.getKeysName(tKeyList[1].v), " ")).. "{CCCCCC}, а также команда {B8DBB8}/cmd.", 0xCCCCCC)
	imgui.Process = imgui.ImBool(true)
	for k, v in pairs(tKeyList) do
		rkeys.registerHotKey(v.v, true, onHotKey)
	end
	sampRegisterChatCommand('me', function(text)
		local first, other = text:match('(.)(.*)%.?%??%!?')
		local first = string.rlower(first)
		sampSendChat('/me ' ..first..other)
	end)
	sampRegisterChatCommand('do', function(text)
		local first, other = text:match('(.)(.*)')
		local first = string.rupper(first)
		if other:find('.*%.') or other:find('.*%?') or other:find('.*%!') then
			sampSendChat('/do ' ..first..other)
		else
			sampSendChat('/do ' ..first..other.. '.')
		end
	end)
	sampRegisterChatCommand('r', function(text)
		local first, other = text:match('(.)(.*)')
		local first = string.rupper(first)
		if other:find('.*%.') or other:find('.*%?') or other:find('.*%!') then
			sampSendChat('/r ' ..first..other)
		else
			sampSendChat('/r ' ..first..other.. '.')
		end
	end)
	sampRegisterChatCommand('f', function(text)
		local first, other = text:match('(.)(.*)')
		local first = string.rupper(first)
		if text:find('хм') or text('хе') or text('хэ') or text('хемс') then
			sampSendChat('/f ' ..first..other)
		else
			sampSendChat('/f ' ..settings.settings.Tag..first..other)
		end
	end)
	sampRegisterChatCommand('proc', function(text)
		if not text:find('^%d+$') or sampGetPlayerScore(tonumber(text)) == 0 then
			sampAddChatMessage("/proc [ID игрока]", 0xAAAAAA)
		else
			nickjob = sampGetPlayerNickname(tonumber(text))
			nickRPjob = nick:gsub('_', ' ')
			idjob = text
			sampShowDialog(908, nick.. '[' ..text.. ']', "{FF5F10}• {FFFFFF}Принять в организацию\n{FF5F10}• {FFFFFF}Принять в организацию (без речи)\n{FF5F10}• {FFFFFF}Уволить из организации\n{FF5F10}• {FFFFFF}Выдать выговор\n{FF5F10}• {FFFFFF}Изменить должность\n{FF5F10}• {FFFFFF}Выдать новую форму", 'Выбрать', 'Закрыть', 2)
		end
	end)
	sampRegisterChatCommand('cfind', cmd_cfind)
	while true do
		wait(0)
		imgui.ShowCursor = main_window_state.v
		if isKeyJustPressed(VK_F12) then
			thisScript():reload()
		end
		if wasKeyPressed(key.VK_L) and not sampIsChatInputActive() and not sampIsDialogActive() then
			main_window_state.v = not main_window_state.v
		end
		local result, button, list, reason = sampHasDialogRespond(900)
		if result and button == 1 then
			if list == 0 then
				sampShowDialog(901, "{FF5F10}Листовки и газеты", "{FF5F10}• {FFFFFF}Положить газету в почтовый ящик\n{FF5F10}• {FFFFFF}Передать листовку\n{FF5F10}• {FFFFFF}Приклеить листовку\n{FF5F10}• {FFFFFF}Печать листовок\n{FF5F10}• {FFFFFF}Печать газет\n{FF5F10}• {FFFFFF}Role-Play написание газеты {AAAAAA}[с 7 ранга]\n{FF5F10}• {FFFFFF}Установка палатки для продажи газет {AAAAAA}[с 7 ранга]\n{FF5F10}• {FFFFFF}Одобрение газеты {AAAAAA}[Для лидера]", "Выбрать", "Назад", 2)
			elseif list == 1 then
				sampShowDialog(902, "{FF5F10}Лекции", "{FF5F10}• {FFFFFF}Дресс-код\n{FF5F10}• {FFFFFF}Транспорт\n{FF5F10}• {FFFFFF}Субординация\n{FF5F10}• {FFFFFF}Рабочий график\n{FF5F10}• {FFFFFF}Некорректное объявление\n{FF5F10}• {FFFFFF}Мероприятия в рабочее время\n{FF5F10}• {FFFFFF}Отчёты и повышение", "Выбрать", "Назад", 2)
			elseif list == 2 then
				sampShowDialog(903, "{FF5F10}Role-Play задания", "{FF5F10}• {FFFFFF}Подключение принтера\n{FF5F10}• {FFFFFF}Расcтановка фотоаппаратов на полке\n{FF5F10}• {FFFFFF}Проверка аппаратуры в радиоэфирной\n{FF5F10}• {FFFFFF}Расстановка журналов на стенде\n{FF5F10}• {FFFFFF}Перенос аптечек в кузов фургона\n{FF5F10}• {FFFFFF}Установка новой клавиатуры для компьютера\n{FF5F10}• {FFFFFF}Уборка сухих листьев около радиоцентра\n{FF5F10}• {FFFFFF}Распаковка ноутбука\n{FF5F10}• {FFFFFF}Очистка истории браузера\n{FF5F10}• {FFFFFF}Подключение мышки для ноутбука", "Выбрать", "Назад", 2)
			elseif list == 3 then
				sampShowDialog(904, "{FF5F10}Радиоэфир", "{FF5F10}• {FFFFFF}Начать эфир\n{FF5F10}• {FFFFFF}Завершение эфира", "Выбрать", "Назад", 2)
			elseif list == 4 then
				sampShowDialog(905, "{FF5F10}Телеэфир", "{FF5F10}• {FFFFFF}Установка камеры\n{FF5F10}• {FFFFFF}Подготовка и начало эфира\n{FF5F10}• {FFFFFF}Выдать микрофон\n{FF5F10}• {FFFFFF}Завершение эфира", "Выбрать", "Назад", 2)
			elseif list == 5 then
				sampShowDialog(907, "{FF5F10}Дополнительные команды", CommandText, "Закрыть", "", 0)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(901)
		if result then
			if button == 1 then
				if list == 0 then -- Положить газету в почтовый ящик
					lua_thread.create(function()
						math.randomseed(os.time())
						local k = math.random(1, 3)
						if k == 1 then
							sampSendChat('/me достал' ..RP1.. ' газету из рюкзака')
							wait(settings.settings.SleepRP)
							sampSendChat("/me аккуратно положил" ..RP1.. " газету в почтовый ящик")
						elseif k == 2 then
							sampSendChat("/me протянув правую руку достал" ..RP1.. " газету из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/me положил" ..RP1.. " газету в почтовый ящик")
						elseif k == 3 then
							sampSendChat("/me лёгким движением руки достал" ..RP1.. " новую газету из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/me положил" ..RP1.. " газету в почтовый ящик")
						end
						screenAndTime()
					end)
				elseif list == 1 then -- Передать листовку
					lua_thread.create(function()
						math.randomseed(os.time())
						local k = math.random(1, 3)
						if k == 1 then
							sampSendChat("/me достал" ..RP1.. " листовку из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("Переключайтесь на волну " ..Town().. " FM. Лучшие эфиры и викторины!")
							wait(settings.settings.SleepRP)
							sampSendChat("/me передал" ..RP1.. " листовку человеку напротив")
						elseif k == 2 then
							sampSendChat("/me протянув правую руку достал" ..RP1.. " листовку из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/todo Ждём вас на радиоволне " ..Town().. " FM*передавая листовку")
						elseif k == 3 then
							sampSendChat("/me лёгким движением руки достал" ..RP1.. " новую листовку из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("Переключайтесь на радиоволну " ..Town().. " FM!")
							wait(settings.settings.SleepRP)
							sampSendChat("Вас ждут увлекательные эфиры и море положительных эмоций!")
							wait(settings.settings.SleepRP)
							sampSendChat("/me передал" ..RP1.. " листовку человеку напротив")
						end
						screenAndTime()
					end)
				elseif list == 2 then -- Приклеить листовку
					lua_thread.create(function()
						math.randomseed(os.time())
						local k = math.random(1, 3)
						if k == 1 then
							sampSendChat("/me достал" ..RP1.. " листовку из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/me достал" ..RP1.. " клей и смазал" ..RP1.. " поверхность доски для рекламы")
							wait(settings.settings.SleepRP)
							sampSendChat("/me приклеил" ..RP1.. " листовку")
							wait(settings.settings.SleepRP)
							sampSendChat("/do На листовке написано:")
							wait(settings.settings.SleepRP)
							sampSendChat("/do Лучшие эфиры и большие призы только на волне " ..Town().. " FM.")
						elseif k == 2 then
							sampSendChat("/me лёгким движением руки достал" ..RP1.. " новую листовку из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/me смазал" ..RP1.. " клеем поверхность доски для рекламы")
							wait(settings.settings.SleepRP)
							sampSendChat("/me приклеил" ..RP1.. " листовку с надписью:")
							wait(settings.settings.SleepRP)
							sampSendChat("/do Переключайтесь на радиоволну " ..Town().. " FM.")
						elseif k == 3 then
							sampSendChat("/me достал" ..RP1.. " новенькую листовку и клей из рюкзака")
							wait(settings.settings.SleepRP)
							sampSendChat("/me смазал" ..RP1.. " клеем листовку, после чего приеклеил" ..RP1.. " её")
							wait(settings.settings.SleepRP)
							sampSendChat("/do На листовке написано: Ждём вас на радиоволне " ..Town().. " FM.")
						end
						screenAndTime()
					end)
				elseif list == 3 then -- Печать листовок
					lua_thread.create(function()
						sampSendChat("/me включил" ..RP1.. " ноутбук и загрузил" ..RP1.. " программу для печати")
						wait(settings.settings.SleepRP)
						sampSendChat("/me в разделе печати выбрал" ..RP1.. " « Печать листовок »")
						wait(settings.settings.SleepRP)
						sampSendChat("/me подключил" ..RP1.. " принтер, после чего нажал" ..RP1.. " на кнопку « Печать »")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " свежеиспечённые листовки и положил" ..RP1.. " их в рюкзак")
						wait(settings.settings.SleepRP)
						sampSendChat("/me выключил" ..RP1.. " принтер и ноутбук")
						screenAndTime()
					end)
				elseif list == 4 then -- Печать газет
					lua_thread.create(function()
						sampSendChat("/do На столе стоит включённый ноутбук.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me открыл" ..RP1.. " новостной сайт и переш" ..RP2.. " на страницу загрузки документов")
						wait(settings.settings.SleepRP)
						sampSendChat("/me в разделе печати выбрал" ..RP1.. " « Загрузка формы новостной газеты »")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Через некоторое время файл был загружен.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me подключил" ..RP1.. " принтер, после чего нажал" ..RP1.. " на кнопку « Печать »")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Через некоторое время принтер закончил печать.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " свежеиспечённые газеты")
						wait(settings.settings.SleepRP)
						sampSendChat("/me выключил" ..RP1.. " ноутбук, после чего сложил" ..RP1.. " газеты в сумку")
						screenAndTime()
					end)
				elseif list == 5 then -- Написание газеты (/paper)
					lua_thread.create(function()
						sampSendChat("/do Ноутбук закрыт и выключен.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me открыл" ..RP1.. " ноутбук и нажал" ..RP1.. " на кнопку « Power »")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Ноутбук запустился.")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Файлы загрузились.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me заш" ..RP2.. " в браузер и открыл" ..RP1.. " раздел « СМИ »")
						wait(settings.settings.SleepRP)
						sampSendChat("/me заш" ..RP2.. " в раздел « Газеты »")
						screenAndTime()
						wait(settings.settings.SleepRP)
						sampSendChat("/me выбрал" ..RP1.. " нужный шрифт и размер текста")
						wait(settings.settings.SleepRP)
						sampSendChat("/me вписал" ..RP1.. " в графу « Тема » нужную тему")
						wait(settings.settings.SleepRP)
						sampSendChat("/me печатает информацию")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Процесс...")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Газета готова.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me нажал" ..RP1.. " на кнопку « Сохранить »")
						wait(settings.settings.SleepRP)
						sampSendChat("/me переш" ..RP2.. " в раздел « Газеты на одобрение »")
						wait(settings.settings.SleepRP)
						sampSendChat("/me написал" ..RP1.. " заявление на одобрение газеты")
						screenAndTime()
						wait(1500)
						sampSendChat('/paper')
					end)
				elseif list == 6 then -- Установка палатки (/tent)
					lua_thread.create(function()
						sampSendChat("/do В руке сумка.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me кинул" ..RP1.. " сумку на землю и открыл" ..RP1.. " её ")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В сумке лежит каркас палатки, плёнка и газеты.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " из сумки каркас и разложил" ..RP1.. " его")
						wait(settings.settings.SleepRP)
						sampSendChat("/me начал" ..RP1.. " устанавливать каркас")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Процесс...")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Каркас установлен.")
						screenAndTime()
						wait(settings.settings.SleepRP)
						sampSendChat("/me взял" ..RP1.. " из сумки плёнку и накинул" ..RP1.. " её на каркас")
						wait(settings.settings.SleepRP)
						sampSendChat("/me начал" ..RP1.. " закреплять плёнку")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Процесс...")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Плёнка закреплена.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " из сумки стопку газет и выставил" ..RP1.. " их")
						screenAndTime()
						wait(1500)
						sampSendChat('/tent')
					end)
				elseif list == 7 then -- Одобрение газеты (/setpaper)
					lua_thread.create(function()
						sampSendChat("/do Ноутбук закрыт и выключен.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me открыл" ..RP1.. " ноутбук и нажал" ..RP1.. " на кнопку « Power »")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Ноутбук запустился.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me заш" ..RP2.. " в браузер и открыл" ..RP1.. " раздел «СМИ»")
						wait(settings.settings.SleepRP)
						sampSendChat("/me заш" ..RP2.. " в раздел «Газеты на рассмотрение»")
						wait(settings.settings.SleepRP)
						sampSendChat("/me наш" ..RP2.. " газету интересующего сотрудника и ознакомил" ..RP3.. " с ней")
						wait(settings.settings.SleepRP)
						sampSendChat("/me нажал" ..RP1.. " на кнопку «Одобрить»")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Газета одобрена.")
						wait(settings.settings.SleepRP)
						sampSendChat("/setpaper")
						screenAndTime()
					end)
				end
			else
				sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(902)
		if result then
			if button == 1 then
				local VarL
				if settings.settings.LectionInR then VarL = "/r " else VarL = "" end
				if list == 0 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Дресс-код ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Дресс-код должен соблюдаться всеми сотрудниками.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Разрешается снимать рабочую форму в обеденное время.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "За нарушение дресс-кода сотруднику будет выдано устное предупреждение.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "При последующем нарушении - выговор.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 1 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Транспорт ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Брать служебный транспорт без спроса Руководящего состава - запрещено.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Так же без разрешения запрещено использовать служебный транспорт в личных целях.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Рабочий транспорт свободно разрешён с должности « Репортёр »")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Служебный вертолёт с должности « Режиссёр »")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 2 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Субординация ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Субординация - система строгого служебного подчинения младшего состава.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Она предусматривает уважительные отношения между начальником и подчинённым.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "В гос.организациях правила субординации устанавливают порядок общения.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "К старшим по должности необходимо обращаться на « Вы »")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 3 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Рабочий график ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Рабочий график по будням: с 09:00 до 19:00.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Обеды: с 12:00 до 13:00 и c 16:00 до 17:00.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Рабочий график по выходным: с 10:00 до 19:00.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Обеды: с 13:00 до 14:00")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 4 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Некорректное объявление ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Если Вы случайно отредактировали объявление некорректно - не нужно огорчаться.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Независимо от вашей должности, вы имеете право обратиться в общую рацию.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "И извиниться за свой проступок. Тогда вы не получите наказания.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 5 then
					lua_thread.create(function()
						sampSendChat(VarL.. "Уважаемые коллеги, минуточку внимания. Лекция на тему « Мероприятия в рабочее время ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Во время рабочего дня запрещается ходить на различные мероприятия.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "А именно: Казино, Бейсджампинг, Гонки, Пейнтболл.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "За нарушение данного правила сотрудник будет наказан предупреждением или выговором.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				elseif list == 6 then
					lua_thread.create(function()
						sampSendChat(VarL "Уважаемые коллеги, минуточку внимания. Лекция на тему « Отчёты и повышение ».")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL "Для успешного продвижения по карьерной лестнице необходимо делать отчёт своей работы.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. 'Форма отчёта находится на портале ' ..Struct2.. ', в разделе СМИ "Полезная информация"')
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "После одобрения отчёта, репортёры и выше получают повышение на общем собрании.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Помощники редакции и Светотехники получают должность внеочереди.")
						wait(settings.settings.SleepLection)
						sampSendChat(VarL.. "Лекция окончена, благодарю за внимание.")
						screenAndTime()
					end)
				end
			else
				sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(903)
		if result then
			if button == 1 then
				if list == 0 then
					lua_thread.create(function()
						sampAddChatMessage('• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play отыгровки подойдите на склад радиоцентра и нажмите « 1 »', -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat('/do На полке стоит коробка с новым принтером.')
						wait(settings.settings.SleepRP)
						sampSendChat('/me протянул' ..RP1.. ' руки и достал' ..RP1.. ' коробку с полки')
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка с новым принтером в руках.")
						screenAndTime()
						sampAddChatMessage('• {FFBF29}[Подсказка] {FFFFFF}Для продолжения подойдите к любому столу в Радиоцентре и нажмите « 1 »', -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do В руках коробка с новым принтером.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и положил" ..RP1.. " коробку с новым принтером на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка с новым принтером на столе.")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Также на столе лежит канцелярский нож.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и взял" ..RP1.. " канцелярский нож")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Канцелярский нож в правой руке.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и разрезал" ..RP1.. " скотч на коробке с новым принтером")
						screenAndTime()
						wait(settings.settings.SleepRP)
						sampSendChat("/me положив канцелярский нож на стол, открыл" ..RP1.. " коробку")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В коробке лежит сам принтер, а также провода питания и документация.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " принтер, после чего поставил" ..RP1.. " его на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " провода питания и начал" ..RP1.. " их подключать")
						wait(settings.settings.SleepRP)
						sampSendChat("/me подключил" ..RP1.. " конец кабеля в разъем на принтере, а вилку кабеля в розетку")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Новый принтер подключен.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 1 then
					lua_thread.create(function()
						sampAddChatMessage('• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play отыгровки подойдите на склад Радиоцентра и нажмите « 1 »', -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На полке стоит коробка с фотоаппаратами.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " коробку с полки, после чего открыл" ..RP1.. " её")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " оттуда несколько фотоаппаратов и начал" ..RP1.. " расставлять их на полке")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Фотоаппараты расставлены на полке.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me убрал" ..RP1.. " коробку, закрыв её")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 2 then
					lua_thread.create(function()
						sampAddChatMessage('• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play отыгровки подойдите к радиоэфирной и нажмите « 1 »', -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На приборной панели в радиоэфирной множество различных кнопок.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me отыскал" ..RP1.. " кнопку включения и сильно надавил" ..RP1.. " на неё")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Аппаратура включена.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me надел" ..RP1.. " наушники, после чего нажал" ..RP1.. " на кнопку включения микрофона")
						wait(settings.settings.SleepRP)
						sampSendChat("/me сказал" ..RP1.. " что-то в микрофон")
						wait(settings.settings.SleepRP)
						sampSendChat("/me снял" ..RP1.. " наушники и сильно надавил" ..RP1.. " на кнопку включения аппаратуры")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Аппаратура выключена.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 3 then
					lua_thread.create(function()
						sampAddChatMessage('• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play отыгровки подойдите на склад Радиоцентра и нажмите « 1 »', -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На полке лежат пачки с журналами.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " одну из пачек с журналами")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Пачка с журналами в руках.")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолжения Role-Play отыгровки подойдите к стенду и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/me открыл" ..RP1.. " пачку с журналами, после чего начал" ..RP1.. " раскладывать их на стенде")
						wait(settings.settings.SleepRP)
						sampSendChat('/do Журналы "Vine-Wood" лежат в среднем ряду.')
						wait(settings.settings.SleepRP)
						sampSendChat('/do Журналы "Hamster Love" лежат в левом ряду.')
						wait(settings.settings.SleepRP)
						sampSendChat("/me скомкал" ..RP1.. " упаковку от журналов, после чего бросил" ..RP1.. " её в мусорное ведро")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 4 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите к шкафу или полке, после чего нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/me протянул" ..RP1.. " руки и открыл" ..RP1.. " шкаф")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В шкафу лежат аптечки.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " несколько аптечек")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолжения Role-Play подойдите к задним дверям фургона и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do Несколько аптечек в руках.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me аккуратно протянул" ..RP1.. " правую руку и открыл" ..RP1.. " дверь фургона")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Двери фургона открыты.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и положил" ..RP1.. " аптечки под сиденья")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и закрыл" ..RP1.. " двери фургона")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Двери фургона закрыты.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 5 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите на склад Радиоцентра и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На полке лежит коробка с клавиатурой.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " коробку с полки")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка с клавиатурой в руках.")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолжения Role-Play подойдите к столу с компьютером и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/me протянул" ..RP1.. " руки и положил" ..RP1.. " коробку на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и взял" ..RP1.. " канцелярский нож")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и разрезал" ..RP1.. " скотч на коробке")
						wait(settings.settings.SleepRP)
						sampSendChat("/me положил" ..RP1.. " канцелярский нож на стол, после чего открыл" ..RP1.. " коробку")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В коробке лежит сама клавиатура, а также инструкция.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " клавиатуру, после чего положил" ..RP1.. " её на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и вставил" ..RP1.. " кабель « USB » в разъём на компьютере")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Клавиатура подключена.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 6 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите к любому столу в Радиоцентре и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На столе лежат ножницы.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и взял" ..RP1.. " ножницы")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Ножницы в правой руке.")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолежния Role-Play подойдите к растениям около Радиоцентра и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На растении присутствуют засохшие листья.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку, после чего начал" ..RP1.. " обрезать сухие листья")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Сухие листья обрезаны.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 7 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите на склад Радиоцентра и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На полке лежит коробка с новым ноутбуком.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и аккуратно достал" ..RP1.. " коробку с ноутбуком")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка с ноутбуком в руках.")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолжения Role-Play подойдите к столу на втором этаже и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do В руках коробка с ноутбуком.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и положил" ..RP1.. " коробку с ноутбуком на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me открыл" ..RP1.. " коробку с ноутбуком")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В коробке лежит провод питания, новый ноутбук, а также инструкции.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " ноутбук, после чего положил" ..RP1.. " его на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " кабель питания, после чего начал" ..RP1.. " его подключать")
						wait(settings.settings.SleepRP)
						sampSendChat("/me подключил" ..RP1.. " конец кабеля в разъём на ноутбуке, а вилку в розетку")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Новый ноутбук подключен.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 8 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите к ноутбуку и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На столе стоит включенный ноутбук.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и с помощью « TouchPad » открыл" ..RP1.. " браузер")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Браузер открыт.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me нажал" ..RP1.. " сочетание клавиш « Ctrl + H » с помощью клавиатуры ноутбука")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Открылась история браузера.")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Сверху присутствует кнопка « Очистить историю браузера ».")
						wait(settings.settings.SleepRP)
						sampSendChat("/me с помощью « TouchPad » нажал" ..RP1.. " на кнопку « Очистить историю браузера »")
						wait(settings.settings.SleepRP)
						sampSendChat("/do История браузера очищена.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				elseif list == 9 then
					lua_thread.create(function()
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для начала Role-Play подойдите на склад Радиоцентра и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/do На полке лежит коробка с компьютерной мышкой.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " руки и достал" ..RP1.. " коробку с полки")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка с компьютерной мышкой в руках.")
						screenAndTime()
						wait(1500)
						sampAddChatMessage("• {FFBF29}[Подсказка] {FFFFFF}Для продолжения Role-Play подойдите к ноутбуку на втором этаже и нажмите « 1 »", -1)
						while true do wait(0) if isKeyJustPressed(key.VK_1) then break end end
						sampSendChat("/me протянул" ..RP1.. " руки и положил" ..RP1.. " коробку на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me аккуратно открыл" ..RP1.. " коробку с компьютерной мышкой")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Коробка открыта.")
						wait(settings.settings.SleepRP)
						sampSendChat("/do В коробке лежит компьютерная мышка, а также инструкция.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и достал" ..RP1.. " мышку, после чего положил" ..RP1.. " её на стол")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP1.. " правую руку и подключил" ..RP1.. " провод в разъём « USB » на ноутбуке")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Мышь подключена.")
						screenAndTime()
						wait(1000)
						sampAddChatMessage("• {00CC00}[Успешно] {FFFFFF}Role-Play задание завершено.", -1)
					end)
				end
			else
				sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(904)
		if result then
			if button == 1 then
				if list == 0 then
					lua_thread.create(function()
						sampSendChat("/me взял" ..RP1.. " микрофон и наушники")
						wait(settings.settings.SleepRP)
						sampSendChat("/me надел" ..RP1.. " наушники на голову")
						wait(settings.settings.SleepRP)
						sampSendChat("/me настроил" ..RP1.. " звуковую дорожку")
						wait(settings.settings.SleepRP)
						sampSendChat("/me настроил" ..RP1.. " оборудование")
						wait(settings.settings.SleepRP)
						sampSendChat("/me приготовил" ..RP3.. " к выходу в эфир")
						wait(settings.settings.SleepRP)
						sampSendChat("/me запустил" ..RP1.. " эфир")
						wait(settings.settings.SleepRP)
						sampSendChat("/me включил запись трансляции на хранилище")
						wait(settings.settings.SleepRP)
						sampSendChat("/ether")
						screenAndTime()
					end)
				elseif list == 1 then
					sampSendChat('/ether')
					wait(settings.settings.SleepRP)
					sampSendChat("/me выш" ..RP2.. " из эфира")
					wait(settings.settings.SleepRP)
					sampSendChat("/me убрал" ..RP1.. " оборудование на место")
					wait(settings.settings.SleepRP)
					sampSendChat("/me выключил" ..RP1.. " оборудование")
					screenAndTime()
				end
			else
				sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(905)
		if result then
			if button == 1 then
				if list == 0 then
					lua_thread.create(function()
						sampSendChat("/do На правом плече весит сумка с камерой, проводами и штативом.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me протянул" ..RP3.. " к сумке, после чего снял" ..RP1.. " её с плеча")
						wait(settings.settings.SleepRP)
						sampSendChat("/do Сумка с камерой, проводами, штативом в руке.")
						wait(settings.settings.SleepRP)
						sampSendChat("/me открыл" ..RP1.. " сумку, после чего достал" ..RP1.. " штатив")
						wait(settings.settings.SleepRP)
						sampSendChat("/me установил" ..RP1.. " штатив, поставив его в нужное место")
						wait(settings.settings.SleepRP)
						sampSendChat("/me уставливает камеру на штатив")
						wait(500)
						sampSendChat('/tvmenu')
						while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'Телеэфир' then break end end
						sampCloseCurrentDialogWithButton(1)
						wait(settings.settings.SleepRP)
						sampSendChat("/do Камера установлена.")
						screenAndTime()
					end)
				elseif list == 1 then
					lua_thread.create(function()
						sampSendChat("/me достал" ..RP1.. " провода, после чего подключил" ..RP1.. " их к планшету")
						wait(settings.settings.SleepRP)
						sampSendChat("/do На планшете вышло окно « Сеть готова к подключению ».")
						wait(settings.settings.SleepRP)
						sampSendChat("/me нажал" ..RP1.. " на кнопку <Rec>, после чего пошла запись")
						wait(settings.settings.SleepRP)
						sampSendChat("/me включил запись трансляции на хранилище")
						wait(500)
						sampSendChat('/tvmenu')
						while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'Телеэфир' then break end end
						sampSetCurrentDialogListItem(2)
						sampCloseCurrentDialogWithButton(1)
						while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'ТВ-Эфир' then break end end
						while true do wait(0) if not sampIsDialogActive() then break end end
						wait(settings.settings.SleepRP)
						sampSendChat("/do Запись идет.")
						screenAndTime()
					end)
				elseif list == 2 then
					lua_thread.create(function()
						sampShowDialog(906, "{FF5F10}Выдача микрофона" , "{FFFFFF}Введите ID игрока и причину выдачи микрофона.\nПример: 228, Помощь", "Выбрать", "Назад", 1)
						while true do wait(0) if select(1, sampHasDialogRespond(906)) then break end end
						local _, button, list, text = sampHasDialogRespond(906)
						if button == 1 then
							if text:find('%d+%,%s-.*') then
								local id, reason = text:match('(%d+)%,%s-(.*)')
								if sampGetPlayerScore(id) > 0 then
									sampSendChat("/me открыл" ..RP1.. " сумку, после чего достал" ..RP1.. " из нее микрофон")
									wait(settings.settings.SleepRP)
									sampSendChat("/do Микрофон в руке.")
									wait(settings.settings.SleepRP)
									sampSendChat("/me передал" ..RP1.. " микрофон " .. sampGetPlayerNickname(id):gsub("_", " "))
									wait(1500)
									sampSendChat('/tvmenu')
									while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'Телеэфир' then break end end
									sampSetCurrentDialogListItem(4)
									while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'ТВ-Микрофон' then break end end
									sampSetCurrentDialogEditboxText(id)
									sampCloseCurrentDialogWithButton(1)
									while true do wait(0) if not sampIsDialogActive() then break end end
									wait(settings.settings.SleepRP)
									sampSendChat("/f " ..settings.settings.Tag.. "Выдал" ..RP1.. " микрофон сотруднику " .. sampGetPlayerNickname(id):gsub("_", " ").. ". Причина: " ..reason)
									screenAndTime()
								end
							else
								sampShowDialog(906, "{FF5F10}Выдача микрофона" , "{FFFFFF}Введите ID игрока и причину выдачи микрофона.\nПример: 228, Помощь", "Выбрать", "Назад", 1)
							end
						else
							sampShowDialog(905, "{FF5F10}Телеэфир", "{FF5F10}• {FFFFFF}Установка камеры\n{FF5F10}• {FFFFFF}Подготовка и начало эфира\n{FF5F10}• {FFFFFF}Выдать микрофон\n{FF5F10}• {FFFFFF}Завершение эфира", "Выбрать", "Назад", 2)
						end
					end)
				elseif list == 3 then
					lua_thread.create(function()
						sampSendChat("/me протянул" ..RP3.. " к планшету и повторно нажал" ..RP1.. " на кнопку <Rec>")
						wait(settings.settings.SleepRP)
						sampSendChat()
						wait(settings.settings.SleepRP)
						sampSendChat()
						wait(settings.settings.SleepRP)
						sampSendChat()
						wait(settings.settings.SleepRP)
						sampSendChat()
						wait(settings.settings.SleepRP)
						sampSendChat()
						screenAndTime()
						wait(1500)
						sampSendChat('/tvmenu')
						while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == 'Телеэфир' then break end end
						sampSetCurrentDialogListItem(3)
						sampCloseCurrentDialogWithButton(1)
						wait(500)
						sampSendChat("/me убрал" ..RP1.. " камеру и штатив в сумку")
						wait(settings.settings.SleepRP)
						sampSendChat("/me убрал" ..RP1.. " планшет в карман")
						screenAndTime()
					end)
				end
			else
				sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
			end
		end
		local result, button, list, reason = sampHasDialogRespond(908)
		if result then
			if button == 1 then
				if list == 0 then
					lua_thread.create(function()
						sampSendChat("/me достал" ..RP1.. " смартфон. Открыл" ..RP1.. " online-базу данных организации")
						wait(settings.settings.SleepRP)
						sampSendChat("/me добавил" ..RP1.. " " ..nickRPjob.. " в базу данных")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " новую форму и бейджик для " ..nickRPjob)
						wait(settings.settings.SleepRP)
						sampSendChat("/me передал" ..RP1.. " форму и бейджик " ..nickRPjob)
						wait(200)
						sampSendChat('/oldanim 6')
						wait(500)
						sampSendChat('/invite ' ..idjob)
						while true do
							wait(0)
							if sampIsDialogActive() and sampGetDialogCaption() == nickjob then
								while true do wait(0) if not sampIsDialogActive() then break end end
								invited = true
								break
							elseif select(1, sampGetChatString(99)) == "Игрок состоит в черном списке" then
								wait(2000)
								sampSendChat("/do В базе данных произошла ошибка.")
								wait(settings.settings.SleepRP)
								sampSendChat('/do ' ..nickRPjob.. ' состоит в чёрном списке организации.')
								wait(settings.settings.SleepRP)
								sampSendChat("Вы находитесь в чёрном списке нашей организации, поэтому вам отказано в собеседовании.")
								wait(settings.settings.SleepRP)
								sampSendChat("/me забрал" ..RP1.. " форму и бейджик у " ..nickRPjob)
								break
							elseif select(1, sampGetChatString(99)) == "У игрока есть варн" then
								wait(2000)
								sampSendChat("/do База данных выявила судимость в личном деле " ..nickRPjob.. ".")
								wait(settings.settings.SleepRP)
								sampSendChat("В вашем личном деле найдена судимость, поэтому я отказываю вам в собеседовании.")
								wait(settings.settings.SleepRP)
								sampSendChat("/n На вашем аккаунте предупреждение (варн). Чтобы узнать его срок, введите команду /warntime")
								wait(settings.settings.SleepRP)
								sampSendChat("/me забрал" ..RP1.. " форму и бейджик у " ..nickRPjob)
								break
							end
						end
						wait(500)
						if invited then
							screenAndTime()
							wait(1500)
							sampSendChat("Уважаемый сотрудник! Для того, чтобы получить повышение")
							wait(3000)
							sampSendChat("Необходимо сдать Устав СМИ и Правила Редактирования Объявлений.")
							wait(5000)
							sampSendChat("Информацию об этом Вы сможете найти на портале " ..Struct2.. ".")
							wait(2000)
							while true do wait(0) if not sampIsDialogActive() then break end end
							wait(500)
							sampSendChat("/n Для более комфортной игры рекомендую скачать LUA script - Mass Media Master.")
							wait(3000)
							sampSendChat("/n Всё необходимое Вы сможете найти на форуме в разделе « CМИ ».")
							if settings.settings.WriteLog then
								toLog("[Invite]:", nickjob, "")
							end
						end
					end)
				elseif list == 1 then
					lua_thread.create(function()
						sampSendChat("/me достал" ..RP1.. " смартфон. Открыл" ..RP1.. " online-базу данных организации")
						wait(settings.settings.SleepRP)
						sampSendChat("/me добавил" ..RP1.. " " ..nickRPjob.. " в базу данных")
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " новую форму и бейджик для " ..nickRPjob)
						wait(settings.settings.SleepRP)
						sampSendChat("/me передал" ..RP1.. " форму и бейджик " ..nickRPjob)
						wait(200)
						sampSendChat('/oldanim 6')
						wait(500)
						sampSendChat('/invite ' ..idjob)
						while true do
							wait(0)
							if sampIsDialogActive() and sampGetDialogCaption() == nickjob then
								while true do wait(0) if not sampIsDialogActive() then break end end
								invited = true
								break
							elseif select(1, sampGetChatString(99)) == "Игрок состоит в черном списке" then
								wait(2000)
								sampSendChat("/do В базе данных произошла ошибка.")
								wait(settings.settings.SleepRP)
								sampSendChat('/do ' ..nickRPjob.. ' состоит в чёрном списке организации.')
								wait(settings.settings.SleepRP)
								sampSendChat("Вы находитесь в чёрном списке нашей организации, поэтому вам отказано в собеседовании.")
								wait(settings.settings.SleepRP)
								sampSendChat("/me забрал" ..RP1.. " форму и бейджик у " ..nickRPjob)
								break
							elseif select(1, sampGetChatString(99)) == "У игрока есть варн" then
								wait(2000)
								sampSendChat("/do База данных выявила судимость в личном деле " ..nickRPjob.. ".")
								wait(settings.settings.SleepRP)
								sampSendChat("В вашем личном деле найдена судимость, поэтому я отказываю вам в собеседовании.")
								wait(settings.settings.SleepRP)
								sampSendChat("/n На вашем аккаунте предупреждение (варн). Чтобы узнать его срок, введите команду /warntime")
								wait(settings.settings.SleepRP)
								sampSendChat("/me забрал" ..RP1.. " форму и бейджик у " ..nickRPjob)
								break
							end
						end
						wait(500)
						if invited then
							screenAndTime()
							if settings.settings.WriteLog then
								toLog("[Invite]:", nickjob, "")
							end
						end
					end)
				elseif list == 2 then
					lua_thread.create(function()
						sampShowDialog(909, nickjob, "{FFFFFF}Введите причину увольнения.", 'Выбрать', 'Назад', 1)
						while true do
							wait(0)
							local result, button, list, input = sampHasDialogRespond(909)
							if result then
								if button == 1 then
									if input then
										sampSendChat("/me достал" ..RP1.. " смартфон. Открыл" ..RP1.. " online-базу данных организации")
										wait(settings.settings.SleepRP)
										sampSendChat("/me стёр" ..RP4.. " личное дело сотрудника " ..nickRP)
										wait(500)
										sampSendChat("/uninvite " ..idjob.. " " ..settings.settings.Tag..input " [" ..idjob.. "]")
										if settings.settings.WriteLog then
											toLog("[Uninvite]:", nickjob, "Причина: " ..input)
										end
										wait(500)
										screenAndTime()
									else
										sampShowDialog(909, nickjob, "{FFFFFF}Введите причину увольнения.", 'Выбрать', 'Назад', 1)
									end
								else
									sampShowDialog(908, nick.. '[' ..idjob.. ']', "{FF5F10}• {FFFFFF}Принять в организацию\n{FF5F10}• {FFFFFF}Принять в организацию (без речи)\n{FF5F10}• {FFFFFF}Уволить из организации\n{FF5F10}• {FFFFFF}Выдать выговор\n{FF5F10}• {FFFFFF}Изменить должность\n{FF5F10}• {FFFFFF}Выдать новую форму", 'Выбрать', 'Закрыть', 2)
								end
								break
							end
						end
					end)
				elseif list == 3 then
					lua_thread.create(function()
						sampShowDialog(910, nick.. '[' ..idjob.. ']', "{FFFFFF}Введите причину выговора.", "Выбрать", "Назад", 1)
						while true do
							wait(0)
							local result, button, list, input = sampHasDialogRespond(910)
							if result then
								if button == 1 then
									if input then
										sampSendChat("/me достал" ..RP1.. " смартфон. Открыл" ..RP1.. " online-базу данных организации")
										wait(settings.settings.SleepRP)
										sampSendChat("/me внес" ..RP4.. " выговор в личное дело сотрудника " ..nickRPjob)
										wait(500)
										sampSendChat("/fwarn " ..idjob.. " " ..settings.settings.Tag..input.. " [" ..idjob.. "]")
										if settings.settings.WriteLog then
											toLog("[Fwarn]:", nickjob, "Причина: " ..input)
										end
										wait(500)
										screenAndTime()
									else sampShowDialog(910, nickjob.. '[' ..idjob.. ']', "{FFFFFF}Введите причину выговора.", "Выбрать", "Назад", 1) end
								end
								break
							end
						end
					end)
				elseif list == 4 then
					lua_thread.create(function()
						sampSendChat("/me передал" ..RP1.. " новый бейджик для сотрудника " ..nickRPjob)
						wait(settings.settings.SleepRP)
						sampSendChat("/me достал" ..RP1.. " смартфон. Открыл" ..RP1.. " online-базу данных организации")
						wait(settings.settings.SleepRP)
						sampSendChat("/me внес" ..RP4.. " изменение в личное дело сотрудника " ..nickRPjob.. " в базу данных")
						wait(500)
						sampSendChat('/find')
						while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == "{ffff00}Члены организации онлайн" then break end end
						while true do
							wait(0)
							if getDialogLine() then end
						end
					end)
				end
			end
		end
	end
end
-- wait(settings.settings.SleepRP)
-- sampSendChat()

function apply_custom_style()
	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.WindowPadding = imgui.ImVec2(4.0, 4.0)
	style.ChildWindowRounding = 0.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	colors[clr.Header]                 = imgui.ImColor(255, 77, 0, 255):GetVec4()
	colors[clr.HeaderHovered]          = imgui.ImColor(125, 125, 125, 174):GetVec4()
	colors[clr.HeaderActive]           = imgui.ImColor(84, 84, 84, 255):GetVec4()
	colors[clr.SeparatorHovered]       = ImVec4(1.00, 0.30, 0.00, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(1.00, 0.30, 0.00, 1.00)
	colors[clr.Border]                 = ImVec4(1.00, 0.30, 0.00, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.Button]                 = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.30, 0.00, 0.70)
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.TitleBg]                = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.30, 0.00, 1.00)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.FrameBg]                = ImVec4(1.00, 0.30, 0.00, 0.50)
    colors[clr.FrameBgHovered]         = ImVec4(1.00, 0.30, 0.00, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(1.00, 0.30, 0.00, 1.00)
	colors[clr.Separator]              = ImVec4(1.00, 0.30, 0.00, 1.00)
end
apply_custom_style()

local bigFont = nil
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
    	local font_config = imgui.ImFontConfig()
    	font_config.MergeMode = true
		if doesFileExist('moonloader/Mass Media Master/fontawesome.ttf') then
   			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Mass Media Master/fontawesome.ttf', 14.0, font_config, fa_glyph_ranges)
		else
			if not downloading then
				sampAddChatMessage('• {FFC800}[Mass Media Master] {FFFFFF}Началась загрузка шрифта.', -1)
				downloading = true
				downloadUrlToFile('https://github.com/MindstormsLego/DAP-Helper/raw/master/fontawesome.ttf', 'moonloader\\Mass Media Master\\fontawesome.ttf', function(id3, status1, p13, p23)
					if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
						sampAddChatMessage('• {FFC800}[Mass Media Master] {FFFFFF}Загрузка шрифта завершена.', -1)
						downloading = false
					end
				end)
			end
		end
 	end
end

local SexId = imgui.ImInt(0)
SexId.v = settings.settings.SexId
local SleepRP = imgui.ImInt(0)
SleepRP.v = settings.settings.SleepRP
local SleepLection = imgui.ImInt(0)
SleepLection.v = settings.settings.SleepLection
local Structure = imgui.ImInt(0)
Structure.v = settings.settings.Structure
local SleepEfir = imgui.ImInt(0)
SleepEfir.v = settings.settings.SleepEfir
local CorrectChat = imgui.ImBool(settings.settings.CorrectChat)
local AutoScreen = imgui.ImBool(settings.settings.AutoScreen)
local WriteLog = imgui.ImBool(settings.settings.WriteLog)
local LectionInR = imgui.ImBool(settings.settings.LectionInR)
local Emotions = imgui.ImBool(settings.settings.Emotions)
local TimeRP = imgui.ImBool(settings.settings.TimeRP)
local btn_size = imgui.ImVec2(-0.1, 0)
local Accent = imgui.ImBuffer(u8(settings.settings.Accent), 256)
local Tag = imgui.ImBuffer(u8(settings.settings.Tag), 256)
local bind_filter = imgui.ImBuffer(256)
function imgui.OnDrawFrame()
	if main_window_state.v then
		local tLastKeys = {}
		local iScreenWidth, iScreenHeight = getScreenResolution()

		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth / 2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(900, 450), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'Mass Media Master ' ..script.this.version.. u8'| Меню скрипта', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild('##left', imgui.ImVec2(-700, 0), true, imgui.WindowFlags.AlwaysUseWindowPadding)

		if not iSelectItem then iSelectItem = 0 end
		if iSelectItem ~= 0 then imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) else imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button]) end
		if imgui.Button(u8('Главная'), imgui.ImVec2(-0.001, 30)) then iSelectItem = 0 end
		imgui.PopStyleColor()
		if iSelectItem ~= 1 then imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) else imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button]) end
		if imgui.Button(u8('Дополнительно'), imgui.ImVec2(-0.001, 30)) then iSelectItem = 1 end
		imgui.PopStyleColor()
		if iSelectItem ~= 2 then imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) else imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button]) end
		if imgui.Button(u8('Бинды'), imgui.ImVec2(-0.001, 30)) then iSelectItem = 2 end
		imgui.PopStyleColor()
		if iSelectItem ~= 3 then imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0, 0, 0)) else imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.Button]) end
		if imgui.Button(u8('Информация'), imgui.ImVec2(-0.001, 30)) then iSelectItem = 3 end
		imgui.PopStyleColor()
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild('##right', imgui.ImVec2(0, 0), false, imgui.WindowFlags.AlwaysUseWindowPadding)

		if iSelectItem == 0 then
			imgui.Text(u8'Главная')
			imgui.Separator(); imgui.Spacing()
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()

			imgui.Text(u8'Активация меню скрипта:')
			imgui.SameLine()
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"Активация главного меню скрипта с различными действиями.")
			   imgui.EndTooltip()
			end

			for k, v in ipairs(tKeyList) do
				if k == 1 and hk.HotKey("##MenuScr", v, tLastKeys, 250) then
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
					end
				end
			end

			imgui.Text(u8'Копирование строки редактируемого объявления:')
			imgui.SameLine()
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"В /edit перейдите к редактированию объявления и активируйте данную функцию.\nТекст объявления скопируется в поле для редактирования.")
			   imgui.EndTooltip()
			end

			for k, v in ipairs(tKeyList) do
				if k == 3 and hk.HotKey("##CopyAdvert", v, tLastKeys, 250) then
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
					end
				end
			end

			imgui.NextColumn()
			imgui.Text(u8'Перезагрузка скрипта:')
			for k, v in ipairs(tKeyList) do
				if k == 2 and hk.HotKey("##ReloadScr", v, tLastKeys, 250) then
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
					end
				end
			end

			imgui.Text(u8'Точное время на сервере:')
			for k, v in ipairs(tKeyList) do
				if k == 4 and hk.HotKey("##ExaxtTime", v, tLastKeys, 250) then
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
					end
				end
			end
			imgui.Columns(1)

			imgui.Spacing(); imgui.Spacing(); imgui.Separator(); imgui.Spacing(); imgui.Spacing()
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.Text(u8"Задержка между Role-Play отыгровками:")
			if imgui.DragInt("##SleepRP", SleepRP, 1, 2000, 10000) then
				settings.settings.SleepRP = SleepRP.v
			end
			imgui.NextColumn()
			imgui.Text(u8"Задержка между Role-Play отыгровками:")
			if imgui.DragInt("##SleepLection", SleepLection, 1, 2000, 10000) then
				settings.settings.SleepLection = SleepLection.v
			end
			imgui.NextColumn()
			imgui.Text(u8"Задержка между строк в эфирах:")
			if imgui.DragInt("##SleepEfir", SleepEfir, 1, 2000, 10000) then
				settings.settings.SleepEfir = SleepEfir.v
			end
			imgui.NextColumn()
			imgui.Text(u8"Тэг:")
			if imgui.InputText("##Tag", Tag) then
				settings.settings.Tag = u8:decode(Tag.v)
			end
			imgui.Columns(1)
		elseif iSelectItem == 1 then
			imgui.Text(u8'Дополнительные настройки')
			imgui.Separator(); imgui.Spacing()
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.Text(u8"Префикс перед сообщениями в чат:")
			if imgui.InputText("##accent", Accent, imgui.InputTextFlags.EnterReturnsTrue) then
				settings.settings.Accent = u8:decode(Accent.v)
			end
			imgui.NextColumn()
			imgui.Text(u8("Форма государства"))
			if imgui.Combo("##Structure", Structure, {u8'Штат', u8'Республика', u8'Федерация'}) then
				settings.settings.Structure = Structure.v
			end
			imgui.NextColumn()
			imgui.Text(u8"Пол:")
			if imgui.Combo("##Male", SexId, {u8'Мужской', u8'Женский'}) then
				settings.settings.SexId = SexId.v
			end
			imgui.NextColumn()
			imgui.Text(u8'Открыть меню /edit')
			for k, v in ipairs(tKeyList) do
				if k == 5 and hk.HotKey("##MenuEdit", v, tLastKeys, 200) then
					if not rkeys.isHotKeyDefined(v.v) then
						if rkeys.isHotKeyDefined(tLastKeys.v) then
							rkeys.unRegisterHotKey(tLastKeys.v)
						end
						rkeys.registerHotKey(v.v, true, onHotKey)
					end
				end
			end
			imgui.Columns(1)
			imgui.Separator(); imgui.Spacing()
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 390); imgui.NextColumn()
			imgui.Text(u8"Корректировка предложений")
			if imgui.ToggleButton("##CorrectChat", CorrectChat) then
		 		settings.settings.CorrectChat = CorrectChat.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"Ваши сообщения всегда будут с большой буквы и точкой на конце.\nИсправляются сообщения, отправленные в чат, а также в [R] и [F] рации.")
			   imgui.EndTooltip()
			end
			imgui.NextColumn()
			imgui.Text(u8"Автоматический скриншот")
			if imgui.ToggleButton("##AutoScreen", AutoScreen) then
		 		settings.settings.AutoScreen = AutoScreen.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"С помощью данной функции будет производится автоматический скриншот с /time в нужном для этого месте.")
			   imgui.EndTooltip()
			end
			imgui.NextColumn()
			imgui.Text(u8"Записывать действия в log")
			if imgui.ToggleButton("##WriteLog", WriteLog) then
		 		settings.settings.WriteLog = WriteLog.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"В файл log_action.txt будут записываться данные о сотрудниках,\nкоторых вы уволили, приняли, повысили, понизили, или выдали выговор.\nДанный файл находится в папке Settings.")
			   imgui.EndTooltip()
			end
			imgui.NextColumn()
			imgui.Text(u8"Зачитывать лекции в [R] рацию")
			if imgui.ToggleButton("##LectionInR", LectionInR) then
		 		settings.settings.LectionInR = LectionInR.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"Возможность зачитывания лекций либо в [R] рацию, либо в обычный чат.\nЧтобы зачитать лекцию, откройте главное меню скрипта в игре и перейдите к лекциям.")
			   imgui.EndTooltip()
			end
			imgui.NextColumn()
			imgui.Text(u8"Смайлики с Role-Play отыгровкой")
			if imgui.ToggleButton("##Emotions", Emotions) then
		 		settings.settings.Emotions = Emotions.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"При отправке в чат следующих символов будет появляться`nопределённая Role-Play отыгровка.\nДоступные символы:\n((( -- оч сильно расстроился\n))) -- ухахатывается\n:)  -- обрадовался\n:c  -- огорчился\n;c  -- огорчился`n:(  -- огорчился\n:D  -- орёт от смеха\n:3  -- кокетливо улыбается\nxD  -- валяется от смеха\nXD  -- кувыркается от смеха\n<3  -- с любовью посмотрел на человека напротив\n:*  -- подмигивает")
			   imgui.EndTooltip()
			end
			imgui.NextColumn()
			imgui.Text(u8"Role-Play отыгровка точного времени")
			if imgui.ToggleButton("##TimeRP", TimeRP) then
		 		settings.settings.TimeRP = TimeRP.v
			end
			imgui.SameLine()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
			imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE)
			if imgui.IsItemHovered() then
			   imgui.BeginTooltip()
			   imgui.TextUnformatted(u8"При активации данного параметра текущее время будет отображаться в виде Role-Play отыгровки.\nПри деактивации данного параметра, текущее время будет отображаться только Вам визуально в чат.")
			   imgui.EndTooltip()
			end
			imgui.Columns(1)
		elseif iSelectItem == 2 then
			imgui.Text(u8'Бинды')
			imgui.Separator(); imgui.Spacing()
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 2.5)
			imgui.PushItemWidth(300)
			imgui.InputText(fa.ICON_FILTER.. '##bind_filter', bind_filter)
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetCursorPosX() + 235)
			if imgui.Button(fa.ICON_PLUS_CIRCLE) then
				table.insert(blanks, {name = 'Без названия', command, state = false, text, type = 0})
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COG) and current_bind then
				imgui.OpenPopup(u8'Настройки##tips')
				imgui.SetNextWindowSize(imgui.ImVec2(610, 0), imgui.Cond.FirstUseEver)
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_TRASH) then
			end
			if imgui.BeginPopupModal(u8('Настройки##tips'), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
				imgui.Text(u8('Название:'))
				if not namebuffered then namebuffer = imgui.ImBuffer(u8(blanks[current_bind].name), 256) namebuffered = true end
				imgui.PushItemWidth(605)
				imgui.InputText('##bind_name', namebuffer)
				imgui.PopItemWidth()
				imgui.Text(u8'Тип:')
				if not typebuffered then typebuffered = true typebuffer = imgui.ImInt(blanks[current_bind].type) end
				imgui.PushItemWidth(605)
				imgui.Combo('##type_bind', typebuffer, {'Role-Play', u8'Радиоэфир', u8'Телеэфир', u8'Гос. новость'})
				imgui.PopItemWidth()
				if typebuffer.v == 3 then
					if not gostypebuffered then gostypebuffered = true if #blanks[current_bind].text == 1 then gostypebuffer = imgui.ImInt(0) else gostypebuffer = imgui.ImInt(1) end end
					imgui.Combo(u8'Тип гос. новости', gostypebuffer, {u8('1 строка'), u8('3 строки')})

					if gostypebuffer.v == 0 and plustwogos then
						plustwogos, gos2, gos3 = false, nil, nil
					elseif gostypebuffer.v == 1 and not plustwogos then
						plustwogos, gos2, gos3 = true, imgui.ImBuffer(u8(blanks[current_bind].text[2]), 256), imgui.ImBuffer(u8(blanks[current_bind].text[3]), 256)
					end

					if not gosbuffered then
						gosbuffered = true
						gos1 = imgui.ImBuffer(u8(blanks[current_bind].text[1]), 256)
						if gostypebuffer.v == 1 then
							gos2 = imgui.ImBuffer(u8(blanks[current_bind].text[2]), 256)
							gos3 = imgui.ImBuffer(u8(blanks[current_bind].text[3]), 256)
							plustwogos = true
						end
					end
					imgui.InputText(u8"Первая строка гос.новости", gos1)
					if gostypebuffer.v == 1 then
						imgui.InputText(u8"Вторая строка гос.новости", gos2)
						imgui.InputText(u8"Третья строка гос.новости", gos3)
					end
				end
				if imgui.Button(u8('Сохранить'), imgui.ImVec2(300, 0)) then
					blanks[current_bind].name = u8:decode(namebuffer.v)
					blanks[current_bind].type = typebuffer.v
					if blanks[current_bind].type == 3 then
						blanks[current_bind].text[1] = u8:decode(gos1.v)
						blanks[current_bind].text[2] = u8:decode(gos2.v)
						blanks[current_bind].text[3] = u8:decode(gos3.v)
						gosbuffered = false
					end
					namebuffered = false
					typebuffered = false
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if imgui.Button(u8('Отмена'), imgui.ImVec2(300, 0)) then
					gosbuffered = false
					namebuffered = false
					typebuffered = false
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			imgui.BeginChild('table##binds', imgui.ImVec2(0, 0), true)
			imgui.Columns(3, "##bind_list", false)
			imgui.SetCursorPosX(17.5)
			imgui.TextQuestion(u8"Данное поле отвечает за включение и отключение бинда", fa.ICON_POWER_OFF)
			imgui.SetColumnWidth(-1, 50)
			imgui.NextColumn()
			imgui.SetCursorPosX(67.5)
			imgui.Text(u8'№')
			imgui.SetColumnWidth(-1, 50)
			imgui.NextColumn()
			imgui.Text(u8'Название')
			imgui.Separator()
			imgui.NextColumn()
			for i = 1, #blanks do
				imgui.SetCursorPosX(15)
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
				if imgui.Checkbox('##' ..i.. '##bindstate', imgui.ImBool(blanks[i].state)) then
					blanks[i].state = not blanks[i].state
				end
				imgui.NextColumn()
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 8)
				imgui.SetCursorPosX(imgui.GetCursorPosX() + 13)
				if current_bind == i then light = true else light = false end
				if imgui.Selectable(tostring(i), light, imgui.SelectableFlags.SpanAllColumns) then current_bind = i end
				imgui.NextColumn()
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 7)
				imgui.Text(u8(blanks[i].name))
				imgui.NextColumn()
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 5)
				if #blanks ~= i then
					imgui.Separator()
				end
			end
			imgui.Columns(1)
			imgui.EndChild()
		elseif iSelectItem == 3 then
			imgui.Text(u8'Примечания')
			imgui.Text(u8'\nНеобходимая версия для работоспособности данного скрипта: SAMP 0.3.7-R1.\nЕсли у вас установлена иная версия, придётся переустановить.\nФайл blanks.ini служит для воспроизведения вашего текста с целью определённого действия.\nАналог обычного биндера.\nНа данный момент, доступные действия, это подача гос. новостей и текст для радио/теле эфиров.\nВ самом файле приведены примеры,\nпоказывающие как правильно составлять секции для воспроизведений их в игре.')
			imgui.Text(u8'\nОбратная связь')
			imgui.Text(u8'\nПо всем вопросам, проблемам и предложениям обращаться к разработчикам'); imgui.SameLine()
			imgui.Text(u8'\nhttps://vk.com/id127896497')
			if imgui.IsItemClicked() then
				os.execute('explorer "https://vk.com/id127896497"')
			end
			imgui.Text(u8'Или'); imgui.SameLine()
			imgui.Text(u8'https://vk.com/iddd8')
			if imgui.IsItemClicked() then
				os.execute('explorer "https://vk.com/iddd8"')
			end
		end

		imgui.EndChild()
	    imgui.End()
	end
end

function imgui.TextQuestion(text, text2)
  imgui.TextDisabled(text2)
  if imgui.IsItemHovered() then
    imgui.BeginTooltip()
    imgui.PushTextWrapPos(450)
    imgui.TextUnformatted(text)
    imgui.PopTextWrapPos()
    imgui.EndTooltip()
  end
end

function onHotKey(id, keys)
	local sKeys = tostring(table.concat(keys, " "))
	for k, v in pairs(tKeyList) do
		if sKeys == tostring(table.concat(v.v, " ")) and k == 1 then
			sampShowDialog(900, "{FF5F10}Mass Media Master [" ..script.this.version.. "]", "{FF5F10}• {FFFFFF}Листовки и газеты\n{FF5F10}• {FFFFFF}Лекции\n{FF5F10}• {FFFFFF}Role-Play\n{FF5F10}• {FFFFFF}Радиоэфир\n{FF5F10}• {FFFFFF}Телеэфир\n{FF5F10}• {FFFFFF}Команды", "Выбрать",  "", 2)
		end
		if sKeys == tostring(table.concat(v.v, " ")) and k == 2 then
			sampAddChatMessage('ReloadScr', -1)
		end
		if sKeys == tostring(table.concat(v.v, " ")) and k == 3 then
			sampAddChatMessage('CopyAdvert', -1)
		end
		if sKeys == tostring(table.concat(v.v, " ")) and k == 4 then
			sampAddChatMessage('ExactTime', -1)
		end
		if sKeys == tostring(table.concat(v.v, " ")) and k == 5 then
			sampAddChatMessage('MenuEdit', -1)
		end
	end
end

function getDialogLine(index)
	l = 0
	local text = sampGetDialogText()
	if text == "" then return "" end
	for line in string.gmatch(text, '[^\r\n]+') do
		l = l + 1
		if l == index then
			return line
		end
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if not doesDirectoryExist(getWorkingDirectory() .. "\\Mass Media Master") then
			createDirectory(getWorkingDirectory() .. "\\Mass Media Master")
		end
		inicfg.save(settings)
		if doesFileExist(file) then
			os.remove(file)
		end
		local f = io.open(file, "w")
		if f then
			f:write(encodeJson(tKeyList))
			f:close()
		end
		if doesFileExist(blanksfile) then
			os.remove(blanksfile)
		end
		local f = io.open(blanksfile, 'w')
		if f then
			f:write(encodeJson(blanks))
			f:close()
		end
	end
end

function imgui.ToggleButton(str_id, bool)

   local rBool = false

   if LastActiveTime == nil then
      LastActiveTime = {}
   end
   if LastActive == nil then
      LastActive = {}
   end

   local function ImSaturate(f)
      return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
   end

   local p = imgui.GetCursorScreenPos()
   local draw_list = imgui.GetWindowDrawList()

   local height = imgui.GetTextLineHeightWithSpacing() + (imgui.GetStyle().FramePadding.y / 2)
   local width = height * 1.55
   local radius = height * 0.50
   local ANIM_SPEED = 0.15

   if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
      bool.v = not bool.v
      rBool = true
      LastActiveTime[tostring(str_id)] = os.clock()
      LastActive[str_id] = true
   end

   local t = bool.v and 1.0 or 0.0

   if LastActive[str_id] then
      local time = os.clock() - LastActiveTime[tostring(str_id)]
      if time <= ANIM_SPEED then
         local t_anim = ImSaturate(time / ANIM_SPEED)
         t = bool.v and t_anim or 1.0 - t_anim
      else
         LastActive[str_id] = false
      end
   end

   local col_bg
   if imgui.IsItemHovered() then
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
   else
      col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBg])
   end

   draw_list:AddRectFilled(p, imgui.ImVec2(p.x + width, p.y + height), col_bg, height * 0.5)
   draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 1.5, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.GetStyle().Colors[imgui.Col.Button]))

   return rBool
end

function screenAndTime()
	lua_thread.create(function()
		if settings.settings.AutoScreen then
			sampSendChat('/time')
			wait(1000)
			memory.setint8(sampGetBase() + 0x119CBC, 1)
		end
	end)
end

function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end
function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- ё
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function cmd_cfind()
	lua_thread.create(function()
		local ArrayNotStreamPlayer = {}
		local ArrayRangs = {"Начинающий работник", "Помощник редакции", "Светотехник", "Репортёр", "Оператор", "Ведущий"}
		local ArrayPhrases = {"/r Вышеперечисленные сотрудники, ваше местоположение?"
	                   		 ,"/r Вышеперечисленные сотрудники, где вы находитесь?"
	                         ,"/r Просьба вышеперечисленным сотрудникам явиться в радиоцентр."
	                         ,"/r Просьба вышеперечисленным сотрудникам прибыть в радиоцентр."}
		sampSendChat('/find')
		while true do wait(0) if sampIsDialogActive() and sampGetDialogCaption() == '{ffff00}Члены организации онлайн' then break end end
		local online = getDialogLine(1)
		local online = online:match("Всего Online: %{f0e48d%}(%d+)")
		local online = online + 2
		for i = 3, online do
			if getDialogLine(i) ~= "" then
				if string.find(getDialogLine(i), "(%d+)%s+%d+%s+%d+%s+(%d+)%s+%d/3(.*)") then
					local value1, value2, value3 = string.match(getDialogLine(i), "(%d+)%s+%d+%s+%d+%s+(%d+)%s+%d/3(.*)")
					local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
					local Ped = select(2, sampGetCharHandleBySampPlayerId(value1))
					if Ped == -1 and value1 ~= tonumber(myid) then
						if value2 ~= 7 and tonumber(value2) < 7 then
							if value3:find("%s+{ffa800}%[AFK: .*%]") then
								timeAfk = value3:match("%s+{ffa800}%[AFK: (.*)%]")
								timeAfk = " [Рация выключена: " ..timeAfk.. "]"
							else
								timeAfk = ""
							end
							table.insert(ArrayNotStreamPlayer, {value1, value2, timeAfk})
						end
					end
				end
			else break end
		end
		sampCloseCurrentDialogWithButton(1)
		if table.maxn(ArrayNotStreamPlayer) == 0 then
			sampAddChatMessage("• {FFC800}[Подсказка] {FFFFFF}Все сотрудники на месте.", -1)
		else
			sampAddChatMessage("Отсутствующие cотрудники:", -1)
			ArrayOutputForCfind(ArrayNotStreamPlayer, 4)
			wait(500)
			sampAddChatMessage("Нажмите {CCCCCC}[F11] {B8DBB8}для продолжения", 0xB8DBB8)
			while true do
				wait(0)
				if isKeyJustPressed(key.VK_F11) then
					sampAddChatMessage("[1]: {CCCCCC}Проговорить ники в чат. {8888FF}[2]: {CCCCCC}Жетоны через /do.", 0x8888FF)
					wait(100)
					sampAddChatMessage("[3]: {CCCCCC}Проговорить ники [R] рацию. {8888FF}[4]: {CCCCCC}Жетоны в [R] рацию. {8888FF}[5]: {CCCCCC}Отмена.", 0x8888FF)
					while true do
						wait(0)
						if isKeyJustPressed(key.VK_1) then
							sampSendChat("/me орлиным взглядом осмотрел всех сотрудников вокруг себя")
							wait(2200)
							sampSendChat("/me произвел расчёты, cопоставил данные")
							wait(1500)
							sampSendChat("Отсутствующие сотрудники:")
							wait(1500)
							for k = 1, #ArrayNotStreamPlayer do
								position = ArrayRangsFuction(ArrayNotStreamPlayer[k][2], ArrayRangs)
								nickname = sampGetPlayerNickname(ArrayNotStreamPlayer[k][1])
								nickname = string.gsub(nickname, "_", " ")
								if nickname ~= nil then
									sampSendChat(position.. " " ..nickname.. " [Жетон №" ..ArrayNotStreamPlayer[k][1].. "]" ..ArrayNotStreamPlayer[k][3])
									wait(1000)
								end
							end
							break
						end
						if isKeyJustPressed(key.VK_2) then
							sampSendChat("/me осмотрел всех сотрудников и записал жетоны отсутствующих")
							wait(2200)
							sampSendChat("/do В блокноте записаны следующие отсутствующие жетоны:")
							wait(2200)
							mass = ""
							for v = 1, #ArrayNotStreamPlayer do
								if tonumber(v) ~= #ArrayNotStreamPlayer then
									mass = mass.. " " ..ArrayNotStreamPlayer[v][1].. ","
								else
									mass = mass.. " " ..ArrayNotStreamPlayer[v][1].. "."
								end
							end
							sampSendChat("/do Жетоны:" ..mass)
							break
						end
						if isKeyJustPressed(key.VK_3) then
							sampSendChat("/me осмотрел всех сотрудников и вычислил отсутствующих")
							wait(2200)
							sampSendChat("/me достал рацию зелёного цвета")
							wait(2200)
							sampSendChat("/r Отсутствующие сотрудники:")
							wait(1000)
							for b = 1, #ArrayNotStreamPlayer do
								nickname = sampGetPlayerNickname(ArrayNotStreamPlayer[b][1])
								nickname = nickname:gsub("_", " ")
								position = ArrayRangsFuction(ArrayNotStreamPlayer[b][2], ArrayRangs)
								sampSendChat("/r " ..position.. " " ..nickname.. " [Жетон №" ..ArrayNotStreamPlayer[b][1].. "]" ..ArrayNotStreamPlayer[b][3])
								wait(500)
							end
							math.randomseed(os.time())
							local k = math.random(1, #ArrayPhrases)
							sampSendChat(ArrayPhrases[k])
							break
						end
						if isKeyJustPressed(key.VK_4) then
							sampSendChat("/me осмотрел всех сотрудников и вычислил отсутствующих")
							wait(2200)
							sampSendChat("/me достал рацию зелёного цвета")
							wait(2200)
							mass = ""
							for v = 1, #ArrayNotStreamPlayer do
								if tonumber(v) ~= #ArrayNotStreamPlayer then
									mass = mass.. " " ..ArrayNotStreamPlayer[v][1].. ","
								else
									mass = mass.. " " ..ArrayNotStreamPlayer[v][1].. "."
								end
							end
							sampSendChat("/r Отсутствующие жетоны:" ..mass)
							wait(1000)
							math.randomseed(os.time())
							local k = math.random(1, #ArrayPhrases)
							sampSendChat(ArrayPhrases[k])
							break
						end
						if isKeyJustPressed(key.VK_5) then
							sampAddChatMessage("Отмена действия", -1)
							break
						end
					end
					break
				end
			end
		end
	end)
end

function ArrayOutputForCfind(Array, step)
	lua_thread.create(function()
		outputlist = ""
		stepLoop = 0
		lengArray = #Array
		while true do
			wait(0)
			if lengArray > step then
				for i = 1, step do
					local id = Array[i + stepLoop][1]
					outputlist = outputlist:gsub("$", sampGetPlayerNickname(id).. " [" ..id.. "]. ")
				end
				lengArray = lengArray - step
				sampAddChatMessage(outputlist, 0xB8DBB8)
				outputlist = ""
			else
				for l = 1, lengArray do
					local id = Array[l + stepLoop][1]
					outputlist = outputlist:gsub("$", sampGetPlayerNickname(id).. " [" ..id.. "]. ")
				end
				sampAddChatMessage(outputlist, 0xB8DBB8)
				outputlist = ""
				break
			end
			stepLoop = stepLoop + step
		end
	end)
end

function ArrayRangsFuction(rang, ArrayRangs)
	for n = 1, #ArrayRangs do
		if tonumber(rang) == n then
			position = ArrayRangs[n]
			break
		end
	end
	return position
end
