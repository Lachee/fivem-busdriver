function table.indexOf(t, object)
    if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end

    for i, v in pairs(t) do
        if object == v then
            return i
        end
    end
    return false
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

-- Clones an object
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

-- Calculates the angles (in radians) from the direction to the direction
function angleFromToo(p1,p2)
    local radians = math.atan2(p2.y, p2.x) - math.atan2(p1.y, p1.x)
    if radians < 0 then radians = radians + (2 * math.pi) end
    return radians
end