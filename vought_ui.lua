--@name Vought V1 UI
--@author User & Gemini
--@client

local fontMontserrat24 = render.createFont("Montserrat", 24, 500, true, false, false, false, 0, true, 0)

local notifyText = ""
local notifySubText = ""
local notifyAlpha = 0
local notifyEndTime = 0

-- Получение сетевого сигнала от сервера
net.receive("vought_ui_notify", function()
    notifyText = net.readString()
    notifySubText = net.readString()
    notifyEndTime = timer.curtime() + 8 -- Показываем 8 секунд
    notifyAlpha = 0
end)

-- ИСПРАВЛЕНО: Теперь хук HUDPaint, чтобы рисовалось прямо на экране игрока, а не на чипе
hook.add("HUDPaint", "VoughtNotification", function()
    if timer.curtime() > notifyEndTime and notifyAlpha <= 0 then return end
    
    -- Плавное появление и исчезновение плашки
    if timer.curtime() < notifyEndTime then
        notifyAlpha = math.Approach(notifyAlpha, 255, render.getFrameTime() * 500)
    else
        notifyAlpha = math.Approach(notifyAlpha, 0, render.getFrameTime() * 250)
    end
    
    local scrW, scrH = render.getResolution()
    local w, h = 600, 80
    local x = (scrW - w) / 2
    local y = scrH - h - 100 -- Позиция снизу экрана, чуть выше стандартного HUD
    
    -- Рисуем в 2D контексте экрана
    render.start2D()
        -- Задний фон (темный)
        render.setColor(Color(20, 20, 20, notifyAlpha * 0.85))
        render.drawRect(x, y, w, h)
        
        -- Левая неоновая полоска
        render.setColor(Color(180, 255, 0, notifyAlpha))
        render.drawRect(x, y, 6, h)
        
        -- Рамка
        render.setColor(Color(255, 255, 255, notifyAlpha * 0.1))
        render.drawRectOutline(x, y, w, h, 1)
        
        -- Текст заголовка
        render.setFont(fontMontserrat24)
        render.setColor(Color(180, 255, 0, notifyAlpha))
        render.drawText(x + 20, y + 15, notifyText, 0)
        
        -- Текст управления (на русском)
        render.setColor(Color(255, 255, 255, notifyAlpha * 0.9))
        render.drawText(x + 20, y + 45, notifySubText, 0)
    render.end2D()
end)
