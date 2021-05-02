Bus = {}
Bus.current = nil
Bus.info = nil
Bus.passengers = {}
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
        if Bus.IsSeatFree(i) then
            return i
        end
    end

    return false
end

-- Checks if the specified seat is free
Bus.IsSeatFree = function(seat) 
    if not Bus.current then return false end
    if not IsVehicleSeatFree(Bus.current, seat) then return false end
    for i,p in pairs(Bus.passengers) do
        if p.seat == seat then return false end
    end
    return true
end

-- Adds the passenger to the seat. By default it will ask them to enter the vehicle nicely
Bus.AddPassenger = function(ped, seat, teleport)
    if not Bus.current then return false end
    if teleport == nil then teleport = false end
    if seat == nil then seat = Bus.FindFreeSeat() end
    if seat == false then print('not enough seats available') return false end
    if ped == nil then print('The ped is null') return false end    
   
    local psg = {
        ped = ped, 
        seat = seat,
        destination = 0,
        isLeaving = false,
        isEntering = false,
    }

    if teleport then
        print('Warping ped into', seat, ped)
        psg.isEntering = false
        TaskWarpPedIntoVehicle(ped, Bus.current, seat)
    else
        print('Telling ped to get in', seat, ped)
        psg.isEntering = true
        TaskEnterVehicle(ped, Bus.current, Config.passengerTimeout, seat, 3.0, 1, 0)
    end

    table.insert(Bus.passengers, psg)
    return #Bus.passengers
end

-- Removes a passenger, asking them nicely to get off the bus
Bus.RemovePassenger = function(passenger, teleport)
    if teleport == nil then teleport = false end

    local i, psg = Bus.GetPassenger(passenger)
    psg.isLeaving = true

    if teleport then
        TaskLeaveVehicle(psg.ped, Bus.current, 16)
    else 
        TaskLeaveVehicle(psg.ped, Bus.current, 1)
    end
end


-- Sets a specific passengers destination
Bus.SetPassengerDestination = function(passenger, destination) 
    local _, psg = Bus.GetPassenger(passenger)
    psg.destination = destination
    return psg
end

-- Checks if all passengers are on board
Bus.CheckPassengersEmbarked = function() 
    for i, psg in pairs(Bus.passengers) do

        -- TODO: CHeck if bed is dead 

        local vehicle = GetVehiclePedIsIn(psg.ped, false)
        if vehicle == nil or vehicle == 0 then
            return false
        end
    end
    return true
end


-- Clears the passenger list of anyone leaving the bust and isn't on the bus
-- Callback is invoked once per passenger when they are removed from the table. Use this to perform auxillary actions
Bus.CheckPassengersDisembarked = function(callback) 
    for i, psg in pairs(Bus.passengers) do
        if psg.isLeaving then

            -- They are no longer in the list, so remove them and check again
            local vehicle = GetVehiclePedIsIn(psg.ped, false)
            if vehicle == nil or vehicle == 0  then
                table.remove(Bus.passengers, i)
                if callback then callback(psg) end
                return Bus.CheckPassengersDisembarked(callback)
            end

            -- They are in the bus, no go
            return false
        end
    end

    -- success
    return true
end

-- Gets the passenger
Bus.GetPassenger = function(index) 
    if index < 1 or index > #Bus.passengers then
        for i, p in pairs(Bus.passengers) do
            if p.ped == index then return i, p end
        end
        return nil
    else
        return index, Bus.passengers[index]
    end
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
        Bus.passengers = {}
        Bus.CloseDoors(true)
        Bus.SetFuel(100)
        callback(Bus.current)
    end)
end

-- Destroys the bus. If the PED is still in the bus, then it will be requested to leave
Bus.Destroy = function(callback)
    if Bus.current then
        ESX.Game.DeleteVehicle(Bus.current)
        Bus.current = nil
        Bus.info = nil
        Bus.passengers = {}
        if callback then callback(true) end
        return true
    end
    if callback then callback(false) end
    return false
end


Bus.GetBusInfoFromRoute = function(routeType)
    if routeType == 'metro' then     return { type = routeType, model = 'bus', capacity = 16 } end
    if routeType == 'rural' then     return { type = routeType, model = 'coach', capacity = 16 } end
    if routeType == 'terminal' then  return { type = routeType, model = 'airbus', capacity = 16 } end
    if routeType == 'party' then     return { type = routeType, model = 'pbus2', capacity = 5 } end
    if routeType == 'tour' then      return { type = routeType, model = 'tourbus', capacity = 5 } end
    return nil
end