---------------------------------------------VERSION 0-------------------------------------------

--[[

Last Modified: 30/04/2024

Update Log:

Updated By: Metadata


]]


------------------------------ CORE UI HANDLER--------------------------------------------

local coreui = script.Parent

-- SUB FRAMES
local dynamicisland_frame = coreui.DynamicIsland_frame

-- settings frame
local settingsframe = coreui.SettingsFrame
local settings_is_open = settingsframe.Open

local settings_open_status = settingsframe.Open
local closebut = settingsframe.closebut

-- garage frame
local garageframe = coreui.garageUI
local garage_frame_is_open = garageframe.Open
-------------------------------

local island_intereact_but = dynamicisland_frame.ISLAND_INTEREACT_BUT
local time_txtlabel = dynamicisland_frame.TIME_txtlabel
local expanded_fold = dynamicisland_frame.expanded_fold
local userpfplabel = expanded_fold.userpfpimg_label
local moneystat = expanded_fold.moneystatlabel
local usernamelabel = expanded_fold.usernamelabel

-- expanded elements
local settingiconbut = expanded_fold.settingsnbut
local vehiclespawnbut = expanded_fold.vehicle_spawn

local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local lplayer = Players.LocalPlayer
local userId = lplayer.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

userpfplabel.Image = content
usernamelabel.Text = lplayer.Name

local expanded = dynamicisland_frame.Expanded -- boolvalue to check if player has island expanded

local expansionx = 0.04
local expansiony = 0.01
local default_movetime = 0.1
local debounce = true
local autoresetdynamic_island = 5

local originalsize = UDim2.new(0.074, 0, 0.056, 0)

local function createTweenInfo(sec)
    return TweenInfo.new(
        sec,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        0,
        false,
        0
    )
end


local function change_size(x, y, sec)
    local sizex = dynamicisland_frame.Size.X.Scale + x
    local sizey = dynamicisland_frame.Size.Y.Scale + y
    local goal = {
        Size = UDim2.new(sizex, 0, sizey, 0)
    }
    local change_tween = tweenservice:Create(dynamicisland_frame, createTweenInfo(sec), goal)
    change_tween:Play()
end

local function change_to_set_size(x, y, sec)
    local sizex = dynamicisland_frame.Size.X.Scale
    local sizey = dynamicisland_frame.Size.Y.Scale
    local goal = {
        Size = UDim2.new(x, 0, y, 0)
    }
    local change_tween = tweenservice:Create(dynamicisland_frame, createTweenInfo(sec), goal)
    change_tween:Play()
end

local function reset_size(sec)
    sec = sec or default_movetime
    local goal = {
        Size = originalsize
    }
    local contract_tween = tweenservice:Create(dynamicisland_frame, createTweenInfo(sec), goal)
    contract_tween:Play()
end

local function closeAllUIExcept(exceptionUI)
    if exceptionUI ~= settingsframe then
        settingsframe.Visible = false
        settings_is_open.Value = false
    end
    if exceptionUI ~= garageframe then
        garageframe.Visible = false
        garage_frame_is_open.Value = false
    end
end

local function hide_expanded()
    for _, v in ipairs(expanded_fold:GetChildren()) do
        v.Visible = false
    end
end

local function closeAllUI()
    settingsframe.Visible = false
    settings_is_open.Value = false
    garageframe.Visible = false
    garage_frame_is_open.Value = false

    -- Check if there are no UIs open
    if not settings_is_open.Value and not garage_frame_is_open.Value then
        hide_expanded()
        reset_size(0.2)
        expanded.Value = false
    end
end

local function show_expanded()
    for _, v in ipairs(expanded_fold:GetChildren()) do
        v.Visible = true
    end
end

local function UI_Clicked(UI, Status)
    if Status.Value then
        Status.Value = false
        UI.Visible = false
    else
        Status.Value = true
        UI.Visible = true
    end
end

local resetTimerCoroutine = nil

local function auto_reset()
    if resetTimerCoroutine then
        coroutine.close(resetTimerCoroutine)
    end
    resetTimerCoroutine = coroutine.create(function()
        wait(autoresetdynamic_island)
        if expanded.Value then
            -- Only hide and reset size if no UI is open
            if not settings_is_open.Value and not garage_frame_is_open.Value then
                hide_expanded()
                reset_size(0.2)
                closeAllUI()
                expanded.Value = false
            end
        end
    end)

    coroutine.resume(resetTimerCoroutine)
end


local function reset_auto_reset_timer()
    if resetTimerCoroutine then
        coroutine.close(resetTimerCoroutine)
    end
    auto_reset()
end

-- Connect click events for buttons inside expanded_fold
for _, button in ipairs(expanded_fold:GetChildren()) do
    if button:IsA("TextButton") or button:IsA("ImageButton") then
        button.MouseButton1Click:Connect(reset_auto_reset_timer)
    end
end

runservice.Heartbeat:Connect(function()
    local timeOfDay = lighting.TimeOfDay
    local hours, minutes, _ = timeOfDay:match("^(%d+):(%d+):(%d+)$")

    -- Convert to numbers
    hours = tonumber(hours)
    minutes = tonumber(minutes)

    -- Determine AM or PM
    local period = "AM"
    if hours >= 12 then
        period = "PM"
    end

    -- Convert from 24-hour time to 12-hour time
    if hours > 12 then
        hours = hours - 12
    elseif hours == 0 then
        hours = 12
    end

    -- Ensure hours and minutes are zero-padded if necessary
    local hourString = string.format("%02d", hours)
    local minuteString = string.format("%02d", minutes)

    time_txtlabel.Text = hourString .. ":" .. minuteString .. " " .. period
end)

island_intereact_but.MouseEnter:Connect(function()
    if not expanded.Value then
        change_size(expansionx, expansiony, default_movetime)
    end
end)

island_intereact_but.MouseLeave:Connect(function()
    if not expanded.Value then
        reset_size()
        expanded.Value = false
    end
end)

island_intereact_but.MouseButton1Click:Connect(function()
    if debounce then
        debounce = false
        if expanded.Value then
            local value = 0.2
            hide_expanded()
            reset_size(value)
            wait(value)
            expanded.Value = false
        else
            change_to_set_size(0.4, 0.066, 0.2)
            show_expanded()
            expanded.Value = true
            auto_reset()
        end
        debounce = true
    end
end)

settingiconbut.MouseButton1Click:Connect(function()
    closeAllUIExcept(settingsframe)
    UI_Clicked(settingsframe, settings_is_open)
end)

vehiclespawnbut.MouseButton1Click:Connect(function()
    closeAllUIExcept(garageframe)
    UI_Clicked(garageframe, garage_frame_is_open)
end)

closebut.MouseButton1Click:Connect(function()
    settingsframe.Visible = false

    -- Check if the expanded island is open and no other UI is open
    if expanded.Value and not garage_frame_is_open.Value then
        hide_expanded()
        reset_size(0.2)
        expanded.Value = false
    end
end)
