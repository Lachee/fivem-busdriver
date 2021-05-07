
BusStop = {}

-- Gets the hash of the bus stop from the given coordinates
BusStop.CalculateHash = function(coords) 
    local x = math.floor(coords.x)
    local y = math.floor(coords.y)
    return sha1.hex('busstop:' .. tostring(x) .. ':' .. tostring(y))
end