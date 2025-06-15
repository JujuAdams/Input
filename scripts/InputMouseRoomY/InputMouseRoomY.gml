// Feather disable all

/// Returns the y coordinate of the mouse point in room-space.

function InputMouseRoomY()
{
    static _system = __InputSystem();
    //Fall back on the cached value if we've blocked the pointer. This "freezes" the cursor in place
    //and is generally preferable to returning some invalid coordinate.
    return (_system.__pointerBlocked)? _system.__pointerRoomY : device_mouse_y(0);
}