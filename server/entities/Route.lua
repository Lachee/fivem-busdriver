Route = {}

-- Gets a shallow copy of all the routes available
Route.GetRoutes = function(callback) 
    MySQL.Async.fetchAll('SELECT id, name, earning, minimum_grade, type FROM lachee_bus_routes', {}, function(results)
        for _, r in pairs(results) do r.stops = nil end
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

-- Get the distance as the bird flys of the route
Route.GetDistance = function(route) 
    if route == nil then print('cannot get distance from nil route') return 0 end
    if route.stops == nil then  print('cannot get distance of route because route infomration was not loaded') return 0 end

    -- Calculate the distance between the first stop and the depo
    local l = #route.stops
    local distance = 0
    if Config.earningIncludesDepo then
        distance = distance + #(vector3(Config.coordinates.x, Config.coordinates.y, Config.coordinates.z) - vector3(route.stops[1].x, route.stops[1].y, route.stops[1].z))
        distance = distance + #(vector3(Config.coordinates.x, Config.coordinates.y, Config.coordinates.z) - vector3(route.stops[l].x, route.stops[l].y, route.stops[l].z))
    end

    -- Calculate the distance between each resulting spot
    for i = 1, l-1 do
        local stop      = route.stops[i]
        local nextStop  = route.stops[i+1]
        local c = vector3(stop.x, stop.y, stop.z)
        local n = vector3(nextStop.x, nextStop.y, nextStop.z)
        local d = #(n - c)
        distance = distance + d
    end

    -- Calculate the distance between the last spot and hte depo
    return distance
end

-- Gets how much money this route is valued at, rounded down.
Route.GetEarning = function(route)
    return math.floor(
            Config.earningBase -- Base Value
            + (Route.GetDistance(route) * (route.multiplier * Config.earningPerKM)) -- KM Bonus
            + (#route.stops + Config.earningPerStop) -- Stop Bonus
        ) + .0
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

-- Registers the callbacks
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