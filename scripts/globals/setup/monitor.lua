--- 恢复生命监听器
---@param obj Unit
monitor.create(
    "hp_regen",
    0.2,
    function(obj)
        local regen = 0.2 * obj:hpRegen()
        local cure = obj:cure() * 0.01
        local v = 0
        if (regen >= 0) then
            v = math.max(0, 1 + cure) * regen
            obj:hpCur("+=" .. v)
        else
            v = math.min(0, cure - 1) * regen
            obj:hpCur("-=" .. v)
        end
    end,
    function(obj)
        return obj:isDead() or nil == obj:hpRegen() or 0 == obj:hpRegen()
    end)

--- 恢复魔法监听器
---@param obj Unit
monitor.create(
    "mp_regen",
    0.3,
    function(obj)
        local regen = 0.3 * obj:mpRegen()
        local cure = obj:cure() * 0.01
        local v = 0
        if (regen >= 0) then
            v = math.max(0, 1 + cure) * regen
            obj:mpCur("+=" .. v)
        else
            v = math.min(0, cure - 1) * regen
            obj:mpCur("-=" .. v)
        end
    end,
    function(obj)
        return obj:isDead() or nil == obj:mpRegen() or 0 == obj:mpRegen()
    end)