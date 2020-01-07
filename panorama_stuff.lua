local js = require("access_panorama") 
local get_ui, set_ui, set_visible = ui.get, ui.set, ui.set_visible

local function collect_keys(tbl, sort)
    local keys = {}
    sort = sort or true
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    if sort then
        table.sort(keys)
    end
    return keys
end

local customvid, selected = "", ""

local settings = {}

local UpdateElements

local presseted = {
	vids = {
		"Acknowledge", 
		"Blacksite", 
		"Cbble", 
		"Digital glitch", 
		"Nuke", 
		"Op9 main", 
		"Op9 mainmenu", 
		"Operation loading", 
		"Search", 
		"Sirocco",
		"Sirocco night",
		"Tiers bg",
		"Tournament bg",
		"Trailer 0",
		"Trailer 1",
		"Vs bg",
		"Custom"
	},
	hideable = {
		["Model"] = "MainMenuVanityParent",
		["Main frame"] = "MainMenuCore",
		["Store and news"] = "JsNewsContainer",
		["Friend list"] = "JsMainMenuSidebar",
	    ["Party chat"] = "PartyChat",
	    ["Left navbar"] = "MainMenuNavBarLeft",
		["Background"] = "MainMenuMovieParent",
	    ["Reconnect pannel"] = "MatchmakingReconnectPanel",
	    ["Notification ( bans )"] = "NotificationsContainer",
	    ["Snow"] = {function() 
			cvar.sv_holiday_mode:set_int(0)
		end, function()
	        cvar.sv_holiday_mode:set_int(2)
	    end},
	},
	models = {
		["Local T Agent"] = {"models/player/custom_player/legacy/tm_phoenix.mdl", true},
		["Local CT Agent"] = {"models/player/custom_player/legacy/ctm_sas.mdl", false},
		["Blackwolf | Sabre"] = {"models/player/custom_player/legacy/tm_balkan_variantj.mdl", true},
		["Rezan The Ready | Sabre"] = {"models/player/custom_player/legacy/tm_balkan_variantg.mdl", true},
		["Maximus | Sabre"] = {"models/player/custom_player/legacy/tm_balkan_varianti.mdl", true},
		["Dragomir | Sabre"] = {"models/player/custom_player/legacy/tm_balkan_variantf.mdl", true},
		["Lt. Commander Ricksaw | NSWC SEAL"] = {"models/player/custom_player/legacy/ctm_st6_varianti.mdl", false},
		["'Two Times' McCoy | USAF TACP"] = {"models/player/custom_player/legacy/ctm_st6_variantm.mdl", false},
		["Buckshot | NSWC SEAL"] = {"models/player/custom_player/legacy/ctm_st6_variantg.mdl", false},
		["Seal Team 6 Soldier | NSWC SEAL"] = {"models/player/custom_player/legacy/ctm_st6_variante.mdl", false},
		["3rd Commando Company | KSK"] = {"models/player/custom_player/legacy/ctm_st6_variantk.mdl", false},
		["'The Doctor' Romanov | Sabre"] = {"models/player/custom_player/legacy/tm_balkan_varianth.mdl", true},
		["Michael Syfers  | FBI Sniper"] = {"models/player/custom_player/legacy/ctm_fbi_varianth.mdl", false},
		["Markus Delrow | FBI HRT"] = {"models/player/custom_player/legacy/ctm_fbi_variantg.mdl", false},
		["Operator | FBI SWAT"] = {"models/player/custom_player/legacy/ctm_fbi_variantf.mdl", false},
		["Slingshot | Phoenix"] = {"models/player/custom_player/legacy/tm_phoenix_variantg.mdl", true},
		["Enforcer | Phoenix"] = {"models/player/custom_player/legacy/tm_phoenix_variantf.mdl", true},
		["Soldier | Phoenix"] = {"models/player/custom_player/legacy/tm_phoenix_varianth.mdl", true},
		["The Elite Mr. Muhlik | Elite Crew"] = {"models/player/custom_player/legacy/tm_leet_variantf.mdl", true},
		["Prof. Shahmat | Elite Crew"] = {"models/player/custom_player/legacy/tm_leet_varianti.mdl", true},
		["Osiris | Elite Crew"] = {"models/player/custom_player/legacy/tm_leet_varianth.mdl", true},
		["Ground Rebel  | Elite Crew"] = {"models/player/custom_player/legacy/tm_leet_variantg.mdl", true},
		["Special Agent Ava | FBI"] = {"models/player/custom_player/legacy/ctm_fbi_variantb.mdl", false},
		["B Squadron Officer | SAS"] = {"models/player/custom_player/legacy/ctm_sas_variantf.mdl", false},
		["Anarchist"] = {"models/player/custom_player/legacy/tm_anarchist.mdl", true},
		["Anarchist (Variant A)"] = {"models/player/custom_player/legacy/tm_anarchist_varianta.mdl", true},
		["Anarchist (Variant B)"] = {"models/player/custom_player/legacy/tm_anarchist_variantb.mdl", true},
		["Anarchist (Variant C)"] = {"models/player/custom_player/legacy/tm_anarchist_variantc.mdl", true},
		["Anarchist (Variant D)"] = {"models/player/custom_player/legacy/tm_anarchist_variantd.mdl", true},
		["Pirate"] = {"models/player/custom_player/legacy/tm_pirate.mdl", true},
		["Pirate (Variant A)"] = {"models/player/custom_player/legacy/tm_pirate_varianta.mdl", true},
		["Pirate (Variant B)"] = {"models/player/custom_player/legacy/tm_pirate_variantb.mdl", true},
		["Pirate (Variant C)"] = {"models/player/custom_player/legacy/tm_pirate_variantc.mdl", true},
		["Pirate (Variant D)"] = {"models/player/custom_player/legacy/tm_pirate_variantd.mdl", true},
		["Professional"] = {"models/player/custom_player/legacy/tm_professional.mdl", true},
		["Professional (Variant 1)"] = {"models/player/custom_player/legacy/tm_professional_var1.mdl", true},
		["Professional (Variant 2)"] = {"models/player/custom_player/legacy/tm_professional_var2.mdl", true},
		["Professional (Variant 3)"] = {"models/player/custom_player/legacy/tm_professional_var3.mdl", true},
		["Professional (Variant 4)"] = {"models/player/custom_player/legacy/tm_professional_var4.mdl", true},
		["Separatist"] = {"models/player/custom_player/legacy/tm_separatist.mdl", true},
		["Separatist (Variant A)"] = {"models/player/custom_player/legacy/tm_separatist_varianta.mdl", true},
		["Separatist (Variant B)"] = {"models/player/custom_player/legacy/tm_separatist_variantb.mdl", true},
		["Separatist (Variant C)"] = {"models/player/custom_player/legacy/tm_separatist_variantc.mdl", true},
		["Separatist (Variant D)"] = {"models/player/custom_player/legacy/tm_separatist_variantd.mdl", true},
		["GIGN"] = {"models/player/custom_player/legacy/ctm_gign.mdl", false},
		["GIGN (Variant A)"] = {"models/player/custom_player/legacy/ctm_gign_varianta.mdl", false},
		["GIGN (Variant B)"] = {"models/player/custom_player/legacy/ctm_gign_variantb.mdl", false},
		["GIGN (Variant C)"] = {"models/player/custom_player/legacy/ctm_gign_variantc.mdl", false},
		["GIGN (Variant D)"] = {"models/player/custom_player/legacy/ctm_gign_variantd.mdl", false},
		["GSG-9"] = {"models/player/custom_player/legacy/ctm_gsg9.mdl", false},
		["GSG-9 (Variant A)"] = {"models/player/custom_player/legacy/ctm_gsg9_varianta.mdl", false},
		["GSG-9 (Variant B)"] = {"models/player/custom_player/legacy/ctm_gsg9_variantb.mdl", false},
		["GSG-9 (Variant C)"] = {"models/player/custom_player/legacy/ctm_gsg9_variantc.mdl", false},
		["GSG-9 (Variant D)"] = {"models/player/custom_player/legacy/ctm_gsg9_variantd.mdl", false},
		["IDF"] = {"models/player/custom_player/legacy/ctm_idf.mdl", false},
		["IDF (Variant B)"] = {"models/player/custom_player/legacy/ctm_idf_variantb.mdl", false},
		["IDF (Variant C)"] = {"models/player/custom_player/legacy/ctm_idf_variantc.mdl", false},
		["IDF (Variant D)"] = {"models/player/custom_player/legacy/ctm_idf_variantd.mdl", false},
		["IDF (Variant E)"] = {"models/player/custom_player/legacy/ctm_idf_variante.mdl", false},
		["IDF (Variant F)"] = {"models/player/custom_player/legacy/ctm_idf_variantf.mdl", false},
		["SWAT"] = {"models/player/custom_player/legacy/ctm_swat.mdl", false},
		["SWAT (Variant A)"] = {"models/player/custom_player/legacy/ctm_swat_varianta.mdl", false},
		["SWAT (Variant B)"] = {"models/player/custom_player/legacy/ctm_swat_variantb.mdl", false},
		["SWAT (Variant C)"] = {"models/player/custom_player/legacy/ctm_swat_variantc.mdl", false},
		["SWAT (Variant D)"] = {"models/player/custom_player/legacy/ctm_swat_variantd.mdl", false},
		["SAS (Variant A)"] = {"models/player/custom_player/legacy/ctm_sas_varianta.mdl", false},
		["SAS (Variant B)"] = {"models/player/custom_player/legacy/ctm_sas_variantb.mdl", false},
		["SAS (Variant C)"] = {"models/player/custom_player/legacy/ctm_sas_variantc.mdl", false},
		["SAS (Variant D)"] = {"models/player/custom_player/legacy/ctm_sas_variantd.mdl", false},
		["ST6"] = {"models/player/custom_player/legacy/ctm_st6.mdl", false},
		["ST6 (Variant A)"] = {"models/player/custom_player/legacy/ctm_st6_varianta.mdl", false},
		["ST6 (Variant B)"] = {"models/player/custom_player/legacy/ctm_st6_variantb.mdl", false},
		["ST6 (Variant C)"] = {"models/player/custom_player/legacy/ctm_st6_variantc.mdl", false},
		["ST6 (Variant D)"] = {"models/player/custom_player/legacy/ctm_st6_variantd.mdl", false},
		["Balkan (Variant E)"] = {"models/player/custom_player/legacy/tm_balkan_variante.mdl", true},
		["Balkan (Variant A)"] = {"models/player/custom_player/legacy/tm_balkan_varianta.mdl", true},
		["Balkan (Variant B)"] = {"models/player/custom_player/legacy/tm_balkan_variantb.mdl", true},
		["Balkan (Variant C)"] = {"models/player/custom_player/legacy/tm_balkan_variantc.mdl", true},
		["Balkan (Variant D)"] = {"models/player/custom_player/legacy/tm_balkan_variantd.mdl", true},
		["Jumpsuit (Variant A)"] = {"models/player/custom_player/legacy/tm_jumpsuit_varianta.mdl", true},
		["Jumpsuit (Variant B)"] = {"models/player/custom_player/legacy/tm_jumpsuit_variantb.mdl", true},
		["Jumpsuit (Variant C)"] = {"models/player/custom_player/legacy/tm_jumpsuit_variantc.mdl", true},
		["Phoenix Heavy"] = {"models/player/custom_player/legacy/tm_phoenix_heavy.mdl", true},
		["Heavy"] = {"models/player/custom_player/legacy/ctm_heavy.mdl", false},
		["Leet (Variant A)"] = {"models/player/custom_player/legacy/tm_leet_varianta.mdl", true},
		["Leet (Variant B)"] = {"models/player/custom_player/legacy/tm_leet_variantb.mdl", true},
		["Leet (Variant C)"] = {"models/player/custom_player/legacy/tm_leet_variantc.mdl", true},
		["Leet (Variant D)"] = {"models/player/custom_player/legacy/tm_leet_variantd.mdl", true},
		["Leet (Variant E)"] = {"models/player/custom_player/legacy/tm_leet_variante.mdl", true},
		["Phoenix"] = {"models/player/custom_player/legacy/tm_phoenix.mdl", true},
		["Phoenix (Variant A)"] = {"models/player/custom_player/legacy/tm_phoenix_varianta.mdl", true},
		["Phoenix (Variant B)"] = {"models/player/custom_player/legacy/tm_phoenix_variantb.mdl", true},
		["Phoenix (Variant C)"] = {"models/player/custom_player/legacy/tm_phoenix_variantc.mdl", true},
		["Phoenix (Variant D)"] = {"models/player/custom_player/legacy/tm_phoenix_variantd.mdl", true},
		["FBI"] = {"models/player/custom_player/legacy/ctm_fbi.mdl", false},
		["FBI (Variant A)"] = {"models/player/custom_player/legacy/ctm_fbi_varianta.mdl", false},
		["FBI (Variant C)"] = {"models/player/custom_player/legacy/ctm_fbi_variantc.mdl", false},
		["FBI (Variant D)"] = {"models/player/custom_player/legacy/ctm_fbi_variantd.mdl", false},
		["FBI (Variant E)"] = {"models/player/custom_player/legacy/ctm_fbi_variante.mdl", false},
		["SAS"] = {"models/player/custom_player/legacy/ctm_sas.mdl", false}
	},
	animations = {
	    {"Fonzie_Pistol", "Emote_Fonzie_Pistol"},
	    {"Bring_It_On", "Emote_Bring_It_On"},
	    {"ThumbsDown", "Emote_ThumbsDown"},
	    {"ThumbsUp", "Emote_ThumbsUp"},
	    {"Celebration_Loop", "Emote_Celebration_Loop"},
	    {"BlowKiss", "Emote_BlowKiss"},
	    {"Calculated", "Emote_Calculated"},
	    {"Confused", "Emote_Confused",},
	    {"Chug", "Emote_Chug"},
	    {"Cry", "Emote_Cry"},
	    {"DustingOffHands", "Emote_DustingOffHands"},
	    {"DustOffShoulders", "Emote_DustOffShoulders",},
	    {"Facepalm", "Emote_Facepalm"},
	    {"Fishing", "Emote_Fishing"},
	    {"Flex", "Emote_Flex"},
	    {"golfclap", "Emote_golfclap",},
	    {"HandSignals", "Emote_HandSignals"},
	    {"HeelClick", "Emote_HeelClick"},
	    {"Hotstuff", "Emote_Hotstuff"},
	    {"IBreakYou", "Emote_IBreakYou",},
	    {"IHeartYou", "Emote_IHeartYou"},
	    {"Kung", "Emote_Kung-Fu_Salute"},
	    {"Laugh", "Emote_Laugh"},
	    {"Luchador", "Emote_Luchador",},
	    {"Make_It_Rain", "Emote_Make_It_Rain"},
	    {"NotToday", "Emote_NotToday"},
	    {"[RPS] Paper", "Emote_RockPaperScissor_Paper"},
	    {"[RPS] Rock", "Emote_RockPaperScissor_Rock",},
	    {"[RPS] Scissor", "Emote_RockPaperScissor_Scissor"},
	    {"Salt", "Emote_Salt"},
	    {"Salute", "Emote_Salute"},
	    {"SmoothDrive", "Emote_SmoothDrive",},
	    {"Snap", "Emote_Snap"},
	    {"StageBow", "Emote_StageBow",},
	    {"Wave2", "Emote_Wave2"},
	    {"Yeet", "Emote_Yeet"},
	    {"DanceMoves", "DanceMoves"},
	    {"Mask_Off_Intro", "Emote_Mask_Off_Intro"},
	    {"Zippy_Dance", "Emote_Zippy_Dance"},
	    {"ElectroShuffle", "ElectroShuffle"},
	    {"AerobicChamp", "Emote_AerobicChamp"},
	    {"Bendy", "Emote_Bendy"},
	    {"BandOfTheFort", "Emote_BandOfTheFort"},
	    {"Boogie_Down_Intro", "Emote_Boogie_Down_Intro",},
	    {"Capoeira", "Emote_Capoeira"},
	    {"Charleston", "Emote_Charleston"},
	    {"Chicken", "Emote_Chicken"},
	    {"Dance_NoBones", "Emote_Dance_NoBones",},
	    {"Dance_Shoot", "Emote_Dance_Shoot"},
	    {"Dance_SwipeIt", "Emote_Dance_SwipeIt"},
	    {"Dance_Disco_T3", "Emote_Dance_Disco_T3"},
	    {"DG_Disco", "Emote_DG_Disco",},
	    {"Dance_Worm", "Emote_Dance_Worm"},
	    {"Dance_Loser", "Emote_Dance_Loser"},
	    {"Dance_Breakdance", "Emote_Dance_Breakdance"},
	    {"Dance_Pump", "Emote_Dance_Pump",},
	    {"Dance_RideThePony", "Emote_Dance_RideThePony"},
	    {"Dab", "Emote_Dab"},
	    {"EasternBloc_Start", "Emote_EasternBloc_Start"},
	    {"FancyFeet", "Emote_FancyFeet",},
	    {"FlossDance", "Emote_FlossDance"},
	    {"FlippnSexy", "Emote_FlippnSexy"},
	    {"Fresh", "Emote_Fresh"},
	    {"GrooveJam", "Emote_GrooveJam",},
	    {"guitar", "Emote_guitar"},
	    {"Hillbilly_Shuffle_Intro", "Emote_Hillbilly_Shuffle_Intro"},
	    {"Hiphop_01", "Emote_Hiphop_01"},
	    {"Hula_Start", "Emote_Hula_Start",},
	    {"InfiniDab_Intro", "Emote_InfiniDab_Intro"},
	    {"Intensity_Start", "Emote_Intensity_Start"},
	    {"IrishJig_Start", "Emote_IrishJig_Start"},
	    {"KoreanEagle", "Emote_KoreanEagle",},
	    {"Kpop_02", "Emote_Kpop_02"},
	    {"LivingLarge", "Emote_LivingLarge"},
	    {"Maracas", "Emote_Maracas"},
	    {"PopLock", "Emote_PopLock"},
	    {"PopRock", "Emote_PopRock"},
	    {"RobotDance", "Emote_RobotDance"},
	    {"T-Rex", "Emote_T-Rex",},
	    {"TechnoZombie", "Emote_TechnoZombie"},
	    {"Twist", "Emote_Twist"},
	    {"WarehouseDance_Start", "Emote_WarehouseDance_Start"},
	    {"Wiggle", "Emote_Wiggle"},
	    {"Youre_Awesome", "Emote_Youre_Awesome",}
	}
}


local dance_names = {}
local dance_strings = {}
for i=1, #presseted.animations do
    local dance_name, dance_string = unpack(presseted.animations[i])
    table.insert(dance_names, dance_name)
    dance_strings[dance_name] =  dance_string
end

local model_names = {
	["CT"] = {}, 
	["T"]  = {}
}
local model_strings = {
	["CT"] = {}, 
	["T"]  = {}
}
for name, mdl_table in pairs(presseted.models) do
	local cur = mdl_table[2] and "T" or "CT"
	table.insert(model_names[cur], name)
	model_strings[cur][name] = mdl_table[1]
end


local function better(text)
	text = text:lower()
	return text:gsub(" ", "_")
end


local function UpdateVid(custom)
	local somepanel = js.get_child("MainMenu")

	local vid = (custom and (type(custom) == "string" and custom or get_ui(settings.custom_back))) or better(selected)
	local folder = custom and "custom" or "videos"

	js.eval( 
	  [[var videoPlayer = $( '#MainMenuMovie' );
		var backgroundMovie = ']] .. vid .. [[';
 
		videoPlayer.SetAttributeString( 'data-type', backgroundMovie );

		videoPlayer.SetMovie( "file://{resources}/]] .. folder .. [[/" + backgroundMovie + ".webm" );
		videoPlayer.Play();]], somepanel
	)
end

local disabled, restored = {}, {}

local function UpdatePanorama()
	local request = ""
	for name,should in pairs(disabled) do
		local id = should and 1 or 2
		local el_name = presseted.hideable[name]
		if type(el_name) == "table" then
			el_name[id]()
		else
			local state = tostring(should)
			request = request .. [[
			var model = $.GetContextPanel().GetChild(0).FindChildInLayoutFile( ']] .. el_name .. [[' );
	        model.visible = ]] .. state .. [[;]]
	        if state == "true" then
	        	disabled[name] = nil
	        end
	    end
	end
	js.eval(request) 
end

function UpdateElements()
	local tbl = get_ui(settings.removeable)
	for name, func in pairs(disabled) do
		disabled[name] = true
	end
	for id, name in pairs(tbl) do
		disabled[name] = false
	end
	UpdatePanorama()
end


settings = {
	enabled = ui.new_checkbox("LUA", "A", "Panorama Enabled"),
	-- video
	selected_back = ui.new_combobox("LUA", "A", "Panorama video", presseted.vids),
	-- custom video
	custom_back = ui.new_textbox("LUA", "A", "Custom panorama video", "custom"),
	custom_apply = ui.new_button("LUA","A", "Apply video", function() UpdateVid(true) end),
	-- hide elements
	removeable = ui.new_multiselect("LUA", "A", "Hide elements", collect_keys(presseted.hideable)),
	removeable_apply = ui.new_button("LUA", "A", "Apply elements", UpdateElements),
	-- models
	models_side = ui.new_combobox("LUA", "A", "Model side", "NONE", "CT", "T", "Custom"),
	models_list_ct = ui.new_listbox("LUA", "A", "Model changer", "NONE", unpack(model_names["CT"])),
	models_list_t = ui.new_listbox("LUA", "A", "Model changer", unpack(model_names["T"])),
	models_custom = ui.new_textbox("LUA", "A", "Model changer"),
	models_apply = ui.new_button("LUA", "A", "Apply model", function() end),
	-- fortnite dance
	animation_select = ui.new_listbox("LUA", "A", "Animation", "NONE", unpack(dance_names)),
	animation_speed = ui.new_slider("LUA", "A", "Animation speed", 1, 200, 100),
	antimation_start = ui.new_button("LUA", "A", "Start anim", function() end),
}


local sets = {
	[settings.custom_back] = function() return get_ui(settings.selected_back) == "Custom" end,
	[settings.custom_apply] = function() return get_ui(settings.selected_back) == "Custom" end,
	[settings.models_list_t] = function() return get_ui(settings.models_side) == "T" end,
	[settings.models_list_ct] = function() return get_ui(settings.models_side) == "CT" end,
	[settings.models_custom] = function() return get_ui(settings.models_side) == "Custom" end,
	[settings.models_apply] = function() return get_ui(settings.models_side) ~= "NONE" end,
}

local function MakeMenu(should)
	for _, v in pairs(settings) do
		if v ~= settings.enabled then
			if sets[v] and should then
				local should = sets[v]()
				set_visible(v, should)
			else
				set_visible(v, should)
			end
		end
	end
end

local function UpdateLocals()
	customvid, selected = get_ui(settings.custom_back), get_ui(settings.selected_back)
end

local last

local function Fortnuts()
	local anim, speed = get_ui(settings.animation_select), get_ui(settings.animation_speed)
	local mdl = last or "models/player/custom_player/legacy/tm_separatist_varianta.mdl"
	speed = speed/100
	if get_ui(settings.animation_select) == 0 then
		js.eval([[
			var model = $.GetContextPanel().GetChild(0).FindChildInLayoutFile( 'JsMainmenu_Vanity' );
	        model.SetScene("resource/ui/econ/ItemModelPanelCharMainMenu.res", "models/player/custom_player/legacy/ctm_sas.mdl", false)
	        model.SetSceneModel("]] .. mdl .. [[");
	        model.SetPlaybackRateMultiplier(]] .. tostring(speed) ..[[, ]] .. tostring(speed) .. [[);
	    ]])

	else
		local dance = dance_strings[dance_names[get_ui(settings.animation_select)]]

		js.eval([[
			var model = $.GetContextPanel().GetChild(0).FindChildInLayoutFile( 'JsMainmenu_Vanity' );
	    	model.SetScene("resource/ui/fornite_dances.res", "]] .. mdl .. [[", false)
	    	model.PlaySequence("]] .. dance .. [[", true)
	    	model.SetPlaybackRateMultiplier(]] .. tostring(speed) ..[[, ]] .. tostring(speed) .. [[);
	    ]])
	end
end

local function updmdl(sel)
	local mdl
	local side = get_ui(settings.models_side)
	local sect = side == "CT" and get_ui(settings.models_list_ct) or get_ui(settings.models_list_t)
	if not sel then
		if get_ui(settings.models_side) == "Custom" then
			mdl = get_ui(settings.models_custom)
		else
			mdl = model_strings[side][model_names[side][sect]]
		end
	else
		print("got sel - " .. tostring(sel))
		mdl = sel
	end
	last = mdl
	js.eval([[
	    var model = $.GetContextPanel().GetChild(0).FindChildInLayoutFile( 'JsMainmenu_Vanity' );
	    model.SetPlayerModel(']] .. mdl ..[[');
	]]) 
end


local function MenuUpdate()
	MakeMenu(get_ui(settings.enabled))
end

MenuUpdate()

ui.set_callback(settings.enabled, MenuUpdate)
ui.set_callback(settings.models_side, MenuUpdate)

ui.set_callback(settings.custom_back, UpdateLocals)
ui.set_callback(settings.selected_back, function()
	MenuUpdate()
	UpdateLocals()
	if get_ui(settings.selected_back) ~= "Custom" then
		UpdateVid()
	end
end)



ui.set_callback(settings.models_apply, function() updmdl() end)
ui.set_callback(settings.antimation_start, Fortnuts)

local curcmd = {
	["setmodel"] = {function(model) 
        model = model:gsub("\\", "/")
        updmdl(model)
	end, function()
		client.color_log(220, 50, 50, "setmodel <model> - sets your panorama model")
	end},
	["setvideo"] = {function(video)
		video = video:gsub(".wav", "")
		UpdateVid(video)
	end, function()
		client.color_log(220, 50, 50, "setvideo <path/video> - sets your panorama video")
	end}
}


local len = 8

client.set_event_callback("console_input", function(cmd)
    if curcmd[cmd:sub(1, len)] then
        if cmd:len() > len+1 then
        	local args = cmd:sub(len+2, -1)
            curcmd[cmd:sub(1, len)][1](args)
        else
            curcmd[cmd:sub(1, len)][2]()
        end
        return true
    end
end)

