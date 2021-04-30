-- Draws a zone marker
DrawZoneMarker = function(coordinate, radius, color)
    -- Prepare the markers
    local size  = { x = (radius + .0) / 2.0, y = (radius + .0) / 2.0, z = 1.0 }
    
    -- Draw the markers and show the interact text
    DrawMarker(1, coordinate.x, coordinate.y, coordinate.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size.x, size.y, size.z, color.r, color.g, color.b, 0.05, 0, 0, 0, 0, 0, 0, 0)
end

-- Draws the zone marker snapped to the ground
DrawZoneMarkerGrounded = function(coordinate, radius, color) 

    local pos = coordinate

    -- Get the position and snap it to the ground
    local retval, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, 0)
    if retval then
        pos = vector3(pos.x, pos.y, groundZ)
    end

    DrawZoneMarker(pos, radius, color)
end

-- Draw the bus zone
DrawBusZone = function(coordinate, heading, color) 
    -- Draw the rectangle
    local depth = 0.5
    local height = 1.0
    local size = { x = 3.5, y = 13.0, z = height }

    --Draw the position
    local z = coordinate.z - depth
    local grnd, groundZ = GetGroundZFor_3dCoord(coordinate.x, coordinate.y, coordinate.z, 0)
    if grnd then z = groundZ - depth end

    DrawMarker(43, 
        coordinate.x + .0, coordinate.y+ .0, z + .0, -- Position
        0.0, 0.0, 0.0,                               -- Direction
        0.0, 0.0, heading + .0,                      -- Rotation
        size.x+ .0, size.y+ .0, size.z+ .0,          -- Scale
        color.r, color.g, color.b, 0.01,             -- Color
        0, 0, 0, 0, 0, 0, 0
    )
end

-- Finds the nearest object from the given list
FindClosestObject = function(names, radius)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestObject = nil
    local closestDist = nil

    for i = 1, #names do
        local name = names[i]
        local objectId = FindNearestObject(name, radius)
        if objectId ~= nil then
            local coords = GetEntityCoords(objectId)
            local dist = #(pedCoords - coords)
            if closestObject == nil or dist < closestDist then
                closestObject = objectId
                closestDist = dist
            end
        end
    end

    return closestObject
end

-- Finds an obejct with the name closes to the player
FindNearestObject = function(name, radius) 
    
    local pedCoords = GetEntityCoords(PlayerPedId())
    local objectId = GetClosestObjectOfType(pedCoords, radius + .0, GetHashKey(name), false)
    
    if DoesEntityExist(objectId) then
        return objectId
    end

    return nil
end

-- Similar to FindNearestObject but returns the Vector3 coords or false instead
FindNearestObjectCoords = function(name, radius) 
    local objectId = FindNearestObject(name, radius)
    if objectId ~= nil then
        local coords = GetEntityCoords(objectId)
        if coords ~= nil then
            return coords
        end
    end
    return false
end