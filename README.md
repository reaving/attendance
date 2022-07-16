# attendance
Go to your Windower4\addons folder.
Create a new folder called "attendance".
Copy the "attendance.lua" file into that folder.

You can type "lua r attendance" in the Windower Console to load immediately.
To load the addon everytime you log in, add "lua load attendance" to your "Windower4\scripts\init.txt" file.

This addon will create a CSV file called "attendance.csv" in the attendance addon folder.

To test this add on, zone into Heaven's Tower from Windurst Walls.
When you do this, it will wait 30 seconds and then add the entry to the CSV file.
If the CSV file does not exist, it will create it.

It should create something like this when you zone into Heaven's Tower:

eventType,eventDate,eventDay,eventDateTime,eventZone,name,count

TEST,2022-07-09,0709,2022-07-09 01:26,Heavens Tower,Wunjo,1
