givecustomcharacters_zsnd()
{
	if( self.characterindex == 0 )
	{
		self setmodel(level.zsndcc1);
	}
	else
	{
		self setmodel(level.zsndcc2);
	}
}

InitializeAesthetics()
{
	map = getdvar("mapname");
	weaponstoprecache = "menu_mp_weapons_mp5,menu_mp_weapons_five_seven,menu_mp_weapons_ar57,menu_zm_weapons_thompson,menu_mp_weapons_870mcs,menu_mp_weapons_olympia,menu_mp_weapons_hamr,menu_mp_weapons_m14,menu_mp_weapons_dsr1,menu_zm_weapons_rnma,menu_mp_weapons_baretta,menu_mp_weapons_raygun,menu_zm_weapons_ballistic_knife,hud_obit_knife,menu_mp_weapons_ksg,menu_mp_weapons_lsat,menu_mp_weapons_1911,menu_zm_weapons_mc96";
	foreach( shader in strtok(weaponstoprecache,","))
		precacheshader( shader );
	if( map == "zm_transit" )
	{
		level.zsndcc1 = "c_zom_player_oldman_fb";
		level.zsndcc2 = "c_zom_player_engineer_fb";
		level.zsndccvm1 = "c_zom_reporter_viewhands";
		level.zsndccvm2 = "c_zom_engineer_viewhands";
	}
	if( map == "zm_nuked" )
	{
		level.zsndcc1 = "c_zom_player_cdc_fb";
		level.zsndcc2 = "c_zom_player_cia_fb";
		level.zsndccvm1 = "c_zom_hazmat_viewhands";
		level.zsndccvm2 = "c_zom_suit_viewhands";
	}
	if( map == "zm_highrise" )
	{
		level.zsndcc1 = "c_zom_player_oldman_dlc1_fb";
		level.zsndcc2 = "c_zom_player_engineer_dlc1_fb";
		level.zsndccvm1 = "c_zom_reporter_viewhands";
		level.zsndccvm2 = "c_zom_engineer_viewhands";
	}
	if( map == "zm_prison" )
	{
		level.zsndcc1 = "c_zom_player_handsome_fb";
		level.zsndcc2 = "c_zom_player_arlington_fb";
		level.zsndccvm1 = "c_zom_handsome_sleeveless_viewhands";
		level.zsndccvm2 = "c_zom_arlington_coat_viewhands";
	}
	if( map == "zm_buried" )
	{
		level.zsndcc1 = "c_zom_player_oldman_fb";
		level.zsndcc2 = "c_zom_player_engineer_fb";
		level.zsndccvm1 = "c_zom_reporter_viewhands";
		level.zsndccvm2 = "c_zom_engineer_viewhands";	
	}
	if( map == "zm_tomb" )
	{
		level.zsndcc1 = "c_zom_tomb_richtofen_fb";
		level.zsndcc2 = "c_zom_tomb_dempsey_fb";
		level.zsndccvm1 = "c_zom_richtofen_viewhands";
		level.zsndccvm2 = "c_zom_dempsey_viewhands";	
	}
	precachemodel( level.zsndcc1 );
	precachemodel( level.zsndcc2 );
	precachemodel( level.zsndccvm1 );
	precachemodel( level.zsndccvm2 );
}


