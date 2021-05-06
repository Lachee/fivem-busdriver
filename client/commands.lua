

if Config.debug then
    
    RegisterCommand('findStops', function(source, args, rawCommand)
        local models = BusStop.FindAllModels(true)
        print('found models: ', #models)
        TriggerEvent('chat:addMessage', {
            template = 'Showing {0} stops',
            args = { #models }
        });
    end)

    -- Test functionality for the object filter
    -- RegisterCommand('objects', function(source, args, rawCommand)
    --     for o in ObjectIterator() do print('object', o) end
    --     for o in ObjectIterator(ObjectFilter.model(BusStop.Models)) do print('bus stops', o) end
    --     for o in ObjectIterator(ObjectFilter.range(GetEntityCoords(PlayerPedId()), 5.0)) do print('within 5m', o) end
    --     
    --     for o in ObjectIterator(
    --                     ObjectFilter.model(BusStop.Models,
    --                         ObjectFilter.range(GetEntityCoords(PlayerPedId()), 5.0)
    --                     )
    --                 ) do 
    --         print('within 5m', o) 
    --     end
    -- end)

    -- Teleports the user to the next stop
    RegisterCommand('nextStop', function(source, args, rawCommand)
        if not Job.active then
            print('cannot skip, you are not on a route')
            TriggerEvent('chat:addMessage', {
                template = 'You have to be in an active route',
                args = { }
            });
            return
        end

        if not Job.Teleport() then
            print('cannot skip, failed to teleport')
            TriggerEvent('chat:addMessage', {
                template = 'You have finished your route, return the bus',
                args = {  }
            });
            return
        end

        print('Teleport success')
        TriggerEvent('chat:addMessage', {
            template = 'You have been teleported',
            args = {  }
        });
    end)

    -- Starts a random route
    RegisterCommand('busme', function(source, args, rawCommand)
        local ped       = GetPlayerPed(source)    
        local entity    = ped
        local vehicle   = GetVehiclePedIsIn(ped, false)
        if vehicle then
            ESX.Game.DeleteVehicle(vehicle)
        end
        
        --Teleport and get your bus            
        TriggerEvent('chat:addMessage', {
                template = 'Fetching a bus...',
                args = { }
        });

        SetPedCoordsKeepVehicle(ped, Config.coordinates.x, Config.coordinates.y, Config.coordinates.z)
        Citizen.Wait(1000)

        Job.Begin(function(bus)
            TriggerEvent('chat:addMessage', {
                template = 'Teleporting you to the start...',
                args = { }
            });
        
            -- Teleport to the stop
            if #args >= 1 then
                if bus then
                    Job.Teleport()
                end
            end
        end)
    end)

    -- Gets the users current coords
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
    RegisterCommand('createStop', function(source, args, rawCommand)
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
            local directions = { N = 360, 0, NE = 315, E = 270, SE = 225, S = 180, SW = 135, W = 90, NW = 45 }
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
end