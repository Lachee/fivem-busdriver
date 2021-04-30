

if Config.debug then
    RegisterCommand('coords', function(source, args, rawCommand) 
        local ped       = GetPlayerPed(source)    
        local entity    = ped
        local vehicle   = GetVehiclePedIsIn(ped, false)
        local entity = ped
        if vehicle ~= 0 then
            entity = vehicle
        end


        local coordinates = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        print(entity, coordinates, heading)
        TriggerEvent('chat:addMessage', {
            template = '{0}, {1}, {2} @ {3} deg',
            args = { coordinates.x, coordinates.y, coordinates.z, heading }
        });
    end)

    -- Registers a particular bus stop at the players location
    RegisterCommand('create_stop', function(source, args, rawCommand)
        local ped = GetPlayerPed(source)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local entity = ped
        if vehicle ~= 0 then
            entity = vehicle
        end

        -- Prepare the coordinate
        local coordinates = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)

        -- Prepare the name
        local name = ''
        if #args == 0 then
            
            local directions = {
                N = 360, 0, NE = 315, E = 270, SE = 225, S = 180, SW = 135, W = 90, NW = 45
            }
            
            local var1, var2 = GetStreetNameAtCoord(coordinates.x, coordinates.y, coordinates.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            local hash1 = GetStreetNameFromHashKey(var1);
            local hash2 = GetStreetNameFromHashKey(var2);
            local dir = ''
            for k, v in pairs(directions) do
                if (math.abs(heading - v) < 22.5) then
                    dir = k;
                    if (dir == 1) then
                        dir = 'N';
                        break;
                    end
                    break;
                end
            end
            
            name = hash1 .. ' ' .. hash2 .. ' ' .. dir
        else
            name = args[1]
        end

        -- Prepare the identifying coordinates
        local identifyingCoordinates = coordinates
        local model = BusStop.FindNearestModel()
        print('Model', model)
        if model then 
            identifyingCoordinates = GetEntityCoords(model) 
            heading = GetEntityHeading(model) + 90
        end

        -- Request the stop
        BusStop.RequestCreateStop(identifyingCoordinates, coordinates, heading, name, function(hash) 
            TriggerEvent('chat:addMessage', {
                template = 'Bus stop {0} has been created',
                args = { hash }
            });
        end)

    end, false)
    TriggerEvent('chat:addSuggestion', '/create_stop', 'Adds a stop', {
        {name = 'name', help = 'The name of the stop'}
    })



    -- Registers a particular bus stop at the players location
    RegisterCommand('find_stops', function(source, args, rawCommand)
        if FindStops then 
            FindStops = false
        else
            FindStops = true
        end

        TriggerEvent('chat:addMessage', {
            template = 'Find stops has been toggled to {0}',
            args = {  FindStops }
        });
    end)
end