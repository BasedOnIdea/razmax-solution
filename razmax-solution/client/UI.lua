UI = {
    ["promo_menu"] = 
    {
        fn_create = function(self, data)
            if ( self.black_bg and isElement( self.black_bg ) ) then self:fn_destroy() return end

            self.activations_count  = data.activations_count --TODO: add data validation
            self.creation_date      = data.creation_date
            self.money_earned       = data.money_earned
            self.my_promo           = data.promo_text
            
            toggleControl("all", false)
            showCursor(true)

            self.black_bg = ibCreateBackground( 0x990D0F10, _, _, true )
            self.sx, self.sy = math.floor( 800 * scaleX ), math.floor( 500 * scaleY )
            self.px, self.py = math.floor( _SCREEN_X_HALF - self.sx / 2 ), math.floor( _SCREEN_Y_HALF - self.sy / 2 )

            self.bg = ibCreateArea( self.px, self.py, self.sx, self.sy, self.black_bg )

            self.menu = ibCreateImage( 0, 0, self.sx, self.sy, nil, self.bg, 0xFF131619 )
                :ibData( "rounded", 10 )
            
            self.cross = ibCreateImage(
                self.sx - math.floor( 58 * scaleX ),
                math.floor( 30 * scaleY ),
                math.floor( 28 * scaleX ),
                math.floor( 28 * scaleY ),
                ":province_sharedAssets/image/cross.png",
                self.menu
            )

            self.cross_base_px, self.cross_base_py = self.cross:ibData( "px" ), self.cross:ibData( "py" )
            self.cross_base_sx, self.cross_base_sy = self.cross:ibData( "sx" ), self.cross:ibData( "sy" )
            self.cross_hover_scale, self.cross_lerp_speed = 1.3, 0.05

            self.cross
                :ibData( "is_hovered", false )
                :ibData( "current_scale", 1 )
                :ibOnHover( function( )
                    source:ibData( "color", 0xFF686B6E )
                    source:ibData( "is_hovered", true )
                end )
                :ibOnLeave( function( )
                    source:ibData( "color", 0xFFFFFFFF )
                    source:ibData( "is_hovered", false )
                end )
                :ibOnRender( function( )
                    local is_hovered    = self.cross:ibData( "is_hovered" )
                    local current_scale = self.cross:ibData( "current_scale" ) or 1
                    local target_scale  = is_hovered and self.cross_hover_scale or 1
                    current_scale = current_scale + ( target_scale - current_scale ) * self.cross_lerp_speed
                    self.cross:ibData( "current_scale", current_scale )
                    local new_sx = self.cross_base_sx * current_scale
                    local new_sy = self.cross_base_sy * current_scale
                    local new_px = self.cross_base_px - ( new_sx - self.cross_base_sx ) / 2
                    local new_py = self.cross_base_py - ( new_sy - self.cross_base_sy ) / 2
                    self.cross:ibBatchData( { px = new_px, py = new_py, sx = new_sx, sy = new_sy } )
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then
                        source:ibData( "color", 0xFF363A3D )
                        return
                    end
                    source:ibData( "color", 0xFF686B6E )
                    self:fn_destroy( )
                end )
            
            ibCreateLabel(
                math.floor( 30 * scaleX ),
                math.floor( 30 * scaleY ),
                0, 0, "Реферальная система", self.menu,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 24 )
            )
            
            self.child_bg_color =  0xFF1A1D21

            --Referral system info window
            self.referral_info_bg = ibCreateImage(
                math.floor( 32 * scaleX ), math.floor( 81 * scaleY ), 
                math.floor( 733 * scaleX ), math.floor( 115 * scaleY ),
                nil, self.menu, self.child_bg_color)
                :ibData( "rounded", 5 )
            
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 10 * scaleY ),
                0, 0, "Реферальная система", self.referral_info_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 20 )
            )

            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 40 * scaleY ),
                0, 0, "Создайте собственный промокод и делитесь им с друзьями. За каждого игрока, который использует \nваш код и достигнет активности в игре, вы будете получать приятные бонусы. Следите за статистикой \nи стройте свою команду!", self.referral_info_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 16 )
            )
            
            --User's promo info window
            self.my_promo_bg = ibCreateImage( 
                math.floor(33 * scaleX), math.floor(216 * scaleX), math.floor( 360 * scaleX ), math.floor( 150 * scaleY ), 
                nil, self.bg, self.child_bg_color
            )
                :ibData( "rounded", 5 )
            
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 10 * scaleY ),
                0, 0, "Ваш промокод", self.my_promo_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 20 )
            )

            self.my_promo_edit_bg = ibCreateImage( 
                math.floor( 10 * scaleX ), math.floor( 46 * scaleY ), 
                math.floor( 207 * scaleX ), math.floor( 40 * scaleY ), 
                nil, self.my_promo_bg, 0xFF0D0F10 )
                :ibData( "rounded", 10 )

            self.my_promo_edit = ibCreateWebEdit( 0, 0, math.floor( 207 * scaleX ), math.floor( 40 * scaleY ), self.my_promo, self.my_promo_edit_bg, 0xFFFFFFFF, 0x00000000 )
            :ibBatchData{
                font              = "FuturaBookC_" .. 18 * scaleX,
                text_align        = "left",
                placeholder       = "",
                placeholder_color = 0xFFFFFFFF,
                is_only_numbers   = false,
                needs_formatting  = false,
            }
            
            self.copy_button = ibCreateImage( 
                math.floor( 232 * scaleX ), math.floor( 46 * scaleY ), 
                math.floor( 118 * scaleX ), math.floor( 40 * scaleY ), 
                nil, self.my_promo_bg, 0xFF243497 )
            :ibData( "rounded", 10 )
            :ibOnHover( function( ) source:ibData( "color", 0xFF1E2C7A ) end )
            :ibOnLeave( function( ) source:ibData( "color", 0xFF243497 ) end )
            :ibOnClick( function( key, state )
                if key == "right" then return end
                if key ~= "left" or state ~= "up" then
                    source:ibData( "color", 0xFF151F56 )
                    return
                end
                source:ibData( "color", 0xFF182364 )
                setClipboard(self.my_promo_edit:ibData( "text" ) or "")
                localPlayer:ShowInfo("Промокод скопирован!")
            end )

            ibCreateLabel(
                math.floor( 11 * scaleX ),
                math.floor( 9 * scaleY ),
                0, 0, "Скопировать", self.copy_button,
                COLOR_WHITE, fs, fs, "left", "top", FontBook( 18 )
            )

            ibCreateLabel(
                math.floor( 30 * scaleX ),
                math.floor( 96 * scaleY ),
                0, 0, "Дата создания промокода: "..os.date("%d.%m.%Y %H:%M", self.creation_date), self.my_promo_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 16 )
            )

            --Promo activation window
            self.activate_promo_bg = ibCreateImage( 
                math.floor(406 * scaleX), math.floor(216 * scaleX), math.floor( 360 * scaleX ), math.floor( 150 * scaleY ), 
                nil, self.bg, self.child_bg_color
            )
                :ibData( "rounded", 5 )
            
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 10 * scaleY ),
                0, 0, "Активировать промокод", self.activate_promo_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 20 )
            )

            self.send_promo_edit_bg = ibCreateImage( 
                math.floor( 10 * scaleX ), math.floor( 46 * scaleY ), 
                math.floor( 207 * scaleX ), math.floor( 40 * scaleY ), 
                nil, self.activate_promo_bg, 0xFF0D0F10 )
                :ibData( "rounded", 10 )

            self.send_promo_edit = ibCreateWebEdit( 0, 0, math.floor( 207 * scaleX ), math.floor( 40 * scaleY ), "", self.send_promo_edit_bg, 0xFFFFFFFF, 0x00000000 )
            :ibBatchData{
                font              = "FuturaBookC_" .. 18 * scaleX,
                text_align        = "left",
                placeholder       = "Введите промокод",
                placeholder_color = 0xFFFFFFFF,
                is_only_numbers   = false,
                needs_formatting  = false,
            }
            
            self.acivate_button = ibCreateImage( 
                math.floor( 232 * scaleX ), math.floor( 46 * scaleY ), 
                math.floor( 118 * scaleX ), math.floor( 40 * scaleY ), 
                nil, self.activate_promo_bg, 0xFF243497 )
            :ibData( "rounded", 10 )
            :ibOnHover( function( ) source:ibData( "color", 0xFF1E2C7A ) end )
            :ibOnLeave( function( ) source:ibData( "color", 0xFF243497 ) end )
            :ibOnClick( function( key, state )
                if key == "right" then return end
                if key ~= "left" or state ~= "up" then
                    source:ibData( "color", 0xFF151F56 )
                    return
                end
                source:ibData( "color", 0xFF182364 )
                triggerServerEvent("referral_system:activatePromo", resourceRoot, self.send_promo_edit:ibData( "text" ) or "")
            end )

            ibCreateLabel(
                math.floor( 11 * scaleX ),
                math.floor( 9 * scaleY ),
                0, 0, "Активировать", self.acivate_button,
                COLOR_WHITE, fs, fs, "left", "top", FontBook( 18 )
            )

            --Statistics window
            self.statistics_bg = ibCreateImage( 
                math.floor(33 * scaleX), math.floor(386 * scaleX), math.floor( 733 * scaleX ), math.floor( 94 * scaleY ), 
                nil, self.bg, self.child_bg_color
            )
                :ibData( "rounded", 5 )
            
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 10 * scaleY ),
                0, 0, "Статистика промокода", self.statistics_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 20 )
            )

            self.activations_count_text = "Количество активаций: ".. tostring(self.activations_count)
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 42 * scaleY ),
                0, 0, self.activations_count_text, self.statistics_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 16 )
            )

            self.earned_money_text = "Заработано с промокода: ".. tostring(self.money_earned)
            ibCreateLabel(
                math.floor( 10 * scaleX ),
                math.floor( 63 * scaleY ),
                0, 0, self.earned_money_text, self.statistics_bg,
                COLOR_WHITE, fs, fs, "left", "top", FontDemi( 16 )
            )
        end,
        fn_destroy = function(self)
            toggleControl("all", true)
            if( self.black_bg and isElement(self.black_bg) ) then
                destroyElement(self.black_bg)
                showCursor(false)
            end
        end
    }
}