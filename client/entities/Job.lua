Job = {}

Job.active = false
Job.bus = nil
Job.route = nil
Job.nextStop = 1

Job.Begin = function(callback) 
    Job.active = true

    ESX.TriggerServerCallback(E.BeginJob, function(route) 

        -- Validate the route
        if route == nil then
            ESX.ShowNotification('There is ~r~no~s~ routes available for you', true, true, 10)
            Job.active = false
            return
        end
        
        Job.route = route
        Job.nextStop = 1

        -- TODO: Trigger Bond Deposit
        
        -- Spawn a bus
        Job.SpawnBus(route.type, Config.coordinates, function(bus) 
            TaskWarpPedIntoVehicle(PlayerPedId(), bus, -1)
            ESX.ShowNotification('You have started working', true, true, 10)
            if callback then callback(route) end
        end)
    end)
end

Job.End = function(forfeit) 
    -- Disable the active state of the job
    Job.active = false
    
    -- Wait for the user to leave the bus
    if forfeit then
        ESX.ShowNotification('You have ~r~forfeited~s~ your route', true, true, 10)
    else 
        ESX.ShowNotification('You have ~g~completed~s~ your route', true, true, 20)
        --TODO: Trigger Bond Repayment
    end

    -- Finally clear the route
    Job.DestroyBus()
    Job.route = nil
end

-- Destroys the bus. If the PED is still in the bus, then it will be requested to leave
Job.DestroyBus = function(callback)
    if Job.bus then

        -- Wait for the bed to leave the vehicle
        -- if IsPedInVehicle(PlayerPedId(), Job.bus, true) then
        --     TaskLeaveVehicle(PlayerPedId(), Job.bus, 256)
        --     while IsPedInVehicle(PlayerPedId(), Job.bus, true) do
        --         Citizen.Wait(0)
        --     end
        --     Citizen.Wait(300)
        -- end
        
        -- Destroy the bus
        print("Destroyed the existing bus")
        ESX.Game.DeleteVehicle(Job.bus)
        Job.bus = nil
        if callback then callback(true) end
        return true
    end
    
    print("Failed to delete bus because it doesn't exist")
    if callback then callback(false) end
    return false
end
Job.SpawnBus = function(type, coordsHeading, callback)
    -- Destroy the previous bus?
    if Job.DestroyBus() then
        ESX.ShowNotification('Previous bus was ~r~DESTROYED', true, true, 10)
    end

    local model = 'bus'
    if type == 'rural' then model = 'coach' end
    if type == 'terminal' then model = 'airbus' end
    if type == 'party' then model = 'pbus2' end
    if type == 'tour' then model = 'tourbus' end

    ESX.Game.SpawnVehicle(model, coordsHeading, coordsHeading.w, function(vehicle) 
        Job.bus = vehicle
        ESX.Game.SetVehicleProperties(Job.bus, { fuelLevel = 100 })
        callback(Job.bus)
    end)
end