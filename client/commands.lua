

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
    --     for o in ObjectIterator(ObjectFilter.model(BusStop.MODELS)) do print('bus stops', o) end
    --     for o in ObjectIterator(ObjectFilter.range(GetEntityCoords(PlayerPedId()), 5.0)) do print('within 5m', o) end
    --     
    --     for o in ObjectIterator(
    --                     ObjectFilter.model(BusStop.MODELS,
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
        local hash = BusStop.CalculateHash(coordinates)

        -- Update the hash if we are able to find the model.
        -- Additionally, update our heading.
        local object = BusStop.FindNearestModel(coordinates)
        if object ~= 0 and object ~= nil then 
            hash = BusStop.CalculateHash(GetEntityCoords(object))
            coordinates, heading = BusStop.GetEstimatedBestCoords(object)
        end

        -- Prepare the name
        local name = nil
        if #args == 1 then
            name = args[1]
        end

        -- Create the stop object
        local stop = {
            hash = hash,
            x = coordinates.x,
            y = coordinates.y,
            z = coordinates.z,
            heading = heading,
            qx = 0,
            qy = 0,
            qz = 0,
            name = name,
            type = 'metro',
            clear = 0
        }

        -- Create the stop
        BusStop.CreateStop(stop, function(count) 
            TriggerEvent('chat:addMessage', {
                template = 'Bus stop has been created: {0}',
                args = { count }
            });
        end)
    end, false)

    -- Sets the queue for the closest bus stop
    RegisterCommand('setQueue', function(source, args, rawCommand)
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)
        
        -- Find the object
        -- TODO: Check by ID instead if we cannot find a model
        local object = BusStop.FindNearestModel(coords)
        if object == 0 or object == nil then 
            TriggerEvent('chat:addMessage', {
                template = 'There is currently no stop nearby',
                args = {  }
            });
            return
        end
            
        -- Get the hash and send a update request
        local stop = {
            hash = BusStop.CalculateHash(GetEntityCoords(object)),
            qx = coords.x,
            qy = coords.y,
            qz = coords.z,
        }
        
        -- Perform the update
        BusStop.UpdateStop(stop, function(success)
            if success then
                TriggerEvent('chat:addMessage', {
                    template = 'Updated the stop',
                    args = { }
                });
            else 
                TriggerEvent('chat:addMessage', {
                    template = 'Failed to update the stop. Has it been created first?',
                    args = { }
                });
            end
        end)
    end)

    
    -- Sets the zone for the closest bus stop
    RegisterCommand('setZone', function(source, args, rawCommand)
        local ped = GetPlayerPed(source)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local entity = ped
        if vehicle ~= 0 then
            entity = vehicle
        end

        -- Prepare the coordinate
        local coords = GetEntityCoords(entity)
        local heading = GetEntityHeading(entity)
        
        -- Ensure the stop exists
        -- TODO: Check by ID instead if we cannot find a model
        local object = BusStop.FindNearestModel(coords)
        if object == 0 or object == nil then 
            TriggerEvent('chat:addMessage', {
                template = 'There is currently no stop nearby',
                args = {  }
            });
            return
        end
            
        -- Get the hash and send a update request
        local stop = {
            hash    = BusStop.CalculateHash(GetEntityCoords(object)),
            x       = coords.x,
            y       = coords.y,
            z       = coords.z,
            heading = heading,
        }
        
        -- Perform the update
        BusStop.UpdateStop(stop, function(success)
            if success then
                TriggerEvent('chat:addMessage', {
                    template = 'Updated the stop',
                    args = { }
                });
            else 
                TriggerEvent('chat:addMessage', {
                    template = 'Failed to update the stop. Has it been created first?',
                    args = { }
                });
            end
        end)
    end)
end