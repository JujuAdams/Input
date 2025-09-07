// Feather disable all

function __InputGetGamepadOutput(_device)
{
    static _gamepadArray = __InputSystem().__gamepadArray;
    
    if (INPUT_BAN_GAMEPADS) return undefined;
    if (_device < 0) return undefined;
    if (not InputGameHasFocus()) return undefined;
    if (not InputDeviceIsConnected(_device)) return undefined;
    if (not gamepad_is_connected(_device)) return undefined;
    
    var _deviceValueArray = _gamepadArray[_device].__valueArray;
    var _binding = 0;
    repeat(INPUT_GAMEPAD_BINDING_COUNT)
    {
        if (abs(_deviceValueArray[_binding]) > INPUT_GAMEPAD_THUMBSTICK_MIN_THRESHOLD)
        {
            return _binding + INPUT_GAMEPAD_BINDING_MIN;
        }
        
        ++_binding;
    }
    
    return undefined;
}