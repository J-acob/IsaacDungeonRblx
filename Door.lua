local Door = {}

Door.__index = Door

local Players = game:GetService("Players")

function Door.new(doorPart)
	
	local newDoor = {}
	
	local self = setmetatable(newDoor, Door)
	
	--Doors are never hidden initially
	self.isHidden = false
	self.doorPart = doorPart
	self.doorPart.CanCollide = true
	self.oppositeDoor = nil
	self.oppositeDirection = nil
	self.enterable = true -- All doors should be enterable by default
	self.parentFloor = nil
	self.parentRoom = nil
	self.canBeTouched = true
	
	self.doorPart.Touched:Connect(function(part)
		
		if self.canBeTouched == true then
			
			print("Door can be touched!")
			
			if part.Parent:FindFirstChild("Humanoid") then	
				
				local player = Players:GetPlayerFromCharacter(part.Parent)			
				if player then				

					--player.Character.HumanoidRootPart.CFrame = self.oppositeDoor.doorPart.CFrame + Vector3.new(1, 1, 1)

					--We should also check to make sure that the door is "enterable" to prevent players from enterig unenterable rooms

					if self.enterable == true and self.isHidden == false then

						player.Character.HumanoidRootPart.CFrame = self.oppositeDoor.doorPart.CFrame + self.oppositeDirection
	
						self.parentRoom:Activate()

					end

					--This is where we should actiave the room we're trying to enter but ONLY if it hasn't been previously activated
				end			
			end	
	
		end
		
	end)
	
	return self
end


function Door:Open()
	
	self.enterable = true
	self.canBeTouched = true
	self.doorPart.Transparency = 0.5
	self.doorPart.BrickColor = BrickColor.new("Dark green")

	
end

function Door:Close()
	
	self.enterable = false
	self.canBeTouched = false
	self.doorPart.Transparency = 0
	self.doorPart.BrickColor = BrickColor.new("Really red")
	
	
end

function Door:Hide(doorColor)
	
	--We want the door to adopt the color of the room it's currently in in order to stay "hidden" from the player
	--Hidden doors shouldn't be counted in the dungeon opening process
	self.doorPart.Transparency = 0
	self.doorPart.BrickColor = doorColor
	self.doorPart.CanCollide = true
	self.isHidden = true
	self.canBeTouched = false
	
end

function Door:PrintStatus(arg)
	
	print("Argument passed with: ", arg)
	
end




return Door
