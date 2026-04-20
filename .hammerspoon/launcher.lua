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
    hs.application.launchOrFocus("Terminal")
    mainModal:exit()
end)
