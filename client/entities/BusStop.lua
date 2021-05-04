
BusStop = {}
BusStop.Models = { 'prop_busstop_05', 'prop_busstop_02', 'prop_busstop_04', 'prop_bus_stop_sign' }
BusStop.Stops = {}
BusStop.Size = { width = 3.5, length= 13.0 }

-- Finds the nearest bus stop model with 25m.
--  Coords is optional
BusStop.FindNearestModel = function(coords) 
    return FindClosestObject(BusStop.Models, 25, coords)
end

-- Requests a new stop to be created
BusStop.RequestCreateStop = function(identifingCoordinate, stopCoordinate, heading, name, queue, callback)
    if queue == nil then queue = vector3(0, 0, 0) end
    
    -- Send the message to the server. Once we get a call back we will log it
    print('Requesting new bus stop', identifingCoordinate, stopCoordinate, heading, name, queue)
    ESX.TriggerServerCallback(E.CreateBusStop, function(hash)
        BusStop.RequestAllStops()
        if callback then callback(hash) end
    end, identifingCoordinate, stopCoordinate, heading, queue, name)
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
    if Config.alwaysShowBlips then
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
end

-- Renders the stops
BusStop.RenderAll = function(color)
    for k, stop in pairs(BusStop.Stops) do
        BusStop.Render(stop, color)
    end
end

-- Gets the stop coordinates
BusStop.GetStopCoords = function(stop) 
    if stop == nil then print('BusStop', 'warning: stop is nil') return vector3(0,0,0) end
    return vector3(stop.x+.0, stop.y+.0, stop.z+.0)
end

-- Gets the queue coordinates
BusStop.GetQueueCoords = function(stop) 
    -- Prepare the queue
    if stop == nil then print('BusStop', 'warning: stop is nil') return vector3(0,0,0) end
    if stop.hasQueue then 
        return vector3(stop.qx+.0, stop.qy+.0, stop.qz+.0)
    end
    
    -- Find the default
    local stopCoords = BusStop.GetStopCoords(stop)
    local isStopSafe, safeCoords = GetSafeCoordForPed(stopCoords.x, stopCoords.y, stopCoords.z, true, 1)
    if isStopSafe then return safeCoords end

    -- Find a new spot based around the edge of the stop
    return stopCoords
end

-- Render a specific stop. Color is optional
BusStop.Render = function(stop, color)
    if color == nil then color = { r = 255, g = 255, b = 0 } end
    
    -- Draw the bus zone
    BusStop.DrawZone(stop, stop.heading, color)

    -- Draw the text above the bus zone
    local model = BusStop.FindNearestModel(stop)
    local textCoord = stop
    if model then textCoord = GetEntityCoords(model) end
    
    textCoord = vector3(textCoord.x+.0, textCoord.y+.0, textCoord.z+4.25)
    DrawText3D(textCoord, tostring(stop.id) .. ' | ' .. stop.name, 3)

    -- Draw some debug markers
    if Config.debug then
        DrawHeadingMarker(BusStop.GetStopCoords(stop), stop.heading, Config.stopDistanceLimit or 1.0, color)
        DrawGroundedZoneMarker(BusStop.GetQueueCoords(stop), 1.0, { r=255, g=0, b=0 })
    end
end

-- Drwas a rectangular zone marker, snapped ot the ground
BusStop.DrawZone = function(coordinate, heading, color) 
    -- Draw the rectangle
    local depth = 0.5
    local height = 1.0
    local size = { x = BusStop.Size.width, y = BusStop.Size.length, z = height }

    --Draw the position
    local rotation = { x = .0, y = .0, z = heading + .0 }
    local position = { x=coordinate.x, y=coordinate.y, z=coordinate.z }
    
    local hasGround, groundZ, normal = GetGroundZAndNormalFor_3dCoord(position.x, position.y, position.z, 0)
    if hasGround then 
        position.z = groundZ - depth
        
        if Config.debug and DEBUG_FindStops then
            local qHeading = quat(heading, vector3(0, 0, 1))
            DrawQuaternion(coordinate, qHeading, {r=255, g=0, b=0})
            
            local qRoad = quat(vector3(0, 1, 0), normal)
            DrawQuaternion(coordinate, qRoad, {r=0, g=255, b=0})

            -- We need to rotate qRoad 90deg in the direction of qHeading
            local qNew = qRoad * quat(90, vector3(1, 0, 0))
            DrawQuaternion(coordinate, qNew, {r=0, g=0, b=255})
        end
    end

    DrawMarker(43, 
        position.x + .0, position.y+ .0, position.z + .0, -- Position
        0.0, 0.0, 0.0,                               -- Direction
        rotation.x, rotation.y, rotation.z,                      -- Rotation
        size.x+ .0, size.y+ .0, size.z+ .0,          -- Scale
        color.r, color.g, color.b, 0.01,             -- Color
        0, 0, 0, 0, 0, 0, 0
    )
end

