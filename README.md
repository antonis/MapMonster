# MAP MONSTER #

Map Monster is a quiz game using Google Streetview to transfer the user to a random place. The user should guess the place between two available options.

![Screenshot](GeoGame/Assets.xcassets/AppIcon.appiconset/Icon60%403x.png)

## Game Design Notes ##

### Objectives ###

* The game should be “easy to learn but hard to master"
* Players experience Beginner’s Luck when they start the early levels

### Values ###

* lives (♡)
	* initially 5

* score
	* for every correct question the remaining seconds are added up to the score

* places
	* it increases by one for every answer (right or wrong)

* wins
	* it increases by one for every correct answer

* level
	* start at 1
	* increase by one for every 10 places

* level wins
	* it increases by one for every correct answer
	* it becomes zero when you start a new level

* consecutive wins
	* it increases by one for every correct answer
	* it becomes zero for every wrong answer

* stars (☆)
	* initially 0

* timer duration
    * Initially 30 secs
    * Decreases by 5 for every level
    * It cannot be less than 10 secs

### Achievements ###

* Get a ☆
	* if you get MIN(5+level, 10) level wins
	
* Get a ♡
	* if you get MIN(2+level, 10) wins in a row
	* if you get 3 ☆
