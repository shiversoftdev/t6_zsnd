callback_playerkilled( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self.killcamlength = 5;
	maps/mp/zombies/_zm::callback_playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	attacker = eattacker;
	if( isDefined( attacker ) && attacker != self && isDefined(attacker.is_zombie) && attacker.is_zombie )
		KillFeed( "Zombie" );
	else
		obituary( self, attacker, sweapon, smeansofdeath );
	self.suicide = 0;
	wasinlaststand = 0;
	deathtimeoffset = 0;
	lastweaponbeforedroppingintolaststand = undefined;
	attackerstance = undefined;
	self.laststandthislife = undefined;
	self.vattackerorigin = undefined;
	if ( isDefined( self.uselaststandparams ) )
	{
		self.uselaststandparams = undefined;
		if ( !level.teambased || isDefined( attacker ) && isplayer( attacker ) || attacker.team != self.team && attacker == self )
		{
			einflictor = self.laststandparams.einflictor;
			attacker = self.laststandparams.attacker;
			attackerstance = self.laststandparams.attackerstance;
			idamage = self.laststandparams.idamage;
			smeansofdeath = self.laststandparams.smeansofdeath;
			sweapon = self.laststandparams.sweapon;
			vdir = self.laststandparams.vdir;
			shitloc = self.laststandparams.shitloc;
			self.vattackerorigin = self.laststandparams.vattackerorigin;
			deathtimeoffset = ( getTime() - self.laststandparams.laststandstarttime ) / 1000;
			if ( isDefined( self.previousprimary ) )
			{
				wasinlaststand = 1;
				lastweaponbeforedroppingintolaststand = self.previousprimary;
			}
		}
		self.laststandparams = undefined;
	}
	bestplayer = undefined;
	bestplayermeansofdeath = undefined;
	obituarymeansofdeath = undefined;
	bestplayerweapon = undefined;
	obituaryweapon = undefined;	
	if ( maps/mp/gametypes_zm/_globallogic_utils::isheadshot( sweapon, shitloc, smeansofdeath, einflictor ) && isplayer( attacker ) )
	{
		attacker playlocalsound( "prj_bullet_impact_headshot_helmet_nodie_2d" );
		smeansofdeath = "MOD_HEAD_SHOT";
	}
	self.deathtime = getTime();
	if ( isDefined( self.hasriotshieldequipped ) && self.hasriotshieldequipped == 1 )
	{
		self detachshieldmodel( level.carriedshieldmodel, "tag_weapon_left" );
		self.hasriotshield = 0;
		self.hasriotshieldequipped = 0;
	}
	if ( isplayer( attacker ) && attacker != self || !level.teambased && level.teambased && self.team != attacker.team )
	{
		if ( wasinlaststand && isDefined( lastweaponbeforedroppingintolaststand ) )
		{
			weaponname = lastweaponbeforedroppingintolaststand;
		}
		else
		{
			weaponname = self.lastdroppableweapon;
		}
		if ( isDefined( weaponname ) && !issubstr( weaponname, "gl_" ) || issubstr( weaponname, "mk_" ) && issubstr( weaponname, "ft_" ) )
		{
			weaponname = self.currentweapon;
		}
	}
	if ( !isDefined( obituarymeansofdeath ) )
	{
		obituarymeansofdeath = smeansofdeath;
	}
	if ( !isDefined( obituaryweapon ) )
	{
		obituaryweapon = sweapon;
	}
	if ( !isplayer( attacker ) || self isenemyplayer( attacker ) == 0 )
	{
		level notify( "reset_obituary_count" );
		level.lastobituaryplayercount = 0;
		level.lastobituaryplayer = undefined;
	}
	else
	{
		if ( isDefined( level.lastobituaryplayer ) && level.lastobituaryplayer == attacker )
		{
			level.lastobituaryplayercount++;
		}
		else
		{
			level notify( "reset_obituary_count" );
			level.lastobituaryplayer = attacker;
			level.lastobituaryplayercount = 1;
		}
		if ( level.lastobituaryplayercount >= 4 )
		{
			level notify( "reset_obituary_count" );
			level.lastobituaryplayercount = 0;
			level.lastobituaryplayer = undefined;
		}
	}
	
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead";
	self.killedplayerscurrent = [];
	self.deathcount++;
	lpselfnum = self getentitynumber();
	lpselfname = self.name;
	lpattackguid = "";
	lpattackname = "";
	lpselfteam = self.team;
	lpselfguid = self getguid();
	lpattackteam = "";
	lpattackorigin = ( 0, 0, 0 );
	lpattacknum = -1;
	awardassists = 0;
	if ( isplayer( attacker ) )
	{
		lpattackguid = attacker getguid();
		lpattackname = attacker.name;
		lpattackteam = attacker.team;
		lpattackorigin = attacker.origin;
		if ( attacker == self )
		{
			dokillcam = 0;
			self.suicide = 1;
		}
		else
		{
			lpattacknum = attacker getentitynumber();
			dokillcam = 1;
		}
	}
	else if ( isDefined( attacker ) || attacker.classname == "trigger_hurt" && attacker.classname == "worldspawn" )
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		awardassists = 1;
	}
	else
	{
		dokillcam = 0;
		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackteam = "world";
		if ( isDefined( einflictor ) && isDefined( einflictor.killcament ) )
		{
			dokillcam = 1;
			lpattacknum = self getentitynumber();
		}
		awardassists = 1;
	}
	if ( sessionmodeiszombiesgame() )
	{
		awardassists = 0;
	}
	self.lastattacker = attacker;
	self.lastdeathpos = self.origin;
	if ( isDefined( self.attackers ) )
	{
		self.attackers = [];
	}
	attackerstring = "none";
	killcamentity = self getkillcamentity( eattacker, einflictor, sweapon );
	killcamentityindex = -1;
	killcamentitystarttime = 0;
	if ( isDefined( killcamentity ) )
	{
		killcamentityindex = killcamentity getentitynumber();
		if ( isDefined( killcamentity.starttime ) )
		{
			killcamentitystarttime = killcamentity.starttime;
		}
		else
		{
			killcamentitystarttime = killcamentity.birthtime;
		}
		if ( !isDefined( killcamentitystarttime ) )
		{
			killcamentitystarttime = 0;
		}
	}
	died_in_vehicle = 0;
	if ( isDefined( self.diedonvehicle ) )
	{
		died_in_vehicle = self.diedonvehicle;
	}
	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;
	self thread [[ level.onplayerkilled ]]( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration );
	self.wantsafespawn = 0;
	perks = [];
	if ( smeansofdeath != "MOD_SUICIDE" && isDefined( attacker ) && attacker.classname != "trigger_hurt" && attacker.classname != "worldspawn" && self != attacker )
	{	
		level thread recordkillcamsettings( lpattacknum, self getentitynumber(), sweapon, self.deathtime, deathtimeoffset, psoffsettime, killcamentityindex, killcamentitystarttime, perks, attacker );
	}
	wait 0.25;
	weaponclass = getweaponclass( sweapon );
	self.cancelkillcam = 0;
	self thread cancelkillcamonuse();
	defaultplayerdeathwatchtime = .25;
	if ( isDefined( level.overrideplayerdeathwatchtimer ) )
	{
		defaultplayerdeathwatchtime = [[ level.overrideplayerdeathwatchtimer ]]( defaultplayerdeathwatchtime );
	}
	maps/mp/gametypes_zm/_globallogic_utils::waitfortimeornotifies( defaultplayerdeathwatchtime );
	self notify( "death_delay_finished" );
	self.respawntimerstarttime = getTime();
	if ( !self.cancelkillcam && dokillcam && level.killcam && !AboutToEndRound() )
	{
		self killcam( lpattacknum, self getentitynumber(), killcamentity, killcamentityindex, killcamentitystarttime, sweapon, self.deathtime, deathtimeoffset, psoffsettime, 0, 5, perks, attacker );
	}
	self.killcamtargetentity = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

getkillcamentity( attacker, einflictor, sweapon )
{
	if ( !isDefined( einflictor ) )
	{
		return undefined;
	}
	if ( einflictor == attacker )
	{
		if ( !isDefined( einflictor.ismagicbullet ) )
		{
			return undefined;
		}
		if ( isDefined( einflictor.ismagicbullet ) && !einflictor.ismagicbullet )
		{
			return undefined;
		}
	}
	else
	{
		if ( isDefined( level.levelspecifickillcam ) )
		{
			levelspecifickillcament = self [[ level.levelspecifickillcam ]]();
			if ( isDefined( levelspecifickillcament ) )
			{
				return levelspecifickillcament;
			}
		}
	}
	if ( sweapon == "m220_tow_mp" )
	{
		return undefined;
	}
	if ( isDefined( einflictor.killcament ) )
	{
		if ( einflictor.killcament == attacker )
		{
			return undefined;
		}
		return einflictor.killcament;
	}
	else
	{
		if ( isDefined( einflictor.killcamentities ) )
		{
			return getclosestkillcamentity( attacker, einflictor.killcamentities );
		}
	}
	if ( isDefined( einflictor.script_gameobjectname ) && einflictor.script_gameobjectname == "bombzone" )
	{
		return einflictor.killcament;
	}
	return einflictor;
}

getclosestkillcamentity( attacker, killcamentities, depth )
{
	if ( !isDefined( depth ) )
	{
		depth = 0;
	}
	closestkillcament = undefined;
	closestkillcamentindex = undefined;
	closestkillcamentdist = undefined;
	origin = undefined;
	_a2977 = killcamentities;
	killcamentindex = getFirstArrayKey( _a2977 );
	while ( isDefined( killcamentindex ) )
	{
		killcament = _a2977[ killcamentindex ];
		if ( killcament == attacker )
		{
		}
		else
		{
			origin = killcament.origin;
			if ( isDefined( killcament.offsetpoint ) )
			{
				origin += killcament.offsetpoint;
			}
			dist = distancesquared( self.origin, origin );
			if ( !isDefined( closestkillcament ) || dist < closestkillcamentdist )
			{
				closestkillcament = killcament;
				closestkillcamentdist = dist;
				closestkillcamentindex = killcamentindex;
			}
		}
		killcamentindex = getNextArrayKey( _a2977, killcamentindex );
	}
	if ( depth < 3 && isDefined( closestkillcament ) )
	{
		if ( !bullettracepassed( closestkillcament.origin, self.origin, 0, self ) )
		{
			betterkillcament = getclosestkillcamentity( attacker, killcamentities, depth + 1 );
			if ( isDefined( betterkillcament ) )
			{
				closestkillcament = betterkillcament;
			}
		}
	}
	return closestkillcament;
}



