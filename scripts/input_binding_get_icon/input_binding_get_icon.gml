/// @param binding
/// @param [playerIndex=0]

function input_binding_get_icon(_binding, _player_index = 0)
{
    if (!input_value_is_binding(_binding)) return "not a binding";
    
    var _fallback_icon_struct = global.__input_icons[$ "gamepad fallback"];
    if (!is_struct(_fallback_icon_struct)) __input_trace("Warning! \"gamepad fallback\" icon data not found");
    
    switch(_binding.__type)
    {
        case __INPUT_BINDING_KEY:
        case __INPUT_BINDING_MOUSE_BUTTON:
        case __INPUT_BINDING_MOUSE_WHEEL_UP:
        case __INPUT_BINDING_MOUSE_WHEEL_DOWN:
            var _category = "keyboard and mouse";
        break;
        
        case __INPUT_BINDING_GAMEPAD_BUTTON:
        case __INPUT_BINDING_GAMEPAD_AXIS:
            var _category = input_player_get_gamepad_type(_player_index, _binding);
        break;
        
        default:
            __input_error("\"", _binding.__type, "\" unsupported");
        break;
    }
    
    //Try to find the lookup table for this particular category
    var _icon_struct = global.__input_icons[$ _category];
    if (!is_struct(_icon_struct))
    {
        __input_trace("Warning! \"", _category, "\" icon data not found");
        
        //Fall back to the "unknown" category
        _icon_struct = _fallback_icon_struct;
    }
    
    //
    var _label = _binding.__label;
    var _icon = is_struct(_icon_struct)? _icon_struct[$ _label] : undefined;
    
    //Most of the time keyboard and mouse labels don't need to be translated into icons
    if (_category == "keyboard and mouse") return _label;
    
    if (_icon == undefined)
    {
        __input_trace("Warning! Could not find valid icon for \"", _label, "\" using \"", _category, "\"");
        
        _icon = is_struct(_fallback_icon_struct)? _fallback_icon_struct[$ _label] : undefined;
        if (_icon == undefined)
        {
            __input_trace("Warning! Could not find valid icon for \"", _label, "\" using \"gamepad fallback\"");
            _icon = _label;
        }
    }
    
    return _icon;
}
