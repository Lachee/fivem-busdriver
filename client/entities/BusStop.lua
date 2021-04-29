
BusStop = {}
BusStop.Models = { 'prop_busstop_05', 'prop_busstop_02', 'prop_busstop_04', 'prop_bus_stop_sign' }

-- Finds the nearest bus stop model with 25m
BusStop.FindNearestModel = function() 
    return FindNearestObjectCoords(BusStop.Models, 25)
end

-- Requests a new stop to be created
BusStop.RequestCreateStop = function(identifingCoordinate, stopCoordinate, heading, name, callback)
    -- Send the message to the server. Once we get a call back we will log it
    ESX.TriggerServerCallback(E.CreateBusStop, callback, identifyingCoordinates, stopCoordinate, heading, name)
end


-- Gets a list of bus stops
BusStop.RequestAllStops = function(callback) 
    ESX.TriggerServerCallback(E.GetBusStops, function(stops)
        callback(stops)
    end)
end
