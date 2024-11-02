local process = Process("test")

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
    
    -- 获取路径的后缀名
    local function ext(path)
        local idx = string.find(path, "%.", nil)
        if idx then
            return string.sub(path, idx)
        else
            return ""
        end
    end
    
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
                    if (ext(icon) == ".blp") then
                        icon = string.gsub(icon, "CommandButtons\\BTN", "CommandButtonsDisabled\\DISBTN", 1)
                        avatar:texture(icon)
                    end
                end)
            end)
            ---@param evtData eventOnUnitReborn
            u:onEvent(eventKind.unitReborn, "heroReborn", function(evtData)
                async.loc(function()
                    local icon = evtData.triggerUnit:icon()
                    avatar:texture(icon)
                end)
            end)
            ---@param evtData eventOnUnitKill
            u:onEvent(eventKind.unitKill, "heroKill", function(evtData)
                evtData.triggerUnit:exp("+=30")
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
    local period = 30 -- 初始周期
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
    
    -- 敌人掉落
    local dropList = { TPL_ITEM["短剑"], TPL_ITEM["木盾"] }
    ---@param evtData eventOnUnitDead
    event.syncRegister(UnitClass, eventKind.unitDead, "enemyDrop", function(evtData)
        local tu = evtData.triggerUnit
        if (enemyTeam:is(tu) and math.rand(1, 10) == 3) then
            local x, y = tu:x(), tu:y()
            local it = Item(table.rand(dropList, 1))
            it:position(x, y)
        end
    end)
    
    -- 刷怪地点
    local fresh = {
        { -2270, 2221, 180 },
        { 2426, 2178, 0 },
    }
end

function process:onOver()
    sound.bgmStop()
    UIText("monTimer"):text("")
end
