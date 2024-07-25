-- Retrieve the vehicle model and chassis
local vehicle_model = script.Parent.Parent.Parent
local Achassis = vehicle_model.ACHASSIS

-- Retrieve the body and subcomponents of the chassis
local body = Achassis.Body
local mbody = body.mbody

-- Define the proxies for the driver and passenger seats
local driverproxy = mbody.driver_proxy.ProximityPrompt
local backleftproxy = mbody.backleft_proxy.ProximityPrompt
local backrightproxy = mbody.backright_proxy.ProximityPrompt
local frontleftproxy = mbody.frontleft_proxy.ProximityPrompt

-- Define the seats
local driverseat = Achassis.DriveSeat
local backleftseat = body.backleft_seat
local backrightseat = body.backright_seat
local frontleftseat = body.frontleft_seat

-- Define the variables to store the last seated players for each seat
local last_seated_plr = driverseat.last_seated_plr
local last_seated_plr_backleft = body.backleft_seat.last_seated_plr
local last_seated_plr_backright = body.backright_seat.last_seated_plr
local last_seated_plr_frontleft = body.frontleft_seat.last_seated_plr

-- Retrieve the ReplicatedFirst service and the remote events
local replicatedfirst = game:GetService("ReplicatedFirst")
local players = game:GetService("Players")
local enter = replicatedfirst:WaitForChild("enter")
local exit = replicatedfirst:WaitForChild("exit")

-- Cooldown flag and duration
local cooldown_active = false
local cooldown_duration = 0.5

-- Function to seat a player in a given seat and update the last seated player value
local function sit_plr(plr, seat, last_seated)
	local humanoid = plr.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		seat:Sit(humanoid)
		last_seated.Value = plr.Character
		enter:FireClient(plr)
	end
end

-- Function to disable all seat proxies
local function disable_all_proxies()
	driverproxy.Enabled = false
	backleftproxy.Enabled = false
	backrightproxy.Enabled = false
	frontleftproxy.Enabled = false
end

-- Function to enable all seat proxies
local function enable_all_proxies()
	driverproxy.Enabled = true
	backleftproxy.Enabled = true
	backrightproxy.Enabled = true
	frontleftproxy.Enabled = true
end

-- Function to start the cooldown
local function start_cooldown()
	cooldown_active = true
	wait(cooldown_duration)
	cooldown_active = false
end

-- Event handler for when the driver proxy is triggered
-- Seats the player in the driver seat, disables all proxies, and starts the cooldown
driverproxy.Triggered:Connect(function(plr)
	if not cooldown_active and driverseat.Occupant == nil then
		sit_plr(plr, driverseat, last_seated_plr)
		enter:FireClient(plr)
		disable_all_proxies()
		start_cooldown()
	end
end)

--[[
The code below detects the event triggered when a player leaves the driver seat. If there's no one in the seat after the signal change,
use the previously stored player instance to teleport the player character instance to some offset along the x-axis relative to the orientation of the car.
Additionally, fire the 'exit' remote event when the player leaves the seat.

Last updated on 25/07/24 by MetaData
]]
driverseat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if driverseat.Occupant == nil then
		local rootpart = last_seated_plr.Value:FindFirstChild("HumanoidRootPart")
		if rootpart then
			rootpart.CFrame = driverproxy.Parent.WorldCFrame * CFrame.new(8, 0, 0)
			exit:FireClient(last_seated_plr.Value)
		end
		print("plr left")
		enable_all_proxies()
	end
end)

-- Array containing the seat proxies, their corresponding seats, and the last seated player variables
local seat_proxies = {
	{ proxy = frontleftproxy, seat = frontleftseat, last_seated = last_seated_plr_frontleft },
	{ proxy = backleftproxy,  seat = backleftseat,  last_seated = last_seated_plr_backleft },
	{ proxy = backrightproxy, seat = backrightseat, last_seated = last_seated_plr_backright }
}

-- Event handlers for the passenger seat proxies
-- Seats the player in the corresponding seat, disables all proxies, and starts the cooldown when triggered
for _, seat_proxy in ipairs(seat_proxies) do
	seat_proxy.proxy.Triggered:Connect(function(plr)
		if not cooldown_active and seat_proxy.seat.Occupant == nil then
			sit_plr(plr, seat_proxy.seat, seat_proxy.last_seated)
			enter:FireClient(plr)
			disable_all_proxies()
			start_cooldown()
		end
	end)

	-- Event handler for when the occupant of a passenger seat changes
	-- If the seat becomes empty, enables all seat proxies and teleports the last seated player to a position
	-- relative to the car's orientation. Additionally, fire the 'exit' remote event when the player leaves the seat.
	seat_proxy.seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if seat_proxy.seat.Occupant == nil then
			enable_all_proxies()
			local rootpart = seat_proxy.last_seated.Value:FindFirstChild("HumanoidRootPart")
			if rootpart then
				rootpart.CFrame = seat_proxy.proxy.Parent.WorldCFrame * CFrame.new(8, 0, 0)
				local plr = players:GetPlayerFromCharacter(seat_proxy.last_seated.Value)
				exit:FireClient()
			end
			print("plr left seat: " .. seat_proxy.seat.Name)
		end
	end)
end
