Route = {}

-- Gets a shallow copy of all the routes available
Route.GetRoutes = function(callback) 
    MySQL.Async.fetchAll('SELECT id, name, earning, minimum_grade, type FROM lachee_bus_routes', {}, function(results)
        callback(results)
    end)
end

-- Gets a particular route, including all the stops
Route.GetRoute = function(routeId, callback) 
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_routes WHERE id = @id LIMIT 1', { id = routeId }, function(results) 
        
        if #results == 0 then
            return callback(nil)
        end

        -- Prepare the route details and get all the responses
        local routeDetail = results[1]
        local stop_ids = json.decode(routeDetail.route)
        BusStop.GetStops(stop_ids, function(results)

            -- Prepare a list of stops
            local stops = {}
            local stopCount = #stop_ids
            
            for i, id in pairs(stop_ids) do
                for _, stop in pairs(results) do
                    if stop.id == id then

                        -- Clone and determine the order
                        local clone = deepcopy(stop)
                        clone.order = i

                        -- Populate passenger count
                        clone.passengers = {}
                        if i ~= stopCount then
                            local count = math.random(1, 3)
                            for k = 1, count do
                                local destination = math.random(i+1, stopCount)
                                table.insert(clone.passengers, destination)
                            end
                        end

                        -- Add to our table
                        table.insert(stops, clone)
                        break
                    end
                end
            end
            
            -- Set the stops
            routeDetail.stops = stops

            -- Give back the results
            if callback ~= nil then callback(routeDetail) end
        end)
    end)
end

-- Gets a random bus route with the matching type
Route.GetRandomRoute = function(type, callback) 
    -- A little inefficient here, but saves me from duplicating code
    local query = ''
    local params = nil
    if type ~= false then
        query = 'SELECT id FROM lachee_bus_routes WHERE type = @type ORDER BY RAND() LIMIT 1'
        params = { type = type }
    else
        query = 'SELECT id FROM lachee_bus_routes ORDER BY RAND() LIMIT 1'
        params = {}
    end


    MySQL.Async.fetchAll(query, params, function(results)
        if #results >= 1 then
            print('Found a random route', results[1].id)
            Route.GetRoute(results[1].id, callback)
        else 
            print('Found no route')
            callback(nil)
        end
    end)
end



Route.RegisterServerCallbacks = function(ESX) 
    print('Routes.lua registering events')
    
    -- We want a list of all routes
    ESX.RegisterServerCallback(E.GetRoutes, function(source, callback) 
        Route.GetRoutes(callback)
    end)

    -- We want a specific stop
    ESX.RegisterServerCallback(E.GetRoute, function(source, callback, id)
        Route.GetRoute(id, callback)
    end)
end