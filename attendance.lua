-- Include Windower libraries.
require('luau')
files = require('files')

-- Addon Author and Version Information
_addon.name = 'Attendance'
_addon.author = 'Wunjo'
_addon.commands = {'Attendance', 'attend'}
_addon.version = '1.0.0.3'

-- 1.0.0.1: Initial version
-- 1.0.0.2: Cleaned up comments in SaveAllianceList()
-- 1.0.0.3: Tightened code and added more comments explaining about the res.zones dictionary
--          The goal is to publish this attendance-taking addon so that other people can help
--          take attendance whenever I cannot attend an event.  Needs to be easy to understand 
--          so that people will not be afraid to use it.

-- This event fires every time you zone.
windower.register_event('zone change',function(new_id,old_id)
    
    -- The parameter, new_id, is a number that represents the zone that you are entering.
    -- You can get the zone's name by using the res.zones dictionary.  The zones dictionary 
    -- can be found in "windower\res\zones.lua".
    -- 
    -- For example:
    -- When you zone into [Reisenjima Henge], this event will occur and the "new_id" parameter 
    -- will be [292].  If you check the res.zones dictionary for entry [292], you should see:
    -- [292] = {id=292,en="Reisenjima Henge",ja="é†´æ³‰å³¶-ç§˜å¢ƒ",search="ReisenHenge"},
    -- 
    -- res.zones[292].id will give you the number 292
    -- res.zones[292].en will give you the string "Reisenjima Henge"
    -- res.zones[292].search will give you the string "ReisenHenge"
    -- 
    -- "res" = windower resources (windower\res)
    -- "zones" = the lua file within the res folder containing the zone dictionary
    -- "en" = English name or the "en" field for that entry in the dictionary
    
    -- Using the zone dictionary, get the name of the zone that you just entered.
    local zoneName = res.zones[new_id].en
    
    if zoneName == "Reisenjima Henge" then
        WaitCountDown()
        log('Taking attendance for Omen')
        SaveAllianceList('Omen',zoneName)
        
    elseif zoneName:startswith("Dynamis") and zoneName:endswith("[D]") then
        WaitCountDown()
        log('Taking attendance for Dynamis[D]')
        SaveAllianceList('Dynamis',zoneName)
        
    elseif zoneName == "Heavens Tower" then
        -- Test this functionality by zoning into "Heaven's Tower".
        WaitCountDown()
        log('Testing')
        SaveAllianceList('TEST',zoneName)
        
    end
end)

-- There's probably a better way to do this, but this way is simple.
function WaitCountDown()
    -- Wait for 30 seconds so that everyone in the alliance can load in.
    -- The log text only appears on the user's screen and nowhere else.
    coroutine.sleep(5)
    log('Taking attendance in 25 seconds')
    coroutine.sleep(5)
    log('Taking attendance in 20 seconds')
    coroutine.sleep(10)
    log('Taking attendance in 10 seconds')
    coroutine.sleep(10)
end

-- The "SaveAllianceList" function calls this function to get a formatted date/time.
function GetNow()
    -- os.date will get the system's date/time information
    -- See Also: https://www.lua.org/pil/22.1.html
    local Now = os.date("*t")
    
    -- Separate the date/time information out into its parts so that we can format it.
    local dtYear, dtMonth,  dtDay    = Now.year, Now.month, Now.day
    local dtHour, dtMinute, dtSecond = Now.hour, Now.min,   Now.sec
    
    -- return the formatted date/time string (yyyy-mm-dd hh:mm)
    -- See Also: https://www.lua.org/pil/20.html
    return string.format("%04d-%02d-%02d %02d:%02d", dtYear, dtMonth, dtDay, dtHour, dtMinute)
end

-- This function saves the current alliance player list to the attendance text file in a 
-- human-readable comma-delimited format that can be opened in Notepad, Excel, LibreOffice, 
-- or Google Sheets.
function SaveAllianceList(eventType,eventZone)
    
    -- Set a reference to the attendance file.
    local file = files.new('attendance.csv')
    -- Does the attendance file exist already?
    if not file:exists() then
        -- if that file does not exist, then create it and set the column headers.
        file:create()
        file:append('eventType,eventDate,eventDay,eventDateTime,eventZone,name,count\n')
    end
    
    -- Get the current date/time "yyyy-mm-dd hh:mm"
    eventDateTime = GetNow()
    -- Get the current date/time "mmdd" (month and day)
    -- See Also: http://lua-users.org/wiki/StringLibraryTutorial
    eventMMDD = string.sub(eventDateTime,6,7)..string.sub(eventDateTime,9,10)
    -- Get just the date from the date/time "yyyy-mm-dd" (year-month-day)
    eventDate = string.sub(eventDateTime,1,10)
    
    -- "windower.ffxi.get_party()" returns a dictionary(table) that contains information about your alliance.
    -- See Also: https://github.com/Windower/Lua/wiki/FFXI-Functions#windowerffxiget_party
    -- Each entry in the "get party" dictionary has a "key" and a "value".
    -- 
    -- Here is an example of a two-person party.
    -- i (the "key" or index)   v (the "value")
    -- ------------------------ -----------------------------------------------------------------------
    -- party1_count             (number of people in party #1)
    -- p1                       (table, has info like hp/mp/tp/name)
    -- party3_count             (number of people in party #3)
    -- alliance_count           (number of people in alliance)
    -- party2_count             (number of people in party #2)
    -- p0                       (table, has info like hp/mp/tp/name)
    -- party_leader             (some sort of reference or index representing the party leader)
    -- 
    -- FYI: p0 is yourself, p1-p5 are your party members, a10-a15 and a20-a25 are your alliance members.
    
    -- Use the "for" loop to check each entry.
    -- We look for entries where the "value" is a table, and from that table, we can get the character name.
    
    if windower.ffxi.get_party().alliance_count > 3 or eventType == 'TEST' then
        -- For each entry in the "get party" dictionary, get the "index" and "value"
        for i,v in pairs(windower.ffxi.get_party()) do
            
            -- Is the "value" a table?
            if type(v) == 'table' then
                -- Yes.  Add an entry to the attendance file with the following information:
                -- event type (Dynamis or Omen), date, month/day, date/time, zone name, character name, the number one
                -- 
                -- For example:
                -- Dynamis,2022-07-02,0702,2022-07-02 20:48,Dynamis - Bastok [D],Wunjo,1
                -- Omen,2022-07-03,0703,2022-07-03 20:50,Reisenjima Henge,Wunjo,1
                
                -- This is not a test.
                file:append(eventType..','..eventDate..','..eventMMDD..','..eventDateTime..','..eventZone..','..v.name..',1\n')
            end
        end
        
        -- Tell the user that the work is done.
        log('Alliance List Recorded')
    else
        log('Not enough players in party, did not record alliance list')
    end
end
