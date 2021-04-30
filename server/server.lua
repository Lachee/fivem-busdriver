
ESX = nil

-- Load up the ESX serverside
TriggerEvent("esx:getSharedObject", function(library) 
    ESX = library 
    
    BusStop.RegisterServerCallbacks(ESX)
    Route.RegisterServerCallbacks(ESX)

    -- Begin handling the job
    ESX.RegisterServerCallback(E.BeginJob, function(source, callback, type)
        print('fish')
        local xPlayer = ESX.GetPlayerFromId(source)
        local job = xPlayer.getJob()
        if job.name == 'busdriver' then
            print('Users wishes to be a bus driver')
            if type == nil then type = false end
            Route.GetRandomRoute(type, callback)
        else
            print('Player attempted to start a job invalid', source, job)
            callback(nil)
        end

    end)
end)
