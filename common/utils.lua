function table.indexOf(t, object)
    if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

    for i, v in pairs(t) do
        if object == v then
            return i
        end
    end
end

-- table.filter({"a", "b", "c", "d"}, function(o, k, i) return o >= "c" end)  --> {"c","d"}
--
-- @FGRibreau - Francois-Guillaume Ribreau
-- @Redsmin - A full-feature client for Redis http://redsmin.com
table.filter = function(t, filterIter)
	local out = {}
  
	for k, v in pairs(t) do
	  if filterIter(v, k, t) then out[k] = v end
	end
  
	return out
  end

local rad2Deg = math.rad2Deg
local pi = math.pi
local half_pi = pi * 0.5
local two_pi = 2 * pi
local negativeFlip = -0.0001
local positiveFlip = two_pi - 0.0001

QuatToEuler = function(quat)
    local x = quat.x
    local y = quat.y
    local z = quat.z
    local w = quat.w    
    
	local check = 2 * (y * z - w * x)	
	if check < 0.999 then
		if check > -0.999 then
			local v = vector3(
                            -math.asin(check), 
                            math.atan2(2 * (x * z + w * y), 1 - 2 * (x * x + y * y)), 
                            math.atan2(2 * (x * y + w * z), 1 - 2 * (x * x + z * z))
                        )

			v = SanitizeEuler(v, rad2Deg)
			return v
		else
			local v = vector3(half_pi, math.atan2(2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
			v = SanitizeEuler(v, rad2Deg)
			return v
		end
	else
		local v = vector3(-half_pi, math.atan2(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
        v = SanitizeEuler(v, rad2Deg)
		return v		
	end
end
function SanitizeEuler(euler, mul)
    if mul == nil then mul = 1 end
    euler = { x = euler.x, y = euler.y, z = euler.z }

	if euler.x < negativeFlip then
		euler.x = euler.x + two_pi
	elseif euler.x > positiveFlip then
		euler.x = euler.x - two_pi
	end

	if euler.y < negativeFlip then
		euler.y = euler.y + two_pi
	elseif euler.y > positiveFlip then
		euler.y = euler.y - two_pi
	end

	if euler.z < negativeFlip then
		euler.z = euler.z + two_pi
	elseif euler.z > positiveFlip then
		euler.z = euler.z + two_pi
	end
    return vector3(euler.x * mul, euler.y * mul, euler.z * mul)
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end