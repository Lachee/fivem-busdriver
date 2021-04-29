
BusStop = {}

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

    MySQL.Async.execute('INSERT INTO lachee_bus_stops (hash, x, y, z, heading, name) VALUES (@hash, @x, @y, @z, @heading, @name)', bindings, function (count) end)
    return bindings.hash
end

-- Gets all the bus stops
BusStop.GetAllStops = function(callback)
    MySQL.Async.fetchAll('SELECT * FROM lachee_bus_stops', {}, function(results)
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