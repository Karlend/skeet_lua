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
local getclass = entity.get_classname
local table_insert = table.insert

local draw_rectangle = client.draw_rectangle

local dragging = (function() local a={}local b,c,d,e,f,g,h,i,j,k,l,m,n,o;local p={__index={drag=function(self,...)local q,r=self:get()local s,t=a.drag(q,r,...)if q~=s or r~=t then self:set(s,t)end;return s,t end,set=function(self,q,r)local j,k=client.screen_size()ui.set(self.x_reference,q/j*self.res)ui.set(self.y_reference,r/k*self.res)end,get=function(self)local j,k=client.screen_size()return ui.get(self.x_reference)/self.res*j,ui.get(self.y_reference)/self.res*k end}}function a.new(u,v,w,x)x=x or 10000;local j,k=client.screen_size()local y=ui.new_slider("LUA","A",u.." window position",0,x,v/j*x)local z=ui.new_slider("LUA","A","\n"..u.." window position y",0,x,w/k*x)ui.set_visible(y,false)ui.set_visible(z,false)return setmetatable({name=u,x_reference=y,y_reference=z,res=x},p)end;function a.drag(q,r,A,B,C,D,E)if globals.framecount()~=b then c=ui.is_menu_open()f,g=d,e;d,e=ui.mouse_position()i=h;h=client.key_state(0x01)==true;m=l;l={}o=n;n=false;j,k=client.screen_size()end;if c and i~=nil then if(not i or o)and h and f>q and g>r and f<q+A and g<r+B then n=true;q,r=q+d-f,r+e-g;if not D then q=math.max(0,math.min(j-A,q))r=math.max(0,math.min(k-B,r))end end end;table.insert(l,{q,r,A,B})return q,r,A,B end;return a end)()
local dragging_indicators = dragging.new("hindicators", 15, 420)
local screen = {}
screen.w, screen.h = client.screen_size()

local frequency = 1

local hudsize = 40

local time = globals.realtime()

local rgbr = math.sin((time / frequency) * 4) * 127 + 128
local rgbg = math.sin((time / frequency) * 4 + 2) * 127 + 128
local rgbb = math.sin((time / frequency) * 4 + 4) * 127 + 128
local rgbr2 = math.sin((time / frequency/1.5) * 4) * 127 + 128
local rgbg2 = math.sin((time / frequency/1.5) * 4 + 2) * 127 + 128
local rgbb2 = math.sin((time / frequency/1.5) * 4 + 4) * 127 + 128

local function getlen(text, norm)
	return renderer.measure_text((norm and "" or "+"), text)
end

local indvars = {
	["Fake lag"] = {
		chokedcommands = 0,
		chokedcommands_prev = 0,
		chokedcommands_prev_cmd = 0,
		chokedcommands_max = 0,
		tickcount = 0,
		tickcount_prev = 0,
		last_cmd = 0,
	},
}

local inds = {}

local indicators = {}

indicators = {
	["Fake Lag"] = {
		solution = {ui.reference("AA", "Fake lag", "Enabled")},
		should = function(self)
			local s, a = self.solution[1], self.solution[2]
			return get_ui(s) and get_ui(a)
		end,
		width = function(self)
			return getlen("Fake Lag", true)*3
		end,
		draw = function(self, x, y)
			local limit = get_ui(ui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks")) - 2
			local tbl = indvars["Fake lag"]
			tbl.chokedcommands_prev = tbl.chokedcommands
            tbl.chokedcommands = globals.chokedcommands()
            if tbl.chokedcommands_max == nil or tbl.chokedcommands > tbl.chokedcommands_max then
                tbl.chokedcommands_max = tbl.chokedcommands
            elseif tbl.chokedcommands == 0 and tbl.chokedcommands_prev ~= 0 then
                tbl.chokedcommands_max = tbl.chokedcommands_prev
            elseif tbl.chokedcommands == 0 and tbl.chokedcommands_prev_cmd == 0 then
                tbl.chokedcommands_max = 0
            end


            tbl.tickcount = globals.tickcount()
            if tbl.tickcount ~= tbl.tickcount_prev then
                tbl.last_cmd = globals.curtime()
                tbl.chokedcommands_prev_cmd = tbl.chokedcommands_prev
                tbl.tickcount_prev = tbl.tickcount
            end

			local n = "Fake Lag"
			drawtext(x, y, 255, 255, 255, 255, "", 0, n)
			local tw, h = getlen(n, true)
			local interp = (globals.curtime() - tbl.last_cmd) / globals.tickinterval()
			local bar_len = 60
			drawrect(x + 5 + tw, y + h/3.1, bar_len, h/2, 20, 20, 20, 220)
			local w = bar_len
			local chokedcommands_interpolated = math.min(tbl.chokedcommands_max, tbl.chokedcommands + (interp < 1 and interp or 0))
			w = math.floor(w*math.max(0, math.min(1, tbl.chokedcommands_max / limit)))
			drawgradient(x + 5 + tw, y + h/3.1, w, h/2, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
			if tbl.chokedcommands_max > 0 then
				drawtext(x + 125, y, 255, 255, 255, 255, "r", 0, tbl.chokedcommands_max)
			end
		end,
	},
	["Ping spike"] = { 
		solution = {ui.reference("MISC", "Miscellaneous", "Ping spike")},
		should = function(self)
			local s, a = self.solution[1], self.solution[2]
			return get_ui(s) and get_ui(a)
		end,
	},
	["FakeDuck"] = { 
		solution = ui.reference("RAGE", "Other", "Duck peek assist"),
		should = function(self) 
			return get_ui(self.solution)
		end, 
	},
	["On shot AA"] = { 
		solution = ui.reference("AA", "Other", "On shot anti-aim"),
		should = function(self) 
			return get_ui(self.solution)
		end, 
	},
	["Double Tap"] = { 
		solution = {ui.reference("RAGE", "Other", "Double tap")},
		should = function(self)
			local s, a = self.solution[1], self.solution[2]
			return get_ui(s) and get_ui(a)
		end,
		width = function(self)
			return getlen("Double tap [Deffensive]", true) + 10
		end,
		draw = function(self, x, y)
			local lp = entity.get_local_player()
			local mode = get_ui(ui.reference("RAGE", "Other", "Double tap mode"))
			drawtext(x, y, 255, 255, 255, 255, "", 0, "Double tap")
			local modex, modey = getlen("Double tap", true)
			local weapon = entity.get_player_weapon(lp)
			local next_attack = math.max(get_prop(weapon, "m_flNextPrimaryAttack") or 0, get_prop(lp, "m_flNextAttack") or 0)
			local r, g, b, a = unpack(globals.curtime() > next_attack and {126, 195, 12} or {230, 230, 39})
			drawtext(x + modex, y, r, g, b, 255, "", 0, " [" .. mode .. "]")
		end,
	},
	["Safe point"] = { 
		solution = ui.reference("RAGE", "Aimbot", "Force safe point"),
		should = function(self) 
			return get_ui(self.solution)
		end, 
	},
	["Freestanding"] = { 
		solution = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")},
		should = function(self) 
			local s, a = self.solution[1], self.solution[2]
			return get_ui(s) and get_ui(a)
		end, 
	},
	["SlowWalk"] = { 
		solution = {ui.reference("AA", "Other", "Slow motion")},
		should = function(self) 
			local s, a = self.solution[1], self.solution[2]
			return get_ui(s) and get_ui(a)
	end, 
	},
	["Anti-aim correction override"] = { 
		solution = ui.reference("RAGE", "Other", "Anti-aim correction override"),
		should = function(self) 
			return get_ui(self.solution)
		end,
	},
	["Force baim"] = { 
		solution = ui.reference("RAGE", "Other", "Force body aim"),
		should = function(self) 
			return get_ui(self.solution)
		end,
	},
}

local indicatorlist = {}

for name, tbl in pairs(indicators) do
	table_insert(indicatorlist, name)
end


local killist = {}


--local wheelup, wheeldown, wheeled = 115, 116

local settings = 
{
   enabled = ui.new_checkbox("LUA", "B", "HUD Enabled"),
   menu_color = ui.reference("Misc", "settings", "Menu color"),
   hud_settings = ui.new_multiselect("LUA", "B", "HUD settings", "Show header", "Rainbow gradient", "Show ammo", "Show armor", "Show buy icon", "Show weapons", "HP Based color", "Kill feed", "Force radar", "Hide hud", "Indicators"),
   hud_beatify = ui.new_multiselect("LUA", "B", "HUD Indicators", "Circle outline", "Line", "For ammo"),
   hud_size = ui.new_slider("LUA", "B", "HUD size", 35, 70, 40),
   -- Gradient settings
   first_color = ui.new_color_picker("LUA", "B", "First gradient", 200, 0, 0, 255),
   second_color = ui.new_color_picker("LUA", "B", "Second gradient", 0, 200, 0, 255),
   -- Color scheme
   hud_customcolor = ui.new_checkbox("LUA", "B", "Custom style"),
   hud_accent = ui.new_color_picker("LUA", "B", "Accent color", 200, 0, 0, 255),

   hud_container = ui.new_combobox("LUA", "B", "Container style", "Gamesense", "Custom", "Dump", "Dump 2", "Trash"),
   hud_container_background = ui.new_color_picker("LUA", "B", "Background color", 20, 20, 20, 220),

   -- KillFeed
   killfeed_remove = ui.reference("MISC", "Miscellaneous", "Persistent kill feed"),
   killfeed_time = ui.new_slider("LUA", "B", "Kill visible time", 1, 15, 5),
   --killfeed_colors = ui.new_checkbox("LUA", "B", "Custom colors"),
   killfeed_enemy = ui.new_color_picker("LUA", "B", "Kill enemy color", 200, 0, 0, 255),
   killfeed_team = ui.new_color_picker("LUA", "B", "Kill team color", 0, 200, 0, 255),

   killfeed_starty = ui.new_slider("LUA", "B", "Kill feed y margin", 2, 200, 10),
   killfeed_between = ui.new_slider("LUA", "B", "Kill feed margin mult", 1, 10, 1),

   killfeed_mkills = ui.new_slider("LUA", "B", "Max kills", 1, 10, 5),

   wselector_starty = ui.new_slider("LUA", "B", "Weapon selector position (y)", 0, screen.h, screen.h/2),

   wselector_height = ui.new_slider("LUA", "B", "Weapon selector height", 30, 50, 35),
   wselector_distance = ui.new_slider("LUA", "B", "Weapon selector distance", 0, 30, 5),
   wselector_cooldown = ui.new_slider("LUA", "B", "Weapon switch cooldown", 2, 100, 20), -- cooldown between q, 1, 2, 3, ...

   indicators = ui.new_multiselect("LUA", "B", "Indicators", indicatorlist),
}

---------------------------------------------------
-----------------HELPER VARS-----------------------


local mr, mg, mb, ma
if get_ui(settings.hud_customcolor) then
	mr, mg, mb, ma = get_ui(settings.hud_accent)
else
	mr, mg, mb, ma = get_ui(settings.menu_color)
end
---------------------------------------------------
-----------------HELPER FUNCS---------------------

local function Contains(table, val) --thanks sapphyrus
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

local containers = { -- pasted from kopretinka <3
	["Gamesense"] = function(x, y, w, h, header)
		local c = {10, 60, 40, 40, 40, 60, 20}
	    for i = 0,6,1 do
	        draw_rectangle(0, x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], 255)
	    end

	    if header == true then
	    	drawgradient(x + 7, y + 5, w - 14, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	        --draw.gradient(x + 7, y + 7, w/2, 1, 59, 175, 222, 255, 202, 70, 205, 255, true)
	        --draw.gradient(x + w/2, y + 7, w/2 - 7, 1, 202, 70, 205, 255, 201, 227, 58, 255, true)
	    end
	end,
	["Custom"] = function(x, y, w, h, header)
		local r, g, b, a = get_ui(settings.hud_container_background)
		drawrect(x, y, w, h, r, g, b, a)

	    if header == true then
	    	drawgradient(x + 2, y + 2, w - 4, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	        --draw.gradient(x + 2, y + 2, w/2, 1, 59, 175, 222, 255, 202, 70, 205, 255, true)
	        --draw.gradient(x + (w/2) - 1, y + 2, (w/2) - 2, 1, 202, 70, 205, 255, 201, 227, 58, 255, true)
	    end
	end,
	["Dump"] = function(x, y, w, h, header)
		drawrect(x, y, w, h, 20, 20, 20, 220)
		if header == true then
	    	drawgradient(x + 2, y + 2, w - 4, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	        --draw.gradient(x + 2, y + 2, w/2, 1, 59, 175, 222, 255, 202, 70, 205, 255, true)
	        --draw.gradient(x + (w/2) - 1, y + 2, (w/2) - 2, 1, 202, 70, 205, 255, 201, 227, 58, 255, true)
	    end
	end,
	["Dump 2"] = function(x, y, w, h, header)
		local r, g, b, a = mr, mg, mb, ma
	    drawrect(x, y, w, h, 56, 53, 60, 255)

	    if header == true then
	    	drawgradient(x + 2, y + 2, w - 4, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	        --drawrect(x, y, w, 3, r, g, b, a)
	    end
	end,
	["Trash"] = function(x, y, w, h, header)
		local r, g, b, a = mr, mg, mb, ma
		local br, bg, bb, ba = get_ui(settings.hud_container_background)
		--rgbr, rgbg, rgbb = get_ui(settings.first_color)
		--rgbr2, rgbg2, rgbb2 = get_ui(settings.second_color)
	    drawrect(x, y, w, h, br, bg, bb, ba)
	    drawline(x - 1, y - 1, (w+x), y - 1, r,g,b, 255)
	    drawline(x - 1, (h+y), (w+x), (h+y), r, g, b, 255)
	    --drawline(x - 1, y - 1, x - 1, (h+y), r, g, b, 255)
	    --drawline((w+x), y - 1, (w+x), (h+y), rgbr2, rgbg2, rgbb2, 255)

	    if header == true then
	        drawrect(x + 1, y + 1, w - 2, 1, rgbr, rgbg, rgbb, a)
	    end
	end
	
}


function draw_container(ctx, x, y, w, h)
	local things3ref = get_ui(settings.hud_settings)
	local need, headers = (get_ui(settings.hud_container) or 0), Contains(things3ref, "Show header")
	containers[need](x, y, w, h, headers)
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


local function clamp(value,min,max)
	if value < min then
		return min
	elseif value > max then
		return max
	end
	return value
end

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

local function GetWeapons(self) -- thx Aviarita
	local weapons = {}
	for i=0, 64 do
		local weapon = get_prop(self, "m_hMyWeapons", i)
		if weapon ~= nil then
			local class = getclass(weapon)
			--print(i .. " " .. class)
			weapons[i] = class
		end
	end
	return weapons
end

local WeapGroup = {
	[""] = true
}

--[[
	  glock
	  hkp2000
	  usp_silencer
	  elite
	  p250
	  tec9
	  fn57
	  deagle
	  galilar
	  famas
	  ak47
	  m4a1
	  m4a1_silencer
	  ssg08
	  aug
	  sg556
	  awp
	  scar20
	  g3sg1
	  nova
	  xm1014
	  mag7
	  m249
	  negev
	  mac10
	  mp9
	  mp7
	  ump45
	  p90
	  bizon
	  vest
	  vesthelm
	  taser
	  defuser
	  heavyarmor
	  molotov
	  incgrenade
	  decoy
	  flashbang
	  hegrenade
	  smokegrenade
]]

local translates = {
	["CDEagle"] = "Deagle",
	["CAK47"] = "AK-47",
	["CKnife"] = "Knife",

	["CSnowball"] = "SnowBall",
	["CMolotovGrenade"] = "Molotov",
	["CIncendiaryGrenade"] = "Fire",
	["CFlashbang"] = "Flashbang",
	["CHEGrenade"] = "HE Grenade",
	["CSmokeGrenade"] = "Smoke",

	["weapon_CItem_Healthshot"] = "Healthshot",

	["CC4"] = "C4"
}

local toclass = {
	["Smoke"] = "smokegrenade",
	["Fire"] = "incgrenade",
	["HE Grenade"] = "hegrenade",
	["AK-47"] = "ak47",
	["Heavy pistol"] = "deagle"
}

local slots_tbl = {
	-- primary
	["weapon_galilar"] = 1,
	["weapon_famas"] = 1,
	["weapon_ak47"] = 1,
	["weapon_m4a1"] = 1,
	["weapon_m4a1_silencer"] = 1,
	["weapon_ssg08"] = 1,
	["weapon_aug"] = 1,
	["weapon_sg556"] = 1,
	["weapon_awp"] = 1,
	["weapon_scar20"] = 1,
	["weapon_g3sg1"] = 1,
	["weapon_nova"] = 1,
	["weapon_sawedoff"] = 1,
	["weapon_xm1014"] = 1,
	["weapon_mag7"] = 1,
	["weapon_m249"] = 1,
	["weapon_negev"] = 1,
	["weapon_mac10"] = 1,
	["weapon_mp9"] = 1,
	["weapon_mp7"] = 1,
	["weapon_ump45"] = 1,
	["weapon_p90"] = 1,
	["weapon_bizon"] = 1,
	-- pistols
	["weapon_glock"] = 2,
	["weapon_hkp2000"] = 2,
	["weapon_usp_silencer"] = 2,
	["weapon_fiveseven"] = 2,
	["weapon_elite"] = 2,
	["weapon_p250"] = 2,
	["weapon_tec9"] = 2,
	["weapon_deagle"] = 2,
	-- knives
	["weapon_knife"] = 3,
	-- grenades
	["weapon_flashbang"] = 8,
	["weapon_smokegrenade"] = 7,
	["weapon_incgrenade"] = 6,
	["weapon_hegrenade"] = 4,
	-- misc
	["weapon_c4"] = 10,
	["weapon_healthshot"] = 9,
}


local extend = {
	["C4"] = true,
	["Knife"] = false,
}

local function GetWeaponClass(wep)
	wep = wep:gsub("CWeapon", ""):gsub("CItem_", "")
	wep = translates[wep] or wep
	local name = wep
	if toclass[wep] then
		wep = toclass[wep]
	elseif toclass[string.lower(wep)] then
		wep = toclass[string.lower(wep)]
	end
	wep = "weapon_" .. wep
	wep = wep:lower()
	return wep, name -- class, name
end


local function RegroupWeapons(tbl) -- main function to return strings
	local back = {}
	for _,wep in pairs(tbl) do
		local wep, name = GetWeaponClass(wep)
		if slots_tbl[wep] then
			back[slots_tbl[wep]] = {class = wep, name = name}
		end
	end
	return back
end

---------------------------------------------------
-------------------INDICATORS----------------------
---------------------------------------------------

local between = 13
local function DrawIndicators()
	local h, w = between*1.5, 80
	local active = {}
	for name,_ in pairs(inds) do
		local tbl = indicators[name]
		if tbl.should(tbl) then
			table_insert(active, tbl.draw and {s = tbl, f = tbl.draw} or name)
			if tbl.width then
				local aw = tbl.width()
				if aw > w then
					w = aw
				end
			end
			h = h + between
		end
	end
	if #active == 0 then return end

	local x, y = dragging_indicators:get()

	local width, height = 120, 10
	dragging_indicators:drag(width, height)

	draw_container(nil, x, y, w, h)
	x = x + 7
	y = y + between/2
	for k, name in pairs(active) do
		local x, y = x + 2, y + ((k-1) * between)
		if type(name) == "table" then
			name.f(name.s, x, y)
		else
			drawtext(x, y, 255, 255, 255, 255, "", 0, name)
		end
	end
end

---------------------------------------------------
------------------------HUD------------------------
---------------------------------------------------

local function DrawHUD(ctx, e)
	if not get_ui(settings.enabled) then return end

	local lp = entity.get_local_player()

	if not entity.is_alive(lp) then
		lp = entity.get_prop(lp, "m_hObserverTarget")
	end
	if lp == nil then 
		return 
	end

	local ammo = get_prop(entity.get_player_weapon(lp), "m_iClip1") or -1
	local ammores = get_prop(entity.get_player_weapon(lp), "m_iPrimaryReserveAmmoCount") or 0
	local armor = get_prop(lp, "m_ArmorValue")
	local buyz = get_prop(lp, "m_bInBuyZone")
	local hp = get_prop(lp, "m_iHealth")
	local money = get_prop(lp, "m_iAccount")
	local pResource = get_all("CCSPlayerResource")[1]
	local hasc4 = get_prop(pResource, "m_iPlayerC4")
	local cwep = get_prop(lp, "m_hActiveWeapon")

	local x3, y3 = 20, screen.h-hudsize
	local r3, g3, b3, a3 = mr, mg, mb, ma
	local things3ref = get_ui(settings.hud_settings)
	local ltypes = get_ui(settings.hud_beatify)
	local len, t, namepos, icon, iconlenght, iconheight
	local time = globals.realtime()

	local bb = hudsize/8

	--set_prop(lp, "m_iHideHud", 8)
	if Contains(things3ref, "Hide hud") then
		set_prop(lp, "m_iHideHud", 9)
	end

	draw_container(ctx, 0, y3, screen.w, hudsize) -- main container

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

	--if Contains(things3ref, "Show header") then
	--	drawgradient(5, y3 + 7, screen.w-10, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
	--end
	
	x3 = x3 + 20
	    drawtext(x3, y3 + hudsize/2, r3, g3, b3, a3, "c+", 0, hp )
	    len = getlen(hp)
	    if Contains(ltypes, "Line") then
			drawrect(x3 - len/2, y3 + hudsize/2+10, len, 3, r3, g3, b3, a3)  
	    end
	    x3 = x3 + len/2 + 15
	    drawtext(x3, y3 + hudsize/2, 255, 255, 255, a3, "c+", 0, "HP")
	    x3 = x3 + getlen("HP")
		if Contains(ltypes, "Circle outline") then
		    draw_indicator_circle(ctx, x3, y3 + hudsize/2, r3, g3, b3, a3, hp)
		    x3 = x3 + 25
		end

	x3 = x3 + 20
	
	if Contains(things3ref, "Show armor") then
	    drawtext(x3, y3 + hudsize/2, r3, g3, b3, a3, "c+", 0, armor )
	    len = getlen(armor)
	    if Contains(ltypes, "Line") then
			drawrect(x3 - len/2, y3 + hudsize/2+10, len, 3, r3, g3, b3, a3)
	    end
	    x3 = x3 + len/2 + 45
	    drawtext(x3, y3 + hudsize/2, 255, 255, 255, a3, "c+", 0, "ARMOR")
	    x3 = x3 + getlen("ARMOR")/1.5
		if Contains(ltypes, "Circle outline") then
		    draw_indicator_circle(ctx, x3, y3 + hudsize/2, r3, g3, b3, a3, hp)
		    x3 = x3 + 25
		end
	end

	x3 = screen.w - 20 -- Left side

	if Contains(things3ref, "Show buy icon") and buyz == 1 then
	    t = "$"
	    drawtext(x3, y3 + hudsize/2, 255, 255, 255, a3, "c+", 0, t )
	    len = getlen(t)/2 + 25
	    x3 = x3 - len*1.5
	    drawtext(x3, y3 + hudsize/2, r3, g3, b3, a3, "c+", 0, money)
	    len = getlen(money)
	    if Contains(ltypes, "Line") then
			drawrect(x3 - len/2, y3 + hudsize/2+10, len, 3, r3, g3, b3, a3)  
	    end

	    x3 = x3 - len
	end

	x3 = x3 - 20

	if Contains(things3ref, "Show ammo") and ammo ~= -1 then
		t = ammo .. "/" .. ammores
		len = getlen(t)
		if Contains(ltypes, "For ammo") then
			if Contains(ltypes, "Circle outline") then
			    draw_indicator_circle(ctx, x3 + len/2.5, y3 + hudsize/2, r3, g3, b3, a3, hp)
			    x3 = x3 - 25
			end
			
		end
		drawtext(x3, y3 + hudsize/2, r3, g3, b3, a3, "c+", 0, t)
		if Contains(ltypes, "For ammo") then
			if Contains(ltypes, "Line") then
				drawrect(x3 - len/2, y3 + hudsize/2+10, len, 3, r3, g3, b3, a3)  
		    end
		end
	end
	if Contains(things3ref, "Kill feed") then 
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
			local me1, me2, me3 = mr, mg, mb
			image = images_icons[tbl.weapon or "icon_suicide"] or images_icons["icon_suicide"]
			local iconw, iconh = image:measure(nil, 16)
			local test_len = getlen(tbl.killer, true) + iconw + 50 + getlen(tbl.victim, true)
			test_len = tbl.hs and test_len + 16 or test_len
			test_len = tbl.wall and test_len + 16 or test_len
			local mult, starty = get_ui(settings.killfeed_between), get_ui(settings.killfeed_starty)
			local startheight, height, between = 15, 15, 2
			height = startheight*(i-1)*(2.25+(mult/10)) + starty - mult/2
			draw_container(ctx, screen.w-test_len+tempx, height+between, test_len-10, 35)
			--if Contains(things3ref, "Show header") then
			--	local gradient_h = height+5
			--	local subbed = test_len/2.3
			--	drawgradient(screen.w-test_len+5+tempx, gradient_h+between, test_len-20, 1, rgbr, rgbg, rgbb, 255, rgbr2, rgbg2, rgbb2, 255, true)
			--end
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
	if Contains(things3ref, "Show weapons") then
		local weptable = RegroupWeapons(GetWeapons(lp))
		local len, bheight, bbeetween = 100, get_ui(settings.wselector_height), get_ui(settings.wselector_distance)
		local wepx, wepy = screen.w,get_ui(settings.wselector_starty)
		for k,v in pairs(weptable) do
			local curwep, curname = GetWeaponClass(getclass(cwep))
			local wep, name  = v.class, v.name
			if extend[name] == true then
				wepy = wepy + bbeetween*1.5
			end
			local class = k .. " - " .. name
			len = getlen(class)+25
			local got = len
			draw_container(ctx, wepx-got, wepy, len, bheight)
			if curwep == wep then
				drawtext(wepx+(len/2)-got, wepy+(bheight/2), r3, g3, b3, a3, "c+", 0, class)
			else
				drawtext(wepx+(len/2)-got, wepy+(bheight/2), 255, 255, 255, a3, "c+", 0, class)
			end
			wepy = wepy + bheight + bbeetween
			if extend[name] == false then
				wepy = wepy + bbeetween*1.5
			end
		end
	end
	if Contains(things3ref, "Indicators") then
		DrawIndicators()
	end
end

client.set_event_callback("paint", DrawHUD)

local keys = {
	[0x30] = 10,
	[0x31] = 1,
	[0x32] = 2,
	[0x33] = 3,
	[0x34] = 4,
	[0x35] = 5,
	[0x36] = 6,
	[0x37] = 7,
	[0x38] = 8,
	[0x39] = 9,
	
}

local cooldown = .1

local nextc = 0

local prev = ""

client.set_event_callback("paint", function() -- bind system
	if not get_ui(settings.enabled) then return end
	if nextc > globals.realtime() then return end

	if client.key_state(0x51) then -- q
		local cwep = get_prop(entity.get_local_player(), "m_hActiveWeapon")
		local now = GetWeaponClass(getclass(cwep))
		client.exec("use " .. prev)
		if prev ~= now then
			prev = now
		end
		nextc = globals.realtime() + cooldown
	end

	for k,v in pairs(keys) do
		if client.key_state(k) then
			local weps = RegroupWeapons(GetWeapons(entity.get_local_player()))
			if not weps[v] then return end

			local cwep = get_prop(entity.get_local_player(), "m_hActiveWeapon")
			local now = GetWeaponClass(getclass(cwep))

			local wep = weps[v].class
			client.exec("use " .. wep)
			if wep ~= now then
				prev = now
			end
			nextc = globals.realtime() + cooldown
		end
	end
end)

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
	if id > get_ui(settings.killfeed_mkills) then
		removefromtable(1)
	end
end

local function ClearList()
	killist = {}
end

local sets = {
	-- gradient
	[settings.first_color] = function() return not Contains(get_ui(settings.hud_settings), "Rainbow gradient") end,
	[settings.second_color] = function() return not Contains(get_ui(settings.hud_settings), "Rainbow gradient") end,
	-- killfeed
	[settings.killfeed_remove] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,
	[settings.killfeed_time] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,
	[settings.killfeed_enemy] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,
	[settings.killfeed_team] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,
	[settings.killfeed_starty] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,
	[settings.killfeed_between] = function() return Contains(get_ui(settings.hud_settings), "Kill feed") end,

	[settings.wselector_starty] = function() return Contains(get_ui(settings.hud_settings), "Show weapons") end,
   	[settings.wselector_height] = function() return Contains(get_ui(settings.hud_settings), "Show weapons") end,
   	[settings.wselector_distance] = function() return Contains(get_ui(settings.hud_settings), "Show weapons") end,

   	[settings.hud_accent] = function() return get_ui(settings.hud_customcolor) end,
   	[settings.hud_container_background] = function() return get_ui(settings.hud_container) == "Custom" or get_ui(settings.hud_container) == "Trash" end,
   	[settings.indicators] = function() return Contains(get_ui(settings.hud_settings), "Indicators") end,
}

local function MakeMenu(should)
	for _, v in pairs(settings) do
		if v ~= settings.enabled and v ~= settings.killfeed_remove and v ~= settings.menu_color then
			if sets[v] and should then
				local should = sets[v]()
				ui.set_visible(v, should)
			else
				ui.set_visible(v, should)
			end
		end
	end
end

local vars = {}
vars["Kill feed"] = {cvar.cl_drawhud_force_deathnotices, -1, 0}
vars["Force radar"] = {cvar.cl_drawhud_force_radar, 1, 0}
--vars["Hide hud"] = {cvar.cl_drawhud, 0, 1}

local function UpdateCvars()
	--if not get_ui(settings.enabled) then return end
	local things3ref = get_ui(settings.hud_settings)
	for cont, tbl in pairs(vars) do
		--client.exec(tbl[1] .. " " .. ((Contains(things3ref, cont) and get_ui(settings.enabled)) and tbl[2] or tbl[3]))
		tbl[1]:set_float((Contains(things3ref, cont) and get_ui(settings.enabled)) and tbl[2] or tbl[3])
	end
end

local function UpdateColors()
	if get_ui(settings.hud_customcolor) then
		mr, mg, mb, ma = get_ui(settings.hud_accent)
	else
		mr, mg, mb, ma = get_ui(settings.menu_color)
	end

	rgbr, rgbg, rgbb = get_ui(settings.first_color)
	rgbr2, rgbg2, rgbb2 = get_ui(settings.second_color)

	hudsize = get_ui(settings.hud_size)
end

local function MenuUpdate()
	MakeMenu(get_ui(settings.enabled))
	UpdateCvars()
	UpdateColors()
	hudsize = get_ui(settings.hud_size)
end


MenuUpdate()
UpdateCvars()

ui.set_callback(settings.enabled, MenuUpdate)
ui.set_callback(settings.hud_settings, MenuUpdate)
ui.set_callback(settings.hud_customcolor, MenuUpdate)
ui.set_callback(settings.hud_container, MenuUpdate)

ui.set_callback(settings.hud_accent, MenuUpdate)

ui.set_callback(settings.first_color, UpdateColors)
ui.set_callback(settings.second_color, UpdateColors)

ui.set_callback(settings.hud_size, UpdateColors)

ui.set_callback(settings.wselector_cooldown, function()
	cooldown = get_ui(settings.wselector_cooldown)/100
end)

ui.set_callback(settings.indicators, function(a)
	inds = {}
	for k,v in pairs(get_ui(a)) do
		inds[v] = true
	end
end)

client.set_event_callback('player_death', LogKill)
client.set_event_callback('round_start', ClearList)

