// Feather disable all

function __InputRegisterCollect()
{
    __InputPlugInRegisterCallbackInternal(INPUT_PLUG_IN_CALLBACK.COLLECT, 0, function()
    {
        static _playerArray    = __InputSystemPlayerArray();
        static _gamepadArray   = __gamepadArray;
        static _rebindingArray = __rebindingArray;
        
        static _once = (function()
        {
            //Set a default device for player 0 on boot. This should only happen once
            //Juju: Because setting the player's device triggers a plug-in callback, it's possible for plug-ins
            //      to accidentally create a loop of static initializations that results in a crash on boot.
            //      This is hard to debug for people who haven't seen it before. Moving default device-setting
            //      to a one-time event before the first collect works around this problem but has the downside
            //      of leaving player 0's device state as `INPUT_NO_DEVICE` before the first collect.
            if (INPUT_ON_MOBILE)
            {
                InputPlayerSetDevice(INPUT_TOUCH);
            }
            else if (INPUT_ON_DESKTOP)
            {
                InputPlayerSetDevice(INPUT_KBM);
            }
            else if (INPUT_ON_CONSOLE)
            {
                var _i = 0;
                repeat(gamepad_get_device_count())
                {
                    if (InputDeviceIsConnected(_i)) InputPlayerSetDevice(_i);
                    ++_i;
                }
            }
        })();
        
        ///////
        // Unstick keys. Hooray for work-arounds!
        ///////
        
        if ((not INPUT_BAN_KBM) && keyboard_check(vk_anykey))
        {
            if (INPUT_ON_WINDOWS)
            {
                if (keyboard_check(vk_alt) && keyboard_check_pressed(vk_space))
                {
                    //Unstick Alt Space
                    keyboard_key_release(vk_alt);
                    keyboard_key_release(vk_space);
                    keyboard_key_release(vk_lalt);
                    keyboard_key_release(vk_ralt);
                }
                
                if (keyboard_check(0xE6) && !keyboard_check_pressed(0xE6))
                {
                    //Unstick OEM key (Power button on Steam Deck)
                    keyboard_key_release(0x0E6);
                }
            }
            else if (INPUT_ON_WEB && INPUT_ON_APPLE)
            {
                if (keyboard_check_released(vk_lmeta) || keyboard_check_released(vk_rmeta))
                {
                    //Meta release sticks every key pressed during hold
                    //This is "the nuclear option", but the problem is severe
                    var _i = 8;
                    var _len = 0x100 - _i;
                    repeat(_len)
                    {
                        keyboard_key_release(_i);
                        ++_i;
                    }
                }
            }
            else if (INPUT_ON_MACOS)
            {
                //Unstick doubled-up control keys
                if (keyboard_check_released(vk_control))
                {
                    keyboard_key_release(vk_lcontrol);
                    keyboard_key_release(vk_rcontrol);
                }
                    
                if (keyboard_check_released(vk_shift))
                {
                    keyboard_key_release(vk_lshift);
                    keyboard_key_release(vk_rshift);
                }
                
                if (keyboard_check_released(vk_alt))
                {
                    keyboard_key_release(vk_lalt);
                    keyboard_key_release(vk_ralt);
                }
                
                //Unstick Meta
                if (keyboard_check_released(vk_lmeta))
                {
                    keyboard_key_release(vk_rmeta);
                }
                else if (keyboard_check_released(vk_rmeta) && keyboard_check(vk_lmeta))
                {
                    keyboard_key_release(vk_lmeta);
                }
            }
        }
        
        if ((not INPUT_BLOCK_MOUSE_CHECKS) && INPUT_ON_WINDOWS)
        {
            //Track clicks from touchpad and touchscreen taps (system-setting dependent)
            __tapPresses  += device_mouse_check_button_pressed( 0, mb_left);
            __tapReleases += device_mouse_check_button_released(0, mb_left);
            
            if (__tapReleases >= __tapPresses)
            {
                //Resolve press/release desync (where press failed to register on same frame as release)
                __tapClick    = (__tapReleases > __tapPresses);
                __tapPresses  = 0;
                __tapReleases = 0;
            }
            else
            {
                __tapClick = false;
            }
        }
        
        ///////
        // Handle Steamworks
        ///////
        
        if (__usingSteamworks)
        {
            steam_input_run_frame();
            
            //Enable Windows IME for Steam Overlay
            if (INPUT_ON_WINDOWS && __windowFocus)
            {
                var _overlayEnabled = steam_is_overlay_activated();
                var _imeEnabled = keyboard_virtual_status();
                
                if (_imeEnabled != _overlayEnabled)
                {
                    if (_overlayEnabled)
                    {
                         keyboard_virtual_show(undefined, undefined, undefined, undefined);
                    }
                    else
                    {
                        keyboard_virtual_hide();
                    }
                }
            }
            
            if (__InputSteamHandlesChanged())
            {
                __InputTrace("Steam handles changed, disconnecting all gamepads for reconnection");
                
                var _device = 0;
                repeat(array_length(_gamepadArray))
                {
                    if (InputDeviceIsConnected(_device))
                    {
                        __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAMEPAD_DISCONNECTED, _device, true);
                    }
                    
                    ++_device;
                }
            }
        }
        
        ///////
        // Detect and handle gamepad connections and disconnections
        ///////
        
        if ((not INPUT_BAN_GAMEPADS) && (current_time > INPUT_GAMEPADS_COLLECT_PREDELAY))
        {
            if (INPUT_ON_ANDROID && (__time - __androidEnumerationTime > INPUT_ANDROID_GAMEPAD_ENUMERATION_INTERVAL))
            {
                __androidEnumerationTime = __time;
                gamepad_enumerate();
            }
            
            var _deviceCountChange = max(0, gamepad_get_device_count() - array_length(_gamepadArray));
            repeat(_deviceCountChange)
            {
                array_push(_gamepadArray, undefined);
            }
            
            var _device = 0;
            repeat(array_length(_gamepadArray))
            {
                var _gamepad = _gamepadArray[_device];
                var _connected = gamepad_is_connected(_device);
                
                if (_gamepad != undefined)
                {
                    if (_connected)
                    {
                        if (INPUT_ON_SWITCH && (_gamepad.__type != __InputGamepadIdentifySwitchType(_device)))
                        {
                            //When Switch L+R assignment is used to pair two gamepads we won't see a normal disconnection/reconnection
                            //Instead we have to check for changes via the gamepad description or Joy-Con left/right connected state
                            
                            __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAMEPAD_DISCONNECTED, _device, true);
                            __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAMEPAD_CONNECTED, _device);
                        }
                        
                        _gamepad.__lastConnectedTime = current_time;
                    }
                    else
                    {
                        if (current_time - _gamepad.__lastConnectedTime >= INPUT_GAMEPADS_DISCONNECTION_TIMEOUT)
                        {
                            __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAMEPAD_DISCONNECTED, _device, true);
                        }
                    }
                }
                else
                {
                    if (_connected)
                    {
                        __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAMEPAD_CONNECTED, _device);
                    }
                }
                
                ++_device;
            }
        }
        
        ///////
        // Handle window state
        ///////
        
        if (INPUT_ON_DESKTOP && (not INPUT_ON_WEB))
        {
            if (os_is_paused())
            {
                //Window has lost focus
                __windowFocus = false;
                __pointerBlockedByWindowDefocus = true;
                
                //Linux app continues to recieve input some number of frames after focus loss
                //Clear IO on focus loss to prevent false positive of subsequent focus regain
                if (INPUT_ON_LINUX)
                {
                    var _keyboardString = keyboard_string;
                    io_clear();
                    keyboard_string = _keyboardString;
                }
                
                //Enable Windows IME
                if (INPUT_ON_WINDOWS)
                {
                    keyboard_virtual_show(undefined, undefined, undefined, undefined);
                }
                
                __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.LOSE_FOCUS);
            }
            else
            {
                //Window is in focus
                
                if (__windowFocus)
                {
                    //We were in focus last frame as well
                    
                    //Unset the one frame defocus but sustain mouse block while a button remains held
                    if (__pointerBlockedByWindowDefocus)
                    {
                        __pointerBlockedByWindowDefocus = false; //Temporarily turn off blocking
                        __pointerBlockedByWindowDefocus = (__InputGetMouseOutput() != undefined);
                    }
                }
                else
                {
                    //We were *not* in focus last frame
                    
                    if ((keyboard_key != vk_nokey) 
                     ||  (mouse_button != mb_none)
                     ||  (INPUT_ON_WINDOWS && window_has_focus())
                     ||  (INPUT_ON_MACOS   && __pointerMoved))
                    {
                        //We got some input! Let's party
                        __windowFocus = true;
                        
                        //Persist defocus for a frame to swallow the first mouse input
                        __pointerBlockedByWindowDefocus = true;
                        
                        //Disable Windows IME
                        if (INPUT_ON_WINDOWS)
                        {
                            keyboard_virtual_hide();
                        }
                    
                        __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.GAIN_FOCUS);
                    }
                }
            }
        }
        
        ///////
        // Collect raw input state
        ///////
        
        if (not INPUT_BLOCK_MOUSE_CHECKS)
        {
            if (not __pointerBlockedByWindowDefocus)
            {
                var _pointerButtonStateRaw = __pointerButtonStateRaw;
                _pointerButtonStateRaw[@ __INPUT_MOUSE_BUTTON_LEFT  ] = (INPUT_ON_WINDOWS && __tapClick)? true : device_mouse_check_button(0, mb_left);
                _pointerButtonStateRaw[@ __INPUT_MOUSE_BUTTON_MIDDLE] = device_mouse_check_button(0, mb_middle);
                _pointerButtonStateRaw[@ __INPUT_MOUSE_BUTTON_RIGHT ] = device_mouse_check_button(0, mb_right);
                _pointerButtonStateRaw[@ __INPUT_MOUSE_BUTTON_SIDE1 ] = device_mouse_check_button(0, mb_side1);
                _pointerButtonStateRaw[@ __INPUT_MOUSE_BUTTON_SIDE2 ] = device_mouse_check_button(0, mb_side2);
            }
            else
            {
                //Wipe out all state
                array_map_ext(__pointerButtonStateRaw, function() { return false; });
            }
        }
        
        ///////
        // Rebinding
        ///////
        
        var _i = 0;
        repeat(array_length(_rebindingArray))
        {
            _rebindingArray[_i].__Update();
            ++_i;
        }
        
        ///////
        // Hotswap
        ///////
        
        if ((not INPUT_BAN_HOTSWAP) && __hotswap)
        {
            if (InputPlayerGetInactive())
            {
                var _device = InputDeviceGetNewActivity();
                if (_device != INPUT_NO_DEVICE)
                {
                    InputPlayerSetDevice(_device);
                    if (is_callable(__hotswapCallback)) __hotswapCallback();
                }
            }
        }
        
        ///////
        // Collect raw input from devices
        ///////
        
        var _i = 0;
        repeat(INPUT_MAX_PLAYERS)
        {
            __InputPlugInExecuteCallbacks(INPUT_PLUG_IN_CALLBACK.COLLECT_PLAYER, _i);
            ++_i;
        }
    });
}