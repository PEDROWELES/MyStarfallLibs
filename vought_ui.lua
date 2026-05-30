--@name Vought V1 UI
--@author User & Gemini
--@client

-- Создаем шрифт помельче, чтобы русский текст управления влез нормально
local fontMontserrat24 = render.createFont("Montserrat", 24, 500, true, false, false, false, 0, true, 0)

local notifyTitle = ""
local notifyText = ""
local notifyEndTime = 0
local notifyAlpha = 0

-- Принимаем сигнал от сервера, когда кто-то колется
net.receive("vought_ui_notify", function()
    notifyTitle = net.readString()
    notifyText = net.readString()
    notifyEndTime = timer.curtime() + 8 -- Показываем плашку 8 секунд
    notifyAlpha = 0
end)

-- Основной хук отрисовки на экран клиента
hook.add("render", "VoughtScreenHUD", function()
    if timer.curtime() > notifyEndTime and notifyAlpha <= 0 then return end
    
    -- Рассчитываем плавное появление/исчезновение альфы
    if timer.curtime() < notifyEndTime then
        notifyAlpha = math.approach(notifyAlpha, 255, render.getFrameTime() * 500)
    else
        notifyAlpha = math.approach(notifyAlpha, 0, render.getFrameTime() * 250)
    end
    
    local scrW, scrH = render.getResolution()
    local w, h = 650, 90
    local x = (scrW - w) / 2
    local y = scrH - h - 80 -- Позиция снизу экрана
    
    -- Рисуем темную плашку (задний фон) в стиле твоего UI
    render.setColor(Color(15, 15, 15, notifyAlpha * 0.9))
    render.drawRect(x, y, w, h)
    
    -- Окантовка (как drawRectOutline из твоего примера)
    render.setColor(Color(255, 255, 255, notifyAlpha * 0.15))
    render.drawRectOutline(x, y, w, h, 2)
    
    -- Левая неоновая полоска (эффект сыворотки)
    render.setColor(Color(180, 255, 0, notifyAlpha))
    render.drawRect(x, y, 6, h)
    
    -- Отрисовка текста
    render.setFont(fontMontserrat24)
    
    -- Заголовок уведомления
    render.setColor(Color(180, 255, 0, notifyAlpha))
    render.drawText(x + 20, y + 15, notifyTitle, 0)
    
    -- Инструкция по управлению
    render.setColor(Color(255, 255, 255, notifyAlpha * 0.85))
    render.drawText(x + 20, y + 48, notifyText, 0)
end)
