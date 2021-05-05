E = {
    CreateBusStop = 'lacheebus:createBusStop',  -- Request to create a bus stop
    GetBusStops = 'lacheebus:requestBusStops',  -- Requests all bus stops

    GetRoutes = 'lacheebus:requestRoutes',          -- Gets a list of routes
    GetRoute = 'lacheebus:requestSpecificRoute',    -- Gets a specific route

    BeginJob = 'lacheebus:startJob',                -- Begin the job
    EndJob = 'lacheebus:endJob',
    
    RouteActive = 'lacheebus:routeActive',          -- Someone has started this route
    RouteDeactive = 'lacheebus:routeDeactive',      -- Someone has finished this route
}


-- print('Loaded Events: ')
-- for k, v in pairs(E) do print(k, v) end