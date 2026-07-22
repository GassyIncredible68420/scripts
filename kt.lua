local LocalPlayer=game:GetService("Players").LocalPlayer
local Path = game:GetService("PathfindingService"):CreatePath()
local ignore={}
local Priority={
	["Golden"]=999;
	["Rock"]=100;
	["Derp"]=99;
	["Trollge"]=98;
	["Trollface"]=0
}
local ownedbadges={}
local ownedpasses={}
local notowned={}
print("lmao")
repeat task.wait() until LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Troll")
print("loaded")
local function Get()
	local result=""
	local currentpr=-1
	for troll,priority in Priority do
		if workspace.Lobby.TrollStands:FindFirstChild(troll) and priority>currentpr and not table.find(notowned,troll.Name) then
			--check req
			local own=true
			if workspace.Lobby.TrollStands:FindFirstChild(troll).Requirements.Stabs.Value>LocalPlayer.leaderstats.Stabs.Value then
				own=false
			end
			for _,b in workspace.Lobby.TrollStands:FindFirstChild(troll).Requirements.Badges:GetChildren() do
				if table.find(ownedbadges,b.Value) then
					continue
				end
				if not game:GetService("BadgeService"):UserHasBadgeAsync(LocalPlayer.UserId,b.Value) then
					own=false
					break
				elseif not table.find(ownedbadges,b.Value) then
					table.insert(ownedbadges,b.Value)
				end
			end
			for _,b in workspace.Lobby.TrollStands:FindFirstChild(troll).Requirements.Gamepasses:GetChildren() do
				if table.find(ownedpasses,b.Value) then
					continue
				end
				if not game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId,b.Value) then
					own=false
					break
				elseif not table.find(ownedpasses,b.Value) then
					table.insert(ownedpasses,b.Value)
				end
			end
			if own then
				result=workspace.Lobby.TrollStands:FindFirstChild(troll)
				currentpr=priority
			else
				table.insert(notowned,troll.Name)
			end
		end
	end
	return result
end
local enabled=false
local gui=Instance.new("ScreenGui")
local b=Instance.new("TextButton")
b.Text="Activate"
b.TextScaled=true
b.Size=UDim2.fromScale(0.25,0.25)
b.Position=UDim2.fromScale(0,1)
b.AnchorPoint=Vector2.new(0,1)
b.BackgroundTransparency=0.5
b.BackgroundColor3=Color3.new(1,0,0)
local constraint=Instance.new("UIAspectRatioConstraint")
constraint.AspectRatio=3
constraint.Parent=b
b.Parent=gui
gui.ResetOnSpawn=false
gui.Parent=LocalPlayer.PlayerGui
print("gui")
b.MouseButton1Click:Connect(function()
	enabled=not enabled
	if enabled then
		b.BackgroundColor3=Color3.new(0,1,0)
	else
		b.BackgroundColor3=Color3.new(1,0,0)
	end
end)
local function FindNearestTarget(Character)
	local maxDistance = math.huge
	local nearestTarget = nil
	for _,target in workspace:GetDescendants() do
		if target:FindFirstChild("Values") and target:FindFirstChild("Humanoid") and target~=Character and target:FindFirstChild("HumanoidRootPart") then
			local distance = (target.HumanoidRootPart.Position-Character.HumanoidRootPart.Position).Magnitude
			if distance < maxDistance then
				nearestTarget = target
				maxDistance = distance
			end
		end
	end
	if maxDistance<25 then
		pcall(function()
			if LocalPlayer.Backpack:FindFirstChildOfClass("Tool") then
				LocalPlayer.Backpack:FindFirstChildOfClass("Tool").Parent=Character
			end
			Character:FindFirstChildOfClass("Tool"):Activate()
		end)
	end
	return nearestTarget,maxDistance
end
local target,distance
local rayp=RaycastParams.new()
rayp.FilterType=Enum.RaycastFilterType.Exclude
rayp.RespectCanCollide=true
rayp.FilterDescendantsInstances=ignore
local function OnNewCharacter(Character:Model)
	while task.wait() do
		local a,e=pcall(function()
			if not enabled then
				return
			end
			if not Character:FindFirstChild("CharacterScript") then
				local troll=Get()
				repeat
					if LocalPlayer.leaderstats.Troll.Value~=troll then
						repeat
							Path:ComputeAsync(Character.HumanoidRootPart.Position,troll.Position)
							local v=Path:GetWaypoints()[2]
							if v~=nil then
								local movefinished=false
								Character.Humanoid.MoveToFinished:Connect(function()
									movefinished=true
								end)
								for i,waypoint in pairs(Path:GetWaypoints()) do
									if i~=1 then
										Character.Humanoid:MoveTo(waypoint.Position)
										if waypoint.Action == Enum.PathWaypointAction.Jump then
											Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
										end
										if not enabled then
											break
										end
										repeat task.wait() until movefinished or not enabled
										movefinished=false
									end
								end
							else
								Character.Humanoid:MoveTo(troll.Position)
							end
							task.wait(1)
						until (Character.HumanoidRootPart.Position-troll.Position).Magnitude<troll.ClickDetector.MaxActivationDistance or not enabled
						if fireclickdetector then
							fireclickdetector(troll.ClickDetector)
						end
						task.wait(1)
					end
					print(LocalPlayer.leaderstats.Troll.Value,troll.Name)
					task.wait(1)
				until LocalPlayer.leaderstats.Troll.Value==troll.Name
				Path:ComputeAsync(Character.HumanoidRootPart.Position,workspace.Lobby.Teleports.Arena.Position)
				local v=Path:GetWaypoints()[2]
				if v~=nil then
					local movefinished=false
					Character.Humanoid.MoveToFinished:Connect(function()
						movefinished=true
					end)
					for i,waypoint in pairs(Path:GetWaypoints()) do
						if i~=1 then
							Character.Humanoid:MoveTo(waypoint.Position)
							if waypoint.Action == Enum.PathWaypointAction.Jump then
								Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
							if not enabled then
								break
							end
							repeat task.wait() until movefinished or not enabled
							movefinished=false
						end
					end
				else
					Character.Humanoid:MoveTo(workspace.Lobby.Teleports.Arena.Position)
				end
				return
			end
			target,distance=FindNearestTarget(Character)
			if target then
				if target.Parent==nil then
					target=nil
					return
				end
				local ray=distance<50 and workspace:Raycast(Character.HumanoidRootPart.Position,target.HumanoidRootPart.Position,rayp)
				if ((ray and ray.Instance) or not ray) and distance<500 then
					local old=target.HumanoidRootPart.Position
					Path:ComputeAsync(Character.HumanoidRootPart.Position,old)
					local v=Path:GetWaypoints()[2]
					if v~=nil then
						local movefinished=false
						Character.Humanoid.MoveToFinished:Connect(function()
							movefinished=true
						end)
						for i,waypoint in pairs(Path:GetWaypoints()) do
							if i~=1 then
								Character.Humanoid:MoveTo(waypoint.Position)
								if waypoint.Action == Enum.PathWaypointAction.Jump then
									Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								end
								if target.HumanoidRootPart.Position~=old or not enabled then
									break
								end
								repeat task.wait() until movefinished or not enabled
								movefinished=false
							end
						end
					else
						Character.Humanoid:MoveTo(target.HumanoidRootPart.Position)
					end
				else
					Character.Humanoid:MoveTo(target.HumanoidRootPart.Position)
				end
				task.wait()
			else
				task.wait(0.1)
			end
		end)
		if not a then warn(e) end
	end
end
LocalPlayer.CharacterAdded:Connect(OnNewCharacter)
OnNewCharacter(LocalPlayer.Character)
