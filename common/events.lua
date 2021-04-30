E = {
    SpawnVehicle = 'lacheebus:spawnVehicle',    -- Spawn a specific vehicle
    CreateBusStop = 'lacheebus:createBusStop',  -- Request to create a bus stop
    GetBusStops = 'lacheebus:requestBusStops',  -- Requests all bus stops

    GetRoutes = 'lacheebus:requestRoutes',          -- Gets a list of routes
    GetRoute = 'lacheebus:requestSpecificRoute',    -- Gets a specific route
}

-- print('Loaded Events: ')
-- for k, v in pairs(E) do print(k, v) end