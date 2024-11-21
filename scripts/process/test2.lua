local process = Process("test2")

function process:onStart()
    
    sound.bgm("Sound\\Music\\mp3Music\\ArthasTheme.mp3")
    
    local bubble = self:bubble()
    
    --- 基地（友军玩家5）
    bubble.base = Unit(Player(5), TPL_UNIT.Base, 0, -2496, 270)
    
    --- 基地死亡则失败
    ---@param evtData eventOnUnitDead
    bubble.base:onEvent(eventKind.unitDead, function(evtData)
        local tips = evtData.triggerUnit:name() .. "炸了"
        for i = 1, 4, 1 do
            Player(i):quit(tips)
        end
    end)
    
    --- 为玩家生成英雄
    local avatar = UIBackdrop("avatar", UIGame)
        :adaptive(true)
        :relation(UI_ALIGN_LEFT_TOP, UIGame, UI_ALIGN_LEFT_TOP, 0.015, -0.04)
        :size(0.04, 0.04)
        :onEvent(eventKind.uiLeftClick,
        function(evtData)
            local idx = evtData.triggerPlayer:index()
            ---@type Unit
            local hero = bubble["hero" .. idx]
            if hero:isAlive() then
                camera.to(hero:x(), hero:y(), 0)
            end
        end)
    async.loc(function()
        avatar:texture(bubble["hero" .. player.localIndex]:icon())
    end)
    for i = 1, 4, 1 do
        local p = Player(i)
        if (p:isPlaying()) then
            local u = Unit(p, TPL_UNIT.Hero, 0, -2496 + 250, 90)
            u:reborn(10) -- 10秒复活
            ---@param evtData eventOnUnitFeignDead
            u:onEvent(eventKind.unitFeignDead, "heroDead", function(evtData)
                async.loc(function()
                    local icon = evtData.triggerUnit:icon()
                    avatar:texture(slk.disIconPath(icon))
                end)
            end)
            ---@param evtData eventOnUnitReborn
            u:onEvent(eventKind.unitReborn, "heroReborn", function(evtData)
                async.loc(function()
                    local icon = evtData.triggerUnit:icon()
                    avatar:texture(icon)
                end)
            end)
            ---@param evtData eventOnUnitLevelChange
            u:onEvent(eventKind.unitLevelChange, "heroLevelUp", function(evtData)
                local diff = evtData.new - evtData.old
                effector.attach(evtData.triggerUnit, "LevelupCaster", "chest", 1)
                evtData.triggerUnit:attack("+=" .. 1 * diff)
                evtData.triggerUnit:attackSpeed("+=0.1")
                evtData.triggerUnit:hp("+=" .. 5 * diff)
                evtData.triggerUnit:hpRegen("+=" .. 1 * diff)
            end)
            -- uiBalloon
            uiBalloon.lighterInsert(u)
            bubble["hero" .. i] = u
        end
    end
    ---@param evtData eventOnKeyboardRelease
    keyboard.onRelease(keyboard.code["F1"], "avatar", function(evtData)
        local idx = evtData.triggerPlayer:index()
        ---@type Unit
        local hero = bubble["hero" .. idx]
        if hero:isAlive() then
            camera.to(hero:x(), hero:y(), 0)
        end
    end)
    
    --- 敌人
    local enemyTeam = Team("敌方", 13, true, true)
    enemyTeam:members({ 10, 11, 12 })
    local cur = 1 -- 当前波
    local wave = 100 -- 100波
    local period = 50 -- 初始周期
    local per = 1 -- 每波缩短周期
    local min = 15 -- 最小周期
    local qty = 6 -- 每地点出怪数量
    -- 出怪地点
    local points = {
        { 0, 2432, 270 }, -- 中
        { -2740, -2496, 0 }, -- 左
        { 2561, -2496, 180 }, -- 右
    }
    bubble.monTimer = time.setInterval(period, function(curTimer)
        cur = cur + 1
        if (cur >= wave) then
            class.destroy(curTimer)
            return
        end
        if (period > min) then
            period = period - per
            curTimer:period(period)
        end
        local i = 0
        bubble.monTimer2 = time.setInterval(1, function(curTimer2)
            i = i + 1
            if (i >= qty) then
                class.destroy(curTimer2)
                return
            end
            for _, p in ipairs(points) do
                local u = Unit(enemyTeam, TPL_UNIT.Empty, p[1], p[2], p[3])
                u._kind = "路线进攻"
                u:orderAttack(0, -2496)
                u:hp("+=" .. cur)
                u:attack("+=" .. cur / 3)
            end
        end)
    end)
    local ui = UIText("monTimer", UIGame)
        :relation(UI_ALIGN_TOP, UIGame, UI_ALIGN_TOP, 0, -0.07)
        :textAlign(TEXT_ALIGN_CENTER)
        :fontSize(12)
    bubble.uiTimer = time.setInterval(1, function()
        ui:text("第" .. cur .. "波：" .. math.floor(bubble.monTimer:remain()))
    end)
    
    for _ = 1, 7 do
        local it = Item(TPL_ITEM["短剑"])
        it:position(0, -1900)
    end
    for _ = 1, 7 do
        local it = Item(TPL_ITEM["木盾"])
        it:position(0, -1900)
    end
    
    -- 物品合成（假如存在）
    if (fusion) then
        ---@param evtData eventOnUnitItemGet
        event.syncRegister(UnitClass, eventKind.unitItemPick, "fusion", function(evtData)
            fusion.conflate(evtData.triggerUnit, evtData.triggerItem)
        end)
    end
    
    -- 2个刷资源地点
    local brushes = {
        {
            name = "刷经验",
            effect = { -800, -1800, 50, "UnholyAura" },
            room = { -2270, 2221, 180 },
            p_num = 0,
            e_num = 0,
        },
        {
            name = "刷金币",
            effect = { 800, -1800, 50, "OmMandAura" },
            room = { 2426, 2178, 0 },
            p_num = 0,
            e_num = 0,
        }
    }
    -- 资源区刷怪
    local toBrushes = function(hero, brush)
        local room = brush.room
        hero:position(room[1], room[2])
        hero:facing(room[3])
        camera.to(room[1], room[2], 0)
        hero._brush = brush
        brush.p_num = brush.p_num + 1
        if (nil == brush.timer) then
            brush.timer = time.setInterval(2, function()
                if (brush.e_num <= 0) then
                    brush.e_num = brush.e_num + 5
                    for _ = 1, 5 do
                        local u = Unit(enemyTeam, TPL_UNIT.Empty, room[1], room[2], 270)
                        u._kind = brush.name
                        u:hp(10)
                        u:attack(10)
                    end
                end
            end)
        end
    end
    
    -- 敌人奖励
    local dropList = { TPL_ITEM["短剑"], TPL_ITEM["木盾"] }
    ---@param evtData eventOnUnitDead
    event.syncRegister(UnitClass, eventKind.unitDead, "enemyDrop", function(evtData)
        local tu = evtData.triggerUnit
        if (enemyTeam:is(tu)) then
            if (tu._kind == "路线进攻") then
                if (evtData.killerUnit) then
                    evtData.killerUnit:exp("+=30")
                end
                if (math.rand(1, 10) == 3) then
                    local x, y = tu:x(), tu:y()
                    local it = Item(table.rand(dropList, 1))
                    it:position(x, y)
                end
            elseif (tu._kind == "刷金币") then
                brushes[2].e_num = brushes[2].e_num - 1
                if (evtData.killerUnit) then
                    evtData.killerUnit:owner():worth("+", { gold = 1 })  -- 未显示
                end
            elseif (tu._kind == "刷经验") then
                brushes[1].e_num = brushes[1].e_num - 1
                if (evtData.killerUnit) then
                    evtData.killerUnit:exp("+=100")
                end
            end
        end
    end)
    
    -- 入口
    uiBalloon.config(nil, "war3_QuestLog")
    for i, b in ipairs(brushes) do
        bubble["ttg" .. i] = ttg.permanent(b.effect[1], b.effect[2], b.name, { zOffset = 150 + b.effect[3] })
        local e = effector.agile(b.effect[4], b.effect[1], b.effect[2], b.effect[3])
        uiBalloon.lanternInsert(e, {
            content = {
                {
                    tips = {
                        b.name .. "吗？",
                        uiBalloon.callTips("出发")
                    },
                    ---@param callbackData balloonCallBack
                    call = function(callbackData)
                        local u = callbackData.lighter
                        toBrushes(u, b)
                    end
                }
            }
        })
        bubble["e:" .. i] = e
    end
    
    -- -hg回城
    player.onChat("-hg", function(evtData)
        local idx = evtData.triggerPlayer:index()
        ---@type Unit
        local hero = bubble["hero" .. idx]
        hero:position(0, -2300)
        hero:facing(270)
        camera.to(0, -2300, 0)
        local brush = hero._brush
        if (nil ~= brush) then
            hero._brush = nil
            brush.p_num = brush.p_num - 1
            if (brush.p_num <= 0) then
                class.destroy(brush.timer)
                brush.timer = nil
            end
        end
    end)
end

function process:onOver()
    sound.bgmStop()
    UIText("monTimer"):text("")
    local bubble = self:bubble()
    ttg.destroy(bubble["ttg1"])
    ttg.destroy(bubble["ttg2"])
end
