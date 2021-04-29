
BusStop = {}
BusStop.Models = { 'prop_busstop_05', 'prop_busstop_02', 'prop_busstop_04', 'prop_bus_stop_sign' }
BusStop.Stops = {}

-- Finds the nearest bus stop model with 25m
BusStop.FindNearestModel = function() 
    return FindClosestObject(BusStop.Models, 50)
end

-- Requests a new stop to be created
BusStop.RequestCreateStop = function(identifingCoordinate, stopCoordinate, heading, name, callback)
    -- Send the message to the server. Once we get a call back we will log it
    print('Requesting new bus stop', identifingCoordinate, stopCoordinate, heading, name)
    ESX.TriggerServerCallback(E.CreateBusStop, function(hash)
        BusStop.RequestAllStops()
        if callback then callback(hash) end
    end, identifingCoordinate, stopCoordinate, heading, name)
end


-- Gets a list of bus stops
BusStop.RequestAllStops = function(callback) 
    ESX.TriggerServerCallback(E.GetBusStops, function(stops)
        BusStop.Stops = stops
        if callback then  callback(stops) end
    end)
end

-- Registers the events
BusStop.RegisterEvents = function(ESX)
    BusStop.RequestAllStops()
end

-- Renders the stops
BusStop.Render = function()
    for k, stop in pairs(BusStop.Stops) do

        -- Debug marker
        -- DrawZoneMarkerGrounded(stop, 0.25, { r = 100, g = 255, b = 0})

        -- Draw the rectangle
        local depth = 0.5
        local height = 1.0

        local z = stop.z  - depth
        local validGroundPosition, groundZ = GetGroundZFor_3dCoord(stop.x, stop.y, stop.z, 0)
        if validGroundPosition then z = groundZ - depth end
        local size = { x = 3.5, y = 13.0, z = height }
        DrawMarker(43, 
            stop.x + .0, stop.y+ .0, z + .0, 
            0.0, 0.0, 0.0,
            0.0, 0.0, stop.heading + .0,
            size.x+ .0, size.y+ .0, size.z+ .0, 
            255, 255, 0, 0.01, 
            0, 0, 0, 0, 0, 0, 0
        )

    end
end