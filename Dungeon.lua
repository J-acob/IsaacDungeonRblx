
local Room = require(script.Room)

local Queue = require(script.Queue)

local Grid = require(game:GetService("ServerStorage").Dungeon.Grid)

local Cell = require(game:GetService("ServerStorage").Dungeon.Grid.Cell)

local Door = require(game:GetService("ServerStorage").Dungeon.Room.Door)

local RunService = game:GetService("RunService")

local Dungeon = {}

Dungeon.__index = Dungeon



function Dungeon.new(XSize, YSize, level, cellPart, neededEndRooms)
	
	local newDungeon = {}
	
	local self = setmetatable(newDungeon, Dungeon)
	
	self.DungeonSizeX  = XSize
	
	self.DungeonSizeY = YSize
	
	self.EndRooms = Queue.new()
	
	self.RoomQueue = Queue.new()
	
	self.PreEndRooms = Queue.new()
	
	self.OccupiedRooms = Queue.new()
	
	self.StartingRoom = nil
	
	self.DungeonRoomCount = 0
	
	self.RegenCount = 1

	self.Grid = Grid.new(self.DungeonSizeX, self.DungeonSizeY, cellPart)
	
	--Very specific formula, change it if needed
	self.neededRooms =  math.floor(math.random(1,2) + 5 + (level * 2.6))
	
	self.neededEndRooms = neededEndRooms
	
	--1) First generate a pool of potential rooms to place into the dungeon
	self.RoomPool = Room:GetPotentialRooms(self.DungeonSizeX, self.DungeonSizeY)

	--Place starting room at a multiple of (3,5) depending on dungeon size

	local NormalRoom = BrickColor.new("Ghost grey")
	

	return newDungeon
	
end

function Dungeon:Visit(neighborCell, directionPool)
	
	
	--Check if the current cell is occupied
	
	if neighborCell.x == 1 or neighborCell.y == 1 or neighborCell.x == self.DungeonSizeX or neighborCell.y == self.DungeonSizeY then


		return false

	end
	
	if neighborCell.Occupied == true then


		return false

	end
	
	if self.Grid:NeighborCount(neighborCell) > 1 then

		

		return false

	end
	
	if self.DungeonRoomCount == self.neededRooms then


		return false

	end
	
	
	--Making it this far means that we've found a valid room to place another room into

	neighborCell.CellPart.BrickColor = BrickColor.new("Black")
	
	self.RoomQueue:push(neighborCell)

	neighborCell.Occupied = true

	neighborCell.OccupiedInt = 1

	self.DungeonRoomCount = self.DungeonRoomCount + 1


	--Getting the available rooms for this neighbor to become
	--directionPool is passed from the generation function

	if directionPool == "North" then
		--neighborCell.LinkedRoom = self.RoomPool.NorthRooms[math.random(1, #self.RoomPool.NorthRooms)]
		
		--Create a new room based on a pool of room MODELS and not ROOM OBJECT
		neighborCell.LinkedRoom = Room.new(self.RoomPool.NorthRooms[math.random(1, #self.RoomPool.NorthRooms)]:Clone(), self.DungeonSizeX, self.DungeonSizeY)
		
		
	elseif directionPool == "East" then

		--neighborCell.LinkedRoom = self.RoomPool.EastRooms[math.random(1, #self.RoomPool.EastRooms)]
		
		neighborCell.LinkedRoom = Room.new(self.RoomPool.EastRooms[math.random(1, #self.RoomPool.EastRooms)]:Clone(), self.DungeonSizeX, self.DungeonSizeY)
		
		
	elseif directionPool == "South" then

		--neighborCell.LinkedRoom = self.RoomPool.SouthRooms[math.random(1, #self.RoomPool.SouthRooms)]
		
		neighborCell.LinkedRoom = Room.new(self.RoomPool.SouthRooms[math.random(1, #self.RoomPool.SouthRooms)]:Clone(), self.DungeonSizeX, self.DungeonSizeY)
		
		

	elseif directionPool == "West" then
		
		--neighborCell.LinkedRoom = self.RoomPool.WestRooms[math.random(1, #self.RoomPool.WestRooms)]
		
		neighborCell.LinkedRoom = Room.new(self.RoomPool.WestRooms[math.random(1, #self.RoomPool.WestRooms)]:Clone(), self.DungeonSizeX, self.DungeonSizeY)
		
	end
	
	--Create a "generate linked rooms"

	--Placing the actual room onto the cell
	
	--wait(2)
	
	self.OccupiedRooms:push(neighborCell)

	neighborCell.CellPart.Transparency = 1
	
	Room:PlaceRoom(neighborCell.LinkedRoom.RoomModel, neighborCell.CellPart)
	
	--If We Reached this point we know that we can safely form a link between 
	--the door that placed this room and the door facing the original door
	
	return true
	
end

function Dungeon:Generate()
	
	local StartingRoomColor = BrickColor.new("Baby blue")
	--This is the "Staring room" for the map
	self.Grid.Map[self.Grid.gridSizeX/2][self.Grid.gridSizeY/2].CellPart.BrickColor = StartingRoomColor
	
	self.Grid.Map[self.Grid.gridSizeX/2][self.Grid.gridSizeY/2].CellPart.Transparency = 1
	
	self.RoomQueue:push(self.Grid.Map[self.Grid.gridSizeX/2][self.Grid.gridSizeY/2])
	
	self.OccupiedRooms:push(self.Grid.Map[self.Grid.gridSizeX/2][self.Grid.gridSizeY/2])
	
	--Mark Starting room as occupied
	self.RoomQueue[1].Occupied = true

	self.RoomQueue[1].OccupiedInt = 1

	--Link room and cell together
	self.RoomQueue[1].LinkedRoom = Room.new(self.RoomPool.NorthRooms[math.random(1, #self.RoomPool.NorthRooms)], self.DungeonSizeX, self.DungeonSizeY)
	
	
	--We must place a starting room onto the current cell
	Room:PlaceRoom(self.RoomQueue[1].LinkedRoom.RoomModel , self.RoomQueue[1].CellPart)
	
	self.StartingRoom = self.RoomQueue[1]
	
	self.StartingRoom.LinkedRoom.RoomModel.Floor.BrickColor = BrickColor.new("Bright blue")
	
	self.StartingRoom.LinkedRoom.hasBeenActivated = true
	
	while(self.RoomQueue:length() > 0) do
		
		wait()

		--Gets us the current cell in the queue
		local currCell = self.RoomQueue:shift()
		
		--We want to visit each neighbor based on the exits of room
		
		for _, door in pairs(currCell.LinkedRoom.RoomDoors) do
			
			if door["exists"] then
				
				local created = false
				
				local neighborCell = self.Grid.NumericalMap[currCell.NumericalValue + door["directionalValue"]]

				created = self:Visit(neighborCell, door["oppositeDirectionPool"])
				
				--If a room is not created, it's an end room and added to the endroom queue
				if(created == false) then
					
					--We need to get a collection of prelimenary end rooms
					--Since this technique will visit a room multiple times, we need to make sure that
					--We're only adding rooms that haven't previously been visited by the algorithm
					
					if self.Grid:NeighborCount(currCell) == 1 and currCell.Visited ~= true then
						
						--currCell.CellPart.BrickColor =  BrickColor.new("Brick yellow")
						
						currCell.Visited = true

						self.PreEndRooms:push(currCell)
												
					end
					

				end
	
			end
	
		end

	end
	
	
	--Iterate over the prelimenary end room queue and find the actual end rooms later
	--We assume that the endPreRooms have been fully vetted for weirndess
	
	for i = 1, #self.PreEndRooms do

		local currCell = self.PreEndRooms:shift()

		if self.Grid:NeighborCount(currCell) == 1 then
						
			self.EndRooms:push(currCell)

		end
	end
	
	
	--Iterating over the final dungeon generation in order to hide doors that lead to nothing
	for _, cell in ipairs(self.OccupiedRooms) do
		
		for _, door in pairs(cell.LinkedRoom.RoomDoors) do
			
			if door["exists"] then
				
				local neighborCell = self.Grid.NumericalMap[cell.NumericalValue + door["directionalValue"]]
				
				--If we've found an unoccupied neighbor cell then we can safely deleted it/deactivate it 
				if neighborCell.Occupied == false then
					--[[
					--This will fully destroy/get rid of the door that needs to be deleted
					door["doorPart"]:Destroy()
					door["doorPart"] = nil
					door["exists"] = false
					]]
					--This is the correct way to "get rid of" doors that shouldn't technically be a part of the rooms post-generation
					door["doorObject"]:Hide(cell.LinkedRoom.RoomModel.Floor.BrickColor)
					door["exists"] = false
				else
					--However, if there is a room that exists, we can safely form a link between the room doors
					
					door["doorObject"].oppositeDoor = neighborCell.LinkedRoom.RoomDoors[door["oppositeDirectionPool"]].doorObject
					
					door["doorObject"].parentFloor = cell.LinkedRoom.RoomModel.Floor	
					door["doorObject"].parentRoom = neighborCell.LinkedRoom
					
				end
			end
		end
	end
	
	
	
	
	--Regenerate the dungeon if it doesn't meet the standards then generate the dungeon again
	--We're expecting at least 4 special rooms to generate so we need dungeons that fit this criteria
	
	
	
	if self.DungeonRoomCount < self.neededRooms or #self.EndRooms < self.neededEndRooms then

		self:CleanUp()

		self:Generate()
		
		return

	end


	
	--[[
	
	--IMPORTANT--
	
	 Generating the dungeon with special rooms requires the dungeon to have an appropriate amount
	 of end rooms in order for the special rooms to generate. Generally, this will occur just by convetion.
	 But there are edge cases where this could potentially occur if we go over the 3 current special rooms that are generated
	 
	]]
	
	--[[
	
	This is where we will handle the creation of special rooms
	
	]]
	--We need to remove the very last room of the dungeon in order to get the furthest node from the start
	local boss1 = table.remove(self.EndRooms, self.EndRooms:length())
	boss1.CellPart.BrickColor = BrickColor.new("Really red")

	local shop1 = self.EndRooms:poprandom()
	shop1.CellPart.BrickColor = BrickColor.new("Brown")

	local treasure1 = self.EndRooms:poprandom()
	treasure1.CellPart.BrickColor = BrickColor.new("Gold")
	
	print("Dungeon took: ", self.RegenCount, " times to generate")
	

	
	
end


function Dungeon:CleanUp()
	
	
	self.RegenCount = self.RegenCount + 1
	
	print("Attempting to clean Dungeon up... ")
	for i, cell in ipairs(self.OccupiedRooms) do
		
		cell.Occupied = false
		cell.OccupiedInt = 0
		cell.NeighborCount = 0
		cell.Visited = false
		cell.AvailDirs = {N = false, E = false, S = false, W = false}
		cell.LinkedRoom.RoomModel:Destroy()
		
		--We need to clear up the memory associated with the monsters in each room
		
		for i, monster in ipairs(cell.LinkedRoom.Monsters) do
			
			monster:CleanUp()
			
		end
		table.clear(cell.LinkedRoom.Monsters)
		cell.LinkedRoom = nil
		cell.CellPart.Transparency = 0
		
		--This is just for visual debugging.
		cell.CellPart.BrickColor = BrickColor.new("Institutional white")
		
		--Removing the current cell from the occupiedrooms table is important since
		--We're getting rid of each of all aspects of the current cell in the occupied room
		self.OccupiedRooms[i] = nil

	end
	
	--No more rooms left in the dungeon
	self.DungeonRoomCount = 0
	
	self.PreEndRooms:clear()
	self.EndRooms:clear()
	table.clear(self.RoomPool)
	self.RoomQueue:clear()
	self.OccupiedRooms:clear()
	
	--Need to reset where it thinks the starting rooms is as well

	self.StartingRoom = nil
	
	--Replenish the Room Pool for future generation
	self.RoomPool = Room:GetPotentialRooms(self.DungeonSizeX, self.DungeonSizeY)
	
end


function Dungeon:FullCleanUp()
	
	
end


return Dungeon
