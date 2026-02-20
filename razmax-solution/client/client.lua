Extend("ib") --Import выглядит лучше но юзаю Extend ибо у него дебаг строки
Extend( "CPlayer" )

ibUseRealFonts( true )

UI = {}

scaleX, scaleY = _SCREEN_X / 1920, _SCREEN_Y / 1080
fs = 0.8

local floor = math.floor
local font_cache_book = {}
local font_cache_demi = {}

function FontBook( size )
    local font = font_cache_book[ size ]
    if not font then
        font = ibFonts[ "FuturaBookC_" .. floor( size ) ]
        font_cache_book[ size ] = font
    end
    return font
end

function FontDemi( size )
    local font = font_cache_demi[ size ]
    if not font then
        font = ibFonts[ "FuturaDemiC_" .. floor( size ) ]
        font_cache_demi[ size ] = font
    end
    return font
end

addEvent("referral_system:onClientUICreate", true)
addEventHandler("referral_system:onClientUICreate", resourceRoot, function(sheets, ...)
    UI[ sheets ]:fn_create(...)
end, false)