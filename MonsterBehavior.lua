local Debris = game:GetService("Debris")

local MonsterBehavior = {
	
	--These functions assume a valid monster object will be passed to them.
	
	["MoveTowardsTarget"] = function(monster)
		
		--We need to get a reference of the object somehow...
		
		local newMonster = monster()

		newMonster.monsterHumanoid:MoveTo(newMonster.target.HumanoidRootPart.Position)
		
	end;
	
	["MoveAwayFromTarget"] = function(monster)
		
		
		
	end;
	
	["Jump"] = function(monster)
		
		local newMonster = monster()
		
		newMonster.monsterHumanoid.Jump = true
		
	end;
	
	
	["Fakeout"] = function(monster)
		
		
		
	end,
	
	
}




return MonsterBehavior
