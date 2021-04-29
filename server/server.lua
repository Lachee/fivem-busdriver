
-- Load up the ESX serverside
ESX = nil
TriggerEvent("esx:getSharedObject", function(library) 
    ESX = library 
end)

