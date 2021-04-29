
ESX = nil

-- Load up the ESX serverside
TriggerEvent("esx:getSharedObject", function(library) 
    ESX = library 
    BusStop.RegisterServerCallbacks(ESX)
end)
