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

local function sit_plr(plrchar,seat)
	
end

driverproxy.Triggered:Connect(function(plr) -- if plr triggers proxy on driver seat, place them into the seat and set the last_seated_plr value to the plr character
	if driverseat.Occupant == nil then
		driverseat:Sit(plr.Character:FindFirstChildWhichIsA("Humanoid"))
		last_seated_plr.Value = plr.Character
	end
end)

--[[
the code below detects the event triggered when plr left the driverseat,if theres no one in 
the seat after signal change, use the previously stored plr instance to 
teleport the plr character instance to some offset along the x axis 
relative to the orientation of the car

last updated on 25/07/24 by MetaData
]]

driverseat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if driverseat.Occupant == nil then
		local rootpart = last_seated_plr.Value:FindFirstChild("HumanoidRootPart")
		if rootpart then
			rootpart.CFrame = driverproxy.Parent.WorldCFrame * CFrame.new(8,0,0)
		end
		print("plr left")
	end
end)

local seat_proxies = {frontleftproxy,backleftproxy,backrightproxy}
local seats = {frontleftseat,backleftseat,backrightseat}
local seats_values = {last_seated_plr_frontleft,last_seated_plr_backleft,last_seated_plr_backright}



local function proxy_clicked(plrchar)
	last_seated_plr_frontleft.Value = plrchar
	local humanoid = plrchar:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		frontleftseat:Sit(humanoid)
end

for _, v in ipairs(seat_proxies) do
	v.Triggered:Connect(function(plr)
		v.Enabled = false
		if v.Name == "frontleftproxy" then
			proxy_clicked(plr.Character)
		elseif v.Name == "backleftproxy" then
			proxy_clicked(plr.Character)
		elseif v.Name == "backrightproxy" then
			proxy_clicked(plr.Character)
		end
	end)
end


for _,v in ipairs(seats) do

	v:GetPropertyChangedSignal("Occupant"):Connect(function()
		print("test")
	end)
end