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
        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open doors")
        if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
            Bus.OpenDoors()
        end
    end
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
        Job.nextStop = 1
        Route.SetGps(Job.route)

        -- TODO: Trigger Bond Deposit
        
        -- Spawn a bus
        Bus.Create(route.type, Config.coordinates, function(bus) 
            TaskWarpPedIntoVehicle(PlayerPedId(), bus, -1)
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