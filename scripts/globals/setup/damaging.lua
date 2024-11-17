local damageFlow = Flow("damage")

--- 伤害为0中止
damageFlow:abort(function(data)
    return data.damage <= 0
end)

--- 提取一些需要的参数
damageFlow:flux("prop", function(data)
    data.defend = data.targetUnit:get("defend") or 0
    data.avoid = data.targetUnit:get("avoid") or 0
    if (class.isObject(data.sourceUnit, UnitClass)) then
        data.avoid = data.avoid - (data.sourceUnit:get("aim") or 0)
    end
end)

--- 判断无视装甲类型
damageFlow:flux("breakArmor", function(data)
    local ignore = { defend = false, avoid = false, invincible = false }
    if (#data.breakArmor > 0) then
        for _, b in ipairs(data.breakArmor) do
            if (nil ~= b) then
                ignore[b.value] = true
                --- 触发无视防御事件
                event.syncTrigger(data.sourceUnit, eventKind.unitBreakArmor, { targetUnit = data.targetUnit, breakArmorType = b })
                --- 触发被破防事件
                event.syncTrigger(data.targetUnit, eventKind.unitBeBreakArmor, { breakUnit = data.sourceUnit, breakArmorType = b })
            end
        end
    end
    --- 处理防御
    if (ignore.defend == true and data.defend > 0) then
        data.defend = 0
    end
    --- 处理回避
    if (ignore.avoid == true and data.avoid > 0) then
        data.avoid = 0
    end
    --- 单位是否无视无敌
    if (true == data.targetUnit:isInvulnerable()) then
        if (ignore.invincible == false) then
            --- 触发无敌抵御事件
            data.damage = 0
            event.syncTrigger(data.targetUnit, eventKind.unitImmuneInvincible, { sourceUnit = data.sourceUnit })
            return
        end
    end
end)

--- 伤害加深(%)
---@param data {sourceUnit:Unit}
damageFlow:flux("damageIncrease", function(data)
    local approve = (data.sourceUnit ~= nil)
    if (approve) then
        local damageIncrease = data.sourceUnit:get("damageIncrease") or 0
        if (damageIncrease > 0) then
            data.damage = data.damage * (1 + damageIncrease * 0.01)
        end
    end
end)

--- 护盾
---@param data {targetUnit:Unit}
damageFlow:flux("shield", function(data)
    local sh = data.targetUnit:get("shieldCur") or 0
    if (sh > 0) then
        local sd = 0
        if (sh >= data.damage) then
            sd = data.damage
            data.damage = 0
        else
            sd = sh
            data.damage = data.damage - sh
        end
        if (sd > 0) then
            data.targetUnit:shieldCur("-=" .. sd)
            event.syncTrigger(data.targetUnit, eventKind.unitBeShield, { sourceUnit = data.sourceUnit, value = sd })
            event.syncTrigger(data.sourceUnit, eventKind.unitShield, { targetUnit = data.targetUnit, value = sd })
        end
    end
end)

--- 受伤加深(%)
---@param data {targetUnit:Unit}
damageFlow:flux("hurtIncrease", function(data)
    local hurtIncrease = data.targetUnit:get("hurtIncrease") or 0
    if (hurtIncrease > 0) then
        data.damage = data.damage * (1 + hurtIncrease * 0.01)
    end
end)

--- 自身暴击
---@param data {sourceUnit:Unit}
damageFlow:flux("crit", function(data)
    local approve = (data.sourceUnit ~= nil and (data.damageSrc == injury.damageSrc.attack))
    if (approve) then
        local crit = data.sourceUnit:get("crit") or 0
        if (crit > 0) then
            local odds = data.sourceUnit:odds("crit") - data.targetUnit:resistance("crit")
            if (odds > math.rand(1, 100)) then
                data.damage = data.damage * (1 + crit * 0.01)
                --- 触发时自动无视回避
                data.avoid = 0
                --- 触发本体暴击
                data.crit = true
                event.syncTrigger(data.sourceUnit, eventKind.unitCrit, { targetUnit = data.targetUnit })
                event.syncTrigger(data.targetUnit, eventKind.unitBeCrit, { sourceUnit = data.sourceUnit })
            end
        end
    end
end)

--- 回避
damageFlow:flux("avoid", function(data)
    local approve = (data.avoid > 0 and (data.damageSrc == injury.damageSrc.attack or data.damageSrc == injury.damageSrc.rebound))
    if (approve) then
        if (data.avoid > math.rand(1, 100)) then
            -- 触发回避事件
            data.damage = 0
            event.syncTrigger(data.targetUnit, eventKind.unitAvoid, { sourceUnit = data.sourceUnit })
            event.syncTrigger(data.sourceUnit, eventKind.unitBeAvoid, { targetUnit = data.targetUnit })
            return
        end
    end
end)

--- 自身攻击眩晕
---@param data {sourceUnit:Unit}
damageFlow:flux("stun", function(data)
    local approve = (data.sourceUnit ~= nil and (data.damageSrc == injury.damageSrc.attack))
    if (approve) then
        local stun = data.sourceUnit:get("stun") or 0
        if (stun > 0) then
            --- 触发眩晕
            ability.stun({ sourceUnit = data.sourceUnit, targetUnit = data.targetUnit, duration = stun, odds = data.sourceUnit:odds("stun") })
        end
    end
end)

--- 反伤(%)
---@param data {sourceUnit:Unit,targetUnit:Unit}
damageFlow:flux("hurtRebound", function(data)
    -- 抵抗
    local approve = (data.sourceUnit ~= nil and data.damageSrc == injury.damageSrc.rebound)
    if (approve) then
        local resistance = data.sourceUnit:resistance("hurtRebound")
        if (resistance > 0) then
            data.damage = math.max(0, data.damage * (1 - resistance * 0.01))
            if (data.damage < 1) then
                data.damage = 0
                return
            end
        end
    end
    -- 反射
    approve = (data.sourceUnit ~= nil and (data.damageSrc == injury.damageSrc.attack or data.damageSrc == injury.damageSrc.ability))
    if (approve) then
        local hurtRebound = data.targetUnit:get("hurtRebound") or 0
        local odds = data.targetUnit:odds("hurtRebound")
        if (hurtRebound > 0 and odds > math.rand(1, 100)) then
            local dmgRebound = math.trunc(data.damage * hurtRebound * 0.01, 3)
            if (dmgRebound >= 1.000) then
                local damagedArrived = function()
                    --- 触发反伤事件
                    ability.damage({
                        sourceUnit = data.targetUnit,
                        targetUnit = data.sourceUnit,
                        damage = dmgRebound,
                        damageSrc = injury.damageSrc.rebound,
                        damageType = data.damageType,
                        damageTypeLevel = 0,
                    })
                end
                if (data.damageSrc == injury.damageSrc.attack) then
                    -- 攻击情况
                    local as = data.sourceUnit:assault()
                    local mode = as:mode()
                    if (mode == "instant") then
                        damagedArrived()
                    elseif (mode == "lightning") then
                        local lDur = 0.3
                        local lDelay = lDur * 0.6
                        lightning.create(
                            as:model(),
                            data.targetUnit:x(), data.targetUnit:y(), data.targetUnit:h(),
                            data.sourceUnit:x(), data.sourceUnit:y(), data.sourceUnit:h(),
                            lDur
                        )
                        time.setTimeout(lDelay, damagedArrived)
                    elseif (mode == "missile") then
                        ability.missile({
                            model = as:model(),
                            sourceUnit = data.targetUnit,
                            targetUnit = data.sourceUnit,
                            speed = as:speed(),
                            height = as:height() / 4,
                            acceleration = as:acceleration(),
                            onEnd = damagedArrived,
                        })
                    end
                elseif (data.damageSrc == injury.damageSrc.ability) then
                    -- 技能情况
                    damagedArrived()
                end
            end
        end
    end
end)

--- 防御
damageFlow:flux("defend", function(data)
    if (data.defend < 0) then
        data.damage = data.damage + math.abs(data.defend)
    elseif (data.defend > 0) then
        data.damage = data.damage - data.defend
        if (data.damage < 1) then
            -- 触发防御完全抵消事件
            data.damage = 0
            event.syncTrigger(data.targetUnit, eventKind.unitImmuneDefend, { sourceUnit = data.sourceUnit })
            return
        end
    end
end)

--- 减伤(%)
---@param data {targetUnit:Unit}
damageFlow:flux("hurtReduction", function(data)
    local hurtReduction = data.targetUnit:get("hurtReduction") or 0
    if (hurtReduction > 0) then
        data.damage = data.damage * (1 - hurtReduction * 0.01)
        if (data.damage < 1) then
            -- 触发减伤完全抵消事件
            data.damage = 0
            event.syncTrigger(data.targetUnit, eventKind.unitImmuneReduction, { sourceUnit = data.sourceUnit })
            return
        end
    end
end)

--- 攻击吸血
---@param data {sourceUnit:Unit}
damageFlow:flux("hpSuckAttack", function(data)
    local approve = (data.sourceUnit ~= nil and data.damageSrc == injury.damageSrc.attack)
    if (approve) then
        local percent = (data.sourceUnit:get("hpSuckAttack") or 0) - data.targetUnit:resistance("hpSuckAttack")
        local val = data.damage * percent * 0.01
        if (percent > 0 and val > 0) then
            data.sourceUnit:hpCur("+=" .. val)
            --- 触发吸血事件
            event.syncTrigger(data.sourceUnit, eventKind.unitHPSuckAttack, { targetUnit = data.targetUnit, value = val, percent = percent })
            event.syncTrigger(data.targetUnit, eventKind.unitBeHPSuckAttack, { sourceUnit = data.sourceUnit, value = val, percent = percent })
        end
    end
end)

--- 技能吸血
---@param data {sourceUnit:Unit}
damageFlow:flux("hpSuckAbility", function(data)
    local approve = (data.sourceUnit ~= nil and data.damageSrc == injury.damageSrc.ability)
    if (approve) then
        local percent = (data.sourceUnit:get("hpSuckAbility") or 0) - data.targetUnit:resistance("hpSuckAbility")
        local val = data.damage * percent * 0.01
        if (percent > 0 and val > 0) then
            data.sourceUnit:hpCur("+=" .. val)
            --- 触发技能吸血事件
            event.syncTrigger(data.sourceUnit, eventKind.unitHPSuckAbility, { targetUnit = data.targetUnit, value = val, percent = percent })
            event.syncTrigger(data.targetUnit, eventKind.unitBeHPSuckAbility, { sourceUnit = data.sourceUnit, value = val, percent = percent })
        end
    end
end)

--- 攻击吸魔;吸魔会根据伤害，扣减目标的魔法值，再据百分比增加自己的魔法值;目标魔法值不足 1 从而吸收时，则无法吸取
---@param data {sourceUnit:Unit}
damageFlow:flux("mpSuckAttack", function(data)
    local approve = (data.sourceUnit ~= nil and data.damageSrc == injury.damageSrc.attack and data.sourceUnit:mp() > 0 and data.targetUnit:mpCur() > 0)
    if (approve) then
        local percent = (data.sourceUnit:get("mpSuckAttack") or 0) - data.targetUnit:resistance("mpSuckAttack")
        if (percent > 0) then
            local mana = math.min(data.targetUnit:mp(), data.damage)
            local val = mana * percent * 0.01
            if (val > 1) then
                data.targetUnit:mpCur("-=" .. val)
                data.sourceUnit:mpCur("+=" .. val)
                --- 触发吸魔事件
                event.syncTrigger(data.sourceUnit, eventKind.unitMPSuckAttack, { targetUnit = data.targetUnit, value = val, percent = percent })
                event.syncTrigger(data.targetUnit, eventKind.unitBeMPSuckAttack, { sourceUnit = data.sourceUnit, value = val, percent = percent })
            end
        end
    end
end)

--- 技能吸魔;吸魔会根据伤害，扣减目标的魔法值，再据百分比增加自己的魔法值;目标魔法值不足 1 从而吸收时，则无法吸取
---@param data {sourceUnit:Unit}
damageFlow:flux("mpSuckAbility", function(data)
    local approve = (data.sourceUnit ~= nil and data.damageSrc == injury.damageSrc.ability and data.sourceUnit:mp() > 0 and data.targetUnit:mpCur() > 0)
    if (approve) then
        local percent = (data.sourceUnit:get("mpSuckAbility") or 0) - data.targetUnit:resistance("mpSuckAbility")
        if (percent > 0) then
            local mana = math.min(data.targetUnit:mp(), data.damage)
            local val = mana * percent * 0.01
            if (val > 1) then
                data.targetUnit:mpCur("-=" .. val)
                data.sourceUnit:mpCur("+=" .. val)
                --- 触发技能吸魔事件
                event.syncTrigger(data.sourceUnit, eventKind.unitMPSuckAbility, { targetUnit = data.targetUnit, value = val, percent = percent })
                event.syncTrigger(data.targetUnit, eventKind.unitBeMPSuckAbility, { sourceUnit = data.sourceUnit, value = val, percent = percent })
            end
        end
    end
end)

--- 附魔加成|抵抗|精通|附着|免疫
---@param data {targetUnit:Unit,sourceUnit:Unit}
damageFlow:flux("enchant", function(data)
    local percent = 0
    if (data.sourceUnit ~= nil) then
        local amplify = data.sourceUnit:enchantStrengthen(data.damageType.value)
        if (amplify ~= 0) then
            percent = percent + amplify
        end
    end
    local resistance = data.targetUnit:enchantResistance(data.damageType.value)
    if (resistance ~= 0) then
        percent = percent - resistance
    end
    if (data.sourceUnit ~= nil) then
        local mystery = data.sourceUnit:enchantMystery() * 0.01 + 1
        mystery = math.max(0, mystery)
        percent = percent * mystery
    end
    --- 触发附魔事件
    event.syncTrigger(data.targetUnit, eventKind.unitEnchant, { sourceUnit = data.sourceUnit, enchantType = data.damageType, percent = percent })
    if (data.damageType ~= injury.damageType.common) then
        -- 一般设定攻击技能物品来源可触发附魔，禁止反应式伤害再触发
        if (data.damageSrc == injury.damageSrc.attack or data.damageSrc == injury.damageSrc.ability or data.damageSrc == injury.damageSrc.item) then
            data.targetUnit:enchantAppend(data.damageType, data.damageTypeLevel, data.sourceUnit)
        end
    end
    if (data.targetUnit:isEnchantImmune(data.damageType.value)) then
        -- 触发免疫附魔事件
        data.damage = 0
        event.syncTrigger(data.targetUnit, eventKind.unitImmuneEnchant, { sourceUnit = data.sourceUnit, enchantType = data.damageType })
    else
        data.damage = data.damage * (100 + percent) * 0.01
    end
end)