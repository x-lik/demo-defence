---@param whichAbility AbilityTpl|Ability
---@return table
function tooltipsAbility(whichAbility, lvOffset)
    if (false == class.instanceof(whichAbility, AbilityTplClass)) then
        return nil
    end
    local types = {
        --{ "worth" },
        { "coolDown", "15DF89", "秒", X_UI_ICON_COOL_DOWN },
        { "hpCost", "DE5D43", "血", X_UI_ICON_HP_COST },
        { "mpCost", "83B3E4", "蓝", X_UI_ICON_MP_COST },
    }
    lvOffset = lvOffset or 0
    local lv = lvOffset + whichAbility:level()
    if (lv > whichAbility:levelMax()) then
        return nil
    end
    local tips
    if (lvOffset > 0) then
        tips = description.combine(whichAbility, { level = lv }, "abilityBase", SYMBOL_D, "attributes", "abilityLvPoint")
    else
        tips = description.combine(whichAbility, nil, "abilityBase", SYMBOL_D, "attributes")
    end
    local content = {
        icons = {},
        bars = {},
        tips = tips,
    }
    for _, c in ipairs(types) do
        local method = c[1]
        if (method == "coolDown" or method == "hpCost" or method == "mpCost") then
            local color = c[2]
            local uit = c[3]
            local val = 0
            if (method == "coolDown") then
                val = whichAbility:coolDown(lv)
            elseif (method == "hpCost") then
                val = whichAbility:hpCost(lv)
            elseif (method == "mpCost") then
                val = whichAbility:mpCost(lv)
            end
            if (val > 0) then
                if (nil ~= uit) then
                    val = val .. " " .. uit
                end
                table.insert(content.icons, {
                    texture = c[4],
                    text = colour.hex(color, val),
                })
            end
        end
    end
    if (class.isObject(whichAbility, AbilityClass)) then
        if (lv == whichAbility:level() and lv < whichAbility:levelMax()) then
            if (whichAbility:exp() > 0) then
                local cur = whichAbility:exp() or 0
                local prev = game.abilityExpNeeds(lv)
                local next = game.abilityExpNeeds(lv + 1)
                local percent = math.trunc((cur - prev) / (next - prev), 3)
                if (nil ~= percent) then
                    table.insert(content.bars, {
                        texture = X_UI_TILE_YELLOW,
                        text = colour.hex("E2C306", "经验：" .. math.floor(cur - prev) .. "/" .. math.ceil(next - prev)),
                        ratio = percent,
                        width = 0.10,
                        height = 0.001,
                    })
                end
            end
        end
    end
    return content
end