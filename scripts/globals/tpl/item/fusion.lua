TPL_ITEM["烈火剑"] = ItemTpl()
    :name("烈火剑")
    :description("三剑合一")
    :icon("ReplaceableTextures\\CommandButtons\\BTNArcaniteMelee.blp")
    :worth({ copper = 10 })
    :attributes(
    {
        { "attack", 43, 0 },
    })


TPL_ITEM["合金盾"] = ItemTpl()
      :name("合金盾")
      :description("三盾合一")
      :icon("ReplaceableTextures\\CommandButtons\\BTNArcaniteArmor.blp")
      :worth({ copper = 10 })
      :attributes(
    {
        { "defend", 20, 0 },
    })

if(fusion)then
    fusion.formula(TPL_ITEM["烈火剑"], TPL_ITEM["短剑"], TPL_ITEM["短剑"], TPL_ITEM["短剑"])
    fusion.formula(TPL_ITEM["合金盾"], TPL_ITEM["木盾"], TPL_ITEM["木盾"], TPL_ITEM["木盾"])
end
