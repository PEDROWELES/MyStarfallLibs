--@name Vought V1 UI
--@author User & Gemini
--@client

-- Создаем шрифт для заголовка и текста (размер как в оригинале)
fontMontserrat50 = render.createFont("Montserrat", 32, 500, true, false, false, false, 0, true, 0)

---@class Bar
Bar = {}
Bar.__index = Bar

function Bar:new(x, y, w, h, percent)
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
        percent = math.clamp(percent, 0, 1),
        label_left = nil,
        label_right = nil,
        barcolor = Color(255, 255, 255)
    }, Bar)
end

function Bar:setPercent(percent)
    self.percent = math.clamp(percent, 0, 1)
    return self
end

function Bar:setLabelLeft(text)
    self.label_left = text
    return self
end

function Bar:setLabelRight(text)
    self.label_right = text
    return self
end

function Bar:setBarColor(col)
    self.barcolor = col
    return self
end

function Bar:draw(alpha)
    -- Задний фон плашки
    render.setColor(Color(15, 15, 15, alpha * 0.85))
    render.drawRect(self.x, self.y, self.w, self.h)
    
    -- Контур плашки
    render.setColor(Color(255, 255, 255, alpha * 0.15))
    render.drawRectOutline(self.x, self.y, self.w, self.h, 2)
    
    -- Внутренняя полоска прогресса
    local progressCol = Color(self.barcolor.r, self.barcolor.g, self.barcolor.b, alpha)
    render.setColor(progressCol)
    render.drawRect(self.x + 4, self.y + 4, (self.w - 8) * self.percent, self.h - 8)
    
    -- Отрисовка текста уведомлений
    render.setFont(fontMontserrat50)
    if self.label_left then
        render.setColor(Color(180, 255, 0, alpha))
        render.drawText(self.x + 15, self.y + 8, self.label_left, 0)
    end
    if self.label_right then
        render.setColor(Color(255, 255, 255, alpha * 0.9))
        render.drawText(self.x + 15, self.y + 42, self.label_right, 0)
    end
end

setmetatable(Bar, {__call = Bar.new})

-- Логика появления плашки
local notifyActive = false
local notifyEndTime = 0
local notifyAlpha = 0
local voughtBar = nil

net.receive("vought_ui_notify", function()
    notifyEndTime = timer.curtime() + 8 -- Показываем ровно 8 секунд
    notifyActive = true
    notifyAlpha = 0
end)

-- ИСПРАВЛЕНО: Используем хук DrawHUD, чтобы гарантированно рисовалось на экране игрока
hook.add("DrawHUD", "VoughtNotificationHUD", function()
    if not notifyActive then return end
    
    local time = timer.curtime()
    if time > notifyEndTime and notifyAlpha <= 0 then
        notifyActive = false
        return
    end
    
    -- Рассчитываем плавное появление и исчезновение альфы
    if time < notifyEndTime then
        notifyAlpha = math.approach(notifyAlpha, 255, render.getFrameTime() * 500)
    else
        notifyAlpha = math.approach(notifyAlpha, 0, render.getFrameTime() * 250)
    end
    
    local w, h = render.getGameResolution()
    local barW, barH = 680, 85
    local x = (w - barW) / 2
    local y = h - barH - 120 -- Позиция внизу экрана, чуть выше чата/основного худа
    
    -- Инициализируем объект Бара один раз (как в astro.txt)
    if not voughtBar then
        voughtBar = Bar:new(x, y, barW, barH, 1)
            :setLabelLeft("СЫВОРОТКА V1 ВВЕДЕНА")
            :setLabelRight("Вы получили лазерный взгляд! Управление: зажмите ЛКМ + ПКМ.")
            :setBarColor(Color(180, 255, 0))
    end
    
    -- Динамически рассчитываем полоску времени действия плашки
    local timeLeft = math.max(0, notifyEndTime - time)
    local progress = timeLeft / 8
    
    -- Двигаем позицию, если разрешение экрана изменилось
    voughtBar.x = x
    voughtBar.y = y
    
    -- Рисуем
    voughtBar:setPercent(progress)
        :draw(notifyAlpha)
end)
