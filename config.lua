print("Loading Lachee's Bus Driver")

-- Master Config
Config = { }
Config.debug = false -- Debug visualisation

Config.coordinates = vector4( 472.2, -592.5, 28.5, 175.28) -- Coordinates to start the job
Config.stopColor = { r = 148, g = 0, b = 211 } -- The colour for the markers

Config.deposit = 200                -- How much the buses cost. The player get this back if they return the bus
Config.earningBase = 0              -- How many dollars does the player get from just completing the job.
Config.earningPerKM = 0.1           -- How many dollars per km does a route earn. 0.1 gives about 400/10minutes.
                                    --      Distance of route is calculated "as the bird flys", use the
                                    --      route "multiplier" in the database to account for this.
                                    --      Try either 0.05 or 0.025
Config.earningPerStop = 10          -- How many dollars per stop extra does the player earn.
                                    --      If a stop takes 0.25 minutes, and 1 minute is worth $20, then the bonus should be
                                    --      about 20*0.25, or $5
Config.earningIncludesDepo = true   -- Does the travel time too and from the depo count?

Config.alwaysRenderStops = Config.debug -- Always render the names of the stop when players approach, rather then just when there is a route active
Config.alwaysShowBlips = false -- Always shows the bus stop blips

Config.passengerRadius = 200.0 -- Distance before passengers are spawned
Config.pedVehicleTimeout = 15.0 -- How long to wait till we give up and TP the passenger
Config.stopDistanceLimit = 1.0 -- How close the bus has to be to the stop
Config.stopHeadingLimit = 5.0 -- How many degrees the bus must be within wiht the stop
