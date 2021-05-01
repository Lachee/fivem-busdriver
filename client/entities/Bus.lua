Bus = {}
Bus.current = nil
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

-- Creates a bus object
Bus.Create = function(type, coordsHeading, callback)
    -- Destroy the previous bus?
    if Bus.Destroy then
        ESX.ShowNotification('Previous bus was ~r~destroyed', true, true, 10)
    end

    -- Determine the model
    local model = 'bus'
    if type == 'rural' then model = 'coach' end
    if type == 'terminal' then model = 'airbus' end
    if type == 'party' then model = 'pbus2' end
    if type == 'tour' then model = 'tourbus' end

    --Spawn the vehicle
    ESX.Game.SpawnVehicle(model, coordsHeading, coordsHeading.w, function(vehicle) 
        Bus.current = vehicle
        Bus.CloseDoors(true)
        Bus.SetFuel(100)
        callback(Bus.current)
    end)
end
