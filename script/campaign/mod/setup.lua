local function init() 
    recruited_unit_health.units_to_starting_health_bonus_values = {}
end

cm:add_first_tick_callback(function() init() end);