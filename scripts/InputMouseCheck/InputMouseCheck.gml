// Feather disable all

/// Returns whether the given mouse button is currently held down.
/// 
/// @param {Constant.MouseButton,Real} [binding=mb_left]

function InputMouseCheck(_binding = mb_left)
{
    static _pointerButtonStateNow = __InputSystem().__pointerButtonStateNow;
    
    if (INPUT_BLOCK_MOUSE_CHECKS) return false;
    
    if (_binding == mb_left)
    {
        return _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_LEFT];
    }
    else if (_binding == mb_right)
    {
        return _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT];
    }
    else if (_binding == mb_middle)
    {
        return _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_MIDDLE];
    }
    else if (_binding == mb_side1)
    {
        return _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE1];
    }
    else if (_binding == mb_side2)
    {
        return _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE2];
    }
    else if (_binding == mb_any)
    {
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_LEFT  ]) return true;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT ]) return true;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_MIDDLE]) return true;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE1 ]) return true;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE2 ]) return true;
        return false;
    }
    else if (_binding == mb_none)
    {
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT ]) return false;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT ]) return false;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_MIDDLE]) return false;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE1 ]) return false;
        if (_pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE2 ]) return false;
        return true;
    }
    else
    {
        __InputError("Mouse button out of range (", _binding, ")");
    }
}