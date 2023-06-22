/*
*	 Black Ops 2 - GSC Studio by iMCSx
*
*	 Creator : A
*	 Project : ZSND
*    Mode : Zombies
*	 Date : 2016/06/05 - 23:53:13	
*
*/	

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_spectating;
init()
{
	InitializeAesthetics();
    level thread onPlayerConnect();
    level.gts = "SEARCH AND DESTROY";
    precacheString(level.gts);
    level._get_game_module_players = undefined;
    level.zombie_team = "team3";
    level.teambased = true;
    level.overrideplayerdeathwatchtimer = undefined;
    precacheshader("damage_feedback");
    precacheshader("menu_zm_popup");
    precacheshader("white");
    precacheshader("gradient_center");
    precacheshader("ui_sliderbutt_1");
    precacheshader("circle");
    precacheshader("menu_zm_background_main");
    precacheshader("waypoint_revive");
    precacheshader("menu_zm_background_main");
    precacheModel("test_sphere_silver");
    precacheshader("specialty_instakill_zombies");
    setdvar( "player_meleeDamageMultiplier", 1 );
    setDvar("tu3_canSetDvars", "1");
	setDvar("g_friendlyfireDist", "0");
	setDvar("allClientDvarsEnabled", "1");
	setDvar("party_gameStartTimerLength", "1");
	setDvar("party_gameStartTimerLengthPrivate", "1");
	setDvar("bg_viewKickScale", "0.0001");
	setdvar( "scr_disable_weapondrop", 0 );
	if( getDvar("party_connectToOthers") == "1" )
		level.nomatchoverride = true;
	level.killcamlength = 5;
	level.zombie_vars["riotshield_hit_points"]= 25000;
	setDvar("party_connectToOthers", "0");
    setDvar("partyMigrate_disabled", "1");
    setDvar("party_mergingEnabled", "0");
	flag_set( "sq_minigame_active" );
	level.zombie_vars["riotshield_gib_damage"]= 99999;
	level.zombie_vars["riotshield_knockdown_damage"]= 99999;
	level.player_out_of_playable_area_monitor = 0;
	level.player_too_many_weapons_monitor = 0;
    level.player_intersection_tracker_override = ::_zm_arena_intersection_override;
	level.player_too_many_players_check = 0;
	level.player_out_of_playable_area_monitor = 0;
	level.player_too_many_players_check_func = ::player_too_many_players_check;
	level.is_player_in_screecher_zone = ::_zm_arena_false_function;
	level.screecher_should_runaway = ::_zm_arena_true_function;
	level.custom_spectate_permissions = setspectatepermissionsgrief();
	kc_init();
	level.callbackplayerlaststand = ::callback_playerkilled;
}

player_too_many_players_check()
{

}
_zm_arena_intersection_override( player )
{
	self waittill("forever");
	return 0;
}

_zm_arena_false_function( player )
{
	return false;
}
_zm_arena_true_function( player )
{
	return true;
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
        player thread onDisconnectMipMapFix();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
	self.has_zsndbomb = 0;
	if( self isHost() )
	{
		level.cText = level createServerFontString("default", 1.7);
		level.cText setPoint("LEFT", "TOP", -380, 70);
		level.cText.color = (1,.5,0);
		level.cText.alpha = 0;
		level.cText.glowColor = (0,0,0);
		level.cText.glowAlpha = 0;
		level.cText.sort = 999;
		level.cText setText("SEARCH AND DESTROY");
		level.cText.foreground = true;
		level.cText.hideWhenInMenu = false;
		level.cText.archived = true;
		level.zsnd_readyplayers = 0;
		level.zsnd_lastround = false;
	}
	self waittill("spawned_player");
	self.kill_streak = 0;
	if( self isHost() )
	{
		level.cText fadeovertime( .75 );
		level.cText.alpha = 1;
		level thread GameEngine();
	}
    for(;;)
    {
        self waittill("spawned_player");
        self thread ZSNDRespawned();
    }
}

onDisconnectMipMapFix()
{
	level endon("end_game");
	self waittill("disconnect");
	wait 1.5;
	foreach( player in level.players )
		player.playershaders[ self.name ] destroy();
}










