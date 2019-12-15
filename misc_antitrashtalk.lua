local exec = client.exec
local userid_to_entindex = client.userid_to_entindex
local get_player_name = entity.get_player_name
local get_local_player = entity.get_local_player
local is_enemy = entity.is_enemy
local console_cmd = client.exec
local ui_get = ui.get
local time = globals.curtime
local gays = {}

local alt_antitrashtalk = ui.new_checkbox("Misc", "Settings", "Anti trashtalk")

local phrases = {}
phrases.trashtalk = {"what?", "who?", "where?"}
phrases.killsays = {"shut up", "nice killsay LOL", "nice baim", "you sell?", "2good 2write urself"}

local function player_to_tbl(e)
    if not ui_get(alt_antitrashtalk) then
      return
    end

    local victim_userid, attacker_userid = e.userid, e.attacker
    if not victim_userid or not attacker_userid then 
    	return
    end
    local victim_entindex, attacker_entindex = userid_to_entindex(victim_userid), userid_to_entindex(attacker_userid)
    if victim_entindex ~= get_local_player() then 
    	return 
    end
    gays[attacker_entindex] = time() + 1
end

local function reset_tbl()
	gays = {}
end


local function hook_say(e)
	local lp = get_local_player()
	local myname = get_player_name(lp)
	local text, userid = e.text, e.userid
	local gay = userid_to_entindex(userid)
	if gay == lp then 
		return
	end
	local guyname = get_player_name(gay)
	local t
	if gays[gay] and gays[gay] > time() then
		t = phrases.killsays[math.random(#phrases.killsays)]
		console_cmd("say " .. t)
	elseif text:find(myname) then
		t = phrases.trashtalk[math.random(#phrases.trashtalk)]
		console_cmd("say " .. t)
	end
end

client.set_event_callback("player_death", player_to_tbl)
client.set_event_callback("player_say", hook_say)

client.set_event_callback("round_start", reset_tbl)
client.set_event_callback("player_connect_full", reset_tbl)


