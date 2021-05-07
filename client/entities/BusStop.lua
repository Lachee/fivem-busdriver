BusStop.MODELS = { 'prop_busstop_05', 'prop_busstop_02', 'prop_busstop_04', 'prop_bus_stop_sign' }
BusStop.SIZE = { width = 3.5, length= 13.0 }

BusStop.blips = {} -- List of blips that have been generated. Indexed by hash.
BusStop.stops = {}  -- List of all stops. Indexed by hash.
BusStop.modelCache = {} -- List of all models. Indexed by hash.

-- Registers the events
BusStop.RegisterEvents = function(ESX)
    BusStop.FetchAllStops()
end

-- Finds the nearest bus stop model with 25m.
--  Coords is optional
BusStop.FindNearestModel = function(coords, distance)
    if distance == nil then distance = 25.0 end 
    return FindNearestObject(BusStop.MODELS, distance, coords)
end

--- Finds all the models and create blips of them.
-- This is a debug only function
BusStop.FindAllModels = function(createBlip)
    if not Config.debug then return false end
    if createBlip == nil then createBlip = false end

    -- Iterate over all hte models
    for o in ObjectIterator(ObjectFilter.model(BusStop.MODELS)) do
        local model = GetEntityModel(o)
        local coords = GetEntityCoords(o)
        local heading = GetEntityHeading(o)
        local hash = BusStop.CalculateHash(coords)

        if BusStop.modelCache[hash] == nil then
            BusStop.modelCache[hash] = {
                object = o,
                hash = hash,
                model = model,
                coords = coords,
                heading = heading
            }
        end

        -- Create the blip
        if createBlip then
            local color = BlipColor.LightRed
            if BusStop.blips[hash] ~= nil then color = BusStop.blips[hash].color end
            BusStop.ShowBlip(BusStop.modelCache[hash], true, color)
        end
    end

    --return the list
    return BusStop.modelCache
end

-- Requests a new stop to be created
BusStop.CreateStop = function(stop, callback)

    -- Calculate a new name
    if stop.name == nil then
        local directions = { N = 360, 0, NE = 315, E = 270, SE = 225, S = 180, SW = 135, W = 90, NW = 45 }
        local var1, var2 = GetStreetNameAtCoord(stop.x, stop.y, stop.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        local hash1 = GetStreetNameFromHashKey(var1);
        local hash2 = GetStreetNameFromHashKey(var2);
        local dir = ''
        for k, v in pairs(directions) do
            if (math.abs(stop.heading - v) < 22.5) then
                dir = k;
                if (dir == 1) then
                    dir = 'N';
                    break;
                end
                break;
            end
        end
        stop.name = hash1 .. ' ' .. hash2 .. ' ' .. dir
    end

    print('Creating a new Bus Stop', stop.hash, stop.x, stop.y, stop.z)
    ESX.TriggerServerCallback(E.CreateBusStop, function(count)
        -- We have it back, so lets now request all the stops again and return the hash
        print('Bus Stop created', stop.hash)
        BusStop.FetchAllStops(function(stops)
            if callback ~= nil then callback(BusStop.stops[stop.hash]) end
        end)
    end, stop)
end

BusStop.UpdateStop = function(stop, callback) 
    if stop == nil or stop.hash == nil then print('cannot possibly update without a hash') return false end
    print('Updating a stop', stop.hash)
    ESX.TriggerServerCallback(E.UpdateBusStop, function(count) 
        if count > 0 then
            print('Bus stop updated: ', count)
            BusStop.FetchAllStops(function(stops)
                if callback ~= nil then callback(true) end
            end)
        else
            print('Failed to update stop')
            if callback ~= nil then callback(false) end
        end
    end, stop)
    return true
end

-- Fetches a list of stops and stores it in the BusStop.stops
BusStop.FetchAllStops = function(callback) 
    print('Fetching all stops...')
    ESX.TriggerServerCallback(E.GetBusStops, function(stops)
        BusStop.stops = {}
        for i, stop in pairs(stops) do
            BusStop.stops[stop.hash] = stop
            if Config.debug or Config.alwaysShowBlips then
                BusStop.ShowBlip(stop, true, BlipColor.White)
            end
        end
        if callback then  callback(BusStop.stops) end
    end)
end

-- Shows a bus stop's blip. Color is a int.
BusStop.ShowBlip = function(stop, visible, color) 
    if stop == nil then print('BusStop', 'warning: stop is nil') return false end
    if visible == nil then visible = true end
    
    -- Blip is already hidden, no action required
    if visible == false and BusStop.blips[stop.hash] == nil then
        return
    end

    -- Ensure the blip exists
    if BusStop.blips[stop.hash] == nil then
        local coords = stop.coords or stop
        print('creating blip', stop.hash)
        BusStop.blips[stop.hash] = {
            blip = CreateBlip(513, coords, "Bus Stop", 0.9, BlipColor.White),
            visible = true,
            color = BlipColor.White
        }
    end

    -- Set the blip's display state
    if visible then
        SetBlipDisplay(BusStop.blips[stop.hash].blip, 4)
        BusStop.blips[stop.hash].visible = true
    else
        SetBlipDisplay(BusStop.blips[stop.hash].blip, 0)
        BusStop.blips[stop.hash].visible = false
    end

    -- Set hte blip's color
    if color ~= nil then
        SetBlipColour(BusStop.blips[stop.hash].blip, color)
        BusStop.blips[stop.hash].color = color
    end
end

-- Hides a bus stop's blip
BusStop.HideBlip = function(stop) 
    return BusStop.ShowBlip(stop, false)
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
    
    -- Find the default position
    local stopCoords = BusStop.GetStopCoords(stop)
    local qForward = quat(stop.heading, vector3(0, 0, 1))
    local qRight = quat(stop.heading-90, vector3(0, 0, 1))
    stopCoords = stopCoords 
                    + ((qForward * vector3(0, 1, 0)) * (BusStop.SIZE.length * 0.5 - 1.5)) 
                    + ((qRight * vector3(0, 1, 0)) * (BusStop.SIZE.width * 0.5 + 1.0))

    -- Try to find the safest coord near that
    local isStopSafe, safeCoords = GetSafeCoordForPed(stopCoords.x, stopCoords.y, stopCoords.z, true, 1)
    if isStopSafe then return safeCoords end

    -- Find a new spot based around the edge of the stop
    return stopCoords
end

-- Gets the estimated best coordinates for the given object
BusStop.GetEstimatedBestCoords = function(obj)
    local coords = GetEntityCoords(obj)
    local heading = (GetEntityHeading(obj) + 90) % 360
    local foundSidePoint, sidePointCoords = GetRoadSidePointWithHeading(coords.x, coords.y, coords.z, heading-90)
    if not foundSidePoint then return false end

    -- Prepare the directions
    local differenceBetweenCoords = sidePointCoords - coords
    local directionToSidePoint = norm(vector3(differenceBetweenCoords.x, differenceBetweenCoords.y, 0))
    
    local directionFromHeading = norm(quat(heading, vector3(0,0,1)) * vector3(0, 1, 0))
    directionFromHeading = norm(vector3(directionFromHeading.x, directionFromHeading.y, 0))
    
    -- Get the angle between them and use that to calculate the offset from the road
    local roadOffsetDistanceCap = 7.0
    local angleBetweenDirections = angleFromToo(directionFromHeading, directionToSidePoint)
    local roadOffsetDistance = math.sin(angleBetweenDirections) * #differenceBetweenCoords
    if roadOffsetDistance > roadOffsetDistanceCap then roadOffsetDistance = roadOffsetDistanceCap end
    local roadOffsetDirection = norm(quat(heading + 90, vector3(0, 0, 1)) * vector3(0, 1, 0))
    local roadOffsetCoords = coords + (roadOffsetDirection * roadOffsetDistance)
    
    -- Determine the best spot for the bus zone
    local busZoneCoords = roadOffsetCoords
                            + (roadOffsetDirection * BusStop.SIZE.width * 0.5) 
                            - (directionFromHeading * BusStop.SIZE.length * 0.35)
                            + vector3(0, 0, 1)

    return busZoneCoords, heading
end

-- Renders all the available stops
BusStop.RenderAll = function(color)
    local coords = GetEntityCoords(PlayerPedId())
    for hash, stop in pairs(BusStop.stops) do
        local distance = #(BusStop.GetStopCoords(stop) - coords)
        if distance <= 100 then
            BusStop.Render(stop, color)
        end
    end 
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
    
    -- Draw the stop
    textCoord = vector3(textCoord.x+.0, textCoord.y+.0, textCoord.z+4.25)
    DrawText3D(textCoord, tostring(stop.id) .. ' | ' .. stop.name, 3)

    -- Draw some debug markers
    if Config.debug then
        local stopCoord = BusStop.GetStopCoords(stop)

        -- Draw the direction
        local qForward = quat(stop.heading, vector3(0, 0, 1))
        local qRight = quat(stop.heading-90, vector3(0, 0, 1))
        DrawQuaternion(stopCoord, qForward, {r=255, g=0, b=0})
        DrawQuaternion(stopCoord, qRight, {r=0, g=255, b=0})
      
        -- Draw where the queue is (RED)
        local queueColor = { r=255, g=0, b=0 }
        if stop.hasQueue then queueColor = { r=0, g=255, b=0 } end
        DrawGroundedZoneMarker(BusStop.GetQueueCoords(stop), 1.0, queueColor)

        -- Draw the clear radius (GRAY)
        if stop.clear > 0 then
            DrawZoneMarker(stopCoord, stop.clear+.0, { r=50,g=50,b=50 })
        end
    end
end

-- Drwas a rectangular zone marker, snapped ot the ground
BusStop.DrawZone = function(coordinate, heading, color) 
    if color == nil then color = Config.color or {r=255,g=255,b=0} end

    -- Draw the rectangle
    local depth = 0.5
    local height = 1.0
    local size = { x = BusStop.SIZE.width, y = BusStop.SIZE.length, z = height }

    --Draw the position
    local rotation = { x = .0, y = .0, z = heading + .0 }
    local position = { x=coordinate.x, y=coordinate.y, z=coordinate.z }
    
    local hasGround, groundZ, normal = GetGroundZAndNormalFor_3dCoord(position.x, position.y, position.z, 0)
    if hasGround then 
        position.z = groundZ - depth
    end

    if Config.debug then          
        DrawHeadingMarker(coordinate, heading, Config.stopDistanceLimit or 1.0, color)
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

