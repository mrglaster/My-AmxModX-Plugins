#include < amxmodx >          
#include < engine >
#include < fakemeta >         
#include < hamsandwich >
#include < hl_wpnmod >
#include < xs >      
#define WEAPON_NAME             "weapon_tfcnailgun"
#define WEAPON_SLOT            3
#define WEAPON_POSITION            5
#define WEAPON_SECONDARY_AMMO        "" // NULL
#define WEAPON_SECONDARY_AMMO_MAX    -1         
#define WEAPON_CLIP            30
#define WEAPON_FLAGS            0
#define WEAPON_WEIGHT            15
#define WEAPON_RELOADTIME        1.9
#define WEAPON_REFIRE_RATE        0.12
#define WEAPON_DAMAGE            35.0
#define WEAPON_RADIUS            60.0 
#define AMMO_MODEL            "models/w_nailgunclip.mdl"
#define AMMO_NAME            "ammo_nails"
#define AMMO_MAX            200
#define AMMO_DEFAULT            30 
#define MODEL_P                "models/p_nailgun.mdl"
#define MODEL_V                "models/v_nailgun.mdl"
#define MODEL_W                "models/w_nailgun.mdl"
#define SOUND_FIRE            "weapons/spike21.wav"
#define SOUND_EXPLODE            "weapons/think11.wav"
#define PLASMA_MODEL            "models/tfcnail.mdl"
#define PLASMA_EXPLODE            "sprites/xspark2.spr"
#define PLASMA_VELOCITY            1300
#define SEQ_IDLE            1
#define SEQ_DEPLOY            4
#define SEQ_RELOAD            3               
#define SEQ_FIRE            5
#define ANIM_EXTENSION            "gauss" 
#define HUD_TXT "sprites/weapon_tfcnailgun.txt"
#define HUD_SPR "sprites/weapon_tfcnailgun.spr"   
                                             

new g_sModelIndexExplode;
#define CLASS_PLASMABOX            "ammo_tfcnailgun"
#define CLASS_PLASMA            "monster_nail"  

new const Float:gVecZero[ ]        = { 0.0, 0.0, 0.0 };

public plugin_precache( )               
{
    new i;
    PRECACHE_MODEL( MODEL_P );
    PRECACHE_MODEL( MODEL_V );
    PRECACHE_MODEL( MODEL_W );
    PRECACHE_MODEL( AMMO_MODEL );
    PRECACHE_SOUND( SOUND_FIRE );             
    PRECACHE_SOUND( SOUND_EXPLODE );
    PRECACHE_MODEL( PLASMA_MODEL );
    g_sModelIndexExplode = PRECACHE_MODEL( PLASMA_EXPLODE );
    PRECACHE_GENERIC(HUD_TXT);
    PRECACHE_MODEL(HUD_SPR);
    
}

public plugin_init( )
{
    register_plugin( "[WPN] TFC NAILGUN", "1.1", "Glaster" );
    new pWeapon = wpnmod_register_weapon
    (
        WEAPON_NAME,
        WEAPON_SLOT,
        WEAPON_POSITION,
        AMMO_NAME,
        AMMO_MAX,
        WEAPON_SECONDARY_AMMO,
        WEAPON_SECONDARY_AMMO_MAX,
        WEAPON_CLIP,
        WEAPON_FLAGS,
        WEAPON_WEIGHT
    );
    
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_Spawn,         "TNail__Spawn" );
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_Deploy,     "TNail__Deploy" );
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_Idle,         "TNail__WeaponIdle" );
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_PrimaryAttack,    "TNail__PrimaryAttack" );
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_Reload,     "TNail__Reload" );
    wpnmod_register_weapon_forward( pWeapon, Fwd_Wpn_Holster,     "TNail__Holster" );
    new pAmmo = wpnmod_register_ammobox( CLASS_PLASMABOX );
    
    wpnmod_register_ammobox_forward( pAmmo, Fwd_Ammo_Spawn,         "TNailAmmo__Spawn" );
    wpnmod_register_ammobox_forward( pAmmo, Fwd_Ammo_AddAmmo,    "TNailAmmo__AddAmmo" );
}

public TNail__Spawn( pItem )
{

    SET_MODEL( pItem, MODEL_W );
    wpnmod_set_offset_int( pItem, Offset_iDefaultAmmo, AMMO_DEFAULT );
}

public TNail__Deploy( pItem )
{

    return wpnmod_default_deploy( pItem, MODEL_V, MODEL_P, SEQ_DEPLOY, ANIM_EXTENSION );
}

public TNail__Holster( pItem, pPlayer )
{

    wpnmod_set_offset_int( pItem, Offset_iInReload, 0 );
}

public TNail__Reload( pItem, pPlayer, iClip, iAmmo )
{
    if( iAmmo <= 0 || iClip >= WEAPON_CLIP )
        return;
    wpnmod_default_reload( pItem, WEAPON_CLIP, SEQ_RELOAD, WEAPON_RELOADTIME );
}

public TNail__PrimaryAttack( pItem, pPlayer, iClip, rgAmmo )
{
    if( iClip <= 0 || entity_get_int( pPlayer, EV_INT_waterlevel ) == 3 )
    {
        wpnmod_play_empty_sound( pItem );
        wpnmod_set_offset_float( pItem, Offset_flNextPrimaryAttack, 0.9 );
        return;                                            
    }
    
    if( TNailb__Spawn( pPlayer ) )
    {
        
        wpnmod_set_offset_int(pPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
        wpnmod_set_offset_int(pPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);
        wpnmod_set_offset_int( pItem, Offset_iClip, iClip -= 1 );
        //entity_set_int( pPlayer, EV_INT_effects, entity_get_int( pPlayer, EV_INT_effects ) | EF_MUZZLEFLASH );
        wpnmod_set_player_anim( pPlayer, PLAYER_ATTACK1 );  
        wpnmod_set_offset_float( pItem, Offset_flNextPrimaryAttack, WEAPON_REFIRE_RATE );
        wpnmod_set_offset_float( pItem, Offset_flTimeWeaponIdle, WEAPON_REFIRE_RATE + 3.0 );
        emit_sound( pPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM );
        wpnmod_send_weapon_anim( pItem, SEQ_FIRE );
        entity_set_vector( pPlayer, EV_VEC_punchangle, Float:{ 0.0, 0.0, 0.0 } );
    }
}

public TNail__WeaponIdle( pItem, pPlayer, iClip, iAmmo )
{
    wpnmod_reset_empty_sound( pItem );
    if( wpnmod_get_offset_float( pItem, Offset_flTimeWeaponIdle ) > 0.0 )
        return;
    wpnmod_send_weapon_anim( pItem, SEQ_IDLE );
    wpnmod_set_offset_float( pItem, Offset_flTimeWeaponIdle, random_float( 5.0, 15.0 ) );
}

TNailb__Spawn( pPlayer )
{
    new pNail = create_entity( "env_sprite" );
    
    if( pNail <= 0 )
        return 0;               
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
    write_byte( TE_KILLBEAM );
    write_short( pNail );
    message_end( );
    entity_set_string( pNail, EV_SZ_classname, CLASS_PLASMA );
    entity_set_model( pNail, PLASMA_MODEL );
    static Float:vecSrc[ 3 ];
    wpnmod_get_gun_position( pPlayer, vecSrc,25.0, 5.4, -13.5 );
    entity_set_origin( pNail, vecSrc );
    entity_set_int( pNail, EV_INT_movetype, MOVETYPE_FLY );
    entity_set_int( pNail, EV_INT_solid, SOLID_BBOX );
    entity_set_size( pNail, gVecZero, gVecZero );
    static Float:vecVelocity[ 3 ];
    velocity_by_aim( pPlayer, PLASMA_VELOCITY, vecVelocity );
    entity_set_vector( pNail, EV_VEC_velocity, vecVelocity );
    static Float:vecAngles[ 3 ];
    engfunc( EngFunc_VecToAngles, vecVelocity, vecAngles );
    entity_set_vector( pNail, EV_VEC_angles, vecAngles );
    entity_set_edict( pNail, EV_ENT_owner, pPlayer );
    wpnmod_set_touch( pNail, "TNailb__Touch" );
    return 1;
}

public TNailb__Touch( pNail, pOther )
{
    if( !is_valid_ent( pNail ) )
        return;
    
    static Float:vecSrc[ 3 ];
    entity_get_vector( pNail, EV_VEC_origin, vecSrc );
    
    engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecSrc, 0 );
    write_byte( TE_EXPLOSION );
    engfunc( EngFunc_WriteCoord, vecSrc[ 0 ] );
    engfunc( EngFunc_WriteCoord, vecSrc[ 1 ] );
    engfunc( EngFunc_WriteCoord, vecSrc[ 2 ] );
    write_short( g_sModelIndexExplode );
    write_byte( 5 );
    write_byte( 15 );
    write_byte( TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND );
    message_end( );
    
    emit_sound( pNail, CHAN_WEAPON, SOUND_EXPLODE, 1.0, 1.0, 0, 100 );
        
    wpnmod_radius_damage( vecSrc, pNail, entity_get_edict( pNail, EV_ENT_owner ), WEAPON_DAMAGE, WEAPON_RADIUS, CLASS_NONE, DMG_BLAST );    
    remove_entity( pNail );    
}

public TNailAmmo__Spawn( pItem )
{
   
    SET_MODEL( pItem, AMMO_MODEL );
}

public TNailAmmo__AddAmmo( pItem, pPlayer )
{
    new iResult = 
    (
        ExecuteHamB
        (
            Ham_GiveAmmo, 
            pPlayer, 
            WEAPON_CLIP, 
            AMMO_NAME,
            AMMO_MAX
        ) != -1
    );
                                             
    if( iResult )
    {
        emit_sound( pItem, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
    }
    
    return iResult;
}
