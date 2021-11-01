#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zm_buried_sq_ctw;
#include maps/mp/zm_buried_sq_ip;
#include maps/mp/zm_buried_sq_tpo;
#include maps/mp/zm_buried_sq_ows;
#include maps/mp/zm_buried_sq;
#include maps/mp/zombies/_zm_sidequests;

init()
{
	if( getPlayers <= 3 )
	{
		replaceFunc(maps/mp/zm_buried_sq_ip::sq_bp_set_current_bulb, ::custom_sq_bp_set_current_bulb);
		replaceFunc(maps/mp/zm_buried_sq_ctw::ctw_max_start_wisp, ::custom_ctw_max_start_wisp);
		replaceFunc(maps/mp/zm_buried_sq_ctw::ctw_max_wisp_enery_watch, ::custom_ctw_max_wisp_enery_watch);
	}
	level thread buried_targets();
}

buried_targets()
{
	//Credit to Teh_Bandit for this function.
	level endon( "end_game" );
	self endon( "disconnect" );
	for(;;)
	{
		flag_wait( "sq_ows_start" );
		if ( getPlayers().size <= 3 )
		{
			flag_set( "sq_ows_success" );
			break;
		}
	}
}

custom_ctw_max_start_wisp()
{
	nd_start = getvehiclenode( level.m_sq_start_sign.target, "targetname" );
	vh_wisp = spawnvehicle( "tag_origin", "wisp_ai", "heli_quadrotor2_zm", nd_start.origin, nd_start.angles );
	vh_wisp makevehicleunusable();
	level.vh_wisp = vh_wisp;
	vh_wisp.n_sq_max_energy = 30;
	vh_wisp.n_sq_energy = vh_wisp.n_sq_max_energy;
	vh_wisp thread ctw_max_wisp_play_fx();
	vh_wisp_mover = spawn( "script_model", vh_wisp.origin );
	vh_wisp_mover setmodel( "tag_origin" );
	vh_wisp linkto( vh_wisp_mover );
	vh_wisp_mover wisp_move_from_sign_to_start( nd_start );
	vh_wisp unlink();
	vh_wisp_mover delete();
	vh_wisp attachpath( nd_start );
	vh_wisp startpath();
	vh_wisp thread ctw_max_success_watch();
	vh_wisp thread ctw_max_fail_watch();
	vh_wisp thread ctw_max_wisp_enery_watch();
	vh_wisp thread buried_maxis_wisp();
	wait_network_frame();
	flag_wait_any( "sq_wisp_success", "sq_wisp_failed" );
	vh_wisp cancelaimove();
	vh_wisp clearvehgoalpos();
	vh_wisp delete();
	if ( isDefined( level.vh_wisp ) )
	{
		level.vh_wisp delete();
	}
}

buried_maxis_wisp()
{
	self endon( "death" );
	while( 1 )
	{
		if( self.n.sq_energy <= 20 )
		{
			self.sq_energy += 20;
		}
		wait 1;
	}
}

custom_ctw_max_wisp_enery_watch()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( self.n_sq_energy > 1000 )
		{
			flag_set( "sq_wisp_failed" );
		}
		wait 1;
	}
}

custom_sq_bp_set_current_bulb( str_tag )
{
	level endon( "sq_bp_correct_button" );
	level endon( "sq_bp_wrong_button" );
	if ( isDefined( level.m_sq_bp_active_light ) )
	{
		level.str_sq_bp_active_light = "";
	}
	level.m_sq_bp_active_light = sq_bp_light_on( str_tag, "yellow" );
	level.str_sq_bp_active_light = str_tag;
	//removed timer
}