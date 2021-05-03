print("Loading Lachee's Bus Driver")

-- Master Config
Config = { }
Config.debug = true -- Debug visualisation

Config.coordinates = vector4( 472.2, -592.5, 28.5, 175.28) -- Coordinates to start the job

Config.stopColor = { r = 148, g = 0, b = 211 } -- The colour for the markers
Config.alwaysRenderStops = false -- Always render the names of the stop when players approach, rather then just when there is a route active
Config.alwaysShowBlips = false -- Always shows the bus stop blips

Config.passengerRadius = 200.0 -- Distance before passengers are spawned
Config.pedVehicleTimeout = 15000 -- How long to wait till we give up and TP the passenger
Config.stopDistanceLimit = 1.0 -- How close the bus has to be to the stop
Config.stopHeadingLimit = 5.0 -- How many degrees the bus must be within wiht the stop
