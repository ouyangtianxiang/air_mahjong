display = {}

local winSize = { width = System.getScreenWidth(), height = System.getScreenHeight() }
display.winSize            = {width = winSize.width, height = winSize.height}
display.width              = System.getScreenScaleWidth()
display.height             = System.getScreenScaleHeight()
display.cx                 = display.width / 2
display.cy                 = display.height / 2
display.left               = 0
display.right              = display.width
display.top                = 0
display.bottom             = display.height
display.c_left             = -display.width / 2
display.c_right            = display.width / 2
display.c_top              = -display.height / 2
display.c_bottom           = display.height / 2
