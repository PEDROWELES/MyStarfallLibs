--@name Eye Laser UI
--@author OpenAI
--@client

local fontTitle = render.createFont(
    "Montserrat",
    30,
    700,
    true,
    false,
    false,
    false,
    0,
    true,
    0
)

local fontBody = render.createFont(
    "Montserrat",
    22,
    500,
    true,
    false,
    false,
    false,
    0,
    true,
    0
)

local EyeLaserUI = {
    active = false,
    expiresAt = 0,
    title = "COMPOUND V ACTIVE",
    lines = {
        "Eye lasers unlocked",
        "Hold LMB + RMB to fire"
    }
}

function EyeLaserUI:show(duration, title, lines)
    self.active = true
    self.expiresAt = duration and duration > 0 and (timer.curtime() + duration) or 0
    self.title = title or "COMPOUND V ACTIVE"
    self.lines = lines or {
        "Eye lasers unlocked",
        "Hold LMB + RMB to fire"
    }
end

function EyeLaserUI:hide()
    self.active = false
    self.expiresAt = 0
end

hook.add("DrawHUD", "EyeLaserInstructionsHUD", function()
    if not EyeLaserUI.active then return end

    if EyeLaserUI.expiresAt > 0 and timer.curtime() >= EyeLaserUI.expiresAt then
        EyeLaserUI:hide()
        return
    end

    local w, h = render.getGameResolution()
    local panelW, panelH = 560, 96
    local x = math.floor((w - panelW) * 0.5)
    local y = math.floor(h * 0.84)

    render.setColor(Color(0, 0, 0, 170))
    render.drawRect(x, y, panelW, panelH)

    render.setColor(Color(180, 255, 0, 255))
    render.drawRect(x, y, panelW, 4)

    render.setColor(Color(255, 255, 255, 25))
    render.drawRect(x + 12, y + 44, panelW - 24, 1)

    render.setColor(Color(200, 255, 120))
    render.setFont(fontTitle)
    render.drawSimpleText(w / 2, y + 10, EyeLaserUI.title, 1)

    render.setColor(Color(255, 255, 255))
    render.setFont(fontBody)
    render.drawSimpleText(w / 2, y + 50, EyeLaserUI.lines[1] or "", 1)
    render.drawSimpleText(w / 2, y + 72, EyeLaserUI.lines[2] or "", 1)
end)

return EyeLaserUI
