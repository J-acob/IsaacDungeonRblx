# IsaacDungeonRblx
IsaacDungeonRblx is an attempt to mirror the algorithm for the binding of isaac 


# How to use

Simply get the model from [here](https://www.roblox.com/library/6685544942/Binding-Of-Isaac-Dungeon-Generator) and follow the ReadMe once loaded into roblox studio.


# Useful functions


## Dungeon
 
Dungeon has a few functions that are key to use and are meant to be used with code for managing players, although I have provided a bare-bones example to get people started.
Ideally, you would declare a new dungeon using **Dungeon.new()** with the require parameters, then use **Dungeon:Generate()** In order to begin the processes of the dungeon generating. The dungeon will clean itself, up and also regenerate itself if it does not meet the specificied amount of rooms and end rooms as well.

# Monsters

Monsters are a very simple implementation of AI using the ECS framework and signals, they don't do damage and are just there so they can be despawned in order to trigger the opening and closing of dungeon rooms. I advise to replace with your own AI.
