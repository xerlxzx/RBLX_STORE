local vehicle_model = script.Parent.Parent.Parent
local Achassis = vehicle_model.ACHASSIS

local body = Achassis.Body
local mbody = body.mbody

local driverproxy = mbody.driver_proxy.ProximityPrompt
local backleftproxy = mbody.backleft_proxy.ProximityPrompt
local backrightproxy = mbody.backright_proxy.ProximityPrompt
local frontleftproxy = mbody.frontleft_proxy.ProximityPrompt

local driverseat = Achassis.DriveSeat
local backleftseat = body.backleft_seat
local backrightseat = body.backright_seat
local frontleftseat = body.frontleft_seat

local last_seated_plr = driverseat.last_seated_plr
local last_seated_plr_backleft = body.backleft_seat.last_seated_plr
local last_seated_plr_backright = body.backright_seat.last_seated_plr
local last_seated_plr_frontleft = body.frontleft_seat.last_seated_plr

local function sit_plr(plrchar, seat, last_seated)
	local humanoid = plrchar:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		seat:Sit(humanoid)
		last_seated.Value = plrchar
	end
end

driverproxy.Triggered:Connect(function(plr)
	if driverseat.Occupant == nil then
		sit_plr(plr.Character, driverseat, last_seated_plr)
	end
end)

driverseat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if driverseat.Occupant == nil then
		local rootpart = last_seated_plr.Value:FindFirstChild("HumanoidRootPart")
		if rootpart then
			rootpart.CFrame = driverproxy.Parent.WorldCFrame * CFrame.new(8, 0, 0)
		end
		print("plr left")
	end
end)

local seat_proxies = {
	{ proxy = frontleftproxy, seat = frontleftseat, last_seated = last_seated_plr_frontleft },
	{ proxy = backleftproxy,  seat = backleftseat,  last_seated = last_seated_plr_backleft },
	{ proxy = backrightproxy, seat = backrightseat, last_seated = last_seated_plr_backright }
}

for _, seat_proxy in ipairs(seat_proxies) do
	seat_proxy.proxy.Triggered:Connect(function(plr)
		if seat_proxy.seat.Occupant == nil then
			sit_plr(plr.Character, seat_proxy.seat, seat_proxy.last_seated)
			seat_proxy.proxy.Enabled = false
		end
	end)

	seat_proxy.seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		if seat_proxy.seat.Occupant == nil then
			seat_proxy.proxy.Enabled = true
			local rootpart = seat_proxy.last_seated.Value:FindFirstChild("HumanoidRootPart")
			if rootpart then
				rootpart.CFrame = seat_proxy.proxy.Parent.WorldCFrame * CFrame.new(8, 0, 0)
			end
			print("plr left seat: " .. seat_proxy.seat.Name)
		end
	end)
end
