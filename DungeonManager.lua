local Dungeon = require(game:GetService("ServerStorage").Dungeon)

local dungeonLevel = 2
local neededEndRooms = 3

local newDungeon  = Dungeon.new(10, 10, dungeonLevel, workspace.InitalGridCellLocations.P1, neededEndRooms)

newDungeon:Generate()

--This is where you would want to place the player at the dungeon since it will yield until generation is complete
local Players = game:GetService("Players")

for i, v in pairs(Players:GetPlayers())do
	
	print(i, v)
	
	v.Character.HumanoidRootPart.CFrame = CFrame.new(newDungeon.StartingRoom.LinkedRoom.RoomFloor.CFrame * Vector3.new(0, 5, 0))
	
end