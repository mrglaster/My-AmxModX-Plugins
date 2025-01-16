#include <amxmodx>
#include <hamsandwich>
#include <hl_wpnmod>
#include <xs>

#define PLUGIN_NAME "[Weapon] OP4 Desert Eagle"
#define PLUGIN_AUTHOR "Glaster"
#define PLUGIN_VERSION "1.1"

#define WEAPON_NAME "weapon_eagle"
#define WEAPON_DAMAGE 40.0
#define WEAPON_SLOT 2
#define WEAPON_POSITION  3
#define WEAPON_PRIMARY_AMMO "ammo_357"
#define WEAPON_PRIMARY_AMMO_MAX 35
#define WEAPON_SECONDARY_AMMO "" 
#define WEAPON_SECONDARY_AMMO_MAX -1
#define WEAPON_MAX_CLIP 7
#define WEAPON_DEFAULT_AMMO  7 
#define WEAPON_FLAGS  0
#define WEAPON_WEIGHT 10
#define ANIM_EXTENSION "python"

#define V_MODEL "models/op4/v_desert_eagle_op4_hev.mdl"
#define W_MODEL "models/op4/w_desert_eagle_op4.mdl"
#define P_MODEL "models/op4/p_desert_eagle_op4.mdl"

#define HUD_SPR1 "sprites/320hud2.spr"
#define HUD_SPR2 "sprites/320hudof01"
#define HUD_SPR3 "sprites/640hud7.spr"
#define HUD_SPR4 "sprites/640hudof01.spr"
#define HUD_SPR5 "sprites/640hudof02.spr"
#define HUD_SPR6 "sprites/crosshairs.spr"
#define HUD_SPR7 "sprites/ofch1.spr"
#define HUD_TXT "sprites/weapon_eagle.txt"

#define HUD_HR_SPR1 "sprites/1280/640hudof01.spr"
#define HUD_HR_SPR2 "sprites/1280/640hudof02.spr"
#define HUD_HR_SPR3 "sprites/1280/weapon_357_ammo.spr"

#define HUD_HR_SPR4 "sprites/2560/640hudof01.spr"
#define HUD_HR_SPR5 "sprites/2560/640hudof02.spr"
#define HUD_HR_SPR6 "sprites/2560/weapon_357_ammo.spr"

#define SOUND_FIRE "weapons/desert_eagle_fire.wav"
#define SOUND_RELOAD "weapons/desert_eagle_reload.wav"
#define SOUND_SIGHT "weapons/desert_eagle_sight.wav"
#define SOUND_SIGHT2 "weapons/desert_eagle_sight2.wav" 

#define RELOAD_TIME 1.68

enum _:Animation{
    ANIM_IDLE1 = 0,
    ANIM_IDLE2,
    ANIM_IDLE3,
    ANIM_IDLE4,
    ANIM_IDLE5,
    ANIM_SHOOT,
    ANIM_SHOOT_EMPTY,
    ANIM_RELOAD,
    ANIM_RELOAD_NO_SHOT,
    ANIM_DRAW,
    ANIM_HOLSTER

}

public plugin_precache(){

    precache_model(V_MODEL)
    precache_model(W_MODEL)
    precache_model(P_MODEL)

    precache_generic(HUD_SPR1)
    precache_generic(HUD_SPR2)
    precache_generic(HUD_SPR3)
    precache_generic(HUD_SPR4)
    precache_generic(HUD_SPR5)
    precache_generic(HUD_SPR6)
    precache_generic(HUD_SPR7)
    precache_generic(HUD_TXT)
    
    precache_generic(HUD_HR_SPR1)
    precache_generic(HUD_HR_SPR2)
    precache_generic(HUD_HR_SPR3)
    precache_generic(HUD_HR_SPR4)
    precache_generic(HUD_HR_SPR5)
    precache_generic(HUD_HR_SPR6)

    precache_sound(SOUND_FIRE)
    precache_sound(SOUND_RELOAD)
    precache_sound(SOUND_SIGHT)
    precache_sound(SOUND_SIGHT2)
}


public plugin_init(){
    
    register_plugin(PLUGIN_NAME, PLUGIN_AUTHOR, PLUGIN_VERSION)

    new eagle = wpnmod_register_weapon(
        WEAPON_NAME,
        WEAPON_SLOT,
        WEAPON_POSITION,
        WEAPON_PRIMARY_AMMO,
        WEAPON_PRIMARY_AMMO_MAX,
        WEAPON_SECONDARY_AMMO,                           
        WEAPON_SECONDARY_AMMO_MAX,
        WEAPON_MAX_CLIP,
        WEAPON_FLAGS,
        WEAPON_WEIGHT
    );

    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_Spawn, "Eagle_Spawn");
    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_Deploy, "Eagle_Deploy");
    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_Idle, "Eagle_Idle");
    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_PrimaryAttack, "Eagle_PrimaryAttack");
    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_Reload, "Eagle_Reload");
    wpnmod_register_weapon_forward(eagle, Fwd_Wpn_Holster, "Eagle_Holster");
}


public Eagle_Spawn(const iItem)
{                              
    SET_MODEL(iItem, W_MODEL);
    wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}

public Eagle_Deploy(const iItem, const iPlayer, const iClip)
{
    return wpnmod_default_deploy(iItem, V_MODEL, P_MODEL, ANIM_DRAW, ANIM_EXTENSION);
}

public Eagle_Idle(const iItem, const iPlayer, const iClip)
{
    wpnmod_reset_empty_sound(iItem);

    if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
    {
        return;
    }
    wpnmod_send_weapon_anim(iItem, iClip ? ANIM_IDLE3 : ANIM_IDLE3);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 4.0);
}

public Eagle_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
	if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
	{
		return;
	}
	
    if (iClip > 0){
        wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, ANIM_RELOAD_NO_SHOT, RELOAD_TIME);
    } else {
        wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, ANIM_RELOAD, RELOAD_TIME);
    }
	emit_sound(iPlayer, CHAN_WEAPON, SOUND_RELOAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
}


public Eagle_PrimaryAttack(const iItem, const iPlayer, iClip)
{
	static Float: flZVel;
	static Float: vecAngle[3];
	static Float: vecForward[3];
	static Float: vecVelocity[3];
	static Float: vecPunchangle[3];
	
	if (pev(iPlayer, pev_waterlevel) == 3 || iClip <= 0)
	{
		wpnmod_play_empty_sound(iItem);
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
		return;
	}
	
	wpnmod_set_offset_int(iItem, Offset_iClip, iClip -= 1)
	wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME)
	wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH)
	wpnmod_fire_bullets(iPlayer,iPlayer,1, VECTOR_CONE_2DEGREES, 8192.0, WEAPON_DAMAGE, DMG_BULLET | DMG_NEVERGIB, 3)
	wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.4)
	wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 7.0)
	

	wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
    if (iClip == 1){
        wpnmod_send_weapon_anim(iItem, ANIM_SHOOT_EMPTY);
    } else {
         wpnmod_send_weapon_anim(iItem, ANIM_SHOOT);
    }
	

	emit_sound(iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
	
	global_get(glb_v_forward, vecForward);
	
	pev(iPlayer, pev_v_angle, vecAngle);
	pev(iPlayer, pev_velocity, vecVelocity);
	pev(iPlayer, pev_punchangle, vecPunchangle);
	
	xs_vec_add(vecAngle, vecPunchangle, vecPunchangle);
	engfunc(EngFunc_MakeVectors, vecPunchangle);
	
	flZVel = vecVelocity[2];
	
	xs_vec_mul_scalar(vecForward, 35.0, vecPunchangle);
	xs_vec_sub(vecVelocity, vecPunchangle, vecVelocity);
	
	vecPunchangle[2] = 1.0;
	vecVelocity[2] = flZVel;
	
	vecPunchangle[0] = -8.0;
	vecPunchangle[1] = random_float(-2.0, 2.0);
	 
	set_pev(iPlayer, pev_velocity, vecVelocity);
	set_pev(iPlayer, pev_punchangle, vecPunchangle);
}
