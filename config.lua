print("Loading Lachee's Bus Driver")

-- Master Config
Config = { }
Config.debug = true -- Debug visualisation
Config.coordinates = vector4( 472.2, -592.5, 28.5, 175.28) -- Coordinates to start the job

Config.passengerRadius = 200.0 -- Distance before passengers are spawned
Config.stopDistanceLimit = 1.0 -- How close the bus has to bed
Config.stopHeadingLimit = 2.0 -- How many degrees the bus must be within wiht the stop
Config.pedVehicleTimeout = 15000 -- How long to wait till we give up and TP the passenger
