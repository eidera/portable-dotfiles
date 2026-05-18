-- 配列の先頭から順に試し、最初に起動成功したアプリで打ち切る
local function launchFirstAvailableApp(appNames)
    for _, name in ipairs(appNames) do
        if hs.application.launchOrFocus(name) then
            return true
        end
    end
    return false
end

-- メインのモーダルを作成（プレフィックス: Shift + Cmd + Space）
local mainModal = hs.hotkey.modal.new({'shift', 'cmd'}, 'space')

-- メインモード入場時にリストを表示（セキュア入力チェック強化）
function mainModal:entered()
    if hs.eventtap.isSecureInputEnabled() then
        hs.alert.show("セキュア入力モードです！ESCやバインドが効きません。非セキュアアプリでテストを。", 5)
    end
    local listText = hs.styledtext.new("メインモード:\n" ..
                                       "r - HammerSpoonの設定をリロード\n" ..
                                       "v - MacVimを起動\n" ..
                                       "t - ターミナルを起動\n" ..
                                       "l - ランチャーメニュー\n" ..
                                       "z - AIメニュー\n" ..
                                       "esc - 退出",
                                       {font = {name = "Menlo", size = 14}, color = {white = 1.0}})
    hs.alert.show(listText, {}, hs.screen.mainScreen(), 'infinite')  -- 無制限表示
end

-- メイン退出時にalertを閉じる
function mainModal:exited()
    hs.alert.closeAll()
end

-- ESCでメイン退出
mainModal:bind('', 'escape', function()
    mainModal:exit()
end)

-- Ctrl+[でもメイン退出
mainModal:bind({'ctrl'}, '[', function()
    mainModal:exit()
end)

-- r: HammerSpoonの設定をリロードし、メイン退出
mainModal:bind('', 'r', function()
    -- タイマーモジュールがロードされている場合は状態を保存
    if timer and timer.saveState then
        timer.saveState()
    end
    hs.reload()
    mainModal:exit()
end)

-- v: MacVimを起動し、メイン退出
mainModal:bind('', 'v', function()
    hs.application.launchOrFocus("MacVim")
    mainModal:exit()
end)

-- t: ターミナルを起動し、メイン退出
mainModal:bind('', 't', function()
    launchFirstAvailableApp({"iTerm", "Terminal"})
    mainModal:exit()
end)

-- ランチャーサブメニューのモーダルを作成
local launcherModal = hs.hotkey.modal.new()

-- ランチャーモード入場時にリストを表示
function launcherModal:entered()
    local listText = hs.styledtext.new("ランチャーメニュー:\n" ..
                                       "w - 天気アプリを開く\n" ..
                                       "c - カレンダーを開く\n" ..
                                       "esc - メインメニューに戻る",
                                       {font = {name = "Menlo", size = 14}, color = {white = 1.0}})
    hs.alert.show(listText, {}, hs.screen.mainScreen(), 'infinite')
end

-- ランチャーモード退出時にalertを閉じる
function launcherModal:exited()
    hs.alert.closeAll()
end

-- ESCでランチャーメニューを退出してメインメニューに戻る
launcherModal:bind('', 'escape', function()
    launcherModal:exit()
    mainModal:enter()
end)

-- Ctrl+[でもランチャーメニューを退出してメインメニューに戻る
launcherModal:bind({'ctrl'}, '[', function()
    launcherModal:exit()
    mainModal:enter()
end)

-- w: 天気アプリを開く
launcherModal:bind('', 'w', function()
    launcherModal:exit()
    hs.application.launchOrFocus("Weather")
end)

-- c: カレンダーを開く
launcherModal:bind('', 'c', function()
    launcherModal:exit()
    hs.application.launchOrFocus("Calendar")
end)

-- l: メインメニューからランチャーメニューへ遷移
mainModal:bind('', 'l', function()
    mainModal:exit()
    launcherModal:enter()
end)

-- AIサブメニューのモーダルを作成
local aiModal = hs.hotkey.modal.new()

-- AIモード入場時にリストを表示
function aiModal:entered()
    local listText = hs.styledtext.new("AIメニュー:\n" ..
                                       "c - VS Codeを起動\n" ..
                                       "esc - メインメニューに戻る",
                                       {font = {name = "Menlo", size = 14}, color = {white = 1.0}})
    hs.alert.show(listText, {}, hs.screen.mainScreen(), 'infinite')
end

-- AIモード退出時にalertを閉じる
function aiModal:exited()
    hs.alert.closeAll()
end

-- ESCでAIメニューを退出してメインメニューに戻る
aiModal:bind('', 'escape', function()
    aiModal:exit()
    mainModal:enter()
end)

-- Ctrl+[でもAIメニューを退出してメインメニューに戻る
aiModal:bind({'ctrl'}, '[', function()
    aiModal:exit()
    mainModal:enter()
end)

-- c: VS Codeを起動し、AIメニュー退出
aiModal:bind('', 'c', function()
    hs.application.launchOrFocus("Visual Studio Code")
    aiModal:exit()
end)

-- z: メインメニューからAIメニューへ遷移
mainModal:bind('', 'z', function()
    mainModal:exit()
    aiModal:enter()
end)
