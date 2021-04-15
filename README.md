# IsaacDungeonRblx


# How to use


# Useful functions


## Dungeon
 
Dungeon has a few functions that are key to use and are meant to be used with code for managing players, although I have provided a bare-bones example to get people started.
Ideally, you would declare a new dungeon using **Dungeon.new()** with the require parameters, then use **Dungeon:Generate()** In order to begin the processes of the dungeon generating. The dungeon will clean itself, up and also regenerate itself if it does not meet the specificied amount of rooms and end rooms as well.

# Monsters

Monsters are a very simple implementation of AI using the ECS framework and signals, they don't do damage and are just there so they can be despawned in order to trigger the opening and closing of dungeon rooms. I advise to replace with your own AI.
