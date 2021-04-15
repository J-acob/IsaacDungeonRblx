local ServerStorage = game:GetService("ServerStorage")
local MonsterDictionary = require(ServerStorage.Monster.MonsterDictionary)
local MonsterBlocks = ServerStorage.MonsterBlocks.MonsterBlock
local RunSerivce = game:GetService("RunService")
local SignalEvent = require(ServerStorage.Utility.SignalEvent)
local CollectionService = game:GetService("CollectionService")
local MonsterBehavior = require(ServerStorage.Monster.MonsterBehavior)



local Monster = {}

Monster.__index = Monster


function Monster.new(monsterBlock, parentRoom)
	
	local newMonster = {}
		
	local self = setmetatable(newMonster, Monster)
	
	--We have to assume that we're being given a valid "monster block" here
	--This means it has a certain set of attributes associated with it as well
	
	self.health = monsterBlock:GetAttribute("Health")
	self.moveSpeed = monsterBlock:GetAttribute("MoveSpeed")
	local newMons = MonsterDictionary["1"]["Model"]:Clone()
	self.monsterModel = newMons
	
	--Things that should only be read once we have an actual model
	self.monsterHumanoid = self.monsterModel:FindFirstChild("Humanoid")
	self.monsterHumanoidHealth = self.monsterHumanoid.Health
	self.parentRoom = parentRoom
	self.HRP = self.monsterModel:FindFirstChild("HumanoidRootPart")
	
	
	--For orienting the monster correctly
	self.alignOrientation = self.HRP:FindFirstChild("AlignOrientation")
	self.worldAttachment = Instance.new("Attachment")
	self.worldAttachment.Name = "MonsterAlignAttachment"
	self.worldAttachment.Parent = workspace.Terrain
	
	self.alignOrientation.Attachment1 = self.worldAttachment

	
	self.target = nil
	self.searchRadius = monsterBlock:GetAttribute("SearchRadius")
	self.searchRegion = nil	
	self.searchingForTarget = true
	
	
	--Connections for signals
	self.ConnectionTable = {}
	
	--These are all the possible states a monster could be in that are useful to connect specific behaviors to
	self.SearchForPlayerConnection = SignalEvent.new(self)
	self.FoundPlayerConnection = SignalEvent.new(self)
	self.InRangeToAttackConnection = SignalEvent.new(self)
	self.InRangeToFireProjectileConnection = SignalEvent.new(self)
	self.DiedConnection = SignalEvent.new(self)
	self.AtSpecificHealthConnection = SignalEvent.new(self)
	
	
	
	self.runServiceConnection = nil --This will be connected later.... 
	self.monsterHumanoid.Died:Connect(function()
		
		print("I have died!")
		
		self.parentRoom.MonsterCount.Value = self.parentRoom.MonsterCount.Value - 1
		
		self.runServiceConnection:Disconnect()
		
		self:CleanUp()
		
	end)
	
	CollectionService:AddTag(self.monsterModel, "Monster")
	
	return self
	
end

function Monster:Spawn(whereToSpawn)
	
	
	local a = coroutine.wrap(function()
		
		self.monsterModel:SetPrimaryPartCFrame(whereToSpawn)
		self.monsterModel.Parent = workspace

		self.FoundPlayerConnection:AddNewSignal(MonsterBehavior["MoveTowardsTarget"])
		self.FoundPlayerConnection:AddNewSignal(MonsterBehavior["Jump"])
		
		--self.FoundPlayerConnection:AddNewSignal(MonsterBehavior["WindupAttack"])



		self:Activate()

		wait(5)

		self.monsterModel.PrimaryPart.BrickColor = BrickColor.new("Black")
		self.monsterModel.Humanoid:TakeDamage(100)

		print("Monster should be dead now!")
		
	end)
	
	
	a()
	
end


function Monster:OnRunService()
	
	--This is where different behaviors should be defined....
	--Roaming, searching, hiding, jumping, etc...
	--Then within this behavior there can be other options as well...
	
	--[[
	
		if self.target == nil and self.searchingForTarget then
		
		self:SearchForPlayerInRange()
		
	else
		
		print("Target found: ", self.target.Name)
		
		self.searchingForTarget = false
		--self.FoundPlayerConnection:Fire()
		
	end
	
	]]
	
	--wait(0.25)
	
	if self.searchingForTarget then
		
		self:SearchForPlayerInRange()
		
	else
		
		self.FoundPlayerConnection:Fire()
		self.alignOrientation.Enabled = true
		
		self.worldAttachment.CFrame = CFrame.new(self.HRP.Position, self.target.HumanoidRootPart.Position)
		
	end
	
end

--This function begins the process of the monsters AI, such as searching for the players and doing various actions
function Monster:Activate()

	self.runServiceConnection = RunSerivce.Heartbeat:Connect(function()
		
		self:OnRunService()
		
	end)
	
end


function Monster:SearchForPlayerInRange()
	
	self.SearchForPlayerConnection:Fire()
	
	local center = self.HRP.Position
	local topCorner = center + Vector3.new(self.searchRadius, self.searchRadius, self.searchRadius)
	local bottomCorner = center + Vector3.new(-self.searchRadius, -self.searchRadius, -self.searchRadius)
	
	self.searcingForPlayer = true
	
	self.searchRegion = Region3.new(bottomCorner, topCorner)
	local searchParts = workspace:FindPartsInRegion3(self.searchRegion, self.monsterModel)
	
	--[[
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = self.searchRegion.Size
	part.CFrame = self.searchRegion.CFrame
	part.Transparency = 0.95
	part.Parent = workspace
	]]
	
	print("Attempting to locate player in my range... ")
	
	
	
	for i, part in pairs(searchParts) do
		
		if 
			
			--Conditions for a player being a valid target
			
			part.Parent:FindFirstChild("Humanoid") and not
			CollectionService:HasTag(part.Parent, "Monster")
				
		then
			
			--We've found a player
			
			self.target = part.Parent
			
			self.searchingForTarget = false
			
			print("Found a target as: ", self.target.Name)
			
			self.FoundPlayerConnection:Fire()
			
		end
	end
end


function Monster:MoveTowardsTarget()
	
	print("Attempting to move towards target: ", self.target.Name)
	self.monsterHumanoid:MoveTo(self.target)
	
end


function Monster:CleanUp()
	
	self.runServiceConnection = nil
	
	for i, connection in pairs(self.ConnectionTable) do
		
		connection:ClearConnectionTable()
		
		self.ConnectionTable[i] = nil
		
	end
	
	self.runServiceConnection = nil
	
	self.target = nil
	
	self.searchingForTarget = nil
	
	self.monsterModel:Destroy()
	
	self.alignOrientation:Destroy()
	
	self.worldAttachment:Destroy()
	
	
	
end


return Monster
