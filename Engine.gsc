/*
	TODO
	0: Fix scoreboard
	
	setdvar("scr_game_rankenabled", 1);
*/

GameEngine()
{
	flag_wait( "start_zombie_round_logic" );
	level.zsnd_round_started = 0;
	level.zsnd_readyplayers = 0;
	level.zsnd_bomb_detonated = 0;
	level.zsnd_bomb_defused = 0;
	level.roundEndKilling = 0;
	if( getDvar("mapname") == "zm_prison" )
	{
		bool = false;
		b_everyone_alive = 0;
		while ( isDefined( b_everyone_alive ) && !b_everyone_alive )
		{
			b_everyone_alive = 1;
			a_players = getplayers();
			_a192 = a_players;
			_k192 = getFirstArrayKey( _a192 );
			while ( isDefined( _k192 ) )
			{
				player = _a192[ _k192 ];
				if ( isDefined( player.afterlife ) && player.afterlife )
				{
					b_everyone_alive = 0;
					wait 0.05;
					break;
				}
				else
				{
					_k192 = getNextArrayKey( _a192, _k192 );
				}
			}
		}
		wait 3;
		foreach( player in level.players )
		{
			player.lives = 0;
			player.pers["lives"] = 0;
			player setclientfieldtoplayer( "player_lives", player.lives );
			player notify( "stop_player_out_of_playable_area_monitor" );
		}
	}
	foreach( player in level.players)
		player EnableInvulnerability();
	level.CLoaderScreen = newHudElem();
	level.CLoaderScreen.elemtype = "icon";
    level.CLoaderScreen.color = (0,0,0);
    level.CLoaderScreen.alpha = 1;
    level.CLoaderScreen.sort = 9;
    level.CLoaderScreen.foreground = 0;
    level.CLoaderScreen.children = [];
	level.CLoaderScreen setParent(level.uiParent);
    level.CLoaderScreen setShader("white", 900, 500);
	level.CLoaderScreen setPoint("CENTER", "CENTER", 0, 0);
	level.CLoaderScreen.hideWhenInMenu = false;
	level.CLoaderScreen.archived = true;
	level.cText ChangeFontScaleOverTime( 1.2 );
	level.cText.fontScale = 2.5;
	level.cText MoveOverTime( 1.2);
	level.cText.Y -= 50;
	level.zombie_ghost_round_states.is_first_ghost_round_finished = 1;
	level.force_ghost_round_start = undefined;
	level.zombie_ghost_round_states.next_ghost_round_number = 999;
	level.zombie_ghost_round_states.current_ghost_round_number = 998;
	level endon("end_game");
	setscoreboardcolumns( "score", "kills", "downs", "", "");
	if(!isDefined(level.nomatchoverride))
		setmatchflag( "disableIngameMenu", 1 );
	AssignTeams();
	setmatchtalkflag( "DeadChatWithDead", 1 );
	setmatchtalkflag( "DeadChatWithTeam", 0 );
	setmatchtalkflag( "DeadHearTeamLiving", 0 );
	setmatchtalkflag( "DeadHearAllLiving", 0 );
	setmatchtalkflag( "EveryoneHearsEveryone", 0 );
	setmatchtalkflag( "DeadHearKiller", 0 );
	setmatchtalkflag( "KillersHearVictim", 0 );
	setmatchflag( "final_killcam", 0 );
	setmatchflag( "round_end_killcam", 0 );
	level.zombie_vars["spectators_respawn"] = 0;
	setDvar("player_lastStandBleedoutTime", 1);
	level.zombie_vars[ "penalty_no_revive" ] = 0;
	level.zombie_vars[ "penalty_died" ] = 0;
	level.zombie_vars[ "penalty_downed" ] = .05;
	level.brutus_spawners = undefined;
	level.no_end_game_check = true;
	level.player_friendly_fire_callbacks = undefined;
	_zm_arena_openalldoors();
	foreach( door in getentarray( "afterlife_door", "script_noteworthy" ))
	{
		door thread maps/mp/zombies/_zm_blockers::door_opened( 0 );
		wait .005;
	}
	foreach( debri in getentarray( "zombie_debris", "targetname" ))
	{
		debri.zombie_cost = 0;
		debri notify( "trigger", level.players[0], 1 ); 
		wait .005;
	}
	level.zsnd_intermission = true;
	level.players[0] iprintln("");
	level.zsnd_bomb_planted = 0;
	n_between_round_time = level.zombie_vars[ "zombie_between_round_time" ];
	level.zombie_vars[ "zombie_new_runner_interval" ] = 3;
	level.zombie_ai_limit = 52;
	level.zombie_vars[ "zombie_max_ai" ] = 52;
	level.zombie_vars[ "zombie_move_speed_multiplier" ] = 180;
	level.zombie_vars[ "zombie_between_round_time" ] = 0.01;
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.1;
	level.zombie_actor_limit = 5;
	target = 5;
	level.time_bomb_round_change = 1;
	level.zombie_round_start_delay = 0;
	level.zombie_round_end_delay = 0;
	level._time_bomb.round_initialized = 1;
	n_between_round_time = level.zombie_vars[ "zombie_between_round_time" ];
	level notify( "end_of_round" );
	flag_set( "end_round_wait" );
	maps/mp/zombies/_zm::ai_calculate_health( target );
	if ( level._time_bomb.round_initialized )
	{
		level._time_bomb.restoring_initialized_round = 1;
		target--;
	}
	level.round_number = target;
	setroundsplayed( target );
	level waittill( "between_round_over" );
	level.zombie_round_start_delay = undefined;
	level.time_bomb_round_change = undefined;
	flag_clear( "end_round_wait" );
	level.round_number = 5;
	level.players[0] iprintln("");
	setDvar("g_ai","0");
	level.players[0] iprintln("");
	level thread z_snd_intro();
	level.zsnd_intialized = false;
	foreach( player in level.players )
	{
		player thread ZSNDRespawned();
	}
	level.Allies_Rounds = 0;
	level.Axis_Rounds = 0;
	TotalRounds = 0;
	level.zsnd_timer_over = true;
	level thread zsnd_timer();
	level.players[0] iprintln("");
	while( level.Allies_Rounds < 4 && level.Axis_Rounds < 4 )
	{
		setmatchtalkflag( "DeadChatWithDead", 1 );
		setmatchtalkflag( "DeadChatWithTeam", 0 );
		setmatchtalkflag( "DeadHearTeamLiving", 0 );
		setmatchtalkflag( "DeadHearAllLiving", 0 );
		setmatchtalkflag( "EveryoneHearsEveryone", 0 );
		setmatchtalkflag( "DeadHearKiller", 0 );
		setmatchtalkflag( "KillersHearVictim", 0 );
		setmatchflag( "final_killcam", 0 );
		setmatchflag( "round_end_killcam", 0 );
		level thread dofinalkillcam();
		level.zsnd_round_started = 0;
		level.zsnd_readyplayers = 0;
		level.zsnd_bomb_detonated = 0;
		level.zsnd_bomb_defused = 0;
		level.zsnd_bomb_planted = 0;
		level.infinalkillcam = 0;
		level.zsnd_timeleft = 180;
		setslowmotion( 0.25, 1, 1 );
		GameObjectsInitialize();
		level.zsnd_intialized = true;
		level.zsnd_intermission = false;
		foreach( player in level.players )
		{
			player thread ZSNDRespawned();
			player notify("end_killcam");
		}
		while( (level.zsnd_readyplayers / level.players.size) < .5 )
			wait .25;
		setDvar("g_ai","0");
		DoRoundCountdown();
		setDvar("g_ai","1");
		if( getDvar( "mapname" ) == "zm_prison" )
		{
			foreach( player in level.players )
			{
				player.lives = 0;
				player.pers["lives"] = 0;
				player setclientfieldtoplayer( "player_lives", player.lives );
			}
		}
		level.zsnd_timer_over = false;
		GiveRandomAxisPlayerABomb();
		foreach( player in level.players )
		{
			player notify("ZSND_round_start");
		}
		level.zsnd_round_started  = 1;
		while( !(level.zsnd_bomb_detonated || level.zsnd_bomb_defused) && GetAlliesCount() > 0 && level.zsnd_timeleft > 0)
		{
			if( GetAxisCount() < 1 && !level.zsnd_bomb_planted )
				break;
			wait 1;
		}
		setmatchtalkflag( "EveryoneHearsEveryone", 1 );
		level notify("zSND_ROUND_COMPLETE");
		level.zsnd_timer_over = true;
		level.zsnd_intermission = true;
		setDvar("g_ai","0");
		GameObjectsCleanUp();
		wait .01;
		if( level.zsnd_bomb_detonated || GetAlliesCount() < 1 )
			WinnersAre( "axis" );
		else
			WinnersAre( "allies" );
		TotalRounds++;
		if( TotalRounds == 3 || TotalRounds == 6 )
		{
			oldscore = level.Axis_Rounds;
			level.Axis_Rounds = level.Allies_Rounds;
			level.Allies_Rounds = oldscore;
			foreach( player in level.players)
			{
				player SetTeam( (player.sessionteam == "allies") ? "axis" : "allies" );
				player.team = (player.sessionteam == "allies")  ? "axis" : "allies";
				player.pers["team"] = (player.sessionteam == "allies")  ? "axis" : "allies";
				player._encounters_team = (player.sessionteam == "allies") ? "axis" : "allies";
				player._team_name = (player.sessionteam == "allies") ? &"ZOMBIE_RACE_TEAM_1" : &"ZOMBIE_RACE_TEAM_2";
				player.sessionteam = (player.sessionteam == "allies")  ? "axis" : "allies";
				player notify( "joined_team" );
				level notify( "joined_team" );
			}
		}
	}
	setslowmotion( 0.25, 1, 1 );
	if( level.Allies_Rounds > 3 )
	{
		foreach( player in level.players )
			player.scoresText = player drawText( ("YOU "+( (player.sessionteam == "allies") ? "WON" : "LOST")), "default", 2, "CENTER", "TOP", 0, 25, ((player.sessionteam == "allies") ? (0,1,0) : (1,0,0)), 1, (0,0,0), 0, 9 );
	}
	else
	{
		foreach( player in level.players )
			player.scoresText = player drawText( ("YOU "+( (player.sessionteam == "axis") ? "WON" : "LOST")), "default", 2, "CENTER", "TOP", 0, 25, ((player.sessionteam == "axis") ? (0,1,0) : (1,0,0)), 1, (0,0,0), 0, 9 );
	}
	foreach( player in level.players )
		player thread playerGiveShotguns();
	wait 4;
	level notify("end_game");
}
GetTeamCount( team )
{
	count = 0;
	foreach( player in level.players )
		if( player.sessionteam == team )
			count++;
	return 0;
}
GetAxisCount()
{
	count = 0;
	foreach( player in level.players )
		if( player.sessionteam == "axis" && player.sessionstate != "spectator" && player.sessionstate != "dead" )
			count++;
	return count;
}

GetAlliesCount()
{
	count = 0;
	foreach( player in level.players )
		if( player.sessionteam == "allies" && player.sessionstate != "spectator"  && player.sessionstate != "dead" )
			count++;
	return count;
} 

WinnersAre( team )
{
	level.finalkillcam_winner = team;
	setDvar("g_ai","0");
	level.roundEndKilling = true;
	foreach( player in level.players )
		if( player.sessionstate != "spectator" )
		{
			player EnableInvulnerability();
			player freezecontrols( 1 );
		}
	if( team == "allies" )
		level.Allies_Rounds++;
	else
		level.Axis_Rounds++;
	if( team == "allies" )
		level.winnerText = level drawText( "Defenders win" , "default", 2, "CENTER", "TOP", 0, 0, (1,1,0), 1, (0,0,0), 0, 9);
	else
		level.winnerText = level drawText( "Attackers win", "default", 2, "CENTER", "TOP", 0, 0, (1,1,0), 1, (0,0,0), 0, 9);

		level.scoresText = level drawText( ("Defenders: "+level.Allies_Rounds+" | Attackers: "+level.Axis_Rounds), "default", 2, "CENTER", "TOP", 0, 25, (1,1,1), 1, (0,0,0), 0, 9 );
	if( level.Allies_Rounds >= 4 || level.Axis_Rounds >= 4 )
	{
		level.zsnd_lastround = true;
	}
	postroundfinalkillcam();
	wait 2;
	foreach( team1 in level.teams )
		clearfinalkillcamteam( team1 );
	level.roundEndKilling = false;
	level.winnerText destroy();
	level.scoresText destroy();
}

ZSNDRespawned()
{
	self notify("zns_rsp");
	self endon("zns_rsp");
	while( level.zsnd_intermission || level.infinalkillcam )
		wait .25;
	self.has_zsndbomb = false;
	while( !level.zsnd_intialized )
		wait .25;
	if ( self.sessionstate == "spectator" )
	{
		if ( isDefined( self.spectate_hud ) )
			self.spectate_hud destroy();
		self [[ level.spawnplayer ]]();
	}
	while( self.sessionstate == "spectator" )
		wait 1;
	self endkillcam( 0 );
	self notify( "end_killcam" );
	self setclientthirdperson( 0 );
	self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
	self DisableInvulnerability();
	self freezecontrols( 0 );
	if( isDefined( self.bombhud ) )
		self.bombhud destroy();
	if( self.sessionteam == "axis" )
		self.characterindex = 0;
	else
		self.characterindex = 1;
	self givecustomcharacters_zsnd();
	self setclientminiscoreboardhide( 1 );
	self thread ShowTeamText();
	self disableweapons();
	SpawnMeInCorrectSpot();
	ClassSelectionScreen();
	self thread OnShotPingRadar();
	self thread waitforplayeractions();
	self thread DamageMonitorFromPlayers();
	self EnableAimAssist();
	cleanOldMiniMap();
	self thread ZMiniMap();
	self.magic_bullet_shield = false;
	self notify( "pers_flopper_lost" );
	self.pers_num_flopper_damages = 0;
	self notify( "stop_player_too_many_weapons_monitor" );
	self notify( "stop_player_out_of_playable_area_monitor" );
	self.lives = 0;
	self.no_revive_trigger = true;
	self waittill("ZSND_round_start");
	self enableweapons();
	self unlink();
	self.stopperobj delete();
	self.maxhealth = 800;
	self.health = 800;
	while( !isDefined( self.laststand ) || !self.laststand )
		wait .25;
	self.laststand = false;
	self.kill_streak = 0;
	if( isDefined(self.lastAttacker))
    {
    	if( self.lastAttacker != self )
    		self.lastAttacker notify("ZSND_ACTION", "KILL", 1500);
    	self thread KillFeed( self.lastAttacker.name );
    	self.lastAttacker = undefined;
    }
    else
    	self thread KillFeed( "Zombies" );
	while( self.sessionstate != "spectator" )
		wait 1;
	foreach( player in level.players )
		player.playershaders[ self.name ] destroy();
	self.dead_from_snd = true;
	self waittill("ZSND_round_switched");
	if ( self.sessionstate == "spectator" )
	{
		if ( isDefined( self.spectate_hud ) )
			self.spectate_hud destroy();
		self [[ level.spawnplayer ]]();
	}
}

DamageMonitorFromPlayers()
{
	self notify("NewZDMonitor");
	self endon("NewZDMonitor");
	wep = undefined;
	while( 1 )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if( isPlayer( attacker ) )
		{
			self.lastAttacker = attacker;
			wep = attacker getcurrentweapon();
			if( wep == "ray_gun_zm" )
			{
				self dodamage( amount * 2, self.origin, attacker);
			}
			if( wep == "slipgun_zm" )
			{
				self dodamage( amount * 5, self.origin, attacker);
			}
			if( wep == "raygun_mark2_zm" )
			{
				self dodamage( amount , self.origin, attacker);
			}
			if( level.script == "zm_prison" && mod == "MOD_GRENADE" && isDefined(attacker.current_tomahawk_weapon) && attacker.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
			{
				self dodamage( amount * 999, self.origin, attacker );
			}
			if( wep == "alcatraz_shield_zm" || wep == "riotshield_zm" || wep == "tomb_shield_zm")
			{
				self dodamage( 200, self.origin, attacker );
			}
			if( self.health <= 1 )
				attacker notify("ZSND_ACTION", "DEATHHITMARKER", 1500);
			else
				attacker notify("ZSND_ACTION", "HITMARKER", 1500);
		}
	}
}

waitforplayeractions()
{
	self notify("newactionmonitor");
	self endon("newactionmonitor");
	self.hitmarker destroy();
	self.hitmarker = newDamageIndicatorHudElem(self);
	self.hitmarker.horzAlign = "center";
	self.hitmarker.vertAlign = "middle";
	self.hitmarker.x = -12;
	self.hitmarker.y = -12;
	self.hitmarker.alpha = 0;
	self.hitmarker setShader("damage_feedback", 24, 48);
	self.hitsoundtracker = 1;
	self.kill_streak = 0;
	while( 1 )
	{
		self waittill("ZSND_ACTION", action, value );
		if( action == "KILL" )
		{
			self.kill_streak++;
			self notify( self.kill_streak + "_ks_achieved" );
			if(  self.kill_streak > 10 )
				self thread KillStreak();
		}
		if( action == "HITMARKER" )
		{
			self whitemarker();
		}
		if( action == "DEATHHITMARKER" )
		{
			self redmarker();
		}
		
	}
}

redmarker()
{
	self notify("red_override");
	self thread playhitsound( mod, "mpl_hit_alert" );
	self.hitmarker.alpha = 1;
	self.hitmarker.color = (1,0,0);
	self.hitmarker fadeOverTime(.5);
	self.hitmarker.color = (1,1,1);
	self.hitmarker.alpha = 0;
}
whitemarker()
{
	self endon("red_override");
	self thread playhitsound( mod, "mpl_hit_alert" );
	self.hitmarker.alpha = 1;
	self.hitmarker fadeOverTime(.5);
	self.hitmarker.alpha = 0;
}

playhitsound( mod, alert )
{
	self endon( "disconnect" );
	if ( self.hitsoundtracker )
	{
		self.hitsoundtracker = 0;
		self playlocalsound( alert );
		wait 0.05;
		self.hitsoundtracker = 1;
	}
}

AssignTeams()
{
	j = randomintrange(0,2);
	possible = array_copy( level.players );
	possible = array_randomize( possible );
	for(i = 0; i < possible.size; i++ )
	{
		j = !j;
		possible[i] SetTeam( j ? "axis" : "allies" );
		possible[i].team = j ? "axis" : "allies";
		possible[i].pers["team"] = j ? "axis" : "allies";
		possible[i].sessionteam = j ? "axis" : "allies";
		possible[i]._encounters_team = j ? "axis" : "allies";
		possible[i]._team_name = j ? &"ZOMBIE_RACE_TEAM_1" : &"ZOMBIE_RACE_TEAM_2";
		possible[i] notify( "joined_team" );
		level notify( "joined_team" );
	}
}

setspectatepermissionsgrief()
{
	self allowspectateteam( "allies", 1 );
	self allowspectateteam( "axis", 1 );
	self allowspectateteam( "freelook", 0 );
	self allowspectateteam( "none", 1 );
}

ClassSelectionScreen()
{
	self endon("zns_rsp");
	self.pickedclass = false;
	self.stopperobj = spawn( "script_origin", self.origin, 1 );
	self playerlinkto( self.stopperobj, undefined );
	self freezecontrols( 0 );
	self.classOptionsBG destroy();
	self.classOption0 destroy();
	self.classOptions[0] destroy();
	self.classOptions[1] destroy();
	self.classOptions[2] destroy();
	self.classOptions[3] destroy();
	self.classOptions[4] destroy();
	self.classOptions[5] destroy();
	self.classOptions[6] destroy();
	self.classOptions[7] destroy();
	self.classOptions[8] destroy();
	self.classOptions[9] destroy();
	self.cco_Primary_slot destroy();
	self.cco_Secondary_slot destroy();
	self.cco_Lethal_slot destroy();
	self.cco_Melee_slot destroy();
	self.cco_Tactical_slot destroy();
	self.classOptions = [];
	self.classOption0 = drawText("[{+gostand}] Select\t[{+actionslot 1}] Scroll Up\t[{+actionslot 2}] Scroll Down", "default", 1.25, "CENTER", "BOTTOM", 0, 0, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[0] = drawText("SMG", "default", 1.75, "LEFT", "TOP", -350, 75, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[1] = drawText("Sniper", "default", 1.75, "LEFT", "TOP", -350, 100, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[2] = drawText("Raygun", "default", 1.75, "LEFT", "TOP", -350, 125, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[3] = drawText("Shotgun", "default", 1.75, "LEFT", "TOP", -350, 150, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[4] = drawText("Specialist", "default", 1.75, "LEFT", "TOP", -350, 175, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[5] = drawText("Ninja", "default", 1.75, "LEFT", "TOP", -350, 200, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[6] = drawText("Trickshotter", "default", 1.75, "LEFT", "TOP", -350, 225, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[7] = drawText("Support", "default", 1.75, "LEFT", "TOP", -350, 250, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[8] = drawText("Pistol Beast", "default", 1.75, "LEFT", "TOP", -350, 275, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptions[9] = drawText("Specialist 2", "default", 1.75, "LEFT", "TOP", -350, 300, (1,1,1), 1, (0,0,0), 0, 1);
	self.classOptionsBG = createShader("white", "CENTER", "CENTER", 0, 0, 900, 500, (0,0,0), .8, 0);
	self setblur(4,0.1);
	sclass = 0;
	self enableweaponcycling();
	self.classOptions[ sclass ].color = (1,.5,0);
	UpdateCCItemsInventory( sclass );
	while( !level.zsnd_round_started  && !self.pickedclass )
	{
		if( self jumpbuttonpressed() )
		{
			self SelectClass( sclass );
		}
		else if( self actionslotonebuttonpressed() )
		{
			self.classOptions[ sclass ].color = (1,1,1);
			sclass--;
			if( sclass < 0 )
				sclass = 9;
			self.classOptions[ sclass ].color = (1,.5,0);
			UpdateCCItemsInventory( sclass );
			while( self actionslotonebuttonpressed())
				wait .05;
		}
		else if( self actionslottwobuttonpressed() )
		{
			self.classOptions[ sclass ].color = (1,1,1);
			sclass++;
			if( sclass > 9 )
				sclass = 0;
			self.classOptions[ sclass ].color = (1,.5,0);
			UpdateCCItemsInventory( sclass );
			while( self actionslottwobuttonpressed() && !level.zsnd_round_started && !self.pickedclass)
				wait .05;
		}
		wait .05;
	}
	self.classOption0 destroy();
	self.classOptions[0] destroy();
	self.classOptions[1] destroy();
	self.classOptions[2] destroy();
	self.classOptions[3] destroy();
	self.classOptions[4] destroy();
	self.classOptions[5] destroy();
	self.classOptions[6] destroy();
	self.classOptions[7] destroy();
	self.classOptions[8] destroy();
	self.classOptions[9] destroy();
	self.classOptionsBG destroy();
	self.cco_Primary_slot destroy();
	self.cco_Secondary_slot destroy();
	self.cco_Lethal_slot destroy();
	self.cco_Melee_slot destroy();
	self.cco_Tactical_slot destroy();
	level.zsnd_readyplayers++;
	self setblur(0,0.1);
	if( ! self.pickedclass )
		self dodamage( 999, self.origin);
}

SelectClass( class )
{
	perks = undefined;
	self.ignoreme = false;
	self takeallweapons();
	self setclientuivisibilityflag( "hud_visible", 0 );
	perks = strtok("specialty_additionalprimaryweapon,specialty_armorpiercing,specialty_armorvest,specialty_bulletaccuracy,specialty_bulletdamage,specialty_bulletflinch,specialty_bulletpenetration,specialty_deadshot,specialty_delayexplosive,specialty_detectexplosive,specialty_disarmexplosive,specialty_earnmoremomentum,specialty_explosivedamage,specialty_extraammo,specialty_fallheight,specialty_fastads,specialty_fastequipmentuse,specialty_fastladderclimb,specialty_fastmantle,specialty_fastmeleerecovery,specialty_fastreload,specialty_fasttoss,specialty_fastweaponswitch,specialty_finalstand,specialty_fireproof,specialty_flakjacket,specialty_flashprotection,specialty_gpsjammer,specialty_grenadepulldeath,specialty_healthregen,specialty_holdbreath,specialty_immunecounteruav,specialty_immuneemp,specialty_immunemms,specialty_immunenvthermal,specialty_immunerangefinder,specialty_killstreak,specialty_longersprint,specialty_loudenemies,specialty_marksman,specialty_movefaster,specialty_nomotionsensor,specialty_noname,specialty_nottargetedbyairsupport,specialty_nokillstreakreticle,specialty_nottargettedbysentry,specialty_pin_back,specialty_pistoldeath,specialty_proximityprotection,specialty_quickrevive,specialty_quieter,specialty_reconnaissance,specialty_rof,specialty_scavenger,specialty_showenemyequipment,specialty_stunprotection,specialty_shellshock,specialty_sprintrecovery,specialty_showonradar,specialty_stalker,specialty_twogrenades,specialty_twoprimaries,specialty_unlimitedsprint", ",");
	foreach( perk in perks )
		self unsetperk( perk );
	if( class == 0 )
	{
		if( getdvar("mapname") == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else
		{
			self giveweapon("tazer_knuckles_zm");
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "cymbal_monkey_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "fiveseven_zm", 0, 0 );
		if( getDvar("mapname") == "zm_highrise" || getDvar("mapname") == "zm_buried" )
			self maps/mp/zombies/_zm_weapons::weapon_give( "pdw57_zm", 0, 0 );
		else if( getDvar("mapname") == "zm_tomb" )
			self maps/mp/zombies/_zm_weapons::weapon_give( "thompson_zm", 0, 0 );
		else
			self maps/mp/zombies/_zm_weapons::weapon_give( "mp5k_zm", 0, 0 );
		perks = strtok("specialty_unlimitedsprint,specialty_sprintrecovery,specialty_rof,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fasttoss,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_extraammo,specialty_armorvest,specialty_bulletflinch",",");
	}
	if( class == 2 )
	{
		if( getdvar("mapname") == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else
		{
			self giveweapon("tazer_knuckles_zm");
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "knife_ballistic_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "ray_gun_zm", 0, 0 );
		self switchtoweapon("ray_gun_zm");
		perks = strtok("specialty_unlimitedsprint,specialty_stalker,specialty_rof,specialty_quieter,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fastreload,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_armorvest,specialty_bulletflinch",",");
	}
	if( class == 1 )
	{
		if( getdvar("mapname") == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else
		{
			self giveweapon("tazer_knuckles_zm");
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "dsr50_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "fivesevendw_zm", 0, 0 );
		self switchtoweapon("dsr50_zm");
		perks = strtok("specialty_scavenger,specialty_reconnaissance,specialty_quieter,specialty_quickrevive,specialty_marksman,specialty_loudenemies,specialty_longersprint,specialty_holdbreath,specialty_gpsjammer,specialty_fastweaponswitch,specialty_fasttoss,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fallheight,specialty_deadshot,specialty_armorvest,specialty_armorpiercing,specialty_bulletaccuracy,specialty_bulletdamage,specialty_bulletpenetration",",");
	}
	if( class == 3 )
	{
		if( getdvar("mapname") == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else
		{
			self giveweapon("tazer_knuckles_zm");
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "m14_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "870mcs_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		perks = strtok("specialty_unlimitedsprint,specialty_stalker,specialty_rof,specialty_quieter,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fastreload,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_armorvest,specialty_bulletflinch",",");
	}
	if( class == 4 )
	{
		if( level.script == "zm_transit" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "riotshield_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "sticky_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "m1911_zm", 0, 0 );
			self switchtoweapon("riotshield_zm");
		}
		if( level.script == "zm_nuked" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "sticky_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "m1911_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "raygun_mark2_zm", 0, 0 );
			self switchtoweapon( "raygun_mark2_zm" );
		}
		if( level.script == "zm_highrise" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "sticky_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "slipgun_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "equip_springpad_zm", 0, 0 );
			self switchtoweapon( "slipgun_zm" );
			self thread DieRiseSpecialistWeapon();
		}
		if( level.script == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "m1911_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "alcatraz_shield_zm", 0, 0 );
			flag_set("soul_catchers_charged");
			level notify( "bouncing_tomahawk_zm_aquired" );
			self notify( "tomahawk_picked_up" );
			self notify( "player_obtained_tomahawk" );
			self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
			self setclientfieldtoplayer( "tomahawk_in_use", 1 );
			self setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
			self.loadout.hastomahawk = 1;
			self maps/mp/zombies/_zm_weapons::weapon_give( "upgraded_tomahawk_zm",0,0 );
			self notify( "new_tactical_grenade" );
			self.current_tactical_grenade = self.current_tomahawk_weapon;
			self switchtoweapon( "alcatraz_shield_zm" );
		}
		if( level.script == "zm_buried" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "rnma_zm", 0, 0 );
			self thread BuriedSpecialistWeapon();
		}
		if( level.script == "zm_tomb" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "c96_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "tomb_shield_zm", 0, 0 );
			self switchtoweapon( "tomb_shield_zm" );
		}
		perks = strtok("specialty_unlimitedsprint,specialty_stalker,specialty_rof,specialty_quieter,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fastreload,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_armorvest,specialty_bulletflinch",",");
	}
	if( class == 5 )
	{
		if( level.script == "zm_prison")
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else if( level.script == "zm_tomb" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "staff_lightning_melee_zm", 0, 0 );
		}
		else
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
		}
		self.ignoreme = true;
		perks = strtok("specialty_unlimitedsprint,specialty_stalker,specialty_rof,specialty_quieter,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fastreload,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_armorvest,specialty_bulletflinch,specialty_movefaster",",");
		self setMoveSpeedScale( 1.25 );
	}
	if( class == 6 )
	{
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "sticky_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "knife_zm", 0, 0 );
		if( level.script != "zm_tomb" )
			self maps/mp/zombies/_zm_weapons::weapon_give( "rottweil72_zm", 0, 0 );
		else
			self maps/mp/zombies/_zm_weapons::weapon_give( "ksg_zm", 0, 0 );
		if( level.script == "zm_prison" )
		{
			flag_set("soul_catchers_charged");
			level notify( "bouncing_tomahawk_zm_aquired" );
			self notify( "tomahawk_picked_up" );
			self notify( "player_obtained_tomahawk" );
			self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
			self setclientfieldtoplayer( "tomahawk_in_use", 1 );
			self setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
			self.loadout.hastomahawk = 1;
			self maps/mp/zombies/_zm_weapons::weapon_give( "upgraded_tomahawk_zm",0,0 );
			self notify( "new_tactical_grenade" );
			self.current_tactical_grenade = self.current_tomahawk_weapon;
		}
		else
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "cymbal_monkey_zm", 0, 0 );
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "dsr50_zm", 0, 0 );
		self switchtoweapon( "dsr50_zm" );
		perks = strtok("specialty_additionalprimaryweapon,specialty_armorpiercing,specialty_bulletdamage,specialty_bulletflinch,specialty_bulletpenetration,specialty_delayexplosive,specialty_detectexplosive,specialty_disarmexplosive,specialty_extraammo,specialty_fallheight,specialty_fastequipmentuse,specialty_fastladderclimb,specialty_fastmantle,specialty_fastmeleerecovery,specialty_fastreload,specialty_fasttoss,specialty_fastweaponswitch,specialty_flashprotection,specialty_immunecounteruav,specialty_immuneemp,specialty_immunemms,specialty_immunenvthermal,specialty_immunerangefinder,specialty_longersprint,specialty_loudenemies,specialty_marksman,specialty_nomotionsensor,specialty_nottargetedbyairsupport,specialty_nokillstreakreticle,specialty_nottargettedbysentry,specialty_pin_back,specialty_proximityprotection,specialty_reconnaissance,specialty_rof,specialty_scavenger,specialty_showenemyequipment,specialty_stunprotection,specialty_sprintrecovery,specialty_twogrenades,specialty_twoprimaries,specialty_unlimitedsprint", ",");
	}
	if( class == 7 )
	{
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "claymore_zm", 0, 0 );
		if( level.script == "zm_tomb" )
			self maps/mp/zombies/_zm_weapons::weapon_give( "c96_zm", 0, 0 );
		else
			self maps/mp/zombies/_zm_weapons::weapon_give( "m1911_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "claymore_zm", 0, 0 );
		if( level.script != "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "hamr_zm", 0, 0 );
			self switchtoweapon( "hamr_zm" );
		}
		else
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "lsat_zm", 0, 0 );
			self switchtoweapon( "lsat_zm" );
		}
		perks = [];
	}
	if( class == 8 )
	{
		self maps/mp/zombies/_zm_weapons::weapon_give( "beretta93r_zm", 0, 0 );
		self maps/mp/zombies/_zm_weapons::weapon_give( "fivesevendw_zm", 0, 0 );
		if( getdvar("mapname") == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "spork_zm_alcatraz", 0, 0 );
		}
		else
		{
			self giveweapon("tazer_knuckles_zm");
		}
		self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
		self switchtoweapon( "beretta93r_zm" );
		perks = strtok("specialty_scavenger,specialty_reconnaissance,specialty_quieter,specialty_quickrevive,specialty_marksman,specialty_loudenemies,specialty_longersprint,specialty_holdbreath,specialty_gpsjammer,specialty_fastweaponswitch,specialty_fasttoss,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fallheight,specialty_deadshot,specialty_armorvest,specialty_armorpiercing,specialty_bulletaccuracy,specialty_bulletdamage,specialty_bulletpenetration",",");
	}
	if( class == 9 )
	{
		if( level.script == "zm_transit" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "python_zm", 0, 0 );
			self thread PythonSpecialistWeapon();
		}
		if( level.script == "zm_nuked" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "python_zm", 0, 0 );
			self thread PythonSpecialistWeapon();
		}
		if( level.script == "zm_highrise" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "bowie_knife_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "python_zm", 0, 0 );
			self thread PythonSpecialistWeapon();
		}
		if( level.script == "zm_prison" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "blundergat_zm", 0, 0 );
			self SetWeaponAmmoStock( "blundergat_zm", 8 );
			self switchtoweapon("blundergat_zm");
		}
		if( level.script == "zm_buried" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "cymbal_monkey_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			weap = maps/mp/zombies/_zm_weapons::get_base_name( "knife_ballistic_zm" );
			weapon = get_upgrade( weap );
			self giveweapon( weapon, 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
			self givestartammo( weapon );
			self switchtoweapon( weapon );
		}
		if( level.script == "zm_tomb" )
		{
			self maps/mp/zombies/_zm_weapons::weapon_give( "frag_grenade_zm", 0, 0 );
			self maps/mp/zombies/_zm_weapons::weapon_give( "python_zm", 0, 0 );
			self thread PythonSpecialistWeapon();
		}
		perks = strtok("specialty_unlimitedsprint,specialty_stalker,specialty_rof,specialty_quieter,specialty_quickrevive,specialty_loudenemies,specialty_longersprint,specialty_gpsjammer,specialty_fastreload,specialty_fastmeleerecovery,specialty_fastmantle,specialty_fastladderclimb,specialty_fastequipmentuse,specialty_fastads,specialty_fallheight,specialty_armorvest,specialty_bulletflinch",",");
	}
	self enableweaponcycling();
	self disableusability();
	foreach( perk in perks )
		self setperk( perk );
	self.pickedclass = true;
}

get_upgrade( weaponname )
{

	if ( isDefined( level.zombie_weapons[ weaponname ] ) && isDefined( level.zombie_weapons[ weaponname ].upgrade_name ) )
	{
		return maps/mp/zombies/_zm_weapons::get_upgrade_weapon( weaponname, 0 );
	}
	else
	{
		return maps/mp/zombies/_zm_weapons::get_upgrade_weapon( weaponname, 1 );

	}
}

DoRoundCountdown()
{
	level.roundcounter = drawValue(5, "objective", 2.0, "CENTER", "CENTER", 0, 0, (1,1,0), 1, (0,0,0), 0, 9);
	level thread IncrementRoundsBy5();
	for( i = 10; i > 0; i-- )
	{
		level.roundcounter setvalue( i );
		wait 1;
	}
	level.roundcounter destroy();
	foreach( player in level.players )
	{
		if( player.team == "axis" )
			player.objtextzsnd = player drawText("Eliminate enemy players or destroy the objective", "default", 1.5, "CENTER", "CENTER", 0, 0, (1,1,1), 1, (0,0,0), 0, 1);
		else
			player.objtextzsnd = player drawText("Protect the objective and eliminate enemy players", "default", 1.5, "CENTER", "CENTER", 0, 0, (1,1,1), 1, (0,0,0), 0, 1);
	}
	wait 3;
	foreach( player in level.players )
	{
		player.objtextzsnd destroy();
	}
}

_zm_arena_openalldoors()
{
	setdvar( "zombie_unlock_all", 1 );
	flag_set( "power_on" );
	players = get_players();
	zombie_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zombie_doors.size )
	{
		zombie_doors[ i ] notify( "trigger" );
		if ( is_true( zombie_doors[ i ].power_door_ignore_flag_wait ) )
		{
			zombie_doors[ i ] notify( "power_on" );
		}
		wait 0.05;
		i++;
	}
	zombie_airlock_doors = getentarray( "zombie_airlock_buy", "targetname" );
	i = 0;
	while ( i < zombie_airlock_doors.size )
	{
		zombie_airlock_doors[ i ] notify( "trigger" );
		wait 0.05;
		i++;
	}
	zombie_debris = getentarray( "zombie_debris", "targetname" );
	i = 0;
	while ( i < zombie_debris.size )
	{
		zombie_debris[ i ] notify("trigger");
		wait 0.05;
		i++;
	}
	level notify( "open_sesame" );
	wait 1;
	setdvar( "zombie_unlock_all", 0 );
}

z_snd_intro()
{
	level.CLoaderScreen fadeovertime(1);
	level.CLoaderScreen.alpha = 0;
	level.cText fadeovertime(1);
	level.cText.alpha = 0;
	wait 1;
	level.CLoaderScreen destroy();
	level.cText destroy();
	level.cText2 destroy();
}


KillFeed( killer )
{
	if( !isDefined( level.firstbloodkiller ) )
	{
		level.firstbloodkiller = killer;
		foreach( player in level.players )
			player iprintln( "^2"+killer + " got the first blood");
	}
	if( killer == "Zombie" )
	{
		foreach( player in level.players )
			player iprintln( self.name + " was mauled to death by zombies" );
		return;
	}
	else
		return;
	if( level.roundEndKilling )
		return;
	
	else if( isDefined(level.nukeActive) )
	{
		foreach( player in level.players )
			player iprintln("^1"+level.nukeActive+" nuked "+self.name);
	}
	else if( killer != self.name )
	{
		foreach( player in level.players)
			player iprintln( killer + " killed " + self.name );
	}
	else
	{
		foreach( player in level.players)
			player iprintln( self.name +" committed suicide" );
	}
}

KillStreak()
{
	foreach( player in level.players )
		player iprintlnbold( self.name + " is on a " + self.kill_streak + " killstreak!" );
}

zsnd_timer()
{
	level endon("end_game");
	level.sndtimerlabel = level drawText( "Time Remaining :", "default", 1.5, "LEFT", "BOTTOM", -375, -40, (1,1,1), 1, (0,0,0), 0, 9 );
	level.sndtimertext = drawValue(180, "default", 1.5, "LEFT", "BOTTOM", -275, -40, (1,1,1), 1, (0,0,0), 0, 9);
	while( 1 )
	{
		for(; level.zsnd_timeleft > 0; level.zsnd_timeleft--)
		{
			if( level.zsnd_timer_over ) break;
			level.sndtimertext SetValue( level.zsnd_timeleft );
			if( level.zsnd_bomb_planted )
			{
				foreach( player in level.players)
					player PlaySoundToPlayer( "uin_alert_lockon_start", player );
			}
			if( level.zsnd_timeleft < 10 && level.zsnd_bomb_planted )
			{
				wait .8;
				foreach( player in level.players)
					player PlaySoundToPlayer( "uin_alert_lockon_start", player );
				wait .2;
				foreach( player in level.players)
					player PlaySoundToPlayer( "uin_alert_lockon_start", player );
				wait .2;
			}
			else
			{
				wait 1;
			}
			
		}
		if( level.zsnd_bomb_planted && !level.zsnd_bomb_defused )
		{
			level.zsnd_bomb_detonated = true;
			if( level.zsnd_bomb_a.armed && level.zsnd_timeleft < 1 )
			{
				RadiusDamage( level.zsnd_bomb_a getorigin(), 500, 999,999, level.players[0] );
				level.zsnd_bomb_a playSound("zmb_phdflop_explo");
				level.zsnd_bomb_a playSound("zmb_phdflop_explo");
				if( level.script == "zm_tomb" || level.script == "zm_buried" )
					playfx(level._effect["divetonuke_groundhit"], level.zsnd_bomb_a getorigin());
				else
					playfx(loadfx("explosions/fx_default_explosion"), level.zsnd_bomb_a getorigin());
				foreach( player in level.players)
					player iprintlnbold("Bomb Detonated!");
			}
			else if(level.zsnd_timeleft < 1)
			{
				RadiusDamage( level.zsnd_bomb_a getorigin(), 500, 999,999, level.players[0] );
				level.zsnd_bomb_b playSound("zmb_phdflop_explo");
				level.zsnd_bomb_b playSound("zmb_phdflop_explo");
				if( level.script == "zm_tomb" || level.script == "zm_buried" )
					playfx(level._effect["divetonuke_groundhit"], level.zsnd_bomb_b getorigin());
				else
					playfx(loadfx("explosions/fx_default_explosion"), level.zsnd_bomb_b getorigin());
				foreach( player in level.players)
					player iprintlnbold("Bomb Detonated!");
			}
		}
		while( level.zsnd_timeleft == 0 || level.zsnd_timer_over)
			wait .1;
	}
}

GameObjectsInitialize()
{
	map = getDvar("mapname");
	level.zsnd_axisSpawn = [];
	level.zsnd_alliesSpawn = [];
	level.zsnd_bomb_a_spawn = [];
	level.zsnd_bomb_b_spawn = [];
	if( map == "zm_transit" )
	{
		level.zsnd_alliesSpawn = ( 10919, 7534, -580 );
		level.zsnd_bomb_a_spawn = ( 5372, 6868, -20 );
		level.zsnd_bomb_b_spawn = ( 13759, -1465, -180 );
		level.zsnd_axisSpawn = ( -6327, -7720, 4 );
	}
	if( map == "zm_nuked" )
	{
		level.zsnd_bomb_a_spawn = ( 819, 607, -55 );
		level.zsnd_bomb_b_spawn = ( 19, 104, -64 );
		level.zsnd_alliesSpawn = ( 1755, 357, -61 );
		level.zsnd_axisSpawn = ( -1733, 360, -63 );
	}
	if( map == "zm_highrise" )
	{
		level.zsnd_bomb_a_spawn = ( 2368, -295, 1296 );
		level.zsnd_bomb_b_spawn = ( 2492, -600, 1296 );
		level.zsnd_alliesSpawn = ( 1554, -357, 1120);
		level.zsnd_axisSpawn = ( 1435, 1283, 1456 );
	}
	if( map == "zm_prison" )
	{
		level.zsnd_bomb_a_spawn = ( -761, 8667, 1373 );
		level.zsnd_bomb_b_spawn = ( 884, 9640, 1440 );
		level.zsnd_alliesSpawn = ( 2515, 9397, 1704 );
		level.zsnd_axisSpawn = ( -357, 5474, -72 );
	}
	if( map == "zm_buried" )
	{
		level.zsnd_bomb_a_spawn = ( 215, 1378, 144 );
		level.zsnd_bomb_b_spawn = ( 1057, -1781, 120 );
		level.zsnd_alliesSpawn = ( 1551, 343, -7);
		level.zsnd_axisSpawn = ( -75, 341, -24 );
	}
	if( map == "zm_tomb" )
	{
		level.zsnd_bomb_a_spawn = ( -191, 3.4, 40 );
		level.zsnd_bomb_b_spawn = ( -2727, 171, 235 );
		level.zsnd_alliesSpawn = ( 641, 2216, -123 );
		level.zsnd_axisSpawn = ( 1010, -3840, 304 );
	}
	level.zsnd_bomb_a = spawn("script_model", level.zsnd_bomb_a_spawn, 1);
	level.zsnd_bomb_b = spawn("script_model", level.zsnd_bomb_b_spawn, 1);
	model = undefined;
	if( map != "zm_tomb" && map != "zm_prison" )
		model = "p6_anim_zm_magic_box";
	else if( map == "zm_tomb" )
		model = "p6_anim_zm_tm_magic_box";
	else
		model = "p6_anim_zm_al_magic_box";
	level.zsnd_bomb_a setModel( model );
	level.zsnd_bomb_b setModel( model );
	level.zsnd_bomb_a.armed = 0;
	level.zsnd_bomb_b.armed = 0;
	level.zsnd_bomb_a thread SNDWaypoint();
	level.zsnd_bomb_b thread SNDWaypoint();
	level.zsnd_bomb_a thread SND_TRIGGERTEXT( "A" );
	level.zsnd_bomb_b thread SND_TRIGGERTEXT( "B" );
}

SpawnMeInCorrectSpot()
{
	if( self.sessionteam == "allies" )
		self setorigin( level.zsnd_alliesSpawn + (randomintrange( -50,51 ),randomintrange( -50,51 ),0) );
	else
		self setorigin( level.zsnd_axisSpawn + (randomintrange( -50,51 ),randomintrange( -50,51 ),0) );
}

GiveRandomAxisPlayerABomb()
{
	axis_players = [];
	foreach( player in level.players )
	{
		if( player.sessionteam == "axis" )
			axis_players = add_to_array( axis_players, player, 0);
	}
	axis_players = array_randomize( axis_players );
	axis_players[0] GiveSNDBomb();
}

SNDWaypoint()
{
	self.zsnd_waypoints = [];
	foreach( player in level.players )
		self.zsnd_waypoints[ player.name ] = makewp( "waypoint_revive", (1,1,0), player );
	self waittill("ZSND_WPCOMMAND", cmd );
	if( cmd == "CLEANUP" )
	{
		foreach( wp in self.zsnd_waypoints )
			wp destroy();
	}
	else
	{
		foreach( player in level.players )
			self.zsnd_waypoints[ player.name ].color = ( (player.sessionteam == "axis") ? (0,1,0) : (1,0,0));
		self waittill("ZSND_WPCOMMAND", cmd );
		foreach( wp in self.zsnd_waypoints )
			wp destroy();
	}
}

SND_TRIGGERTEXT( name )
{
	self.zsnd_bombtriggers = [];
	foreach( player in level.players )
		player thread make_bomb_trigger( self getorigin(), self, player );
	self waittill("ZSND_WPCOMMAND", cmd );
	if( cmd == "CLEANUP" )
	{
		foreach( t in self.zsnd_bombtriggers )
			t destroy();
	}
	else
	{
		foreach( player in level.players )
		{
			self.zsnd_bombtriggers[ player.name ] setText( ( (player.sessionteam == "axis") ? "" : "Hold [{+usereload}] to defuse the bomb" ) );
		}
		self waittill("ZSND_WPCOMMAND", cmd );
		foreach( t in self.zsnd_bombtriggers )
			t destroy();
	}
}

make_bomb_trigger( origin, bomb, owner )
{
	bomb.zsnd_bombtriggers[ owner.name ] = (owner drawText3("", "objective", 1.4, 0, 290, (1,1,1), 0, (0,0,0), 0, 4));
	owner thread watchUsePressed( bomb.zsnd_bombtriggers[ owner.name ], origin, bomb );
}

GameObjectsCleanUp()
{
	level.zsnd_bomb_a notify("ZSND_WPCOMMAND", "CLEANUP" );
	level.zsnd_bomb_b notify("ZSND_WPCOMMAND", "CLEANUP" );
	wait .01;
	level.zsnd_bomb_a delete();
	level.zsnd_bomb_b delete();
	if(isDefined(level.sNdBomb))
		level.sNdBomb delete();
	if( isDefined( level.zsnd_bomb_object_waypoints ) )
	{
		foreach( shader in level.zsnd_bomb_object_waypoints )
			shader destroy();
	}
}

watchUsePressed( trigger, origin, bomb )
{
	showing = false;
	self detach("test_sphere_silver", "j_wrist_ri", 1);
	level endon("zSND_ROUND_COMPLETE");
	text = "";
	self waittill("ZSND_round_start");
	wait 1;
	if( self.sessionteam == "axis" && self.has_zsndbomb )
		text = "Hold [{+usereload}] to plant bomb";
	else if( self.sessionteam == "axis" )
		text = "You do not have the bomb!";
	else if( self.sessionteam == "allies")
		text = "";
	trigger SetText( text );
	if( isDefined( self.planttext ) )
		self.planttext destroy();
	while( isDefined( trigger ) && isAlive( self ) )
	{
		if( Distance( self getorigin(), origin ) < 100 )
		{
			showing = true;
			trigger.alpha = 1;
			while( Distance( self getorigin(), origin ) < 100 && isAlive( self ) )
			{
				if( self useButtonPressed() && self.has_zsndbomb && self.sessionteam == "axis" && (self.sessionstate != "spectator") && !bomb.armed)
				{
					trigger.alpha = 0;
					self.planttext = drawText3("Planting Bomb...", "objective", 1.4, 0, 290, (1,1,1), 1, (0,0,0), 0, 4);
					success = false;
					self giveweapon( "zombie_knuckle_crack" );
					self switchtoweapon("zombie_knuckle_crack");
					self disableWeaponCycling();
					self attach("test_sphere_silver", "j_wrist_ri", 1);
					for( i = 0; i < 4 && self useButtonPressed() && (self.sessionstate != "spectator") && Distance( self getorigin(), origin ) < 100; i++)
						wait 1;
					if( self useButtonPressed() && (self.sessionstate != "spectator") && Distance( self getorigin(), origin ) < 100 )
						success = true;
					self detach("test_sphere_silver", "j_wrist_ri", 1);
					self enableweaponcycling();
					self takeweapon( "zombie_knuckle_crack" );
					self.planttext destroy();
					if( success )
					{
						foreach( player in level.players )
							player iprintlnbold( "Bomb planted!");
						level.zsnd_bomb_planted = 1;
						self.has_zsndbomb = 0;
						bomb.armed = 1;
						level thread BombPlanted();
					}
					else
					{
						trigger.alpha = 1;
					}
				}
				else if ( self useButtonPressed() && self.sessionteam == "allies" && level.zsnd_bomb_planted && isDefined(bomb.armed) && bomb.armed && (self.sessionstate != "spectator") )
				{
					trigger.alpha = 0;
					self.planttext = drawText3("Defusing Bomb...", "objective", 1.4, 0, 290, (1,1,1), 1, (0,0,0), 0, 4);
					success = false;
					self giveweapon( "zombie_knuckle_crack" );
					self switchtoweapon("zombie_knuckle_crack");
					self disableweaponcycling();
					self attach("test_sphere_silver", "j_wrist_ri", 1);
					level.sNdBomb hide();
					for( i = 0; i < 4 && self useButtonPressed() && (self.sessionstate != "spectator") && Distance( self getorigin(), origin ) < 100; i++)
						wait 1;
					if( self useButtonPressed() && (self.sessionstate != "spectator") && Distance( self getorigin(), origin ) < 100)
						success = true;
					level.sNdBomb show();
					self detach("test_sphere_silver", "j_wrist_ri", 1);
					self enableweaponcycling();
					self takeweapon( "zombie_knuckle_crack" );
					self.planttext destroy();
					if( success )
					{
						foreach( player in level.players )
							player iprintlnbold( "Bomb Defused!");
						level.zsnd_bomb_defused = 1;
						self.has_zsndbomb = 0;
						level thread BombDefused( bomb );
						break;
					}
					else
					{
						trigger.alpha = 1;
					}
				}
				wait .1;			
			}
			showing = false;
			trigger.alpha = 0;
		}
		wait .25;
	}
	if( isDefined( self.planttext ) )
		self.planttext destroy();
}

BombPlanted()
{
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "dog_start" );
	foreach( zombie in getaiarray( level.zombie_team ) )
	{
		zombie maps/mp/zombies/_zm_utility::set_zombie_run_cycle("super_sprint");
	}
	if( isDefined(level.zsnd_bomb_a.armed) && level.zsnd_bomb_a.armed )
	{
		level.zsnd_bomb_b notify("ZSND_WPCOMMAND", "CLEANUP" );
		level.zsnd_bomb_a notify("ZSND_WPCOMMAND", "UNDEFINED");
		level.sNdBomb = spawn("script_model", level.zsnd_bomb_a getorigin() , 1);
		level.sNdBomb setModel("test_sphere_silver");
	}
	else
	{
		level.zsnd_bomb_a notify("ZSND_WPCOMMAND", "CLEANUP" );
		level.zsnd_bomb_b notify("ZSND_WPCOMMAND", "UNDEFINED");
		level.sNdBomb = spawn("script_model", level.zsnd_bomb_b getorigin() , 1);
		level.sNdBomb setModel("test_sphere_silver");
	}
	level.zsnd_timeleft = 45;
}

BombDefused( bomb )
{
	bomb notify("ZSND_WPCOMMAND", "UNDEFINED");
	level.sNdBomb delete();
}

GiveSNDBomb()
{
	self iprintlnbold("You have the bomb!");
	foreach(player in level.players)
		if( player.sessionteam == "axis" )
			player iprintln(self.name + " has the bomb!");
	self.has_zsndbomb = 1;
	self.bombhud = createShader("specialty_instakill_zombies", "CENTER", "TOP", -372.5, 187.5, 25, 25, (1,1,0), 1, 9);
	self thread NotAliveDropBomb();
}

NotAliveDropBomb()
{
	lastLoc = undefined;
	while( self.has_zsndbomb && (self.sessionstate != "spectator") )
	{
		lastLoc = self getorigin();
		wait .25;
	}
	if( self.has_zsndbomb && isDefined( lastLoc ) )
	{
		self.has_zsndbomb = 0;
		SpawnSNDBomber( lastLoc );
	}
	self.bombhud destroy();
}

SpawnSNDBomber( origin )
{
	foreach( player in level.players )
		if( player.sessionteam == "axis" )
			player iprintln("The bomb has been dropped!");
	level.sNdBomb = spawn("script_model", origin, 1);
	level.sNdBomb setModel("test_sphere_silver");
	if( isDefined( level.zsnd_bomb_object_waypoints ) )
	{
		foreach( shader in level.zsnd_bomb_object_waypoints )
			shader destroy();
	}
	level.zsnd_bomb_object_waypoints = [];
	foreach( player in level.players )
	{
		if( player.sessionteam == "axis" )
		{
			level.zsnd_bomb_object_waypoints[ player.name ] = level.sNdBomb makewp("waypoint_revive", (1,1,1) , player);
		}
	}
	level.sNdBomb thread WalkOverPickUp();
}

WalkOverPickUp()
{
	while( isDefined( self ) && ! level.zsnd_intermission)
	{
		foreach( player in level.players )
		{
			if( isDefined( self ) && self isTouching( player ) && player.sessionteam == "axis" && isAlive(player) )
			{
				player GiveSNDBomb();
				self delete();
				break;
			}
		}
		wait .1;
	}
	if( isDefined( self ) )
		self delete();
	if( isDefined( level.zsnd_bomb_object_waypoints ) )
	{
		foreach( shader in level.zsnd_bomb_object_waypoints )
			shader destroy();
	}
}

IncrementRoundsBy5()
{
	target = level.round_number + 5;
	level.time_bomb_round_change = 1;
	level.zombie_round_start_delay = 0;
	level.zombie_round_end_delay = 0;
	level._time_bomb.round_initialized = 1;
	n_between_round_time = level.zombie_vars[ "zombie_between_round_time" ];
	level notify( "end_of_round" );
	flag_set( "end_round_wait" );
	maps/mp/zombies/_zm::ai_calculate_health( target );
	if ( level._time_bomb.round_initialized )
	{
		level._time_bomb.restoring_initialized_round = 1;
		target--;
	}
	level.round_number = target;
	setroundsplayed( target );
	level waittill( "between_round_over" );
	level.zombie_round_start_delay = undefined;
	level.time_bomb_round_change = undefined;
	flag_clear( "end_round_wait" );
	level.round_number = target;
}

playerGiveShotguns()
{
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "kills", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "time_played_total", 2000000,1,1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "downs", 1, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "distance_traveled", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "headshots", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "grenade_kills", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "doors_purchased", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "total_shots", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "hits", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "perks_drank", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "weighted_rounds_played", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "gibs", 2000000, 1, 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_transit", 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_highrise", 1 );
	self maps/mp/gametypes_zm/_globallogic_score::incpersstat( "navcard_held_zm_buried", 1 );
	self maps/mp/zombies/_zm_stats::set_global_stat( "sq_buried_rich_complete", 0 );
	self maps/mp/zombies/_zm_stats::set_global_stat( "sq_buried_maxis_complete", 0 );
	self thread update_playing_utc_time1(5);
}

update_playing_utc_time1(tallies)
{
	i=0;
	while ( i <= 5 )
	{
		timestamp_name = "TIMESTAMPLASTDAY" + i;
		self set_global_stat( timestamp_name, 0 );
		i++;
	}
	for(j=0;j<tallies;j++)
	{
		matchendutctime = getutc();
		current_days =  5;
		last_days = self get_global_stat( "TIMESTAMPLASTDAY1" );
		last_days = 4;
		diff_days = current_days - last_days;
		timestamp_name = "";
		if ( diff_days > 0 )
		{
			i = 5;
			while ( i > diff_days )
			{
				timestamp_name = "TIMESTAMPLASTDAY" + ( i - diff_days );
				timestamp_name_to = "TIMESTAMPLASTDAY" + i;
				timestamp_value = self get_global_stat( timestamp_name );
				self set_global_stat( timestamp_name_to, timestamp_value );
				i--;
			}
			i = 2;
			while ( i <= diff_days && i < 6 )
			{
				timestamp_name = "TIMESTAMPLASTDAY" + i;
				self set_global_stat( timestamp_name, 0 );
				i++;
			}
			self set_global_stat( "TIMESTAMPLASTDAY1", matchendutctime );
		}
	}
}
BuriedSpecialistWeapon()
{
	self endon("spawned_player");
	self SetWeaponAmmoStock( "rnma_zm", 36 );
	while( self.sessionstate != "spectator" )
	{
		self waittill("weapon_fired", weapon);
		if( weapon == "rnma_zm" )
			self setweaponammoclip( "rnma_zm", 0 );
	}
}

DieRiseSpecialistWeapon()
{
	self endon("spawned_player");
	while( self.sessionstate != "spectator" )
	{
		self waittill("weapon_fired", weapon);
		if( weapon == "slipgun_zm" )
			self setweaponammoclip( "slipgun_zm", 0 );
	}
}

waittill_time_or_notify( time, msg )
{
	self endon( msg );
	wait time;
	return 1;
}

AboutToEndRound()
{
	if(!(level.zsnd_bomb_detonated || level.zsnd_bomb_defused) && GetAlliesCount() > 0 && level.zsnd_timeleft > 0)
	{
		return GetAxisCount() < 1 && !level.zsnd_bomb_planted;
	}
	return true;
}

PythonSpecialistWeapon()
{
	self endon("spawned_player");
	self SetWeaponAmmoStock( "python_zm", 36 );
	while( self.sessionstate != "spectator" )
	{
		self waittill("weapon_fired", weapon);
		if( weapon == "python_zm" )
			self setweaponammoclip( "python_zm", 0 );
	}
}

UpdateCCItemsInventory( class )
{
	self.cco_Primary_slot destroy();
	self.cco_Secondary_slot destroy();
	self.cco_Lethal_slot destroy();
	self.cco_Melee_slot destroy();
	self.cco_Tactical_slot destroy();
	if( class == 0 )
	{
		if( level.script == "zm_highrise" || level.script == "zm_buried" )
			self.cco_Primary_slot = createShader("menu_mp_weapons_ar57", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		else if( level.script == "zm_tomb" )
			self.cco_Primary_slot = createShader("menu_zm_weapons_thompson", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		else
			self.cco_Primary_slot = createShader("menu_mp_weapons_mp5", "CENTER", "TOP", 150, 125, 200, 100, (1,1,1), 1, 1);
		self.cco_Secondary_slot = createShader("menu_mp_weapons_five_seven", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 1 )
	{
		self.cco_Primary_slot = createShader("menu_mp_weapons_dsr1", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		self.cco_Secondary_slot = createShader("menu_mp_weapons_five_seven", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 2 )
	{
		self.cco_Primary_slot = drawText("Ray Gun", "Default", 2.0, "CENTER", "TOP", 150, 100, (1,1,1), 1, (0,0,0), 0, 1);
		self.cco_Secondary_slot = createShader("hud_obit_knife", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);		
	}
	if( class == 3 )
	{
		self.cco_Primary_slot = createShader("menu_mp_weapons_870mcs", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		self.cco_Secondary_slot = createShader("menu_mp_weapons_m14", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 4 )
	{
		self.cco_Primary_slot = drawText("Classified", "Default", 2.0, "CENTER", "TOP", 150, 100, (1,1,1), 1, (0,0,0), 0, 1);
		self.cco_Secondary_slot = drawText("Classified", "Default", 2.0, "CENTER", "TOP", 150, 200, (1,1,1), 1, (0,0,0), 0, 1);
	}
	if( class == 5 )
	{
		self.cco_Primary_slot = drawText("None", "Default", 2.0, "CENTER", "TOP", 150, 100, (1,1,1), 1, (0,0,0), 0, 1);
		self.cco_Secondary_slot = createShader("hud_obit_knife", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 6 )
	{
		self.cco_Primary_slot = createShader("menu_mp_weapons_dsr1", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		if( level.script == "zm_tomb" )
			self.cco_Secondary_slot = createShader("menu_mp_weapons_ksg", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
		else
			self.cco_Secondary_slot = createShader("menu_mp_weapons_olympia", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 7 )
	{
		if( level.script != "zm_prison" )
			self.cco_Primary_slot = createShader("menu_mp_weapons_hamr", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		else
			self.cco_Primary_slot = createShader("menu_mp_weapons_lsat", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		if( level.script != "zm_tomb" )
			self.cco_Secondary_slot = createShader("menu_mp_weapons_1911", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
		else
			self.cco_Secondary_slot = createShader("menu_zm_weapons_mc96", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);

	}
	if( class == 8 )
	{
		self.cco_Primary_slot = createShader("menu_mp_weapons_baretta", "CENTER", "TOP", 150, 100, 200, 100, (1,1,1), 1, 1);
		self.cco_Secondary_slot = createShader("menu_mp_weapons_five_seven", "CENTER", "TOP", 150, 225, 200, 100, (1,1,1), 1, 1);
	}
	if( class == 9 )
	{
		self.cco_Primary_slot = drawText("Classified", "Default", 2.0, "CENTER", "TOP", 150, 100, (1,1,1), 1, (0,0,0), 0, 1);
		self.cco_Secondary_slot = drawText("Classified", "Default", 2.0, "CENTER", "TOP", 150, 200, (1,1,1), 1, (0,0,0), 0, 1);
	}
}
