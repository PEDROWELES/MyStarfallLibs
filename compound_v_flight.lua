--@name Compound V Flight
--@author OpenAI
--@shared

local CompoundVFlight = {}
CompoundVFlight.__index = CompoundVFlight

function CompoundVFlight:new()
    return setmetatable({
        hoverMode = true,
        lastJump = 0,
        jumpHeld = false
    }, CompoundVFlight)
end

function CompoundVFlight:reset()
    self.hoverMode = true
    self.lastJump = 0
    self.jumpHeld = false
end

function CompoundVFlight:getHoverMode()
    return self.hoverMode
end

function CompoundVFlight:update(ply)
    if not isValid(ply) or ply:isNoclipped() then
        return {
            active = false,
            hoverMode = self.hoverMode,
            toggled = false
        }
    end

    local vel = ply:getVelocity()
    local jump = ply:keyDown(IN_KEY.JUMP)
    local toggled = false

    if jump and not self.jumpHeld then
        local now = timer.systime()
        if now - self.lastJump < 0.35 then
            self.hoverMode = not self.hoverMode
            toggled = true
        end
        self.lastJump = now
    end

    self.jumpHeld = jump

    if jump then
        local forward = ply:getEyeAngles():getForward()
        forward.z = 0
        ply:setVelocity(Vector(0, 0, 25) + forward * 10)
    elseif self.hoverMode then
        local hoverForce = -vel.z * 0.75 * 2.1
        ply:setVelocity(Vector(-vel.x * 0.20, -vel.y * 0.20, hoverForce))
    end

    return {
        active = true,
        hoverMode = self.hoverMode,
        toggled = toggled
    }
end

return setmetatable(CompoundVFlight, {
    __call = function(_, ...)
        return CompoundVFlight:new(...)
    end
})
