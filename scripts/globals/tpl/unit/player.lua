--- 玩家单位
TPL_UNIT.Hero = UnitTpl("Beastmaster", "avatar")
    :preAbility({ TPL_ABILITY.ZZJY })
    :name("兽王")
    :model("Rexxar")
    :icon("ReplaceableTextures\\CommandButtons\\BTNBeastMaster.blp")
    :weaponSound("metal_chop_heavy")
    :move(300)
    :attack(20)
    :hp(200)
    :scale(1.6)
    :level(1)
    :levelMax(999)

--- 守护的基地
TPL_UNIT.Base = UnitTpl('', "pathTex10x_ss")
--TPL_UNIT.Base = UnitTpl('')
    :name("基地")
    :model("TownHall")
    :modelScale(1.00)
    :scale(4.00)
    :animateProperties({ "upgrade", "second" })
    :preNoAttack()
    :preNoAbilitySlot()
    :preNoItemSlot()
    :splat("ReplaceableTextures\\Splats\\HumanTownHallUberSplat.blp")
    :hp(10000)