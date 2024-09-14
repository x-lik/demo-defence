-- 事件反应
---@param u Unit
local function _z(u, offset)
    return u:h() + 130 + offset
end

---@param evtData evtOnUnitCritData
event.reactRegister(eventKind.unitCrit, function(evtData)
    effector.attach(evtData.targetUnit, "lik_crit", "origin", 0.5)
end)
---@param evtData evtOnUnitCritAbilityData
event.reactRegister(eventKind.unitCritAbility, function(evtData)
    effector.attach(evtData.targetUnit, "lik_crit_ability", "origin", 0.5)
    mtg.model({
        model = "lik_ttg_crit",
        size = 1.4,
        x = evtData.targetUnit:x(),
        y = evtData.targetUnit:y(),
        z = _z(evtData.targetUnit, -24),
        height = 50,
        speed = 0.5,
        duration = 0.8,
    })
end)
---@param evtData evtOnUnitAvoidData
event.reactRegister(eventKind.unitAvoid, function(evtData)
    effector.attach(evtData.triggerUnit, "lik_ttg_avoid", "overhead", 0.3)
end)
---@param evtData evtOnUnitImmuneInvincibleData
event.reactRegister(eventKind.unitImmuneInvincible, function(evtData)
    effector.attach(evtData.triggerUnit, "DivineShieldTarget", "origin", 1)
    mtg.model({
        model = "lik_ttg_immune_invincible",
        size = 1.2,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData evtOnUnitImmuneDefendData
event.reactRegister(eventKind.unitImmuneDefend, function(evtData)
    mtg.model({
        model = "lik_ttg_immune_damage",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData evtOnUnitImmuneReductionData
event.reactRegister(eventKind.unitImmuneReduction, function(evtData)
    mtg.model({
        model = "lik_ttg_immune_damage",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData evtOnUnitImmuneEnchantData
event.reactRegister(eventKind.unitImmuneEnchant, function(evtData)
    mtg.model({
        model = "lik_ttg_immune_enchant",
        size = 0.7,
        x = evtData.triggerUnit:x(),
        y = evtData.triggerUnit:y(),
        z = _z(evtData.triggerUnit, -44),
        height = 100,
        duration = 1,
    })
end)
---@param evtData evtOnUnitHPSuckAttackData
event.reactRegister(eventKind.unitHPSuckAttack, function(evtData)
    effector.attach(evtData.triggerUnit, "HealTarget2", "origin", 0.5)
end)
---@param evtData evtOnUnitHPSuckAbilityData
event.reactRegister(eventKind.unitHPSuckAbility, function(evtData)
    effector.attach(evtData.triggerUnit, "HealTarget2", "origin", 0.5)
end)
---@param evtData evtOnUnitMPSuckAttackData
event.reactRegister(eventKind.unitMPSuckAttack, function(evtData)
    effector.attach(evtData.triggerUnit, "AImaTarget", "origin", 0.5)
end)
---@param evtData evtOnUnitMPSuckAbilityData
event.reactRegister(eventKind.unitMPSuckAbility, function(evtData)
    effector.attach(evtData.triggerUnit, "AImaTarget", "origin", 0.5)
end)
---@param evtData evtOnUnitBeStunData
event.reactRegister(eventKind.unitBeStun, function(evtData)
    effector.attach(evtData.triggerUnit, "ThunderclapTarget", "overhead", evtData.duration)
end)
---@param evtData evtOnUnitBeSplitData
event.reactRegister(eventKind.unitBeSplit, function(evtData)
    effector.unit("SpellBreakerAttack", evtData.triggerUnit, 0)
end)
---@param evtData evtOnUnitBeSplitSpreadData
event.reactRegister(eventKind.unitBeSplitSpread, function(evtData)
    effector.unit("CleaveDamageTarget", evtData.triggerUnit, 0)
end)
---@param evtData evtOnUnitBeShieldData
event.reactRegister(eventKind.unitBeShield, function(evtData)
    local u = evtData.triggerUnit
    mtg.word({
        style = "default",
        str = math.format(evtData.value, 0),
        width = 7.5,
        size = 0.45,
        x = u:x(),
        y = u:y(),
        z = _z(u, 0),
        height = 150,
        duration = 0.6,
    })
end)
---@param evtData evtOnUnitHurtData
event.reactRegister(eventKind.unitHurt, function(evtData)
    local str = math.format(evtData.damage, 0)
    local height = -50
    if (true == evtData.crit) then
        str = 'C' .. str
        height = 300
    end
    local u = evtData.triggerUnit
    mtg.word({
        style = "default",
        str = str,
        width = 12,
        size = 0.7,
        x = u:x(),
        y = u:y(),
        z = _z(u, 0),
        height = height,
        duration = 0.7,
    })
end)
---@param evtData evtOnUnitEnchantData
event.reactRegister(eventKind.unitEnchant, function(evtData)
    local m = {
        [injury.damageType.fire.value] = "lik_ttg_e_fire",
        [injury.damageType.water.value] = "lik_ttg_e_water",
        [injury.damageType.ice.value] = "lik_ttg_e_ice",
        [injury.damageType.rock.value] = "lik_ttg_e_rock",
        [injury.damageType.wind.value] = "lik_ttg_e_wind",
        [injury.damageType.light.value] = "lik_ttg_e_light",
        [injury.damageType.dark.value] = "lik_ttg_e_dark",
        [injury.damageType.grass.value] = "lik_ttg_e_grass",
        [injury.damageType.thunder.value] = "lik_ttg_e_thunder",
        [injury.damageType.poison.value] = "lik_ttg_e_poison",
        [injury.damageType.steel.value] = "lik_ttg_e_steel",
    }
    if (nil ~= m[evtData.enchantType.value]) then
        local u = evtData.triggerUnit
        mtg.model({
            model = m[evtData.enchantType.value],
            size = 1.2,
            x = u:x() - math.rand(30, -30),
            y = u:y(),
            z = _z(u, -u:stature() * 2),
            height = 160,
            speed = 0.4,
            duration = 1,
        })
    end
end)