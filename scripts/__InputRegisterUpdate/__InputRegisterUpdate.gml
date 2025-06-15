// Feather disable all

function __InputRegisterUpdate()
{
    __InputPlugInRegisterCallbackInternal(INPUT_PLUG_IN_CALLBACK.UPDATE, 0, function()
    {
        static _playerArray        = __InputSystemPlayerArray();
        static _virtualButtonArray = __virtualButtonArray;
        
        __time += delta_time/1000;
        ++__frame;
        
        ///////
        // Track mouse movement
        ///////
        
        if (not INPUT_BLOCK_MOUSE_CHECKS)
        {
            __prevPointerDeviceX = __pointerDeviceX;
            __prevPointerDeviceY = __pointerDeviceY;
            
            if (__pointerBlockedByUser || (__pointerBlockedByWindowDefocus && (not INPUT_ON_MACOS)) || ((not INPUT_BAN_KBM) && InputDeviceGetRebinding(INPUT_KBM)))
            {
                __pointerBlocked = true;
            }
            else
            {
                __pointerBlocked = false;
                
                __pointerRoomX = device_mouse_x(0);
                __pointerRoomY = device_mouse_y(0);
                __pointerGuiX  = device_mouse_x_to_gui(0);
                __pointerGuiY  = device_mouse_y_to_gui(0);
                
                if (INPUT_ON_WINDOWS)
                {
                    __pointerDeviceX = display_mouse_get_x() - window_get_x();
                    __pointerDeviceY = display_mouse_get_y() - window_get_y();
                }
                else
                {
                    __pointerDeviceX = device_mouse_raw_x(0);
                    __pointerDeviceY = device_mouse_raw_y(0);
                }
            }
            
            __pointerMoved = (point_distance(__prevPointerDeviceX, __prevPointerDeviceY, __pointerDeviceX, __pointerDeviceY) > INPUT_MOUSE_MOVE_DEADZONE);
        }
        
        ///////
        // Update cached pointer button state
        ///////
        
        //Move the previous button state into our "previous" array
        array_copy(__pointerButtonStatePrev, 0, __pointerButtonStateNow, 0, __INPUT_MOUSE_BUTTON_COUNT);
        
        if (not __pointerBlocked)
        {
            //If we"re not blocked, copy the raw state
            array_copy(__pointerButtonStateNow, 0, __pointerButtonStateRaw, 0, __INPUT_MOUSE_BUTTON_COUNT);
        }
        else
        {
            //Wipe out all state if we are blocked
            array_map_ext(__pointerButtonStateNow, function() { return false; });
        }
        
        ///////
        //Reorder virtual buttons
        ///////
        
        if (__virtualOrderDirty)
        {
            __virtualOrderDirty = false;
            
            //Clean up any destroyed virtual buttons
            var _i = 0;
            repeat(array_length(_virtualButtonArray))
            {
                if (_virtualButtonArray[_i].__destroyed)
                {
                    array_delete(_virtualButtonArray, _i, 1);
                }
                else
                {
                    ++_i;
                }
            }
            
            array_sort(_virtualButtonArray, function(_a, _b)
            {
                return sign(_b.__priority - _a.__priority);
            });
        }
        
        ///////
        // Update player state
        ///////
        
        __lowestConnectedPlayerIndex = undefined;
        var _i = 0;
        repeat(INPUT_MAX_PLAYERS)
        {
            _playerArray[_i].__Update();
            
            if (__lowestConnectedPlayerIndex == undefined)
            {
                if (InputPlayerIsConnected(_i))
                {
                    __lowestConnectedPlayerIndex = _i;
                }
            }
            
            ++_i;
        }
    });
}
