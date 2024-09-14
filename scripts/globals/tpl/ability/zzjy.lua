---@param hurtData evtOnUnitHurtData
---@param effectiveData evtOnAbilityEffectiveData
TPL_ABILITY.ZZJY = AbilityTpl()
    :name("自在极意被动")
    :targetType(ability.targetType.pas)
    :icon(X_UI_BLACK)
    :coolDownAdv(10, 0)
    :mpCostAdv(100, 0)
    :levelMax(10)
    :levelUpNeedPoint(2)
    :onUnitEvent(eventKind.unitHurt, function(hurtData) hurtData.triggerAbility:spell() end)
    :onEvent(eventKind.abilityEffective,
    function(effectiveData)
        -- 技能被触发的效果
        local tu = effectiveData.triggerUnit
        Buff({
            key = "自在极意被动",
            object = tu,
            icon = "ability/IncendiaryBonds",
            description = "轻松躲躲躲",
            duration = 3,
            ---@param buffObj Unit
            purpose = function(buffObj)
                effector.attach(buffObj, "DivineShieldTarget", "origin", -1)
                buffObj:hurtReduction("+=100"):hurtRebound("+=100"):odds("hurtRebound", "+=100")
            end,
            ---@param buffObj Unit
            rollback = function(buffObj)
                effector.detach(buffObj, "DivineShieldTarget")
                buffObj:hurtReduction("-=100"):hurtRebound("-=100"):odds("hurtRebound", "-=100")
            end,
        })
    end)