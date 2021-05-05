
DEBUG_FindStops = false

-- Load up the ESX. Its a single line cause im a lazy git and prefer it this way
ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        if ESX == nil then
            TriggerEvent("esx:getSharedObject", function(library)
                ESX = library
                BusStop.RegisterEvents(ESX)
                Route.RegisterEvents(ESX)
                EnsureJob(ESX.PlayerData)
            end)
            
            Citizen.Wait(0)
        end
    end
end)

-- Ensures the job blip
local blip = nil
function EnsureJob(playerData)
    if playerData == nil then return end 
    if playerData.job == nil then return end
    
    local jobName = playerData.job.name
    if jobName == 'busdriver' then
        if blip ~= nil then
            SetBlipDisplay(blip, 4)
        else
            blip = CreateBlip(513, Config.coordinates, "Bus Depo", 1.0, 16)
        end
    elseif blip ~= nil then
        SetBlipDisplay(blip, 0)
    end
end

-- Load up the player data
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
    EnsureJob(ESX.PlayerData)
end)

-- Load up the player job
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
    ESX.PlayerData["job"] = newJob
    EnsureJob(ESX.PlayerData)
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

        -- This is technically bugged. Means you can walk home without your bus
        if Job.isRouteFinished then
            ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~g~finish~s~ your route and ~r~forfeit~s~ your bond.", true, false)
            if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
                Job.End(false, false)
            end
        else
            ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~r~forfeit~s~ your route and your bond.", true, false)
            if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
                Job.End(true, false)
            end
        end
    else
        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to begin a route.", true, false)
        if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
            Job.Begin()
        end
    end
end

function OnBusMarker() 
    if Job.isRouteFinished then
        ESX.ShowHelpNotification("Press ~INPUT_VEH_EXIT~ to ~g~finish~s~ your route", true, false)
    else
        ESX.ShowHelpNotification("Press ~INPUT_VEH_EXIT~ to ~r~forfeit~s~ your route", true, false)
    end

    -- Wait for the bed to leave the vehicle
    if not IsPedInVehicle(PlayerPedId(), Bus.current, true) then
        Job.End(Job.isRouteFinished == false, true)
    end
end


-- Draw all the markers and handle the main game loop
Citizen.CreateThread(function()
    local frame = 0;
    while true do
        Citizen.Wait(5)

        -- Render either the specific stop or all the stops
        if Config.alwaysRenderStops then
            BusStop.RenderAll(Config.stopColor)
        elseif Job.active then
            local stop = Job.GetNextStop()
            if stop ~= nil then  BusStop.Render(stop, Config.stopColor) end
        end
        
        -- Draw the zone to spawn the bus
        -- BusStop.DrawZone(Config.coordinates, Config.coordinates.w, { r = 255, 0, 0 })

        local coords    = GetEntityCoords(PlayerPedId())
        local vehicle   = GetVehiclePedIsIn(PlayerPedId(), true) 
        local distance  = GetDistanceBetweenCoords(coords, Config.coordinates, false)
        local onMarker = false

        -- Draw the bus return marker
        if vehicle ~= nil and vehicle == Bus.current then
            distance = GetDistanceBetweenCoords(GetEntityCoords(vehicle), Config.coordinates, false)
            if distance < 1.5 then
                BusStop.DrawZone(Config.coordinates, Config.coordinates.w, { r = 255, 0, 0 })
                OnBusMarker()
                onMarker = true
            else
                -- Draw where to park the bus
                BusStop.DrawZone(Config.coordinates, Config.coordinates.w, { r = 200, 100, 0 })
            end
        else 
            -- Draw the job marker
            if distance < 1.5 then
                DrawGroundedZoneMarker(Config.coordinates, 3, { r = 255, 0, 0 })
                OnJobMarker()
                onMarker = true
            else
                DrawGroundedZoneMarker(Config.coordinates, 3, { r = 200, 100, 0 })
            end
        end

        
        -- Run the job
        if not onMarker and Job.active then
            Job.Process()
        end

    end
end)

-- Draw the debug visualisations
if Config.debug then
    DoorsOpen = false
    Citizen.CreateThread(function()
        local frame = 0;
        while true do
            Citizen.Wait(5)
            if DEBUG_FindStops then
                frame = frame + 1
                local radius = 15.0
                local propCoords = false
                
                radius = 500
                local closestObject = FindClosestObject(BusStop.Models, radius)
                if closestObject then 
                    propCoords = GetEntityCoords(closestObject)
                    DrawGroundedZoneMarker(propCoords, 10.0, { r = 255, g = 0, b = 255 }) 

                    if frame % 2 == 0 then
                        SetNewWaypoint(propCoords.x, propCoords.y)
                    end
                end
            end
        
        end
    end)
end