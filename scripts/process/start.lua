local process = Process("start")

function process:onStart()
    
    -- 调试自动去除迷雾
    fog.enable(not XLIK_DEBUG)
    fog.maskEnable(not XLIK_DEBUG)

    self:next("test")

end
