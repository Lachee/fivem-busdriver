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
        BusStop.GetStops(stop_ids, function(stops)

            -- Determine the order of the routes
            for _,s in pairs(stops) do
                s.order = table.indexOf(stop_ids, s.id)
            end

            -- Sort the routes
            table.sort(stops, function(a, b) return a.order < b.order end)
            routeDetail.route = stops

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