
-- Load up the ESX. Its a single line cause im a lazy git and prefer it this way
ESX = nil
Citizen.CreateThread(function()
    while true do
        if ESX == nil then
            TriggerEvent("esx:getSharedObject", function(library)
                print('Found ESX')
                ESX = library
            end)
            
            Citizen.Wait(0)
        else 
            Citizen.Wait(500)
        end
    end
end)

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

-- Spawn a bus
RegisterNetEvent(E.SpawnVehicle)
AddEventHandler(E.SpawnVehicle, function() 
    print('Spawn Event: ' .. E.SpawnVehicle)
    --local xPlayer = ESX.GetPlayerFromId(playerId)
    local ped = GetPlayerPed(-1)

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    ESX.Game.SpawnVehicle("bus", coords, heading, function(vehicle) 
        print(DoesEntityExist(vehicle), 'this code is async!')
    end)
end)


-- Debug Visualisation
Citizen.CreateThread(function()
    local frame = 0;
    while true do
        Citizen.Wait(5)
        frame = frame + 1

        local radius = 15.0
        local propCoords = false
        
        radius = 500
        local closestObject = FindClosestObject(BusStop.Models, radius)
        if closestObject then 
            propCoords = GetEntityCoords(closestObject)
            DrawZoneMarkerGrounded(propCoords, 10.0, { r = 255, g = 0, b = 255 }) 

            if frame % 2 == 0 then
                SetNewWaypoint(propCoords.x, propCoords.y)
            end
        end
      
    end
end)