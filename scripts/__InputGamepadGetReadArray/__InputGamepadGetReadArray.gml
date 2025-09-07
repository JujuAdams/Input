// Feather disable all

/// @param device

function __InputGamepadGetReadArray(_device)
{
    static _gamepadArray = __InputSystem().__gamepadArray;
    
    if ((_device < 0) || (_device >= array_length(_gamepadArray)))
    {
        return undefined;
    }
    
    var _struct = _gamepadArray[_device];
    return (_struct == undefined)? undefined : _struct.__readArray;
}