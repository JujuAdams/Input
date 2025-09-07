// Feather disable all

/// @param gamepadIndex

function __InputClassGamepad(_gamepadIndex) constructor
{
    static _genericReadArray = __InputSystem().__genericReadArray;
    static _zeroValueArray   = __InputSystem().__zeroValueArray;
    
    __gamepadIndex      = _gamepadIndex;
    __blocked           = false;
    __lastConnectedTime = current_time;
    
    __guid    = undefined;
    __vendor  = "";
    __product = "";
    
    __description = "Generic Gamepad";
    __type        = INPUT_GAMEPAD_TYPE_XBOX;
    __xinput      = false;
    
    __xinput            = false;
    __steamHandle       = undefined;
    __steamHandleIndex  = undefined;
    
    __readArray = variable_clone(_genericReadArray, 1);
    
    __prevValueArray = array_create(INPUT_GAMEPAD_BINDING_COUNT, 0);
    __valueArray     = array_create(INPUT_GAMEPAD_BINDING_COUNT, 0);
    
    
    
    static __UpdateValues = function()
    {
        var _gamepadIndex = __gamepadIndex;
        
        if (INPUT_BAN_GAMEPADS || __blocked || (not gamepad_is_connected(_gamepadIndex)))
        {
            array_copy(__prevValueArray, 0, _zeroValueArray, 0, INPUT_GAMEPAD_BINDING_COUNT);
            array_copy(__valueArray,     0, _zeroValueArray, 0, INPUT_GAMEPAD_BINDING_COUNT);
            return;
        }
        
        //Swap the previous and current arrays
        var _valueArray  = __prevValueArray;
        __prevValueArray = __valueArray
        __valueArray     = _valueArray;
        
        //Collect new values
        var _readArray = __readArray;
        var _binding = 0;
        repeat(INPUT_GAMEPAD_BINDING_COUNT)
        {
            _valueArray[@ _binding] = _readArray[_binding](_gamepadIndex, _binding + INPUT_GAMEPAD_BINDING_MIN);
            ++_binding;
        }
    }
}