// Feather disable all

/// Sets whether mouse input should be blocked.
/// 
/// @param state

function InputMouseSetBlocked(_state)
{
    static _system = __InputSystem();
    with(_system)
    {
        if (_state != __pointerBlockedByUser)
        {
            if (_state)
            {
                //Newly blocked, wipe out all state
                array_map_ext(__pointerButtonStateNow, function() { return false; });
            }
            else
            {
                //Newly unblocked, restore the raw state
                array_copy(__pointerButtonStateNow, 0, __pointerButtonStateRaw, 0, __INPUT_MOUSE_BUTTON_COUNT);
            }
            
            __pointerBlockedByUser = _state;
        }
    }
}