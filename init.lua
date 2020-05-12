hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

SCROLL_DELTA = 1

--size 950 * 659
--fold 538 * 606 : 0.56 * 0.92
--check call 707 * 607 : 0.74 * 0.92
--bet raise 865 * 606: 0.91 * 0.92

BUTTON_TOP_PCT = 0.92
FOLD_LEFT_PCT = 0.56
CHECK_LEFT_PCT = 0.74
BET_LEFT_PCT = 0.91

--raise min
--raise shortcut 1 756 * 535
--raise shortcut 2 835 * 535
--raise shortcut 3 915 * 535

RAISE1_LEFT_PCT = 0.79
RAISE2_LEFT_PCT = 0.88
RAISE3_LEFT_PCT = 0.96
RAISE_TOP_PCT = 0.81

types = hs.eventtap.event.types

function click(pos)
    local msg = "clicking:" .. pos.x .. " " .. pos.y
    hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
    hs.eventtap.event.newMouseEvent(types.mouseMoved, pos):post()
    hs.timer.usleep(10)
    hs.eventtap.event.newMouseEvent(types.leftMouseDown, pos):post()
    hs.eventtap.event.newMouseEvent(types.leftMouseUp, pos):post()
end

function getPosInWindow(x, y)
    local window = hs.window.focusedWindow()
    local windowPos = window:topLeft();
    return hs.geometry.point(windowPos.x + x, windowPos.y + y)
end

function getRelativePosInWindow(xpct, ypct)
    local window = hs.window.focusedWindow()
    local windowSize = window:size()
    return getPosInWindow(windowSize.w * xpct, windowSize.h * ypct)
end

function clickRelativeWindowPos(xpct, ypct)
    click(getRelativePosInWindow(xpct, ypct))
end

psKeys = {
  hs.hotkey.bind({"cmd"}, ",", function()
    clickRelativeWindowPos(RAISE1_LEFT_PCT, RAISE_TOP_PCT)
  end),
  hs.hotkey.bind({"cmd"}, ".", function()
    clickRelativeWindowPos(RAISE2_LEFT_PCT, RAISE_TOP_PCT)
  end),
  hs.hotkey.bind({"cmd"}, "/", function()
    clickRelativeWindowPos(RAISE3_LEFT_PCT, RAISE_TOP_PCT)
  end),
  hs.hotkey.bind({"cmd"}, "left", function()
    clickRelativeWindowPos(FOLD_LEFT_PCT, BUTTON_TOP_PCT)
  end),
  hs.hotkey.bind({"cmd"}, "down", function()
    clickRelativeWindowPos(CHECK_LEFT_PCT, BUTTON_TOP_PCT)
  end),
  hs.hotkey.bind({"cmd"}, "right", function()
    clickRelativeWindowPos(BET_LEFT_PCT, BUTTON_TOP_PCT)
  end),
  hs.hotkey.bind({}, "down", function()
    clickRelativeWindowPos(0.5, 0.5)
    hs.eventtap.scrollWheel({0, -SCROLL_DELTA}, {});
  end),
  hs.hotkey.bind({}, "up", function()
    clickRelativeWindowPos(0.5, 0.5)
    hs.eventtap.scrollWheel({0, SCROLL_DELTA}, {});
  end),
}

function setEnabled(enabled)
  --hs.notify.new({title=appName, informativeText="Change state"}):send()
  for i,m in ipairs(psKeys) do
    if enabled then
      m:enable()
    else
      m:disable()
    end
  end
end

watcher = hs.application.watcher.new(function(appName, eventType, app)
  -- also watch non-pokerstars since hammer spoon sometimes misses
  -- apps that dies
  if hs.application.watcher.activated == eventType then
    setEnabled(appName == "PokerStars")
  end
  if hs.application.watcher.deactivated == eventType then
    if appName == "PokerStars" then
      setEnabled(false)
    end
  end
end)
watcher:start()
