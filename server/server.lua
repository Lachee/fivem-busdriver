
ESX = nil

playerRoutes = {}

-- Load up the ESX serverside
TriggerEvent("esx:getSharedObject", function(library) 
    ESX = library 
    
    BusStop.RegisterServerCallbacks(ESX)
    Route.RegisterServerCallbacks(ESX)

    -- Begin handling the job
    ESX.RegisterServerCallback(E.BeginJob, function(source, callback, type)
        local xPlayer = ESX.GetPlayerFromId(source)
        local job = xPlayer.getJob()
        if job.name == 'busdriver' then
            print('Users wishes to be a bus driver')

            -- Ensure they got the cash for the deposit
            if xPlayer.getMoney() < Config.deposit then
                callback(nil, 'deposit')
                return
            end

            -- Take the deposit then spawn the vehicle
            xPlayer.removeMoney(Config.deposit)

            -- Get a random route for the requested type
            if type == nil then type = false end
            Route.GetRandomRoute(type, function(route)
                -- Store the route the user is doing
                playerRoutes[xPlayer.getIdentifier()] = route.id
                print(ESX.DumpTable(playerRoutes))
                callback(route)
            end)
        else
            print('Player attempted to start a job invalid', source, job)
            callback(nil, 'not_driver')
        end
    end)

    -- End handling the job
    ESX.RegisterServerCallback(E.EndJob, function(source, callback, routeId, state)
        local xPlayer = ESX.GetPlayerFromId(source)

        -- Validate the route matches
        local prevRouteId = playerRoutes[xPlayer.getIdentifier()]
        playerRoutes[xPlayer.getIdentifier()] = nil

        if prevRouteId ~= routeId then
            print('user route', previousRouteId, routeId)
            callback(false, 'You were not doing this route')
            return
        end


        -- Get the route they are doing
        Route.GetRoute(routeId, function(route)
            
            local earning = 0

            -- Add back the deposit
            if state == RouteState.ForfeitWithVehicle or state == RouteState.FinishedWithVehicle then
                earning = earning + Config.deposit
            end
            
            -- Pay them for the route
            if state == RouteState.FinishedWithoutVehicle or state == RouteState.FinishedWithVehicle then
                earning = earning + route.earning
            end

            xPlayer.addMoney(earning)
            callback(true, earning)
        end)
    end)
end)
