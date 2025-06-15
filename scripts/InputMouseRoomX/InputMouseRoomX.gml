// Feather disable all

/// Returns the x coordinate of the mouse point in room-space.

function InputMouseRoomX()
{
    static _system = __InputSystem();
    //Fall back on the cached value if we've blocked the pointer. This "freezes" the cursor in place
    //and is generally preferable to returning some invalid coordinate.
    return (_system.__pointerBlocked)? _system.__pointerRoomX : device_mouse_x(0);
}