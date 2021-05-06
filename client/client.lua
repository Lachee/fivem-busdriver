
DEBUG_FindStops = false

-- Load up the ESX. Its a single line cause im a lazy git and prefer it this way
ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        if ESX == nil then
            TriggerEvent("esx:getSharedObject", function(library)
                ESX = library
                BusStop.RegisterEvents(ESX)
                Route.RegisterEvents(ESX)
                EnsureJob(ESX.PlayerData)
            end)
            
            Citizen.Wait(0)
        end
    end
end)

-- Ensures the job blip
local blip = nil
function EnsureJob(playerData)
    if playerData == nil then return end 
    if playerData.job == nil then return end
    
    local jobName = playerData.job.name
    if jobName == 'busdriver' then
        if blip ~= nil then
            SetBlipDisplay(blip, 4)
        else
            blip = CreateBlip(513, Config.coordinates, "Bus Depo", 1.0, 16)
        end
    elseif blip ~= nil then
        SetBlipDisplay(blip, 0)
    end
end

-- Load up the player data
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
    EnsureJob(ESX.PlayerData)
end)

-- Load up the player job
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
    ESX.PlayerData["job"] = newJob
    EnsureJob(ESX.PlayerData)
end)

-- Update while the player is within the job marker
function UpdateJobMarker() 
    if Job.active then

        -- This is technically bugged. Means you can walk home without your bus
        if Job.isRouteFinished then
            ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~g~finish~s~ your route and ~r~forfeit~s~ your bond.", true, false)
            if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
                Job.End(false, false)
            end
        else
            ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to ~r~forfeit~s~ your route and your bond.", true, false)
            if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
                Job.End(true, false)
            end
        end
    else
        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to begin a route.", true, false)
        if IsControlJustPressed(0, Controls.INPUT_CONTEXT) then
            Job.Begin()
        end
    end
end

-- Update while the player is within the bus return marker
function UpdateBusMarker() 
    if Job.isRouteFinished then
        ESX.ShowHelpNotification("Press ~INPUT_VEH_EXIT~ to ~g~finish~s~ your route", true, false)
    else
        ESX.ShowHelpNotification("Press ~INPUT_VEH_EXIT~ to ~r~forfeit~s~ your route", true, false)
    end

    -- Wait for the bed to leave the vehicle
    if not IsPedInVehicle(PlayerPedId(), Bus.current, true) then
        Job.End(Job.isRouteFinished == false, true)
    end
end


-- Draw all the markers and handle the main game loop
Citizen.CreateThread(function()
    local frame = 0;
    while true do
        Citizen.Wait(5)

        -- Render either the specific stop or all the stops
        if Config.alwaysRenderStops then
            BusStop.RenderAll(Config.stopColor)
        elseif Job.active then
            local stop = Job.GetNextStop()
            if stop ~= nil then  BusStop.Render(stop, Config.stopColor) end
        end
        
        local coords    = GetEntityCoords(PlayerPedId())
        local vehicle   = GetVehiclePedIsIn(PlayerPedId(), true) 
        local distance  = GetDistanceBetweenCoords(coords, Config.coordinates, false)
        local onMarker = false

        -- Draw the bus return marker
        if vehicle ~= nil and vehicle == Bus.current then
            distance = GetDistanceBetweenCoords(GetEntityCoords(vehicle), Config.coordinates, false)
            if distance < 1.5 then
                BusStop.DrawZone(Config.coordinates, Config.coordinates.w, { r = 255, 0, 0 })
                UpdateBusMarker()
                onMarker = true
            else
                -- Draw where to park the bus
                BusStop.DrawZone(Config.coordinates, Config.coordinates.w, { r = 200, 100, 0 })
            end
        else 
            -- Draw the job marker
            if not Ped.InVehicle(PlayerPedId()) then
                if distance < 1.5 then
                    DrawGroundedZoneMarker(Config.coordinates, 3, { r = 255, 0, 0 })
                    UpdateJobMarker()
                    onMarker = true
                else
                    DrawGroundedZoneMarker(Config.coordinates, 3, { r = 200, 100, 0 })
                end
            end
        end

        
        -- Run the job
        if not onMarker and Job.active then
            Job.Process()
        end

    end
end)

-- Draw the debug visualisations
if Config.debug then
    Citizen.CreateThread(function()
        local frame = 0
        local roadCoords = vector3(0,0,0)
        local foundRoad = false
        local sidePointCoords = vector3(0,0,0)
        local foundSidePoint = false
        local models = {}
        while true do
            Citizen.Wait(10)
            
            -- Find models
            frame = frame + 1
            if frame % 10 == 0 then
                models = BusStop.FindAllModels(true)
            end

            -- Get the closest model
            --local obj = BusStop.FindNearestModel(GetEntityCoords(PlayerPedId()), 200.0)
            for _, m in pairs(models) do
                local obj = m.object
                --if obj ~= nil and obj ~= 0 then
                    --Get the stop coords
                local coords = m.coords
                local heading = (m.heading + 90) % 360
                DrawHeadingMarker(coords+vector3(0,0,.1), heading, 1.0, {r=0,g=255,b=255})

                --Get the road coords
                --if frame % 1 == 0 then
                    --foundRoad, roadCoords = GetNthClosestVehicleNode(coords.x, coords.y, coords.z, 1, 0, 0, 0)
                    foundSidePoint, sidePointCoords = GetRoadSidePointWithHeading(coords.x, coords.y, coords.z, heading-90)
                --end

                if foundRoad then
                    DrawLineMarker(roadCoords, coords, {r=255,g=0,b=255})
                    DrawZoneMarker(roadCoords, 0.1, {r=255,g=0,b=255})
                end

                -- Side Point
                if foundSidePoint then
                    DrawLineMarker(sidePointCoords, coords, {r=0,g=0,b=255})
                    DrawZoneMarker(sidePointCoords, 0.1, {r=0,g=0,b=255})
                    
                    -- Origin X, Y, Z
                    -- DrawRay(coords + vector3(0,0,0.5), vector3(1, 0, 0), {r=255,g=0,b=0})
                    -- DrawRay(coords + vector3(0,0,0.5), vector3(0, 1, 0), {r=0,g=255,b=0})
                    -- DrawRay(coords + vector3(0,0,0.5), vector3(0, 0, 1), {r=0,g=0,b=255})

                    -- Prepare the directions
                    local differenceBetweenCoords = sidePointCoords - coords
                    local directionToSidePoint = norm(vector3(differenceBetweenCoords.x, differenceBetweenCoords.y, 0))
                    -- DrawRay(coords, directionToSidePoint, {r=255,g=0,b=0})
            
                    local directionFromHeading = norm(quat(heading, vector3(0,0,1)) * vector3(0, 1, 0))
                    directionFromHeading = norm(vector3(directionFromHeading.x, directionFromHeading.y, 0))
                    -- DrawRay(coords, directionFromHeading, {r=255,g=255,b=255})

                    -- Get the angle between them and use that to calculate the offset from the road
                    local roadOffsetDistanceCap = 7.0
                    local angleBetweenDirections = angleFromToo(directionFromHeading, directionToSidePoint)
                    local roadOffsetDistance = math.sin(angleBetweenDirections) * #differenceBetweenCoords
                    if roadOffsetDistance > roadOffsetDistanceCap then roadOffsetDistance = roadOffsetDistanceCap end
                    local roadOffsetDirection = norm(quat(heading + 90, vector3(0, 0, 1)) * vector3(0, 1, 0))
                    local roadOffsetCoords = coords + (roadOffsetDirection * roadOffsetDistance)
                    -- DrawRay(coords + vector3(0, 0, 0.5), roadOffsetDirection, {r=255,g=0,b=255})
                    -- DrawZoneMarker(roadOffsetCoords, 0.25, {r=255, g=255, b=255})

                    -- Determine the best spot for the bus zone
                    local busZoneCoords = roadOffsetCoords
                                            + (roadOffsetDirection * BusStop.Size.width * 0.5) 
                                            - (directionFromHeading * BusStop.Size.length * 0.35)
                                            + vector3(0, 0, 1)
                                            
                    DrawHeadingMarker(busZoneCoords, heading, 1.0, {r=255,g=255,b=0})                                                  
                    BusStop.DrawZone(busZoneCoords, heading, {r=255,g=255,b=0})
                end
            end
        end
    end)
end