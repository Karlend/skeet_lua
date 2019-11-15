--local ffi = require("ffi") -- localization
--require("lua_lib/player_lib") -- <3 Thanks Aviarita for weapon list
local images_lib = require("lua_lib/images") -- icons stuff
local images_icons = images_lib.load(require("lua_lib/imagepack_icons")) -- icons stuff


local drawgradient = renderer.gradient
local drawline = renderer.line
local drawrect = renderer.rectangle
local drawtext = renderer.text
local get_all = entity.get_all
local get_lp = entity.get_local_player
local get_prop = entity.get_prop
local get_ui = ui.get
local set_prop = entity.set_prop

local draw_rectangle = client.draw_rectangle

local screen = {}
screen.w, screen.h = client.screen_size()

local killist = {}


--local wheelup, wheeldown, wheeled = 115, 116

local settings = 
{
   enabled = ui.new_checkbox("LUA", "B", "HUD Enabled"),
   menu_color = ui.reference("Misc", "settings", "Menu color"),
   hud_settings = ui.new_multiselect("LUA", "B", "HUD settings", "Show gradient header", "Rainbow gradient", "Show ammo", "Show armor", "Show buy icon", "HP Based color", "Kill feed"),
   hud_beatify = ui.new_multiselect("LUA", "B", "HUD Indicators", "Circle outline", "Line", "For ammo"),
   -- KillFeed

   killfeed_remove = ui.reference("MISC", "Miscellaneous", "Persistent kill feed"),
   killfeed_time = ui.new_slider("LUA", "B", "Kill visible time", 1, 15, 5),
   --killfeed_colors = ui.new_checkbox("LUA", "B", "Custom colors"),
   killfeed_enemy = ui.new_color_picker("LUA", "B", "Kill enemy color", 200, 0, 0, 255),
   killfeed_team = ui.new_color_picker("LUA", "B", "Kill team color", 0, 200, 0, 255),

   killfeed_starty = ui.new_slider("LUA", "B", "Kill feed y margin", 2, 200, 10),
   killfeed_between = ui.new_slider("LUA", "B", "Kill feed margin mult", 1, 10, 1),
}

local function Contains(table, val) --thanks sapphyrus
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function draw_container(ctx, x, y, w, h) --gamesense container
    local c = {10, 60, 40, 40, 40, 60, 20}
    for i = 0,6,1 do
        draw_rectangle(ctx, x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], 255)
    end
end

local function draw_indicator_circle(ctx, x, y, r, g, b, a, percentage, outline) --stolen from oxisDOG
    local outline = outline == nil and true or outline
    local radius = 9
    local start_degrees = 0
    if outline then
        client.draw_circle_outline(ctx, x, y, 0, 0, 0, 200, radius, start_degrees, 1.0, 5)
    end
    client.draw_circle_outline(ctx, x, y, r, g, b, a, radius - 1, start_degrees, percentage, 3)
end


local function getlen(text, norm)
	return renderer.measure_text((norm and "" or "+"), text)
end

local function clamp(value,min,max)
	if value < min then
		return min
	elseif value > max then
		return max
	end
	return value
end

local frequency = 1

local time = globals.realtime()

local rgbr = math.sin((time / frequency) * 4) * 127 + 128
local rgbg = math.sin((time / frequency) * 4 + 2) * 127 + 128
local rgbb = math.sin((time / frequency) * 4 + 4) * 127 + 128
local rgbr2 = math.sin((time / frequency/1.5) * 4) * 127 + 128
local rgbg2 = math.sin((time / frequency/1.5) * 4 + 2) * 127 + 128
local rgbb2 = math.sin((time / frequency/1.5) * 4 + 4) * 127 + 128


local function removefromtable(id)
	local cur = #killist
	killist[id] = nil
	for i=id, cur+1 do
		if killist[i] ~= nil or killist[i-1] == nil then
			killist[i-1] = killist[i]
			killist[i] = nil
		end
	end
end

local function DrawHUD(ctx, e)
	if not get_ui(settings.enabled) then return end

	local lp = entity.get_local_player()

	if not entity.is_alive(lp) then
		lp = entity.get_prop(lp, "m_hObserverTarget")
	end
	if lp == nil then return end

	local ammo = get_prop(entity.get_player_weapon(lp), "m_iClip1") or -1
	local ammores = get_prop(entity.get_player_weapon(lp), "m_iPrimaryReserveAmmoCount") or 0
	local armor = get_prop(lp, "m_ArmorValue")
	local buyz = get_prop(lp, "m_bInBuyZone")
	local hp = get_prop(lp, "m_iHealth")
	local money = get_prop(lp, "m_iAccount")
	local pResource = get_all("CCSPlayerResource")[1]
	local hasc4 = get_prop(pResource, "m_iPlayerC4")
	local cwep = get_prop(lp, "m_hActiveWeapon")
	local x3, y3 = 10, screen.h-60
	local r3, g3, b3, a3 = get_ui(settings.menu_color)
	local things3ref = get_ui(settings.hud_settings)
	local ltypes = get_ui(settings.hud_beatify)
	local len, t, namepos, icon, iconlenght, iconheight
	local time = globals.realtime()

	set_prop(lp, "m_iHideHud", 8)
	draw_container(ctx, 0, y3, screen.w, 60) -- main container

	if Contains(things3ref, "HP Based color") then
		r3, g3, b3 = clamp(255-hp*2.55, 0, 255), clamp(hp, 0, 200), 0
	end

	if Contains(things3ref, "Rainbow gradient") then
		rgbr = math.sin((time / frequency) * 4) * 127 + 128
		rgbg = math.sin((time / frequency) * 4 + 2) * 127 + 128
		rgbb = math.sin((time / frequency) * 4 + 4) * 127 + 128

		rgbr2 = math.sin((time / frequency/1.5) * 4) * 127 + 128
		rgbg2 = math.sin((time / frequency/1.5) * 4 + 2) * 127 + 128
		rgbb2 = math.sin((time / frequency/1.5) * 4 + 4) * 127 + 128
	end

	if Contains(things3ref, "Show gradient header") then
		drawgradient(5, y3 + 7, screen.w-10, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	end
	
	x3 = x3 + 20
	    drawtext(x3, y3 + 17.5, r3, g3, b3, a3, "+", 0, hp )
	    len = getlen(hp)
	    if Contains(ltypes, "Line") then
			drawrect(x3, y3 + 45, len, 3, r3, g3, b3, a3)  
	    end
	    x3 = x3 + len + 15
	    drawtext(x3, y3 + 17.5, 255, 255, 255, a3, "+", 0, "HP")
	    x3 = x3 + getlen("HP") + 12
		if Contains(ltypes, "Circle outline") then
		    draw_indicator_circle(ctx, x3, y3 + 32, r3, g3, b3, a3, hp)
		    x3 = x3 + 20
		end

	x3 = x3 + 10
	
	if Contains(things3ref, "Show armor") then
	    drawtext(x3, y3 + 17.5, r3, g3, b3, a3, "+", 0, armor )
	    len = getlen(armor)
	    if Contains(ltypes, "Line") then
			drawrect(x3, y3 + 45, len, 3, r3, g3, b3, a3)  
	    end
	    x3 = x3 + len + 15
	    drawtext(x3, y3 + 17.5, 255, 255, 255, a3, "+", 0, "ARMOR")
	    x3 = x3 + getlen("ARMOR") + 12
		if Contains(ltypes, "Circle outline") then
		    draw_indicator_circle(ctx, x3, y3 + 32, r3, g3, b3, a3, hp)
		    x3 = x3 + 30
		end
	end

	x3 = screen.w - 30 -- Left side

	if Contains(things3ref, "Show buy icon") and buyz == 1 then
	    t = "$"
	    drawtext(x3, y3 + 30, 255, 255, 255, a3, "c+", 0, t )
	    len = getlen(t)/2 + 25
	    x3 = x3 - len
	    drawtext(x3, y3 + 17.5, r3,g3,b3, a3, "r+", 0, money)
	    len = getlen(money)
	    if Contains(ltypes, "Line") then
			drawrect(x3-len, y3 + 45, len, 3, r3, g3, b3, a3)  
	    end

	    x3 = x3 - len*1.5

	end

	if Contains(things3ref, "Show ammo") and ammo ~= -1 then
		t = ammo .. "/" .. ammores
		len = getlen(t)
		if Contains(ltypes, "For ammo") then
			if Contains(ltypes, "Circle outline") then
			    draw_indicator_circle(ctx, x3, y3 + 32, r3, g3, b3, a3, hp)
			    x3 = x3 - 30
			end
			
		end
		drawtext(x3, y3 + 17.5, r3, g3, b3, y3, "r+", 0, t)
		if Contains(ltypes, "For ammo") then
			if Contains(ltypes, "Line") then
				drawrect(x3-len, y3 + 45, len, 3, r3, g3, b3, a3)  
		    end
		end
	end
	if not Contains(things3ref, "Kill feed") then return end
	for i,tbl in pairs(killist) do
		local tempx = tbl.x or 0
		if tempx > 200 then
			removefromtable(i)
			break 
		elseif tbl.remove and time > tbl.remove then
			killist[i].x = tempx + 2
		end

		local enemy1, enemy2, enemy3 = get_ui(settings.killfeed_enemy)
		local team1, team2, team3 = get_ui(settings.killfeed_team)
		local me1, me2, me3 = get_ui(settings.menu_color)
		image = images_icons[tbl.weapon or "icon_suicide"] or images_icons["icon_suicide"]
		local iconw, iconh = image:measure(nil, 16)
		local test_len = getlen(tbl.killer, true) + iconw + 50 + getlen(tbl.victim, true)
		test_len = tbl.hs and test_len + 16 or test_len
		test_len = tbl.wall and test_len + 16 or test_len
		local mult, starty = get_ui(settings.killfeed_between), get_ui(settings.killfeed_starty)
		local startheight, height, between = 15, 15, 2
		height = startheight*(i-1)*(2.25+(mult/10)) + starty - mult/2
		draw_container(ctx, screen.w-test_len+tempx, height+between, test_len-10, 35)
		if Contains(things3ref, "Show gradient header") then
			local gradient_h = height+5
			local subbed = test_len/2.3
			drawgradient(screen.w-test_len+5+tempx, gradient_h+between, test_len-20, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
		end
		namepos = screen.w - test_len + 10
		local r = (tbl.col == "enemy") and enemy1 or (tbl.col == "team") and team1 or me1
		local g = (tbl.col == "enemy") and enemy2 or (tbl.col == "team") and team2 or me2
		local b = (tbl.col == "enemy") and enemy3 or (tbl.col == "team") and team3 or me3
		local texth, iconh = height + startheight-1, height + startheight-1.5
		drawtext(namepos+tempx, texth, r, g, b, 255, "", 0, tbl.killer)
		len = getlen(tbl.killer, true)
		namepos = namepos + len + 10
		local width = image:draw(namepos + tempx, iconh, nil, 16, 255, 255, 255, 255)
		if tbl.wall then
			image = images_icons["penetrate"]
			local w = image:draw(namepos + tempx + width + 2, iconh, nil, 16, 255, 255, 255, 255)
			width = width + 16
		end
		if tbl.hs then
			image = images_icons["icon_headshot"]
			local w = image:draw(namepos + tempx + width + 2, iconh, nil, 16, 255, 255, 255, 255)
			width = width + 16
		end
		namepos = namepos + width + 10
		local r2 = (tbl.col2 == "enemy") and enemy1 or (tbl.col2 == "team") and team1 or me1
		local g2 = (tbl.col2 == "enemy") and enemy2 or (tbl.col2 == "team") and team2 or me2
		local b2 = (tbl.col2 == "enemy") and enemy3 or (tbl.col2 == "team") and team3 or me3
		drawtext(namepos + tempx, texth, r2, g2, b2, 255, "", 0, tbl.victim)
	end

end


client.set_event_callback("paint", DrawHUD)
local function LogKill(evnt)
	local time, should = get_ui(settings.killfeed_time), get_ui(settings.killfeed_remove)
	local id = #killist + 1
	local killerman, me, victimman = client.userid_to_entindex(evnt.attacker), entity.get_local_player(), client.userid_to_entindex(evnt.userid)
	local killer, victim, weapon, hs, wall = entity.get_player_name(killerman), entity.get_player_name(victimman), evnt.weapon, evnt.headshot, evnt.penetrated == 1

	local now = globals.realtime()

	local col, col2 = (entity.is_enemy(killerman) and "enemy" or killerman ~= me and "team"), (entity.is_enemy(victimman) and "enemy" or victimman ~= me and "team")
	time = time + now
	if should and killerman == me then 
		time = nil
	end
	killist[id] = {killer = killer:sub(0,15), victim = victim:sub(0,15), weapon = weapon, hs = hs, wall = wall, col = col, col2 = col2, remove = time, x = 0}
end

local function ClearList()
	killist = {}
end

local function MakeMenu(should)
	for _, v in pairs(settings) do
		if v ~= settings.enabled and v ~= settings.killfeed_remove then
			ui.set_visible(v, should)
		end
	end
end

local function MenuUpdate()
	MakeMenu(get_ui(settings.enabled))
end

local function CheckForKills()
	if not get_ui(settings.enabled) then return end
	local things3ref = get_ui(settings.hud_settings)
	local that = Contains(things3ref, "Kill feed") and "-1" or "0"
	client.exec("cl_drawhud_force_deathnotices " .. that)
end

--for k,v in pairs(GetWeapons(entity.get_local_player())) do
--	print(ffi.string(entity.get_classname(v)))
--end

MenuUpdate()
CheckForKills()

ui.set_callback(settings.enabled, MenuUpdate)
ui.set_callback(settings.hud_settings, CheckForKills)

client.set_event_callback('player_death', LogKill)
client.set_event_callback('round_start', ClearList)
