Bus = {}
Bus.current = nil
Bus.info = nil
Bus.passengers = {}
Bus.doorsOpen = false

-- Opens the bus door
Bus.OpenDoors = function(instant) 
    if instant == nil then instant = true else instant = false end   
    if not Bus.current then return false end

    for i = 1, #Bus.info.doors do
        SetVehicleDoorOpen(Bus.current, Bus.info.doors[i], false, instant)
    end

    Bus.doorsOpen = true
    return true
end

-- Closes the bus door
Bus.CloseDoors = function(instant)
    if instant == nil then instant = true else instant = false end
    if not Bus.current then return false end
    
    for i = 1, #Bus.info.doors do
        SetVehicleDoorShut(Bus.current, Bus.info.doors[i], false, instant)
    end

    Bus.doorsOpen = false
    return true
end

-- Turns the hazards either on or off
Bus.SetHazards = function(state) 
    if Bus.current == nil then print('cannot set hazards on a nil bus') return false end
    SetVehicleIndicatorLights(Bus.current, 0, state)
    SetVehicleIndicatorLights(Bus.current, 1, state)
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

    for i = 1, capacity do
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
Bus.AddPassenger = function(ped, seat)
    if not Bus.current then return false end
    if seat == nil then seat = Bus.FindFreeSeat() end
    if seat == false then print('not enough seats available') return false end
    if ped == nil then print('The ped is null') return false end    
   
    if not Ped.EnterVehicle(ped, Bus.current, seat, Ped.RUN, nil, true) then
        print('failed to get ped to enter vehicle')
        return false
    end
    
    local psg = {
        ped = ped, 
        seat = seat,
        destination = 0,
        isLeaving = false,
        isEntering = true,
    }

    if not Ped.EnterVehicle(ped, Bus.current, seat, Ped.RUN) then
        print('Bus: Failed to make ped enter bus')
        return false
    end


    table.insert(Bus.passengers, psg)
    return #Bus.passengers, seat
end

-- Removes a passenger, asking them nicely to get off the bus
Bus.RemovePassenger = function(passenger)
    if teleport == nil then teleport = false end
    local i, psg = Bus.GetPassenger(passenger)
    if psg ~= nil then
        psg.isLeaving = true
        Ped.ExitVehicle(psg.ped, 256, Bus.current)
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

        -- If the ped is dead, then remove them from our list and tell GTA to clean them up
        if Ped.IsDead(psg.ped) then
            print('Ped died while waiting for embarkment')
            Ped.Remove(psg.ped)
            table.remove(Bus.passengers, i)
            return Bus.CheckPassengersEmbarked()
        end

        -- If the ped is not in the bus yet, abort
        if not Ped.InVehicle(psg.ped, Bus.current, false) then
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

            -- Get the passenger states
            local inVehicle =  Ped.InVehicle(psg.ped, Bus.current, false)
            local isDead = Ped.IsDead(psg.ped)

            -- They are no longer in the list, so remove them and check again
            if not inVehicle or isDead then
                if isDead then Ped.Remove(psg.ped) end
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

-- Removes sticky shits
Bus.Cull = function()
    Bus.passengers = table.filter(Bus.passengers, function(o, k, i)
        if o.isLeaving then
            print('removing sticky shit ', o.ped)
            Ped.Remove(o.ped)
            return false
        end
        return true
    end)
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
    if Bus.Destroy() then
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

-- Gets meta information about a particular bus for the specified route type
Bus.GetBusInfoFromRoute = function(routeType)
    if routeType == 'metro' then     return { type = routeType, model = 'bus', capacity = 15, doors = {0, 1, 2, 3 }} end
    if routeType == 'terminal' then  return { type = routeType, model = 'airbus', capacity = 15, doors = {0, 1, 2, 3 }} end
    if routeType == 'airport' then  return { type = routeType, model = 'airbus', capacity = 15, doors = {0, 1, 2, 3 }} end

    if routeType == 'rural' then     return { type = routeType, model = 'coach', capacity = 9, doors = { 0 } } end
    
    if routeType == 'party' then     return { type = routeType, model = 'pbus2', capacity = 9, doors = { 0 }  } end
    
    if routeType == 'tour' then      return { type = routeType, model = 'tourbus', capacity = 8, doors = { 2, 3 }} end
    
    if routeType == 'rental' then    return { type = routeType, model = 'rentalbus', capacity = 8, doors = { 2, 3 }} end
    return nil
end
