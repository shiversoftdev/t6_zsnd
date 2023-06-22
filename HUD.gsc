createShader(shader, align, relative, x, y, width, height, color, alpha, sort)
{
    hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
	hud setParent(level.uiParent);
    hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	hud.hideWhenInMenu = true;
	hud.archived = false;
    return hud;
}

drawShader(shader, x, y, width, height, color, alpha, sort, allclients)
{
	hud = undefined;
	if( isDefined( allclients ) )
		hud = newHudElem();
	else
   		hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
	hud.hideWhenInMenu = true;
	hud.archived = false;
    return hud;
}

drawText(text, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = undefined;
	if( self == level )
		hud = level createServerFontString(font, fontScale);
	else
		hud = self createFontString(font, fontScale);
    hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setText(text);
	if(text == "SInitialization")
		hud.foreground = true;
	hud.hideWhenInMenu = true;
	hud.archived = false;
	return hud;
}

drawText2(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort, allclients)
{
	if (!isDefined(allclients))
		allclients = false;
	if (!allclients)
		hud = self createFontString(font, fontScale);
	else
		hud = level createServerFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.foreground = true;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	return hud;
}

drawSVT(text, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = createServerFontString(font, fontScale);
    hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setText(text);
	if(text == "SInitialization")
		hud.foreground = true;
	hud.hideWhenInMenu = true;
	hud.archived = false;
	return hud;
}

sSetText( svar )
{
	self SetText( svar );
	if(level.SENTINEL_CURRENT_OVERFLOW_COUNTER > level.SENTINEL_MIN_OVERFLOW_THRESHOLD)
	{
		level notify( "SENTINEL_OVERFLOW_BEGIN_WATCH" );
	}
}

drawValue(value, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = createServerFontString(font, fontScale);
    hud setPoint( align, relative, x, y );
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud setValue(value);
	hud.foreground = true;
	hud.hideWhenInMenu = true;
	return hud;
}

ZMiniMap()
{
	self.minimap = self createShader("menu_zm_popup", "CENTER", "TOP", -300, 85, 170, 170, (1,1,1), .75, 1);
	self.playershaders = [];
	self.mmi = createShader("ui_sliderbutt_1", "CENTER", "TOP", -300, 75, 7, 17, (0,0,1), .9, 2);
	foreach( player in level.players)
	{
		if( player == self )
			continue;
		if( player.sessionteam == self.sessionteam )
			self.playershaders[ player.name ] = self createShader("ui_sliderbutt_1", "CENTER", "TOP", -300, 75, 7, 17, (0,1,0), 1, 2);
		else
			self.playershaders[ player.name ] = self createShader("ui_sliderbutt_1", "CENTER", "TOP", -300, 75, 7, 17, (1,0,0), 0, 2);
	}
	self.dead_from_snd = false;
	while( !self.dead_from_snd && !level.zsnd_intermission && self.sessionstate != "spectator")
	{
		foreach( player in level.players )
		{
			if( player == self )
				continue;
			self.playershaders[ player.name ] updateMMPos( self getOrigin(), player getOrigin(), self getplayerangles() );
		}
		wait .1;
	}
	self.dead_from_snd = false;
	foreach( shader in self.playershaders)
		shader destroy();
	self.minimap destroy();
	self.mmi destroy();
}
 
cleanOldMiniMap()
{
	foreach( shader in self.playershaders)
		shader destroy();
	self.minimap destroy();
	self.mmi destroy();
}
 
updateMMPos( center, offset, angles )
{
	d = offset - center;
	d0 = Distance( offset, center );
	x = cos( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
	y = sin( angles[1] - ATan2( d[1], d[0] ) + 90 ) * d0;
	offx = x / 1500;
	if( offx > 1 )
		offx = 1;
	else if( offx < -1 )
		offx = -1;
	offy = y / 1500;
	if( offy > 1 )
		offy = 1;
	else if( offy < -1 )
		offy = -1;
	self.x = -300 + offx * 75;
	self.y = 75 + offy * 75;
}

ATan2( y, x )
{
	if( x > 0 )
		return ATan( y / x );
	if( x < 0 && y >= 0 )
		return ATan( y / x ) + 180;
	if( x < 0 && y < 0 )
		return ATan( y / x ) - 180;
	if( x == 0 && y > 0 )
		return 90;
	if( x == 0 && y < 0 )
		return -90;
	return 0;
}

PingShader()
{
	self.alpha = 1;
	self fadeovertime( .8 );
	self.alpha = 0;
}

PingShaderFromShoot()
{
	self.mmi.color = (0,1,1);
	self.mmi fadeovertime( 1 );
	self.mmi.color = (0,0,1);
}

makewp(icon, color, player)
{
	headicon = newclienthudelem(player);
	headicon.archived = 1;
	headicon.x = 8;
	headicon.y = 8;
	headicon.z = 30;
	headicon.alpha = 0.8;
	headicon setshader( icon, 8, 8 );
	headicon.color = color;
	headicon setwaypoint( 1 );
	headicon settargetent( self );
	return headicon;
}

drawText3(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort)
{
	hud = self createFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	return hud;
}

OnShotPingRadar()
{
	self notify("newPinger");
	self endon("newPinger");
	while( 1 )
	{
		self waittill("weapon_fired", weapon);
		self thread PingShaderFromShoot();
		foreach( player in level.players )
			if( player.sessionteam != self.sessionteam )
				player.playershaders[ self.name ] PingShader();
	}
}

ShowTeamText()
{
	if( isDefined( self.team_hud_text ) )
		self.team_hud_text destroy();
	text = (self.sessionteam == "axis") ? ("Your Team : " + level.Axis_Rounds + " | Defenders : " + level.Allies_Rounds) : ("Your Team : " + level.Allies_rounds + " | Attackers : " + level.Axis_rounds);
	color = undefined;
	if( self.sessionteam == "axis" )
	{
		if( level.Axis_Rounds > level.Allies_Rounds )
			color = (0,1,0);
		else if( level.Axis_Rounds == level.Allies_Rounds )
			color = (1,1,0);
		else
			color = (1,0,0);
	}
	else
	{
		if( level.Allies_Rounds > level.Axis_Rounds )
			color = (0,1,0);
		else if( level.Axis_Rounds == level.Allies_Rounds )
			color = (1,1,0);
		else
			color = (1,0,0);
	}
	self.team_hud_text = self drawText(text, "default", 1.5, "LEFT", "BOTTOM", -375, -20, color, 1, (0,0,0), 0, 9);
}


