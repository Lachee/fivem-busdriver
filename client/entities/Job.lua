Job = {}

Job.active = false
Job.route = nil
Job.nextStop = 1
Job.canBoardPassengers = false
Job.preloadedPeds = nil
Job.boardingPeds = nil
Job.isBoarding = false
Job.isRouteFinished = false

-- Internal update loop
Job.Process = function() 
    if not Job.active then return end

    local stop = Job.GetNextStop()
    if stop ~= nil then
        -- Check if the bus is on it
        if Bus.current == nil then
            ESX.ShowHelpNotification("Get back into your bus.", true, false)
            return
        end
        
        -- Determine how far away we are
        local stopCoords = vector3(stop.x+.0, stop.y+.0, stop.z+.0)
        local coords = GetEntityCoords(Bus.current)
        local heading = GetEntityHeading(Bus.current)
        local distance = GetDistanceBetweenCoords(coords, stopCoords, false)
        local headingDiff = (heading - stop.heading + 180 + 360) % 360 - 180

        -- Determine if we can preload
        if distance <= Config.passengerRadius then
            Job.PreloadPeds()
        end

        -- Cull any vehicles on the spot
        if distance <= 25.0 and stop.clear > 0.0 then
            -- TODO: Text Owners that their vehicle was deleted because it was illegal
            -- parked in a bus stop
            ClearVehiclesInArea(vector3(stop.x, stop.y, stop.z), stop.clear + .0)
            stop.clear = 0
        end

        -- Determine if we can pickup passengers
        Job.canBoardPassengers = false
        if distance <= Config.stopDistanceLimit then
            if headingDiff <= Config.stopHeadingLimit and headingDiff >= -Config.stopHeadingLimit then
                Job.canBoardPassengers = true
            end
        end

        -- We are not boarding and we are not in a spot that can board passengers. Tell the user to go to the stop
        if Job.isBoarding then
            -- We are boarding, so keep the controls disabled and the hazards on
            Bus.SetHazards(true)
            DisableControlActions(0, {
                Controls.INPUT_VEH_ACCELERATE,
                Controls.INPUT_VEH_BRAKE
            }, true)
        else
            -- We are not boarding, display the help notification
            if not Job.canBoardPassengers then
                local stopName = '~y~'.. stop.id .. '~s~ | ~y~' .. stop.name .. '~s~'
                ESX.ShowHelpNotification('Drive to ' .. stopName, true, false)

                -- Close the damn doors
                if not IsVehicleStopped(Bus.current) then
                    Bus.CloseDoors()
                end
            end
        end


        -- If we can board passengers
        if Job.canBoardPassengers then
            if not Job.isBoarding then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open and close doors", true, false)
            end

            -- Disable the control
            DisableControlActions(0, {
                Controls.INPUT_VEH_EXIT,
                Controls.INPUT_VEH_HORN,
                Controls.INPUT_VEH_HEADLIGHT,
                Controls.INPUT_VEH_CIN_CAM,
                Controls.INPUT_VEH_NEXT_RADIO,
                Controls.INPUT_VEH_PREV_RADIO,
            } , true)

            -- We are not boarding and we pressed the board button, we should perform the board logic
            if not Job.isBoarding and IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
                Job.isBoarding = true
                Citizen.CreateThread(function() 
  
                    ESX.ShowNotification('Disembarking Passengers...', true, false, 60)
                    Job.DisembarkPassengers()

                    -- Opening doors bugs out the AI
                    -- Bus.OpenDoors()
                    -- Citizen.Wait(150)

                    ESX.ShowNotification('Boarding Passengers...', true, false, 60)
                    Job.EmbarkPassengers()

                    -- Close the door, show the notif and play a sound
                    
                    Citizen.Wait(1000)
                    Bus.CloseDoors()
                    Citizen.Wait(500)
                    ESX.ShowNotification('All passengers ready', true, false, 60)

                    -- Increment the stop
                    Job.NextStop()
                    Job.isBoarding = false
                    Bus.SetHazards(false)

                    -- Enable controls if we are no longer boarding
                    EnableControlActions(0, {
                        Controls.INPUT_VEH_ACCELERATE,
                        Controls.INPUT_VEH_BRAKE
                    }, true)
                end)
            end
        else
            -- Renable the control
            EnableControlActions(0, {
                Controls.INPUT_VEH_EXIT,
                Controls.INPUT_VEH_HORN,
                Controls.INPUT_VEH_HEADLIGHT,
                Controls.INPUT_VEH_CIN_CAM,
                Controls.INPUT_VEH_NEXT_RADIO,
                Controls.INPUT_VEH_PREV_RADIO,
            } , true)

        end
        
        -- We are boarding, wait
        if Job.isBoarding then
            ESX.ShowHelpNotification('Wait for passengers', true, false)
            for _, bp in pairs(Job.boardingPeds) do
                if not Ped.InVehicle(bp.ped) then
                    local coords = GetEntityCoords(bp.ped)
                    DrawMarker(0, coords.x, coords.y, coords.z + 1.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 0, 1.0, false, false, 2, false)
                end
            end
        end
    end
    
    if Job.isRouteFinished then
        -- We need to clean up
        ESX.ShowHelpNotification('Return the bus to the ~y~depo', true, false)
    end
    
end

-- Loads all the passengers if able
Job.PreloadPeds = function()
    -- Make sure we have a stop
    local stop = Job.GetNextStop()  
    if stop == nil then return false end
    
    -- Get the coordinates of the stop
    local stopCoords = BusStop.GetStopCoords(stop)
    local queueCoords =  BusStop.GetQueueCoords(stop)

    -- Make sure we havn't already preloaded
    if Job.preloadedPeds ~= nil then return true end

    -- Perform the preload
    Job.preloadedPeds = {}
    Citizen.CreateThread(function() 
        print('Job', 'Preload Begin')

        -- Spawn passenger
        for i,destination in pairs(stop.passengers) do
            -- TODO: Randomise a bit where they spawn
            
            -- Determine where to spawn them
            local randomRadius = 50.0
            local randVector = vector3(math.random(-randomRadius, randomRadius), math.random(-randomRadius, randomRadius), 0)
            local checkVector = stopVector + randVector
            local isSafe, spawnCoords = GetSafeCoordForPed(checkVector.x, checkVector.y, checkVector.z, true, 1)
            if not isSafe then spawnCoords = stopVector end
            
            -- Spawn the ped
            local ped = Ped.SpawnRandom(spawnCoords)
            if ped ~= nil then
                print("Ped Spawned", ped)
                
                Citizen.Wait(100)
                Ped.NavigateTo(ped, stopCoords, Ped.RUN, 0.5)
                table.insert(Job.preloadedPeds, { ped = ped, destination = destination })
            end
        end
        print('Job', 'Preload End')
    end)

    -- We preloaded them
    return true
end

-- Goes to the next stop
Job.NextStop = function() 
    -- Increment and set waypoint
    Job.nextStop = Job.nextStop + 1
    Job.SetWaypoint()

    -- Check if its end
    if Job.GetNextStop() == nil then
        Job.isRouteFinished = true
    end

    -- Preload the passengers
    Job.preloadedPeds = nil
    Job.boardingPeds = {}
end

-- Tells the passengers to get on
Job.EmbarkPassengers = function(callback)
    local stop = Job.GetNextStop()
    if not stop then 
        print('Job', 'failure: stop does not exist')
        return false 
    end

    -- Wait to preload the peds
    -- while Job.preloadedPeds == nil do
    --     print('Job', 'preloading peds')
    --     Job.PreloadPeds()
    --     Citizen.Wait(10)
    -- end

    -- Tell the passengers to get on the bus
    print('Job', 'embarking new passengers')
    Job.boardingPeds = {}
    for i, pp in pairs(Job.preloadedPeds) do
        local passenger, seat = Bus.AddPassenger(pp.ped)
        if passenger ~= nil then 
            -- Set hte destination
            Bus.SetPassengerDestination(passenger, pp.destination)
            table.insert(Job.boardingPeds, { ped = pp.ped, seat = pp.seat })
        else
            -- Tell GTA to clean this user up
            Ped.WanderAway(pp.ped)
        end
    end

    -- Wait till they are all on the bus
    print('Job', 'waiting for passengers to embark')
    while not Bus.CheckPassengersEmbarked() do
        Citizen.Wait(250) 
    end

    -- Finally callback
    print('Job', 'passengers embarked')
    if callback then callback() end
end

-- Tells the passengers to fuck off
Job.DisembarkPassengers = function(callback)
    print('Job', 'Disembarking Passengers')

    -- Tell passengers when their destination arrived
    for i, p in pairs(Bus.passengers) do
        if p.destination == Job.nextStop then
            Bus.RemovePassenger(i)
        end
    end

    local disembarkAttempts = 100

    -- Wait for them to leave
    while not Bus.CheckPassengersDisembarked(function(passenger) 
        -- Tell the ped to wander around. We dont care.
        Ped.WanderAway(passenger.ped)
    end) and disembarkAttempts >=0 do 
        disembarkAttempts = disembarkAttempts - 1
        Citizen.Wait(100) 
    end
    
    -- Cull the shits that wont leave
    Bus.Cull()

    -- Finally callback
    print('Job', 'Passengers left')
    if callback then callback() end
end

-- Sets the waypoint to the current stop
Job.SetWaypoint = function()    
    local stop = Job.GetNextStop()
    if stop ~= nil then
        -- Set the waypoint to the stop
        SetNewWaypoint(stop.x+.0, stop.y+.0)
    else
        -- Set the waypoint to home
        SetNewWaypoint(Config.coordinates.x, Config.coordinates.y)
    end
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

    ESX.TriggerServerCallback(E.BeginJob, function(route, message) 

        -- Validate the route
        if route == nil then
            if message == 'deposit' then
                ESX.ShowNotification('You do not have enough money for the ~r~'..tomoney(Config.deposit)..'~s~ deposit', true, false, 16)
            else
                ESX.ShowNotification('There is ~r~no~s~ routes available for you', true, true, 10)
            end

            Job.active = false
            return
        end
        
        -- set the route and reset the stop counter
        Job.route = route
        Job.nextStop = 0
        Job.isRouteFinished = false
        Job.isBoarding = false

        --Route.SetGps(Job.route)
        
        -- if Config.debug then print(ESX.DumpTable(Job.route)) end
        
        -- TODO: Trigger Bond Deposit
        
        -- Spawn a bus
        Bus.Create(route.type, Config.coordinates, function(bus) 
            if bus == nil then 
                Job.End(false, true) 
                ESX.ShowNotification('~r~Your bus failed to spawn for some reason', true, true, 10)
                return 
            end

            Ped.EnterVehicle(PlayerPedId(), bus, -1, Ped.TELEPORT)
            Citizen.Wait(10)

            -- Trigger next stop
            Job.NextStop()
            ESX.ShowNotification('You paid ~r~'..tomoney(Config.deposit)..'~s~ and started your route', true, true, 10)
            if callback then callback(route) end
        end)
    end)
end

-- Ends the job
Job.End = function(isForfeit, hasReturnedBus) 
    -- Disable the active state of the job
    Job.active = false
    
    -- Calculate the route state
    local routeState = 0
    if hasReturnedBus then routeState = routeState + 1 end
    if not isForfeit then routeState = routeState + 2 end

    print('Ending Job', Job.route.id, routeState)
    ESX.TriggerServerCallback(E.EndJob, function(success, data) 
        -- Something fucky happened
        if not success then
            print('failed to payout for the route', data)
            ESX.ShowNotification('Something went ~r~wrong~s~', true, true, 10)
            return
        end

        print('result', success, data)

        -- Alert the notification
        if routeState == RouteState.ForfeitWithoutVehicle then
            ESX.ShowNotification('You ~r~forfeited~s~ the route and the deposit', true, true, 10)
        end
        if routeState == RouteState.ForfeitWithVehicle then
            ESX.ShowNotification('You ~r~forfeited~s~ the route. Your deposit was ~g~returned', true, true, 10)
        end
        if routeState == RouteState.FinishedWithoutVehicle then
            ESX.ShowNotification('You ~g~completed~s~ the route, but ~r~forfeited~s~ your deposit', true, true, 10)
        end        
        if routeState == RouteState.FinishedWithVVehicle then
            ESX.ShowNotification('You ~g~completed~s~ the route. Your deposit was ~g~returned', true, true, 10)
        end

        -- Show we were paid
        if data > 0 then
            ESX.ShowNotification('You were paid ~g~' .. tomoney(data), true, true, 10)
        end

    end, Job.route.id, routeState)

    -- Finally clear the route
    Bus.Destroy()
    Job.route = nil
end


-- Gets the stop the bus has to get to
Job.GetNextStop = function() 
    if Job.route and #Job.route.stops >= Job.nextStop then
        return Job.route.stops[Job.nextStop]
    end
    return nil
end