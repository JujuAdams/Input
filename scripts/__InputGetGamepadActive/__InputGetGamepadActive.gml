// Feather disable all

function __InputGetGamepadActive(_device)
{
    static _gamepadArray = __InputSystem().__gamepadArray;
    
    if (INPUT_BAN_GAMEPADS) return false;
    
    if (_device < 0) return false;
    if (not InputGameHasFocus()) return false;
    if (not InputDeviceIsConnected(_device)) return false;
    if (not gamepad_is_connected(_device)) return false;
    
    with(_gamepadArray[_device])
    {
        var _prevValueArray = __prevValueArray;
        var _valueArray     = __valueArray;
        
        var _binding = 0;
        repeat(INPUT_GAMEPAD_BINDING_COUNT)
        {
            if ((_binding == gp_axislh - INPUT_GAMEPAD_BINDING_MIN)
            ||  (_binding == gp_axislv - INPUT_GAMEPAD_BINDING_MIN)
            ||  (_binding == gp_axisrh - INPUT_GAMEPAD_BINDING_MIN)
            ||  (_binding == gp_axisrv - INPUT_GAMEPAD_BINDING_MIN))
            {
                if (INPUT_GAMEPAD_THUMBSTICK_REPORTS_ACTIVE)
                {
                    if ((abs(_prevValueArray[_binding]) <= INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD)
                    &&  (abs(    _valueArray[_binding]) >  INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD))
                    {
                        return true;
                    }
                }
            }
            else if ((_binding == gp_shoulderlb - INPUT_GAMEPAD_BINDING_MIN)
                 ||  (_binding == gp_shoulderrb - INPUT_GAMEPAD_BINDING_MIN))
            {
                if (INPUT_GAMEPAD_TRIGGER_REPORTS_ACTIVE)
                {
                    if ((abs(_prevValueArray[_binding]) <= INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD)
                    &&  (abs(    _valueArray[_binding]) >  INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD))
                    {
                        return true;
                    }
                }
            }
            else 
            {
                if (_valueArray[_binding])
                {
                    return true;
                }
            }
            
            ++_binding;
        }
    }
    
    return false;
}