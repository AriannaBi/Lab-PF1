# PF1 Project

See [the instructions](https://usi-pl.github.io/pf1-2019/hw/project.html).

MAZE GAME
Razvan Petrica Onciu
Arianna Bianchi

-----------------User level documentation-----------------------
We create a maze random generator.

First, we divide a square of 1000x1000px into 100 cells, considering the plan as a Cartesian Plane with x axis and y axis.
The x and y axis are divided into 10 ranges each of 100px starting from 0.
We have a random list of lists: for example ‘((0 0 0 0) (0 0 0 0)...) called LIST-OF-WALLS that states the condition of the walls (0 if the wall is closed and 1 if it’s open).
We create two functions create-rows and create-cols that create the entire grid of the maze. the grid is formed by 100 cells each of 100px for the x and for the y position.
Every side of the cell is formed by one segment created by this two function and these are the walls of the maze. We create the function list-of-walls that creates random a LIST-OF-WALLS and the functions color-picker-columns and color-picker-rows decide if the wall of the cell is black (if it is 1 = open) or white (if it is 0 = closed).
Then, when the random walls are setting, we set the real path that follows the diagonal of the plan cartesian from the first cell with coordinates (0;0) to the last coordinate (1000;1000).
With two functions list-rows and list-columns we changed some value of the LIST-OF-WALLS because for example two cells adjacent has a common side, that in the first cell is 0 but in the second cell is 1, but the wall is the same for both the cell so it must have just one value.

The ball starts in the first cell which has coordinates (10,10) and moves to up, right, down and left with the arrow key. The ball runs as it's in a physic world so it decelerates by itself. The ball can exceed the wall if the ball is in the first and last cell of the y axis. In this way the maze is continued.


The user can use the program just by moving the ball and manage to reach the end point which is the last cell of the maze.


•	Structs:
o	World-game which contains a canvas and the maze
o	Player with a x and a y position and a dx and dy velocity

•	Constants: to define the canvas with width and height setting at 1000px, a scale of 10px and a red background.

•	Lists:
o	List of walls that creates random a list of 100 argument, each of them contains 4 number among 0 and 1 that are the              walls of the maze. 0 if there is the wall and 1 if there isn’t the wall.
o	List of the path which creates the path in diagonal.
o	List-R for the list that takes as input the list of path and create a new list with every row matched.
o	List-C for the list that takes as input the list-R and create a new list with every column matched.


•	Recursions: mostly more than the half of our functions.
-----------------End of user level documentation-----------------------



-----------------Developer level documentation-----------------------
The package required by the program are
1.(require 2htdp/image)
2.(require 2htdp/universe)
3.(require racket/list)
The first package is used for the place-image, the second one for run the big-bang and the third for some functions of the lists, such as drop-right and list-set.

WHAT CHANGES: the position of the ball and its velocity
WHAT DOES NOT CHANGE: the global constants
-----------------End of developer level documentation-----------------------
