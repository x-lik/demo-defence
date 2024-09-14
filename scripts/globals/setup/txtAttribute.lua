--- attribute&buff 属性配置

--- 游戏规定的几率key
local odds = {
    "hurtRebound",
    "crit",
    "stun"
}
--- 游戏规定的抗性key
local resistance = {
    "hpSuckAttack",
    "hpSuckAbility",
    "mpSuckAttack",
    "mpSuckAbility",
    "hurtRebound",
    "crit",
    "stun",
    "punish",
    "split",
    "silent",
    "unArm",
    "lightningChain",
    "crackFly",
}
--- 附魔元素对应图标路径
local elementIconPath = {
    dark = "ability/Nightswallow",
    fire = "ability/IncendiaryBonds",
    grass = "ability/SpellLfieblood",
    ice = "ability/Glacier",
    light = "ability/HolyBolt",
    poison = "ability/SummonDemonicGateway",
    rock = "item/MiscQirajiCrystal01",
    steel = "ability/FlameCrystal",
    thunder = "ability/SplitLightning",
    water = "ability/DeathknightFrozencenter",
    wind = "ability/Greenengulfingtornado",
}

local T = true
local F = false
attribute.conf(F, "str", "力量", nil, "ability/Strength3")
attribute.conf(F, "agi", "敏捷", nil, "ability/RogueQuickRecovery")
attribute.conf(F, "int", "智力", nil, "ability/DeclarationofGod")
attribute.conf(F, "aim", "命中", '%', "ability/DeadlyDoubleLine")
attribute.conf(F, "animateScale", "动作", '%', "ability/LightWork")
attribute.conf(F, "attack", "攻击", nil, "ability/CrystalSlash")
attribute.conf(F, "attackRange", "攻击范围", nil, "ability/HunterLockAndLoad")
attribute.conf(F, "attackRangeAcquire", "主动攻击范围", nil, "ability/HunterLockAndLoad")
attribute.conf(F, "attackRipple", "攻击浮动")
attribute.conf(T, "attackSpace", "攻击间隔", "击每秒", "ability/WarriorWeaponMastery")
attribute.conf(T, "attackSpaceBase", "原始攻击间隔", "击每秒", "ability/WarriorWeaponMastery")
attribute.conf(F, "attackSpeed", "攻击速度", '%', "ability/DemonhunterBladeDance")
attribute.conf(F, "avoid", "回避", '%', "ability/Greenphantom")
attribute.conf(F, "breakArmor", "破甲", nil, "ability/ShadowCurseOfSargeras")
attribute.conf(T, "castChant", "吟唱时间", "秒", "ability/ShadowLastingAfflictions")
attribute.conf(T, "castChantPercent", "吟唱时间", '%', "ability/ShadowLastingAfflictions")
attribute.conf(F, "castDistance", "施法距离", nil, "ability/ShadowLastingAfflictions")
attribute.conf(F, "castDistancePercent", "施法距离", '%', "ability/ShadowLastingAfflictions")
attribute.conf(T, "castKeep", "施法持续时间", "秒", "ability/ShadowLastingAfflictions")
attribute.conf(T, "castKeepPercent", "施法持续时间", '%', "ability/ShadowLastingAfflictions")
attribute.conf(F, "castRange", "施法范围", nil, "ability/ShadowLastingAfflictions")
attribute.conf(F, "castRangePercent", "施法范围", '%', "ability/ShadowLastingAfflictions")
attribute.conf(T, "coolDown", "冷却时间", "秒", "ability/ShadowLastingAfflictions")
attribute.conf(T, "coolDownPercent", "冷却时间", '%', "ability/ShadowLastingAfflictions")
attribute.conf(T, "cost", "施法消耗", nil, "ability/ShadowLastingAfflictions")
attribute.conf(T, "costPercent", "施法消耗", '%', "ability/ShadowLastingAfflictions")
attribute.conf(F, "crit", "暴击", '%', "ability/ShockCut")
attribute.conf(F, "cure", "治疗加成", '%', "ability/Heal")
attribute.conf(F, "damageIncrease", "伤害增幅", '%', "ability/LingerSometimesConstantlyKnife")
attribute.conf(F, "defend", "防御", nil, "ability/ThickFur")
attribute.conf(F, "enchantMystery", "附魔精通", '%', "ability/ElementalSilk")
attribute.conf(F, "freeze", "冻结", nil, "ability/HolyWrath")
attribute.conf(F, "hp", "HP", nil, "ability/HPRecharge")
attribute.conf(F, "hpCur", "当前HP", nil, "ability/HPRecharge")
attribute.conf(F, "hpRegen", "HP恢复", "每秒", "ability/ReplenishHealth")
attribute.conf(F, "hpSuckAbility", "技能吸血", '%', "ability/DrainLife")
attribute.conf(F, "hpSuckAttack", "攻击吸血", '%', "ability/NatureHealingWay")
attribute.conf(T, "hurtIncrease", "受伤加深", '%', "ability/IronmaidensBloodritual")
attribute.conf(F, "hurtRebound", "反弹伤害", '%', "ability/MageMoltenArmor")
attribute.conf(F, "hurtReduction", "受伤减轻", '%', "ability/HolyGreaterBlessingofSanctuary")
attribute.conf(F, "move", "移动", nil, "ability/RogueFleetFooted")
attribute.conf(F, "mp", "MP", nil, "ability/ManaRecharge2")
attribute.conf(F, "mpCur", "当前MP", nil, "ability/ManaRecharge2")
attribute.conf(F, "mpRegen", "MP恢复", "每秒", "ability/ReplenishMana")
attribute.conf(F, "mpSuckAbility", "技能吸魔", '%', "ability/DrainMana")
attribute.conf(F, "mpSuckAttack", "攻击吸魔", '%', "ability/ManaBurn2")
attribute.conf(F, "nsight", "夜晚视野", nil, "ability/SigntNight")
attribute.conf(F, "reborn", "复活时间", "秒", "ability/HolyHolyGuidance")
attribute.conf(F, "rgba", "偏色", nil, "ability/HunterBeastWithin")
attribute.conf(F, "punish", "硬直", nil, "ability/ValkyrieArmed")
attribute.conf(F, "punishCur", "当前硬直", nil, "ability/ValkyrieArmed")
attribute.conf(F, "punishRegen", "硬直恢复", "每秒", "ability/GodofWar")
attribute.conf(F, "shield", "护盾", nil, "ability/HolyBlessingOfProtection")
attribute.conf(T, "shieldBack", "护盾恢复需时", "秒", "ability/HolyBlessingOfProtection")
attribute.conf(F, "sight", "白昼视野", nil, "ability/SigntDay")
attribute.conf(F, "stun", "眩晕", '%', "ability/Stun")
attribute.conf(F, "visible", "反隐范围", nil, "ability/MagicalSentry")
attribute.conf(F, "weight", "负重", nil, "other/DustOfAppearance")
attribute.conf(F, "weightCur", "当前负重", nil, "other/DustOfAppearance")
attribute.conf(F, "unArm", "缴械", nil, "ability/ShadowCurseOfMannoroth")
attribute.conf(F, "silent", "沉默", nil, "ability/Silence")
attribute.conf(F, "split", "分裂", nil, "ability/CleavingAttack")
attribute.conf(F, "invisible", "隐身", nil, "ability/Vanish")
attribute.conf(F, "invulnerable", "无敌", '%', "ability/Invulnerable")
attribute.conf(F, "lightningChain", "闪电链", nil, "ability/ChainLightning")
attribute.conf(F, "leap", "冲锋中", nil, "ability/Sprinter")
attribute.conf(F, "crackFly", "被击飞", nil, "ability/Jumpback")
attribute.conf(F, "sp", "额外特性")
--
for _, k in ipairs(enchant.keys) do
    local n = Enchant(k):name()
    local eip = elementIconPath[k]
    attribute.conf(F, k, n, nil, eip)
    attribute.conf(F, SYMBOL_E .. k, n .. "强化", '%', eip)
    attribute.conf(F, SYMBOL_E .. k .. "Weapon", n .. "武装", eip)
    attribute.conf(F, SYMBOL_E .. k .. "Append", n .. "附着", eip)
    attribute.conf(F, SYMBOL_EI .. k, n .. "免疫", eip)
    attribute.conf(F, SYMBOL_ODD .. SYMBOL_E .. k, n .. "几率", '%', eip)
    attribute.conf(F, SYMBOL_RES .. SYMBOL_E .. k, n .. "抗性", '%', eip)
end
for _, v in ipairs(odds) do
    attribute.conf(F, SYMBOL_ODD .. v, attribute.label(v) .. "几率", '%', attribute.icon(v))
end
for _, v in ipairs(resistance) do
    attribute.conf(F, SYMBOL_RES .. v, attribute.label(v) .. "抗性", '%', attribute.icon(v))
end

-- 定义智能属性描述体
-- [基础信息]
---@param this Ability|Item
---@param options {level:number}
description.define("attributes", function(this, options)
    local attributes = this:modify("attributes")
    if (type(attributes) ~= "table" or #attributes == 0) then
        return nil
    end
    local desc = {}
    local lv = math.floor(options.level or this:level())
    for _, a in ipairs(attributes) do
        local param = a[1]
        local m2 = a[2] or 0
        local d1
        local d2
        if (type(m2) == "number") then
            d1 = m2
            d2 = a[3] or d1
        elseif (type(m2) == "string") then
            param = attribute.enParam(m2)
            d1 = a[3] or 0
            d2 = a[4] or d1
        end
        local label = attribute.label(param)
         if (nil ~= label) then
            local v = d1
            if (lv > 1) then
                v = v + (lv - 1) * d2
            end
            table.insert(desc, attribute.format(param, v))
        end
    end
    return desc
end)