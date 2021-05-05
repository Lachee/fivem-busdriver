
BusStop = {}

-- Creates the bus stop object
function _prepareBusStop(data)
    data.hasQueue = false
    if data.qx ~= 0 and data.qy ~= 0 and data.qz ~= 0 then
        data.hasQueue = true
    end
    return data
end

-- Creates a new bus stop at the given location
BusStop.CreateStop = function(identifingCoordinate, stopCoordinate, heading, name)
    
    local  hash = sha1.hex(tostring(identifingCoordinate))
    print('Creating new bus stop', identifingCoordinate, stopCoordinate, heading, name)

    local bindings = { 
        hash = hash,
        x = stopCoordinate.x, 
        y = stopCoordinate.y, 
        z = stopCoordinate.z, 
        heading = heading, 
        name = name 
    };

    MySQL.Async.execute('INSERT INTO lachee_bus_stops (hash, x, y, z, heading, name) VALUES (@hash, @x, @y, @z, @heading, @name)', bindings, function (count) 
        if count > 0 then
            BusStop.GetAllStops(function(stops)
                TriggerEvent(E.GetBusStops, stops)
            end)
        end
    end)

    return bindings.hash
end

-- Gets all the bus stops
BusStop.GetAllStops = function(callback)
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_stops', {}, function(results)
        for _, s in pairs(results) do s = _prepareBusStop(s) end
        callback(results)
    end)
end

-- Gets all the stops at the given location
BusStop.GetStops = function(ids, callback) 
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_stops WHERE id IN (@ids)', { ids = ids }, function(results)
        for _, s in pairs(results) do s = _prepareBusStop(s) end
        callback(results)
    end)
end

BusStop.RegisterServerCallbacks = function(ESX) 

    print('BusStop.lua registering events')

    -- We requested to create a bus stop, so we should
    ESX.RegisterServerCallback(E.CreateBusStop, function(source, callback, identifingCoordinate, stopCoordinate, heading, name)
        local hash = BusStop.CreateStop(identifingCoordinate, stopCoordinate, heading, name)
        callback(hash)
    end)

    
    -- We requested to create a bus stop, so we should
    ESX.RegisterServerCallback(E.GetBusStops, function(source, callback)
        BusStop.GetAllStops(callback)
    end)

end