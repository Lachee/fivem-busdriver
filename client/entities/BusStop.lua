
BusStop = {}
BusStop.Models = { 'prop_busstop_05', 'prop_busstop_02', 'prop_busstop_04', 'prop_bus_stop_sign' }
BusStop.Stops = {}

-- Finds the nearest bus stop model with 25m.
--  Coords is optional
BusStop.FindNearestModel = function(coords) 
    return FindClosestObject(BusStop.Models, 25, coords)
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
    BusStop.RequestAllStops(function(stops)

        for _, stop in pairs(stops) do
            stop.blip = AddBlipForCoord(stop.x, stop.y, stop.z)
            SetBlipSprite(stop.blip, 513)
            SetBlipDisplay(stop.blip, 4)
            SetBlipScale(stop.blip, 0.9)
            -- SetBlipColour(info.blip, info.colour)
            SetBlipAsShortRange(stop.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Bus Stop")
            EndTextCommandSetBlipName(stop.blip)
        end
    end)
end

-- Renders the stops
BusStop.RenderAll = function()
    for k, stop in pairs(BusStop.Stops) do
        BusStop.Render(stop)
    end
end

-- Render a specific stop. Color is optional
BusStop.Render = function(stop, color)
    if color == nil then color = { r = 255, g = 255, b = 0 } end
    
    DrawBusZone(stop, stop.heading, color)
    local model = BusStop.FindNearestModel(stop)
    local textCoord = stop
    if model then textCoord = GetEntityCoords(model) end
    
    textCoord = vector3(textCoord.x+.0, textCoord.y+.0, textCoord.z+4.25)
    DrawText3D(textCoord, tostring(stop.id) .. ' | ' .. stop.name, 3)
end