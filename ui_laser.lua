--@name Dingus Cute UI
--@author vertihluy
--@client

local ui = {}

local fontTitle = render.createFont("Consolas", 26, 700, true, false, false, false, 0, true, 0)
local fontBody = render.createFont("Consolas", 18, 500, true, false, false, false, 0, true, 0)
local fontAscii = render.createFont("Consolas", 24, 700, true, false, false, false, 0, true, 0)

local PANEL_BG = Color(22, 10, 18, 180)
local PANEL_BORDER = Color(255, 130, 210, 255)
local PANEL_SOFT = Color(255, 190, 235, 80)
local TEXT_MAIN = Color(255, 210, 240, 255)
local TEXT_DIM = Color(255, 175, 225, 210)
local BAR_FILL = Color(255, 120, 205, 255)
local BAR_READY = Color(255, 185, 235, 255)
local BAR_BG = Color(60, 20, 44, 210)

local abilities = {
    shot = { id = "shot", key = "LMB", label = "dingus", cooldown = 0.9, readyAt = 0 },
    volley = { id = "volley", key = "RMB", label = "swarm", cooldown = 3.2, readyAt = 0 },
    purr = { id = "purr", key = "E", label = "purr", cooldown = 1.8, readyAt = 0 },
    bomb = { id = "bomb", key = "R", label = "maxwell", cooldown = 1.2, readyAt = 0 },
}

local order = { "shot", "volley", "purr", "bomb" }
local enabled = true
local title = "dingus ui"

local asciiCat = {
    " /\\_/\\\\",
    "( =^.^= )",
    " (\")_(\")"
}

local function now()
    return timer.curtime()
end

local function clamp01(value)
    return math.max(0, math.min(1, value))
end

local function getPercent(entry)
    if entry.cooldown <= 0 then return 1 end
    return clamp01(1 - math.max(entry.readyAt - now(), 0) / entry.cooldown)
end

local function getTimeLeft(entry)
    return math.max(entry.readyAt - now(), 0)
end

local function makeBar(percent, width)
    local filled = math.floor(clamp01(percent) * width + 0.5)
    return "[" .. string.rep("#", filled) .. string.rep("-", width - filled) .. "]"
end

local function drawPanel(x, y, w, h)
    render.setColor(PANEL_BG)
    render.drawRect(x, y, w, h)
    render.setColor(PANEL_SOFT)
    render.drawRect(x + 3, y + 3, w - 6, 2)
    render.setColor(PANEL_BORDER)
    render.drawRectOutline(x, y, w, h, 2)
end

local function drawAsciiCat(screenW)
    local sway = math.sin(now() * 1.8) * 8
    local panelW = 244
    local panelH = 112
    local x = screenW - panelW - 26 + sway
    local y = 24

    drawPanel(x, y, panelW, panelH)

    render.setFont(fontTitle)
    render.setColor(TEXT_MAIN)
    render.drawSimpleText(x + 16, y + 10, "== " .. title .. " ==", TEXT_ALIGN.LEFT)

    render.setFont(fontAscii)
    render.drawSimpleText(x + 16, y + 42, asciiCat[1], TEXT_ALIGN.LEFT)
    render.drawSimpleText(x + 16, y + 66, asciiCat[2], TEXT_ALIGN.LEFT)
    render.drawSimpleText(x + 16, y + 90, asciiCat[3], TEXT_ALIGN.LEFT)
end

local function drawCooldowns(screenW, screenH)
    local panelW = 370
    local panelH = 168
    local x = screenW - panelW - 26
    local y = screenH - panelH - 26

    drawPanel(x, y, panelW, panelH)

    render.setFont(fontTitle)
    render.setColor(TEXT_MAIN)
    render.drawSimpleText(x + 16, y + 10, "== cooldowns ==", TEXT_ALIGN.LEFT)

    render.setFont(fontBody)
    for index, id in ipairs(order) do
        local entry = abilities[id]
        local percent = getPercent(entry)
        local bar = makeBar(percent, 16)
        local timeLeft = getTimeLeft(entry)
        local textY = y + 38 + ((index - 1) * 28)
        local rightText = timeLeft > 0 and string.format("%.1fs", timeLeft) or "ready"

        render.setColor(TEXT_DIM)
        render.drawSimpleText(x + 16, textY, entry.key, TEXT_ALIGN.LEFT)

        render.setColor(percent >= 1 and BAR_READY or BAR_FILL)
        render.drawSimpleText(x + 70, textY, bar, TEXT_ALIGN.LEFT)

        render.setColor(TEXT_MAIN)
        render.drawSimpleText(x + 230, textY, entry.label, TEXT_ALIGN.LEFT)
        render.drawSimpleText(x + panelW - 16, textY, rightText, TEXT_ALIGN.RIGHT)
    end
end

function ui.setEnabled(state)
    enabled = state and true or false
end

function ui.setTitle(newTitle)
    title = tostring(newTitle or title)
end

function ui.defineAbility(id, key, label, cooldown)
    if not id then return end
    abilities[id] = abilities[id] or {}
    abilities[id].id = id
    abilities[id].key = key or abilities[id].key or "?"
    abilities[id].label = label or abilities[id].label or id
    abilities[id].cooldown = cooldown or abilities[id].cooldown or 1
    abilities[id].readyAt = abilities[id].readyAt or 0
end

function ui.setCooldown(id, readyAt, cooldown)
    local entry = abilities[id]
    if not entry then return end
    entry.readyAt = readyAt or 0
    if cooldown then
        entry.cooldown = cooldown
    end
end

function ui.use(id, cooldown)
    local entry = abilities[id]
    if not entry then return end
    entry.readyAt = now() + (cooldown or entry.cooldown or 0)
end

function ui.setCooldowns(state)
    if not state then return end
    for id, data in pairs(state) do
        if abilities[id] then
            if data.readyAt then
                abilities[id].readyAt = data.readyAt
            end
            if data.cooldown then
                abilities[id].cooldown = data.cooldown
            end
        end
    end
end

function ui.syncDingus(nextFire, nextSwarm, nextPurr, nextBomb)
    ui.setCooldown("shot", nextFire, abilities.shot.cooldown)
    ui.setCooldown("volley", nextSwarm, abilities.volley.cooldown)
    ui.setCooldown("purr", nextPurr, abilities.purr.cooldown)
    ui.setCooldown("bomb", nextBomb, abilities.bomb.cooldown)
end

hook.add("render", "dingus_cute_ascii_ui", function()
    if not enabled then return end

    local screenW, screenH = render.getGameResolution()
    if not screenW or not screenH then return end

    drawAsciiCat(screenW)
    drawCooldowns(screenW, screenH)
end)

return ui

