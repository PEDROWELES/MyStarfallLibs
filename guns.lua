--@name Projectiles, damage and ETC
--@author AstricUnion (Base)
--@shared

if SERVER then
    local chipOwner = chip():getOwner()
    if isValid(chipOwner) then
        chipOwner:printMessage(3, "[:(] Код отключен на сервере.")
    end
end
