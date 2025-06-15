// Feather disable all

/// Returns whether the given mouse button is newly pressed this frame.
/// 
/// @param {Constant.MouseButton,Real} [binding=mb_left]

function InputMousePressed(_binding = mb_left)
{
    static _pointerButtonStateNow  = __InputSystem().__pointerButtonStateNow;
    static _pointerButtonStatePrev = __InputSystem().__pointerButtonStatePrev;
    
    if (INPUT_BLOCK_MOUSE_CHECKS) return false;
    
    if (_binding == mb_right)
    {
        return (not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_RIGHT])
                 && _pointerButtonStateNow[ __INPUT_MOUSE_BUTTON_RIGHT];
    }
    else if (_binding == mb_middle)
    {
        return (not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_MIDDLE])
                 && _pointerButtonStateNow[ __INPUT_MOUSE_BUTTON_MIDDLE];
    }
    else if (_binding == mb_side1)
    {
        return (not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE1])
                 && _pointerButtonStateNow[ __INPUT_MOUSE_BUTTON_SIDE1];
    }
    else if (_binding == mb_side2)
    {
        return (not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE2])
                 && _pointerButtonStateNow[ __INPUT_MOUSE_BUTTON_SIDE2];
    }
    else
    {
        //Edge testing
        if (INPUT_ON_MOBILE && (INPUT_TOUCH_EDGE_DEADZONE > 0))
        {
            var _x = device_mouse_raw_x(0);
            var _y = device_mouse_raw_y(0);
            
            if ((_x < INPUT_TOUCH_EDGE_DEADZONE) || (_x > (display_get_width()  - INPUT_TOUCH_EDGE_DEADZONE))
            ||  (_y < INPUT_TOUCH_EDGE_DEADZONE) || (_y > (display_get_height() - INPUT_TOUCH_EDGE_DEADZONE)))
            {
                var _left = false;
            }
            else
            {
                var _left = (not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_LEFT])
                              && _pointerButtonStateNow[ __INPUT_MOUSE_BUTTON_LEFT];
            }
        }
        
        if (_binding == mb_left)
        {
            return _left;
        }
        else if (_binding == mb_any)
        {
            if (_left) return true;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_RIGHT ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT ]) return true;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_MIDDLE]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_MIDDLE]) return true;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE1 ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE1 ]) return true;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE2 ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE2 ]) return true;
            return false;
        }
        else if (_binding == mb_none)
        {
            if (_left) return false;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_RIGHT ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_RIGHT ]) return false;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_MIDDLE]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_MIDDLE]) return false;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE1 ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE1 ]) return false;
            if ((not _pointerButtonStatePrev[__INPUT_MOUSE_BUTTON_SIDE2 ]) && _pointerButtonStateNow[__INPUT_MOUSE_BUTTON_SIDE2 ]) return false;
            return true;
        }
        else
        {
            __InputError("Mouse button out of range (", _binding, ")");
        }
    }
}
