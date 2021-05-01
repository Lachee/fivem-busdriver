Route = {}

Route.SetGps = function(route)
    ClearGpsMultiRoute()
    StartGpsMultiRoute(8, true, false)
    for _, s in pairs(route.stops) do
        AddPointToGpsMultiRoute(s.x+.0, s.y+.0, s.z+.0)
    end
    SetGpsMultiRouteRender(true)
end