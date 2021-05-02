Job = {}

Job.active = false
Job.route = nil
Job.nextStop = 1
Job.canLoadPassengers = false

-- Internal update loop
Job.UpdateThread = function() 
    if not Job.active then return end

    local stop = Job.GetNextStop()
    if not stop then return end
    
    -- Set the GPS
    local stopCoords = vector3(stop.x+.0, stop.y+.0, stop.z+.0)
    SetNewWaypoint(stopCoords)

    -- Check if the bus is on it
    if Bus.current == nil then
        ESX.ShowHelpNotification("Get back into your bus.")
        return
    end

    local coords = GetEntityCoords(Bus.current)
    local heading = GetEntityHeading(Bus.current)
    local distance = GetDistanceBetweenCoords(coords, stopCoords, false)
    local headingDiff = (heading - stop.heading + 180 + 360) % 360 - 180
    Job.canLoadPassengers = false    
    if distance <= Config.stopDistanceLimit then
        if headingDiff <= Config.stopHeadingLimit and headingDiff >= -Config.stopHeadingLimit then
            Job.canLoadPassengers = true
        end
    end

    if Job.canLoadPassengers then
        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open and close doors")
        if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
            --Bus.OpenDoors()
            Citizen.CreateThread(function() 
                Job.DepartPassengers(function() 
                    Job.BoardPassengers(function()
                        Bus.CloseDoors()
                        Job.nextStop = Job.nextStop + 1
                        ESX.ShowNotification('All passengers ready', true, false, 60)
                        PlaySoundFromEntity(-1, "Burglar_Bell", Bus.current, "Generic_Alarms", 0, 0)
                    end)
                end)
            end)
        end
    end
end

Job.DepartPassengers = function(callback)
    print('kicking the lil shits off')

    -- Tell passengers when their destination arrived
    for i, p in pairs(Bus.passengers) do
        if p.destination == Job.nextStop then
            Bus.RemovePassenger(i)
        end
    end

    -- Wait for them to leave
    print('waiting for them to leave')
    while not Bus.CheckPassengersDisembarked(function(passenger) 
        -- Tell the ped to wander around. We dont care.
        TaskWanderStandard(passenger.ped, 10.0, 10)
        RemovePedElegantly(passenger.ped)
    end) do Citizen.Wait(10) end
    
    -- Finally callback
    print('everyone off')
    ESX.ShowNotification('Passengers disembarked', true, false, 60)
    callback()
end

-- Spawns passengers
Job.BoardPassengers = function(callback)
    print('boarding new shits')
    local stop = Job.GetNextStop()
    if not stop then 
        print('stop does not exist')
        return false 
    end

    -- We will use this and ensure it has gone up
    local initialPassengerCount = #Bus.passengers
    local spawnCount = 0

    -- Spawn in the passengers
    for i,destination in pairs(stop.passengers) do

        -- TODO: Randomise the spot check
        local hasSafeSpot, spot = GetSafeCoordForPed(stop.x, stop.y, stop.z, true, 1)
        if not hasSafeSpot then 
            print('no safe spot exists')
            return false 
        end

        if Config.debug then
            print('creating random ped')
            DrawZoneMarkerTTL(spot, 2, {r=255,0,0}, 1000)
        end

        -- We check if we actually got available seats on the bus before attempting to spawn
        if Bus.FindFreeSeat() ~= false then
            spawnCount = spawnCount + 1
            SpawnRandomPed(spot, function(ped)
                -- However, we let the bus determine the seat after the fact because async delay
                local passenger = Bus.AddPassenger(ped, nil) 
                Bus.SetPassengerDestination(passenger, destination)
            end)
        else
            print('unable to find any seats')
            return false
        end
    end
        
    -- Wait till they are all spawned
    print('waiting for passenger count to go up')
    while #Bus.passengers < initialPassengerCount + spawnCount do Citizen.Wait(100) end

    -- Wait till they are all on the bus
    print('waiting for passenger onboard')
    while not Bus.CheckPassengersEmbarked() do Citizen.Wait(100) end

    -- Finally callback
    print('We are ready')
    ESX.ShowNotification('Passengers embarked', true, false, 60)
    callback()
    return true
end

-- Teleports the bus to the next stop perfectly
Job.Teleport = function()     
    local stop = Job.GetNextStop()
    if not stop then 
        print('No stop available')
        return false
    end

    local ped = GetPlayerPed(PlayerPedId())
    print('Setting ped coords', stop.x, stop.y, stop.z, stop.heading)
    SetPedCoordsKeepVehicle(PlayerPedId(), stop.x+.0, stop.y+.0, stop.z+.0)
    SetEntityHeading(PlayerPedId(), stop.heading+.0)
    return true
end

-- Begins the job
Job.Begin = function(callback) 
    Job.active = true

    ESX.TriggerServerCallback(E.BeginJob, function(route) 

        -- Validate the route
        if route == nil then
            ESX.ShowNotification('There is ~r~no~s~ routes available for you', true, true, 10)
            Job.active = false
            return
        end
        
        Job.route = route
        Job.nextStop = 2
        --Route.SetGps(Job.route)
        
        -- if Config.debug then print(ESX.DumpTable(Job.route)) end
        
        -- TODO: Trigger Bond Deposit
        
        -- Spawn a bus
        Bus.Create(route.type, Config.coordinates, function(bus) 
            if bus == nil then 
                Job.End(false) 
                ESX.ShowNotification('~r~Your bus failed to spawn for some reason', true, true, 10)
                return 
            end

            TaskWarpPedIntoVehicle(PlayerPedId(), bus, -1)
            Citizen.Wait(10)

            ESX.ShowNotification('You have started working', true, true, 10)
            if callback then callback(route) end
        end)
    end)
end

-- Ends the job
Job.End = function(forfeit) 
    -- Disable the active state of the job
    Job.active = false
    
    -- Wait for the user to leave the bus
    if forfeit then
        ESX.ShowNotification('You have ~r~forfeited~s~ your route', true, true, 10)
    else 
        ESX.ShowNotification('You have ~g~completed~s~ your route', true, true, 20)
        --TODO: Trigger Bond Repayment
    end

    -- Finally clear the route
    Bus.Destroy()
    Job.route = nil
end


-- Gets the stop the bus has to get to
Job.GetNextStop = function() 
    if Job.route and #Job.route.stops >= Job.nextStop then
        return Job.route.stops[Job.nextStop]
    end
    return false
end