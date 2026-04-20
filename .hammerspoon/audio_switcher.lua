-- サウンドメニューを Option+クリックで開く（フラグ使用版）
hs.hotkey.bind({"alt", "cmd"}, "E", function()
    local controlCenter = hs.appfinder.appFromName("コントロールセンター")
    if not controlCenter then
        hs.alert.show("コントロールセンターが見つかりません")
        return
    end
    
    local axApp = hs.axuielement.applicationElement(controlCenter)
    if not axApp then return end
    
    local children = axApp:attributeValue("AXChildren")
    if not children then return end
    
    local menubar = nil
    for _, child in ipairs(children) do
        if child:attributeValue("AXRole") == "AXMenuBar" then
            menubar = child
            break
        end
    end
    
    if not menubar then return end
    
    local items = menubar:attributeValue("AXChildren")
    if not items then return end
    
    local soundItem = nil
    for _, item in ipairs(items) do
        local desc = item:attributeValue("AXDescription")
        if desc == "サウンド" or desc == "Sound" then
            soundItem = item
            break
        end
    end
    
    if not soundItem then return end
    
    local position = soundItem:attributeValue("AXPosition")
    local size = soundItem:attributeValue("AXSize")
    if not position or not size then return end
    
    local clickPoint = {
        x = position.x + size.w / 2,
        y = position.y + size.h / 2
    }
    
    -- Optionキーのフラグを設定してクリック
    local optionFlag = hs.eventtap.event.properties.keyboardEventKeycode
    
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseDown,
        clickPoint
    ):setFlags({alt = true}):post()
    
    hs.timer.usleep(100000)
    
    hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.leftMouseUp,
        clickPoint
    ):setFlags({alt = true}):post()
    
    -- hs.alert.show("サウンドメニューを開きました")
end)
