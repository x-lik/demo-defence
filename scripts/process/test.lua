local process = Process("test")

function process:onStart()
    
    sound.bgm("Sound\\Music\\mp3Music\\ArthasTheme.mp3")
    
    local bubble = self:bubble()
    
    --- 基地（友军玩家5）
    bubble.base = Unit(Player(5), TPL_UNIT.Base, 0, 0, 270)
    
    --- 基地死亡则失败
    ---@param evtData evtOnUnitDeadData
    bubble.base:onEvent(eventKind.unitDead, function(evtData)
        local tips = evtData.triggerUnit:name() .. "炸了"
        for i = 1, 4, 1 do
            Player(i):quit(tips)
        end
    end)
    
    --- 为玩家生成英雄
    for i = 1, 4, 1 do
        local p = Player(i)
        if (p:isPlaying()) then
            local u = Unit(p, TPL_UNIT.Hero, 0, -250, 270)
            u:reborn(10) -- 10秒复活
        end
    end
    
    --- 敌人
    local enemy = Team("敌方", TEAM_COLOR_BLP_BLACK, true, true)
    enemy:members({ 10, 11, 12 })
    local cur = 1 -- 当前波
    local wave = 100 -- 100波
    local period = 60 -- 初始周期
    local per = 5 -- 每波缩短周期
    local min = 30 -- 最小周期
    local qty = 10 -- 每地点出怪数量
    -- 出怪地点
    local points = {
        { 0, 2437, 270 }, -- 中
        { -2740, -2502, 0 }, -- 左
        { -2561, -2487, 180 }, -- 右
    }
    -- 刷怪地点
    local fresh = {
        { -2270, 2221, 180 },
        { 2426, 2178, 0 },
    }
    time.setInterval(period, function(curTimer)
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
        time.setInterval(0.5, function(curTimer2)
            i = i + 1
            if (i >= qty) then
                class.destroy(curTimer2)
                return
            end
            for _, p in ipairs(points) do
                local u = Unit(enemy, TPL_UNIT.Empty, p[1], p[2], p[3])
                u:orderAttack(0, 0)
            end
        end)
    end)
end

function process:onOver()
    sound.bgmStop()
end
