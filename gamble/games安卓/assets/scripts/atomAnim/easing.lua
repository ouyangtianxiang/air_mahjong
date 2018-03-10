-- Author: Xiaofeng Yang
-- Version: ea.2015.05.19.1 (very early stage)
-- Last modification : 2015-05-19
-- Description: libEffect easing module


local M = { }


M.getEaseArray = function (easeFunction, duration, b, c)
    local fn = easeFunction
    if type(easeFunction) == "string" then 
        fn = M.fns[easeFunction]
    end 

    -- fill the array
    local arr = {}
    for i = 1, duration + 1 do
        arr[i] = fn(i - 1, b, c, duration)
    end 

    return arr
end


--- 
M.fns = {
    --- 
    -- @param t #number current time (t>=0)
    -- @param b #number beginning value (b>=0)
    -- @param c #number change in value (c>=0)
    -- @param d #number duration (d>0)
    -- @return #number the calculated result
    swing = function(t, b, c, d)
        return M.fns.easeOutQuad(t, b, c, d)
    end,

    easeInQuad = function(t, b, c, d)
        t = t / d
        return c * t * t + b
    end,

    easeOutQuad = function(t, b, c, d)
        t = t / d
        return - c * t *(t - 2) + b
    end,

    easeInOutQuad = function(t, b, c, d)
        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * t * t + b
        end

        t = t - 1

        return - c / 2 *(t *(t - 2) -1) + b
    end,

    easeInCubic = function(t, b, c, d)
        t = t / d
        return c * t * t * t + b
    end,

    easeOutCubic = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t + 1) + b
    end,

    easeInOutCubic = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t + b
        end

        t = t - 2
        return c / 2 *(t * t * t + 2) + b
    end,

    easeInQuart = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t + b
    end,

    easeOutQuart = function(t, b, c, d)
        t = t / d - 1
        return - c *(t * t * t * t - 1) + b
    end,

    easeInOutQuart = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t + b
        end

        t = t - 2
        return - c / 2 *(t * t * t * t - 2) + b
    end,

    easeInQuint = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t * t + b
    end,

    easeOutQuint = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t * t * t + 1) + b
    end,

    easeInOutQuint = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t * t + b
        end
        t = t - 2
        return c / 2 *(t * t * t * t * t + 2) + b
    end,


    easeInSine = function(t, b, c, d)
        return - c * math.cos(t / d *(math.pi / 2)) + c + b
    end,

    easeOutSine = function(t, b, c, d)
        return c * math.sin(t / d *(math.pi / 2)) + b
    end,

    easeInOutSine = function(t, b, c, d)
        return - c / 2 *(math.cos(math.pi * t / d) -1) + b
    end,

    easeInExpo = function(t, b, c, d)
        if t == 0 then
            return b
        else
            return c * math.pow(2, 10 *(t / d - 1)) + b
        end
    end,

    easeOutExpo = function(t, b, c, d)
        if t == d then
            return b + c
        else
            return c *(- math.pow(2, -10 * t / d) + 1) + b
        end
    end,

    easeInOutExpo = function(t, b, c, d)
        if (t == 0) then
            return b
        end

        if (t == d) then
            return b + c
        end

        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * math.pow(2, 10 *(t - 1)) + b
        end

        t = t - 1
        return c / 2 *(- math.pow(2, -10 * t) + 2) + b
    end,

    easeInCirc = function(t, b, c, d)
        t = t / d
        return - c *(math.sqrt(1 - t * t) -1) + b
    end,

    easeOutCirc = function(t, b, c, d)
        t = t / d - 1
        return c * math.sqrt(1 - t * t) + b
    end,

    easeInOutCirc = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return - c / 2 *(math.sqrt(1 - t * t) -1) + b
        end
        t = t - 2
        return c / 2 *(math.sqrt(1 - t * t) + 1) + b
    end,

    easeInElastic = function(t, b, c, d)
        local s = 1.70158
        local p = 0
        local a = c

        if (t == 0) then
            return b
        end

        t = t / d
        if (t == 1) then
            return b + c
        end

        
        p = d * .3
        

        if (a < math.abs(c)) then
            a = c
            s = p / 4
        else
            s = p /(2 * math.pi) * math.asin(c / a)
        end

        t = t - 1
        return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
    end,

    easeOutElastic = function(t, b, c, d)
        local s = 1.70158
        local p = 0
        local a = c

        if (t == 0) then
            return b
        end

        t = t / d
        if (t == 1) then
            return b + c
        end

        p = d * .3        

        if (a < math.abs(c)) then
            a = c
            s = p / 4
        else
            s = p /(2 * math.pi) * math.asin(c / a)
        end

        return a * math.pow(2, -10 * t) * math.sin((t * d - s) *(2 * math.pi) / p) + c + b
    end,

    easeInOutElastic = function(t, b, c, d)
        local s = 1.70158
        local p = 0
        local a = c

        if (t == 0) then
            return b
        end

        t = t /(d / 2)
        if (t == 2) then
            return b + c
        end

        p = d *(.3 * 1.5)

        if (a < math.abs(c)) then
            a = c
            s = p / 4
        else
            s = p /(2 * math.pi) * math.asin(c / a)
        end

        if (t < 1) then
            t = t - 1
            return -.5 *(a * math.pow(2, 10 *(t)) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
        end

        t = t - 1
        return a * math.pow(2, -10 *(t)) * math.sin((t * d - s) *(2 * math.pi) / p) * .5 + c + b
    end,

    easeInBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d
        return c *(t) * t *((s + 1) * t - s) + b
    end,

    easeOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d - 1
        return c *(t * t *((s + 1) * t + s) + 1) + b
    end,

    easeInOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t /(d / 2)

        if (t < 1) then
            s = s *(1.525)
            return c / 2 *(t * t *((s + 1) * t - s)) + b
        end
        s = s *(1.525)
        t = t - 2
        return c / 2 *(t * t *((s + 1) * t + s) + 2) + b
    end,

    easeInBounce = function(t, b, c, d)
        return c - M.fns.easeOutBounce(d - t, 0, c, d) + b
    end,

    easeOutBounce = function(t, b, c, d)
        t = t / d
        if (t <(1 / 2.75)) then
            return c *(7.5625 * t * t) + b
        elseif (t <(2 / 2.75)) then
            t = t -(1.5 / 2.75)
            return c *(7.5625 * t * t + .75) + b
        elseif (t <(2.5 / 2.75)) then
            t = t -(2.25 / 2.75)
            return c *(7.5625 * t * t + .9375) + b
        else

            t = t -(2.625 / 2.75)
            return c *(7.5625 * t * t + .984375) + b
        end
    end,

    easeInOutBounce = function(t, b, c, d)
        if (t < d / 2) then
            return M.fns.easeInBounce(t * 2, 0, c, d) * .5 + b
        end
        return M.fns.easeOutBounce(t * 2 - d, 0, c, d) * .5 + c * .5 + b
    end
}

return M
