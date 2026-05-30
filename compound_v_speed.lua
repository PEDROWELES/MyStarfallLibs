--@name Compound V Speed v2 - Wind Sound Fix
--@author OpenAI
--@shared
--@include https://raw.githubusercontent.com/AstricUnion/Libs/refs/heads/main/sounds.lua as sounds

local CompoundVSpeed = {}
CompoundVSpeed.__index = CompoundVSpeed

function CompoundVSpeed:new(baseSpeed, sprintMultiplier)
    return setmetatable({
        baseSpeed = baseSpeed or 1200,
        sprintMultiplier = sprintMultiplier or 2.5,
        trailMain = nil,
        trailLightning = nil,
        trailColor = Color(0, 150, 255),
        lightningColor = Color(120, 220, 255),
        nextWind = 0,
        windSound = nil
    }, CompoundVSpeed)
end

function CompoundVSpeed:setTrailColor(color)
    self.trailColor = color or Color(0, 150, 255)
end

function CompoundVSpeed:setLightningColor(color)
    self.lightningColor = color or Color(120, 220, 255)
end

function CompoundVSpeed:createTrails(ply)
    if not isValid(ply) then return end

    if not isValid(self.trailMain) then
        self.trailMain = hologram.create(
            ply:getPos(),
            Angle(),
            "models/hunter/misc/sphere025x025.mdl",
            Vector(0.01)
        )

        if isValid(self.trailMain) then
            self.trailMain:setParent(ply)
            self.trailMain:setLocalPos(Vector(0, 0, 45))
            self.trailMain:setColor(Color(self.trailColor.r, self.trailColor.g, self.trailColor.b, 0))
            self.trailMain:suppressEngineLighting(true)
        end
    end

    if not isValid(self.trailLightning) then
        self.trailLightning = hologram.create(
            ply:getPos(),
            Angle(),
            "models/hunter/misc/sphere025x025.mdl",
            Vector(0.01)
        )

        if isValid(self.trailLightning) then
            self.trailLightning:setParent(ply)
            self.trailLightning:setLocalPos(Vector(0, 0, 45))
            self.trailLightning:setColor(Color(255, 255, 255, 0))
            self.trailLightning:suppressEngineLighting(true)
        end
    end
end

function CompoundVSpeed:stopTrailVisual()
    if isValid(self.trailMain) then
        self.trailMain:setTrails(0, 0, 0, "", Color(0, 0, 0, 0))
    end

    if isValid(self.trailLightning) then
        self.trailLightning:setTrails(0, 0, 0, "", Color(0, 0, 0, 0))
    end
end

function CompoundVSpeed:removeTrails()
    self:stopTrailVisual()

    if isValid(self.trailMain) then
        self.trailMain:remove()
    end

    if isValid(self.trailLightning) then
        self.trailLightning:remove()
    end

    self.trailMain = nil
    self.trailLightning = nil
end

function CompoundVSpeed:stopWind()
    if self.windSound then
        self.windSound:stop()
        self.windSound = nil
    end
end

function CompoundVSpeed:playWind(ply)
    if not isValid(ply) then return end

    self:stopWind()
    self.windSound = sounds.create(ply, "ambient/wind/wind_hit" .. math.random(1, 3) .. ".wav")
    if self.windSound then
        self.windSound:play()
    end
end

function CompoundVSpeed:reset()
    self.nextWind = 0
    self:removeTrails()
    self:stopWind()
end

function CompoundVSpeed:update(ply)
    if not isValid(ply) or ply:isNoclipped() then
        self:stopTrailVisual()
        return {
            active = false,
            moving = false,
            speed = 0
        }
    end

    local eye = ply:getEyeAngles()
    local forward = eye:getForward()
    local right = eye:getRight()
    local move = Vector()

    if ply:keyDown(IN_KEY.FORWARD) then
        move = move + forward
    end

    if ply:keyDown(IN_KEY.BACK) then
        move = move - forward
    end

    if ply:keyDown(IN_KEY.MOVELEFT) then
        move = move - right
    end

    if ply:keyDown(IN_KEY.MOVERIGHT) then
        move = move + right
    end

    move.z = 0

    if move:getLength() <= 0 then
        self:stopTrailVisual()
        return {
            active = true,
            moving = false,
            speed = 0
        }
    end

    move = move:getNormalized()

    local targetSpeed = self.baseSpeed
    if ply:keyDown(IN_KEY.SPEED) then
        targetSpeed = targetSpeed * self.sprintMultiplier
    end

    local desired = move * targetSpeed
    local currentVelocity = ply:getVelocity()
    local push = desired - Vector(currentVelocity.x, currentVelocity.y, 0)
    ply:setVelocity(push)

    self:createTrails(ply)

    if isValid(self.trailMain) then
        self.trailMain:setTrails(350, 0, 28, "trails/laser", self.trailColor)
    end

    if isValid(self.trailLightning) then
        self.trailLightning:setTrails(35, 0, 10, "trails/electric", self.lightningColor)
    end

    if timer.curtime() >= self.nextWind then
        self:playWind(ply)
        self.nextWind = timer.curtime() + 0.7
    end

    return {
        active = true,
        moving = true,
        speed = targetSpeed
    }
end

return setmetatable(CompoundVSpeed, {
    __call = function(_, ...)
        return CompoundVSpeed:new(...)
    end
})
