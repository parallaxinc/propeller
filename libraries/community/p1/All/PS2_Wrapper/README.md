# PS2_Wrapper

By: Kristian Charboneau

Language: Spin

Created: Apr 12, 2013

Modified: October 12, 2013

PS2\_Wrapper provides a simple spin interface around Juan Carlos Orozco's Play Station 2 Controller driver. Each button has its own method which returns 1 or 0 and each joystick axis has its own method which returns a decimal _(0 to 255)_. Object can now detect multiple buttons within same group being pressed at the same time. Also added a stop routine. Changes: Switched from using string conversion and comparison to bitwise & operator, also removed several unnecessary methods
