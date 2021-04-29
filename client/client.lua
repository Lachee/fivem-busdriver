
-- Load up the ESX. Its a single line cause im a lazy git and prefer it this way
ESX = nil
Citizen.CreateThread(function() while not ESX do TriggerEvent("esx:getSharedObject", function(library) ESX = library end) end end)

-- Load up the player data
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
end)

-- Load up the player job
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
    ESX.PlayerData["job"] = newJob
end)

