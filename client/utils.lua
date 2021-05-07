-- Draws a zone marker
DrawZoneMarker = function(coordinate, radius, color)
    -- Prepare the markers
    local size  = { x = (radius + .0) / 2.0, y = (radius + .0) / 2.0, z = 1.0 }
    
    -- Draw the markers and show the interact text
    DrawMarker(1, coordinate.x, coordinate.y, coordinate.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size.x, size.y, size.z, color.r, color.g, color.b, 0.05, 0, 0, 0, 0, 0, 0, 0)
end

-- Draws a zone marker wiht a TTL
DrawZoneMarkerTTL = function(coordinate, radius, color, ttl)
    local lifetime = ttl
    local sleep = 10
    Citizen.CreateThread(function() 
        
        while lifetime > 0 do
            local size  = { x = (radius + .0) / 2.0, y = (radius + .0) / 2.0, z = 1.0 }
            DrawMarker(1, coordinate.x, coordinate.y, coordinate.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size.x, size.y, size.z, color.r, color.g, color.b, 0.05, 0, 0, 0, 0, 0, 0, 0)
            Citizen.Wait(sleep)
            lifetime = lifetime - sleep
        end
    end)
end

-- Draws the zone marker snapped to the ground
DrawGroundedZoneMarker = function(coordinate, radius, color) 

    local pos = coordinate

    -- Get the position and snap it to the ground
    local retval, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, 0)
    if retval then
        pos = vector3(pos.x, pos.y, groundZ)
    end

    DrawZoneMarker(pos, radius, color)
end

-- Draws a circle on the ground, facing the given heading
DrawHeadingMarker = function(coords, heading, radius, color)
    if radius == nil then radius = 1.0 end
    if color == nil then color = {r=255, g=255, b=255} end
    local size  = { x = (radius + .0) / 2.0, y = (radius + .0) / 2.0, z = 1.0 }
    
    local ch = EnsureCoordinateHeading(coords, heading)
    DrawMarker(26, ch.x, ch.y, ch.z, 0, 0, 0, 0, 0, ch.w, size.x, size.y, size.z, color.r, color.g, color.b, color.a or 0.05, 0, 0, 0, 0, 0, 0, 0)
end

-- OBSOLETE
FindClosestObject = function(names, radius, coords)
    return FindNearestObject(names, radius, coords)
end

-- Finds the nearest object. If name is an array, then it will find one of each and return the closest
FindNearestObject = function(name, radius, coords) 

    --Prepare a coordinate
    if coords == nil then 
        coords = GetEntityCoords(PlayerPedId()) 
    else
        coords = vector3(coords.x + .0, coords.y + .0, coords.z + .0)
    end

    if type(name) == "string" then
        -- Find the nearest obejct
        local objectId = GetClosestObjectOfType(coords, radius + .0, GetHashKey(name), false)
        if DoesEntityExist(objectId) then
            return objectId
        end
    else 
        -- Find the nearest object for all of them
        local closestObject = nil
        local closestDist = nil    
        for i = 1, #name do
            local objectId = FindNearestObject(name[i], radius, coords)
            if objectId ~= nil then
                local objCoords = GetEntityCoords(objectId)
                local dist = #(coords - objCoords)
                if closestObject == nil or dist < closestDist then
                    closestObject = objectId
                    closestDist = dist
                end
            end
        end
        return closestObject
    end

    return nil
end

-- Similar to FindNearestObject but returns the Vector3 coords or false instead
FindNearestObjectCoords = function(name, radius, coords) 
    local objectId = FindNearestObject(name, radius, coords)
    if objectId ~= nil then
        local coords = GetEntityCoords(objectId)
        if coords ~= nil then
            return coords
        end
    end
    return false
end

-- Draw 3D text at position. If available, ESX will be used
DrawText3D = function(coords, text, size, font) 
    if ESX then
        ESX.Game.Utils.DrawText3D(coords, text, size, font)
    else
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
        local px, py, pz = table.unpack(GetGameplayCamCoords())
        
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.005 + factor, 0.03, 0, 0, 0, 100)
    end
end

-- Draws a quaternion at the given location
DrawQuaternion = function(from, q, color, scale) 
    if color == nil then color = { r=255, g=0, b=0 } end
    if scale == nil then scale = 1.0 end
    -- local from = position
    -- local too = position + q
    --from = GetEntityCoords(PlayerPedId())

    local dir = norm(q * vector3(0, 1, 0))
    local too = vector3(from.x + (dir.x * scale), from.y + (dir.y * scale), from.z + (dir.z * scale))
    DrawLine(
        from.x, from.y, from.z,
        too.x, too.y, too.z,
        color.r, color.g, color.b, 1.0
    )

    -- Initial line for directional information
    too = vector3(from.x + (dir.x * 0.1), from.y + (dir.y * 0.1), from.z + (dir.z * 0.1))
    DrawLine(
        from.x, from.y, from.z,
        too.x, too.y, too.z,
        255, 0, 255, 1.0
    )
end

DrawRay = function(coord, dir, color)
    DrawLineMarker(coord, coord + dir, color)
end

DrawLineMarker = function(from, too, color) 
    if color == nil then color = {r=255,b=255,g=255} end
    DrawLine(
        from.x, from.y, from.z,
        too.x, too.y, too.z,
        color.r, color.g, color.b, color.a or 1.0
    )
end

-- Ensures the given coordinates and heading will be returned as a valid vector4(x, y, z, heading)
--- if the z false, then it will be snapped to ground
--- if heading is omitted, then it will use coords.w or a random value if unavailable
EnsureCoordinateHeading = function(coords, heading)
    -- Determine where to spawn the ped
    local coordHeading = { x=coords.x, y=coords.y, z=false, w=false }
    if type(coords) == 'vector4' then 
        coordHeading.z = coords.z
        coordHeading.w = coords.w 
    elseif type(coords) == 'vector3' then 
        coordHeading.z =  coords.z
    elseif type(coords) == 'vector2' then
    else
        coordHeading.z = coords.z or false
        coordHeading.w = coords.w or false
    end

    -- Snap to ground if we dont have a Z
    if coordHeading.z == false then
        local onGround, groundZ = GetGroundZFor_3dCoord(coordHeading.x, coordHeading.y, 99999.0, false)
        if onGround then
            coordHeading.z = groundZ
        else
            --print('warning: failed to local ground for ped spawn.', model, coords)
            coordHeading.z = 0
        end
    end

    -- Update the heading
    if heading ~= nil then
        coordHeading.w = heading+.0
    elseif coordHeading.w == false then
        coordHeading.w = math.random() * 360
    end

    return coordHeading
end

-- Disables a group of actions
DisableControlActions = function(group, controls, toggle)
    for _, c in pairs(controls) do
        DisableControlAction(group, c, toggle)
    end
end

-- Enables a group of actions
EnableControlActions = function(group, controls, toggle)
    for _, c in pairs(controls) do
        EnableControlAction(group, c, toggle)
    end
end

--- Creates a blip and returns it. Scale and Color are optional.
-- Use BlipColor constant for the colors
CreateBlip = function(sprite, coords, name, scale, color) 
    if coords == nil then 
        Citizen.Trace('Cannot create blip because coords are nil') 
        return false 
    end

    local blip = AddBlipForCoord(coords.x+.0, coords.y+.0, coords.z+.0)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)

    if scale == nil then scale = 0.5 end
    SetBlipScale(blip, scale+.0)

    if color == nil then color = 0 end
    SetBlipColour(blip, color)

    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Uses ESX to create a monitary display
tomoney = function(value)
    if ESX == nil then print('tomoney requires ESX') return '$' .. tostring(value) end
    if value == nil then return '$0' end
    return '$' .. tostring(ESX.Math.GroupDigits(value))
end

-- Cleans up any vehicles within the given coordinates safely
-- This requires ESX because GetAllVehicles() doesn't work in Lua yet
ClearVehiclesInArea = function(coords, radius)
    if ESX == nil then print('ClearVehiclesInArea requires ESX') return false end
    local vehicles = ESX.Game.GetVehiclesInArea(coords, radius)
    local deleted = {}
    for _, v in pairs(vehicles) do
        -- Delete the vehicle
        if ESX.Game.IsVehicleEmpty(v) then
            local property = ESX.Game.GetVehicleProperties(v)
            table.insert(deleted, deleted.plate)
            ESX.Game.DeleteVehicle(v)
        end
    end
    return deleted
end

--- Iterates over all the objects in the world
-- Don't use this to filter for specific vehicles or peds as better functionality exists for those with FindFirstVehicle and FindFirstPed
-- @params filter a callback to be executed for ever object found. Use something like ObjectFilter.model
ObjectIterator = function(filter)
    local handle, next = FindFirstObject()
    local hasNext = handle ~= nil and handle ~= 0
    local curr = nil

    return function()
        -- Keep looping until we return something
        while hasNext do
            -- Get the current and the next
            curr = next
            hasNext, next = FindNextObject(handle)
    
            -- Filter the record if we can, otherwise just return the record
            if curr ~= nil and curr ~= 0 and (filter == nil or filter(curr)) then
                return curr
            end
        end

        -- Clean up the handle
        if handle ~= nil and handle ~= 0 then    
            EndFindObject(handle)
        end
    end
end

--- Iterates over all the objects in the world and returns a table
-- @params filter a callback to be executed for every object found. Use something like ObjectFilter ob it
GetObjects = function(filter) 
    local arr = {}
    for _, v in ObjectIterator(filter) do arr[#arr + 1] = v end
    return arr
end

--- List of filters that can be used with the ObjectIterator.
-- All items within the object are constructors for the filter.
--  The last element is always the optional child filter that get's AND
ObjectFilter = {
    --- Filters objects to a list of models
    model = function(models, filter)
        hashes = {}
        if type(models) == 'string' then 
            hashes[GetHashKey(models)] = models
        else
            for _, m in pairs(models) do
                hashes[GetHashKey(m)] = m
            end
        end
        
        -- Return the filter
        return function(object) 
            local hash = GetEntityModel(object)
            return hashes[hash] ~= nil and 
                    (filter == nil or filter(object))
        end
    end,
    --- Filter objects to within the range of coordinates
    range = function(coordinates, range, filter) 
        local coords = vector3(coordinates.x, coordinates.y, coordinates.z)
        return function(object)
            local objCoords = GetEntityCoords(object)
            return #(objCoords - coords) <= range+.0 and 
                    (filter == nil or filter(object)) 
        end
    end,
    --- Fitlers for peds
    ped = function(filter) 
        return function(object)
            return GetEntityType(object) == 1 and
                    (filter == nil or filter(object)) 
        end
    end,
    --- Filters for vehicles.  
    vehicle = function(filter)
        return function(object)
            return GetEntityType(object) == 2 and
                    (filter == nil or filter(object)) 
        end
    end,
    --- Checks if the entity is dead
    dead = function(filter)        
        return function(object)
            return IsEntityDead(object) and
                    (filter == nil or filter(object)) 
        end
    end,

    --- Inverts the filter
    -- Its probably better to just make your own filter instead of using this.
    -- ObjectFilter.not(ObjectFilter.dead())
    ['not'] = function(filter) 
        if filter == nil then 
            print('error: filter cannot be nil for NOT')
            return nil
        end
        return function(object)
            return not filter(object)
        end
    end
}
