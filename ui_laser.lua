--@name Eye Laser UI v2 - Toast API
--@author OpenAI
--@client

local fontTitle = render.createFont("Montserrat", 28, 700, true)
local fontBody = render.createFont("Montserrat", 20, 500, true)
local fontSmall = render.createFont("Montserrat", 17, 500, true)

local EyeLaserUI = {
    powers = {},
    toasts = {}
}

local function cloneRows(rows)
    local result = {}
    for index, row in ipairs(rows or {}) do
        result[index] = {
            label = row.label or "",
            detail = row.detail or "",
            color = row.color or Color(180, 255, 0)
        }
    end
    return result
end

function EyeLaserUI:setPowers(rows)
    self.powers = cloneRows(rows)
end

function EyeLaserUI:clearPowers()
    self.powers = {}
end

function EyeLaserUI:pushToast(title, message, color, duration)
    table.insert(self.toasts, 1, {
        title = title or "COMPOUND V",
        message = message or "",
        color = color or Color(180, 255, 0),
        expire = timer.curtime() + (duration or 6)
    })

    while #self.toasts > 4 do
        table.remove(self.toasts)
    end
end

function EyeLaserUI:clearToasts()
    self.toasts = {}
end

local function drawPowerPanel()
    if #EyeLaserUI.powers == 0 then return end

    local w, h = render.getGameResolution()
    local panelW = 720
    local rowH = 30
    local panelH = 54 + (#EyeLaserUI.powers * rowH)
    local x = math.floor((w - panelW) * 0.5)
    local y = math.floor(h * 0.77)

    render.setColor(Color(0, 0, 0, 170))
    render.drawRect(x, y, panelW, panelH)

    render.setColor(Color(180, 255, 0, 255))
    render.drawRect(x, y, panelW, 4)

    render.setColor(Color(200, 255, 120))
    render.setFont(fontTitle)
    render.drawSimpleText(w * 0.5, y + 10, "COMPOUND V ACTIVE", 1)

    render.setFont(fontBody)
    for index, row in ipairs(EyeLaserUI.powers) do
        local rowY = y + 42 + ((index - 1) * rowH)
        render.setColor(Color(255, 255, 255, 20))
        render.drawRect(x + 16, rowY + 23, panelW - 32, 1)

        render.setColor(row.color)
        render.drawText(x + 24, rowY, row.label)

        render.setColor(Color(255, 255, 255))
        render.drawText(x + 220, rowY, row.detail)
    end
end

local function drawToasts()
    local now = timer.curtime()
    for index = #EyeLaserUI.toasts, 1, -1 do
        if EyeLaserUI.toasts[index].expire <= now then
            table.remove(EyeLaserUI.toasts, index)
        end
    end

    if #EyeLaserUI.toasts == 0 then return end

    local w = render.getGameResolution()
    render.setFont(fontBody)

    for index, toast in ipairs(EyeLaserUI.toasts) do
        local timeLeft = math.max(toast.expire - now, 0)
        local alpha = math.floor(math.min(timeLeft, 1) * 230)
        local y = 70 + ((index - 1) * 64)

        render.setColor(Color(0, 0, 0, math.floor(alpha * 0.75)))
        render.drawRect((w * 0.5) - 300, y, 600, 54)

        render.setColor(Color(toast.color.r, toast.color.g, toast.color.b, alpha))
        render.drawRect((w * 0.5) - 300, y, 600, 3)

        render.setColor(Color(toast.color.r, toast.color.g, toast.color.b, alpha))
        render.setFont(fontBody)
        render.drawSimpleText(w * 0.5, y + 7, toast.title, 1)

        render.setColor(Color(255, 255, 255, alpha))
        render.setFont(fontSmall)
        render.drawSimpleText(w * 0.5, y + 30, toast.message, 1)
    end
end

hook.add("DrawHUD", "EyeLaserPowerHUD", function()
    drawToasts()
    drawPowerPanel()
end)

return EyeLaserUI
