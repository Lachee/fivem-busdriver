
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


BusStop.RegisterEvents = function(ESX)
    BusStop.RequestAllStops()
end