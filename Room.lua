local Room = {}

Room.__index = Room

local ServerStorage = game:GetService("ServerStorage")
local MonsterDictionary = require(ServerStorage.Monster.MonsterDictionary)
local MonsterBlocks = ServerStorage.MonsterBlocks
local Monster = require(ServerStorage.Monster)

local Rooms = ServerStorage.TestRooms1
local Door = require(ServerStorage.Dungeon.Room.Door)

function Room.new(roomModel, travelSizeX, travelSizeY)
	
	local newRoom = {}
	
	local self = setmetatable(newRoom, Room)
			
	self.RoomDoors = {
		
		["North"] ={
			
			exists = false,
			directionalValue = -travelSizeY,
			oppositeDirectionPool = "South",
			doorPart = nil,
			doorObject = nil,
			doorTravel = Vector3.new(1, 0, 0)
			
		};
		
		
		["East"] ={

			exists = false,
			directionalValue = 1,
			oppositeDirectionPool = "West",
			doorPart = nil,
			doorObject = nil,
			doorTravel = Vector3.new(0, 0, 1)

		};
		
		["South"] ={

			exists = false,
			directionalValue = travelSizeY,
			oppositeDirectionPool = "North",
			doorPart = nil,
			doorObject = nil,
			doorTravel = Vector3.new(-1, 0, 0)
			
		};

		["West"] ={

			exists = false,
			directionalValue = -1,
			oppositeDirectionPool = "East",
			doorPart = nil,
			doorObject = nil,
			doorTravel = Vector3.new(0, 0, -1)

		};
		
		
	}
	
	
	if(roomModel:FindFirstChild("North")) then
		
		self.RoomDoors.North.exists = true
		--We know this exists so it's valid!
		self.RoomDoors["North"]["doorPart"] = roomModel.North

		--This is where we would want to use the constructor of a door object.
		--Although, since we delete doors later, we should make sure to properly handle the deletion of door objects later
		self.RoomDoors["North"]["doorObject"] = Door.new(self.RoomDoors["North"]["doorPart"])
		
		self.RoomDoors["North"]["doorObject"].oppositeDirection = Vector3.new(8, 0, 0)
		
		
	end
	
	if(roomModel:FindFirstChild("East")) then

		self.RoomDoors.East.exists = true
		
		self.RoomDoors["East"]["doorPart"] = roomModel.East
		
		self.RoomDoors["East"]["doorObject"] = Door.new(self.RoomDoors["East"]["doorPart"])
		
		self.RoomDoors["East"]["doorObject"].oppositeDirection = Vector3.new(0, 0, 8)

	end
	
	if(roomModel:FindFirstChild("South")) then

		self.RoomDoors.South.exists = true
		
		self.RoomDoors["South"]["doorPart"] = roomModel.South
		
		self.RoomDoors["South"]["doorObject"] = Door.new(self.RoomDoors["South"]["doorPart"])
		
		self.RoomDoors["South"]["doorObject"].oppositeDirection = Vector3.new(-8, 0, 0)

	end

	if(roomModel:FindFirstChild("West")) then

		self.RoomDoors.West.exists = true
		
		self.RoomDoors["West"]["doorPart"] = roomModel.West
		
		self.RoomDoors["West"]["doorObject"] = Door.new(self.RoomDoors["West"]["doorPart"])
		
		self.RoomDoors["West"]["doorObject"].oppositeDirection = Vector3.new(0, 0, -8)

	end

	--Below properties are meant to be used for player interaction with rooms
	
	self.RoomModel = roomModel
	
	self.RoomFloor = self.RoomModel:FindFirstChild("Floor")
	
	self.hasBeenActivated = false
	
	for i, v in pairs(self.RoomModel:GetChildren()) do
		
		if v:IsA("Part") and v.Name == "MonsterBlock" then
			
			--We've found a monster block, turn it into a monster object and put it into the monsters table :D
			
		end
		
	end
	
	self.Monsters = {}
	
	self.MonsterCount = Instance.new("IntValue")
	self.MonsterCount.Name = "MonsterCount"
	self.MonsterCount.Parent = self.RoomModel
	
	self.MonsterCount:GetPropertyChangedSignal("Value"):Connect(function()
		
		
		--This is specifically checking if there are 0 monsters left,
		--Perhaps we can generalize this system to be "room deactivate objects" instead
		--So we can use other things to deactivate rooms as well
		
		if self.MonsterCount.Value == 0 or self.MonsterCount.Value < 0 then 
			
			self:Deactivate()
			
		end
		
	end)

	
	--We're just gonna insert a monster into it for now to test.
	
	for i=1, 4 do
		
		self.Monsters[i] = Monster.new(MonsterBlocks.MonsterBlock, self)
		
		self.MonsterCount.Value = self.MonsterCount.Value + 1

	end
	
	
	--self.Monsters[1] = Monster.new(MonsterBlocks.MonsterBlock, self)
	--self.MonsterCount.Value = 1
	
	return newRoom
	
end


function Room:PlaceRoom(roomToPlace, roomToPlaceAt)
	
	--roomToPlace.PrimaryPart.CFrame = roomToPlaceAt.CFrame
	
	roomToPlace:SetPrimaryPartCFrame(roomToPlaceAt.CFrame)
	
	roomToPlace.Parent = workspace


end



--The size of the dungeon needs to be passed into the room to know how far the room
--Can look
function Room:GetPotentialRooms(dungeonSizeX, dungeonSizeY)

	
	local FinalRoomPool = {}
	
	FinalRoomPool.NorthRooms = {}
	
	FinalRoomPool.EastRooms = {}
	
	FinalRoomPool.SouthRooms = {}
	
	FinalRoomPool.WestRooms = {}
	

	
	local RoomPool = {}
	
	RoomPool.NorthRooms = Rooms.NorthRooms:GetChildren()
	
	RoomPool.EastRooms = Rooms.EastRooms:GetChildren()
	
	RoomPool.SouthRooms = Rooms.SouthRooms:GetChildren()
	
	RoomPool.WestRooms = Rooms.WestRooms:GetChildren()
	

		
	
	for j = 1, #RoomPool.NorthRooms do
		
		table.insert(FinalRoomPool.NorthRooms, RoomPool.NorthRooms[j]:Clone())
		
		--FinalRoomPool.NorthRooms[j] =  Room.new(RoomPool.NorthRooms[j]:Clone(), dungeonSizeX, dungeonSizeY)

	end
		
		
	
	for k = 1, #RoomPool.EastRooms do

		
		table.insert(FinalRoomPool.EastRooms, RoomPool.EastRooms[k]:Clone())

	end
		
		
	
	for l = 1, #RoomPool.SouthRooms do
		

		table.insert(FinalRoomPool.SouthRooms, RoomPool.SouthRooms[l]:Clone())


	end
		
		
	
	for m = 1, #RoomPool.WestRooms do

		
		table.insert(FinalRoomPool.WestRooms, RoomPool.WestRooms[m]:Clone())


	end
	
	
	

	--[[
	local RoomPool = Rooms:GetChildren()
	
	local FinalRoomPool = {}
	
	
	for i = 1, #RoomPool do
		
		FinalRoomPool[i] = Room.new(RoomPool[i], dungeonSizeX, dungeonSizeY)
		
	end
	
	return FinalRoomPool
	

	]]
	
	
	
	
	return FinalRoomPool
	
end
  

function Room:Activate()
	--Close all doors associated with room
	--Spawn monsters within room? it might be a good idea to do this with a table and iteration instead of having dynamic monsters. TBD
	
	--We need to make sure that we're not attempting to activate rooms that have already been activated before
	
	
	--We should also check to make sure that the room actually does need to be activate... like if there's no monsters then set
	--The room to being activated
	
	if self.hasBeenActivated == false then
		
		self.hasBeenActivated = true	
		
		for _, door in pairs(self.RoomDoors) do

			if door["exists"] and door["doorObject"].isHidden == false then

				door["doorObject"]:Close()

			end
			
			--Spawn all the monsters associated with the current room.	
		end
		

		for i, monster in pairs(self.Monsters) do

			monster:Spawn(self.RoomFloor.CFrame + Vector3.new(0,5 + i/2,0))

		end
		
	end

end

function Room:Deactivate()
	
	for _, door in pairs(self.RoomDoors) do

		if door["exists"] and door["doorObject"].isHidden == false then

			door["doorObject"]:Open()
			
		end

	end

	
end

function Room:Initialize()
	
	for _, door in ipairs(self.RoomDoors) do
		
		--We want to make sure doors are "enterable" initially
		
		if door["exists"] and door["doorObject"].isHidden == false then

			door["doorPart"].CanCollide = false

		end
		
	end
	
	
end


return Room
