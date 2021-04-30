
-- Load up the ESX. Its a single line cause im a lazy git and prefer it this way
ESX = nil
Citizen.CreateThread(function()
    while true do
        if ESX == nil then
            TriggerEvent("esx:getSharedObject", function(library)
                ESX = library
                BusStop.RegisterEvents(ESX)
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

function OnJobMarker() 
    if Job.active then
        ESX.ShowHelpNotification("Press ~g~~INPUT_CONTEXT~~s~ to end your route and surrend the bound")
    else
        ESX.ShowHelpNotification("Press ~g~~INPUT_CONTEXT~~s~ to begin your route", true)
        if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
            print("YOU PRESSED THE BUTTON")
        end
    end
end

function OnBusMarker() 
    ESX.ShowHelpNotification("Get ~r~out~s~ of the bus to end your route")
end

-- Draw all the markers and handle the main game loop
Citizen.CreateThread(function()
    local frame = 0;
    while true do
        Citizen.Wait(5)
        BusStop.Render()
        
        -- Draw the zone to spawn the bus
        -- DrawBusZone(Config.coordinates, Config.coordinates.w, { r = 255, 0, 0 })

        local coords    = GetEntityCoords(PlayerPedId())
        local vehicle   = GetVehiclePedIsIn(PlayerPedId()) 
        local distance  = GetDistanceBetweenCoords(coords, Config.coordinates, false)


        -- Draw the bus return marker
        -- TODO: Check if player is in same bus
        if vehicle ~= nil and vehicle == Job.bus then
            if distance < 1.5 then
                DrawBusZone(Config.coordinates, Config.coordinates.w, { r = 255, 0, 0 })
                OnBusMarker()
            else
                DrawBusZone(Config.coordinates, Config.coordinates.w, { r = 200, 100, 0 })
            end
        else 
            -- Draw the job marker
            if distance < 1.5 then
                DrawZoneMarkerGrounded(Config.coordinates, 3, { r = 255, 0, 0 })
                OnJobMarker()
            else
                DrawZoneMarkerGrounded(Config.coordinates, 3, { r = 200, 100, 0 })
            end
        end
       
    end
end)

-- Draw the debug visualisations
if Config.debug then
    FindStops = false
    Citizen.CreateThread(function()
        local frame = 0;
        while true do
            Citizen.Wait(5)
            frame = frame + 1

            if FindStops then
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
        
        end
    end)
end