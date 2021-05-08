Stopwatch = {
    _start = 0,
    _end = 0,
    _offset = 0,
}

-- Gets the time that has elapsed
function Stopwatch:elapsed() 
    local et = self._end
    if et == nil then et = Stopwatch.Now() end
    return (et - self._start) + self._offset
end

--- Stops the stopwatch and returns the time elapsed
function Stopwatch:stop() 
    self._offset = self:elapsed()
    self._start = 0
    self._end = 0
    return self._offset
end

--- Starts the stopwatch
function Stopwatch:start()
    self._start = Stopwatch.Now()
    self._end = nil
end

--- Current game time in seconds
Stopwatch.Now = function()
    return GetGameTimer() / 1000.0
end

--- Creates a new stopwatch and starts it immediately
Stopwatch.Start = function() 
    local sw = Stopwatch
    sw:start()
    return sw
end