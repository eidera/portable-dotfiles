local hotkey = require "hs.hotkey"
local window = require "hs.window"
local screen = require "hs.screen"

local function moveWindowToEdge(direction)
    local win = window.focusedWindow()
    if not win then return end
    local frame = win:frame()
    local scr = win:screen():frame()  -- フルフレーム（visible frameで調整可能）

    if direction == "left" then
        frame.x = scr.x  -- 左端、Yはそのまま
    elseif direction == "right" then
        frame.x = scr.x + scr.w - frame.w  -- 右端、Yはそのまま
    elseif direction == "top" then
        frame.y = scr.y  -- 上端、Xはそのまま
    elseif direction == "bottom" then
        frame.y = scr.y + scr.h - frame.h  -- 下端、Xはそのまま
    elseif direction == "top-left" then
        frame.x = scr.x
        frame.y = scr.y
    elseif direction == "top-right" then
        frame.x = scr.x + scr.w - frame.w
        frame.y = scr.y
    elseif direction == "bottom-left" then
        frame.x = scr.x
        frame.y = scr.y + scr.h - frame.h
    elseif direction == "bottom-right" then
        frame.x = scr.x + scr.w - frame.w
        frame.y = scr.y + scr.h - frame.h
    end

    win:setFrame(frame)
end

-- 四隅ショートカット: Ctrl + Shift + Cmd + 指定キー
hotkey.bind({"ctrl", "shift", "cmd"}, "[", function() moveWindowToEdge("top-left") end)
hotkey.bind({"ctrl", "shift", "cmd"}, "]", function() moveWindowToEdge("top-right") end)
hotkey.bind({"ctrl", "shift", "cmd"}, ";", function() moveWindowToEdge("bottom-left") end)
hotkey.bind({"ctrl", "shift", "cmd"}, "'", function() moveWindowToEdge("bottom-right") end)
