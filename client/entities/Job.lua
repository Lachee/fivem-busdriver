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
            Job.SpawnPassengers()
        end
    end
end

-- Spawns passengers
Job.SpawnPassengers = function(callback)
    local stop = Job.GetNextStop()
    if not stop then 
        print('stop does not exist')
        return false 
    end

    print('finding safe ped spot')
    local hasSafeSpot, spot = GetSafeCoordForPed(stop.x, stop.y, stop.z, true, 1)
    if not hasSafeSpot then 
        print('no safe spot exists')
        return false 
    end

    print('creating random ped')
    DrawZoneMarkerTTL(spot, 2, {r=255,0,0}, 1000)
    local seat = Bus.FindFreeSeat()
    if seat ~= false then
        SpawnRandomPed(spot, function(ped) Bus.RequestPedToSeat(ped, seat) end)
    else
        print('unable to find any seats')
        return false
    end

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
        Route.SetGps(Job.route)
        
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