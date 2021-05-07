-- Creates the bus stop object
function _prepareBusStop(data)
    data.hasQueue = false
    if data.qx ~= 0 and data.qy ~= 0 and data.qz ~= 0 then
        data.hasQueue = true
    end
    return data
end

-- Creates a new bus stop at the given location
BusStop.CreateStop = function(stop, callback)
    
    -- Security check: only allow new stops to be created if we are debug
    if not Config.debug then 
        print('cannot possibly create a bus stop outside debug mode')
        return false
    end

    -- Ensure X, Y, Z, Heading and Name are filled
    if stop.x == nil or stop.y == nil or stop.z == nil or stop.heading == nil or stop.name == nil then
        print('cannot create stop, missing one of the following: x, y, z, heading, name')
        return false
    end

    -- Ensure hash is correct
    if stop.hash == nil or stop.hash == '' then 
        stop.hash = BusStop.CalculateHash(vector3(stop.x, stop.y, stop.z)) 
    end

    -- Create a binding. We are copying so we dont have extra data sent to MySQL
    local bindings = { 
        -- Required
        hash = stop.hash,
        x = stop.x, 
        y = stop.y, 
        z = stop.z, 
        heading = stop.heading, 
        name = stop.name,

        -- Optionals
        qx = stop.qx or 0,
        qy = stop.qy or 0,
        qz = stop.qz or 0,
        type = stop.type or 'metro',
        clear = stop.clear or 0,
    };

    -- Execute the function
    print('MySQL: Creating a new bus stop', stop.hash, stop.x, stop.y, stop.z, stop.name)
    MySQL.Async.execute('INSERT INTO lachee_bus_stops (hash, x, y, z, heading, name, qx, qy, qz, type, clear) VALUES (@hash, @x, @y, @z, @heading, @name, @qx, @qy, @qz, @type, @clear)', bindings, function (count) 
        if callback ~= nil then callback(count) end
    end)

    -- Return the hash
    return true
end

BusStop.UpdateStop = function(stop, callback)
    -- Security check
    if not Config.debug then 
        print('cannot possibly update a bus stop outside debug mode')
        return false
    end

    -- Ensure we actually got the stop
    if stop.hash == nil or stop.hash == '' then
        print('Cannot possibly update a stop without knowing it\'s hash')
        return false
    end

    local ALLOWED_PARAMS = { 'x', 'y', 'z', 'heading', 'qx', 'qy', 'qz', 'name', 'type', 'clear' }
    local statement = 'UPDATE lachee_bus_stops SET'
    local bindings = { hash = stop.hash }
    local isFirstValue = true

    -- Prepare the statement and bindings
    for k, v in pairs(stop) do
        local index = table.indexOf(ALLOWED_PARAMS, k)
        if index ~= false and index > 0 then
            local query  = ' ' .. ALLOWED_PARAMS[index] .. ' = @' .. ALLOWED_PARAMS[index]
            if not isFirstValue then  query = ', ' .. query end

            statement = statement .. query
            bindings[ALLOWED_PARAMS[index]] = v
            isFirstValue = false
        end
    end


    -- Ensure we have something other than hash to update
    if #bindings == 1 then 
        print('There is nothing to update in this stop')
        return false
    end

    -- Add the last bit and execute the statement
    statement = statement .. ' WHERE `hash` = @hash LIMIT 1'

    
    print(statement)
    MySQL.Async.execute(statement, bindings, function (count) 
        if callback ~= nil then callback(count) end
    end)

    return true
end

-- Gets all the bus stops
BusStop.GetAllStops = function(callback)
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_stops', {}, function(results)
        for _, s in pairs(results) do s = _prepareBusStop(s) end
        callback(results)
    end)
end

-- Get all the stops with the specified ID
BusStop.GetStops = function(ids, callback) 
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_stops WHERE id IN (@ids)', { ids = ids }, function(results)
        for _, s in pairs(results) do s = _prepareBusStop(s) end
        callback(results)
    end)
end

-- Register events 
BusStop.RegisterServerCallbacks = function(ESX) 

    if Config.debug then
        print('warning: registering debug callbacks that can manipulate the database')

        -- Request to create a stop
        ESX.RegisterServerCallback(E.CreateBusStop, function(source, callback, stop)
            if not BusStop.CreateStop(stop, callback) then
                callback(false)
            end
        end)

        -- Request to update a stop
        ESX.RegisterServerCallback(E.UpdateBusStop, function(source, callback, stop)
            if not BusStop.UpdateStop(stop, callback) then
                callback(false)
            end
        end)
    end

    -- Request to get all the stops
    ESX.RegisterServerCallback(E.GetBusStops, function(source, callback)
        BusStop.GetAllStops(callback)
    end)

end