E = {
    SpawnVehicle = 'lacheebus:spawnVehicle',
    CreateBusStop = 'lacheebus:createBusStop',
    GetBusStops = 'lacheebus:requestBusStops',
}

print('Loaded Events: ')
for k, v in pairs(E) do print(k, v) end