Bus = {}
Bus.current = nil
Bus.info = nil
Bus.doorsOpen = false

-- Opens the bus door
Bus.OpenDoors = function(instant) 
    if instant then instant = true else instant = false end   
    if not Bus.current then return false end 
    SetVehicleDoorOpen(Bus.current, 0, false, instant)
    SetVehicleDoorOpen(Bus.current, 1, false, instant)
    Bus.doorsOpen = true
    return true
end

-- Closes the bus door
Bus.CloseDoors = function(instant)
    if instant then instant = true else instant = false end
    if not Bus.current then return false end
    SetVehicleDoorShut(Bus.current, 0, false, instant)
    SetVehicleDoorShut(Bus.current, 1, false, instant)
    Bus.doorsOpen = false
    return true
end

-- Toggles the doors
Bus.ToggleDoors = function(instant) 
    if Bus.doorsOpen then 
        return Bus.CloseDoors(instant)
    else
        return Bus.OpenDoors(instant)
    end
end

-- Destroys the bus. If the PED is still in the bus, then it will be requested to leave
Bus.Destroy = function(callback)
    if Bus.current then
        ESX.Game.DeleteVehicle(Bus.current)
        Bus.current = nil
        Bus.info = nil
        if callback then callback(true) end
        return true
    end
    if callback then callback(false) end
    return false
end

Bus.SetFuel = function(level) 
    if not Bus.current then return false; end
    ESX.Game.SetVehicleProperties(Bus.current, { fuelLevel = level })
    return true
end

-- Gets the capacity of the bus
Bus.GetCapacity = function() 
    if not Bus.info then return nil end
    return Bus.info.capacity
end

-- Finds a random free seat
Bus.FindFreeSeat = function()
    if not Bus.current then return false end
    local capacity = GetVehicleMaxNumberOfPassengers(Bus.current)

    for i = 0, capacity do
        if IsVehicleSeatFree(Bus.current, i) then
            return i
        end
    end

    return false
end

-- Asks the ped to make their way into the bus
Bus.RequestPedToSeat = function(ped, seat) 
    if not Bus.current then return false end
    if seat == nil then seat = Bus.FindFreeSeat() end
    if seat == false then print('not enough seats available') return false end
    if ped == nil then print('The ped is null') return false end    
            
    print('Telling ped to get in', seat, ped)
    TaskEnterVehicle(ped, Bus.current, Config.passengerTimeout, seat, 1.0, 1, 0)
    return true
end

-- Creates a bus object
Bus.Create = function(type, coordsHeading, callback)
    -- Destroy the previous bus?
    if Bus.Destroy then
        ESX.ShowNotification('Previous bus was ~r~destroyed', true, true, 10)
    end

    -- Determine the model
    local info = Bus.GetBusInfoFromRoute(type)
    if info == nil then print('Failed to find a bus', type) callback(nil) return end

    --Spawn the vehicle
    ESX.Game.SpawnVehicle(info.model, coordsHeading, coordsHeading.w, function(vehicle) 
        Bus.current = vehicle
        Bus.info = info
        Bus.CloseDoors(true)
        Bus.SetFuel(100)
        callback(Bus.current)
    end)
end


Bus.GetBusInfoFromRoute = function(routeType)
    if routeType == 'metro' then     return { type = routeType, model = 'bus', capacity = 16 } end
    if routeType == 'rural' then     return { type = routeType, model = 'coach', capacity = 16 } end
    if routeType == 'terminal' then  return { type = routeType, model = 'airbus', capacity = 16 } end
    if routeType == 'party' then     return { type = routeType, model = 'pbus2', capacity = 5 } end
    if routeType == 'tour' then      return { type = routeType, model = 'tourbus', capacity = 5 } end
    return nil
end