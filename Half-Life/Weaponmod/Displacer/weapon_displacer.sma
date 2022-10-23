#include < amxmodx >
#include < engine >                                              
#include < fakemeta >
#include < hamsandwich >                                                                
#include < hl_wpnmod >              
#include < xs >
                          
#define WEAPON_NAME             "weapon_displacer"
#define WEAPON_SLOT            4
#define WEAPON_POSITION            4
#define WEAPON_SECONDARY_AMMO        "" // NULL    
#define WEAPON_SECONDARY_AMMO_MAX    -1
#define WEAPON_CLIP            -1
#define WEAPON_FLAGS            0
#define WEAPON_WEIGHT            15
#define WEAPON_RELOADTIME        3.36
#define WEAPON_REFIRE_RATE        0.15
#define WEAPON_DAMAGE            200.0        
#define WEAPON_RADIUS            300.0

#define AMMO_NAME            "uranium"  
#define AMMO_MAX            250
#define AMMO_DEFAULT            30

#define MODEL_P                "models/p_displacer_cannon.mdl"
#define MODEL_V                "models/v_displacer_cannon.mdl" 
#define MODEL_W                "models/w_displacer_cannon.mdl" 

#define SOUND_FIRE            "weapons/displacer_fire.wav"
#define SOUND_EXPLODE            "weapons/displacer_teleport.wav"  
#define DISPLACER_TELEPORT_SELF "weapons/displacer_teleport_self.wav"  
#define EMPTY_SOUND "weapons/ar2_empty1.wav"

#define PLASMA_MODEL            "sprites/exit1.spr"
#define PLASMA_EXPLODE            "sprites/displacer_ring.spr"
#define PLASMA_VELOCITY 300                   
#define DISPLACER_EXIT_ALIVE_TIME 1.6
#define CLASS_PLASMA            "monster_plasma"  
#define ANIM_EXTENSION            "gauss"  

const m_flNextSecondaryAttack        = 36
new const gClassname[] = "self_disp" 
new g_sModelIndexExplode;
new g_SpawnsId[64]
new const Float:gVecZero[ ]        = { 0.0, 0.0, 0.0 };  
new mExitPortal;
new respent;
new const HUD_SPRITES[ ][ ]        =
{
    "sprites/weapon_displacer.txt",
    "sprites/weapon_displacer.spr"
}; 
enum _:Animation{
        DISPLACER_IDLE, 
        DISPLACER_IDLE2,               
        DISPLACER_SPINUP,   
        DISPLACER_SPIN,
        DISPLACER_FIRE,   
        DISPLACER_DRAW,
        DISPLACER_HOLSTER 
}                                 

enum _: Animation
{
	DISPLACER_IDLE,
	DISPLACER_IDLE2,
	DISPLACER_SPINUP,
	DISPLACER_SPIN,
	DISPLACER_FIRE,
	DISPLACER_DRAW,
	DISPLACER_HOLSTER
}

public plugin_precache()
{
	new i;
	PRECACHE_MODEL(MODEL_P);
	PRECACHE_MODEL(MODEL_V);
	PRECACHE_MODEL(MODEL_W);
	PRECACHE_SOUND(SOUND_FIRE);
	PRECACHE_SOUND(EMPTY_SOUND);
	PRECACHE_SOUND(SOUND_EXPLODE);
	PRECACHE_SOUND(DISPLACER_TELEPORT_SELF);

	mExitPortal = PRECACHE_MODEL(PLASMA_MODEL);
	g_sModelIndexExplode = PRECACHE_MODEL(PLASMA_EXPLODE);
	for (i = 0; i < sizeof HUD_SPRITES; i++)
		PRECACHE_GENERIC(HUD_SPRITES[i]);
}

public plugin_init()
{
	register_touch(gClassname, "player", "EntityTouch")
	register_plugin("[WPN] DISPLACER", "1.3", "Glaster");
	new pWeapon = wpnmod_register_weapon(		WEAPON_NAME,
		WEAPON_SLOT,
		WEAPON_POSITION,
		AMMO_NAME,
		AMMO_MAX,
		WEAPON_SECONDARY_AMMO,
		WEAPON_SECONDARY_AMMO_MAX,
		-1,
		WEAPON_FLAGS,
		WEAPON_WEIGHT
);

	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_Spawn, "Displacer__Spawn");
	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_Deploy, "Displacer__Deploy");
	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_Idle, "Displacer__WeaponIdle");
	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_PrimaryAttack, "Displacer__PrimaryAttack");
	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_Holster, "Displacer__Holster");
	wpnmod_register_weapon_forward(pWeapon, Fwd_Wpn_SecondaryAttack, "Displacer_SecondaryAttack");
	register_touch(gClassname, "player", "EntityTouch");
	start_map()

}

public Displacer__Spawn(pItem)
{
	SET_MODEL(pItem, MODEL_W);
	wpnmod_set_offset_int(pItem, Offset_iDefaultAmmo, AMMO_DEFAULT);
}

public Displacer__Deploy(pItem)
{
	return wpnmod_default_deploy(pItem, MODEL_V, MODEL_P, DISPLACER_DRAW, ANIM_EXTENSION);
}

public Displacer__Holster(pItem, pPlayer)
{
	wpnmod_set_offset_int(pItem, Offset_iInReload, 0);
}

public Displacer__PrimaryAttack(pItem, pPlayer, iClip, rgAmmo)
{
	if (rgAmmo - 25 <= 0 || entity_get_int(pPlayer, EV_INT_waterlevel) == 3)
	{
		emit_sound(pPlayer, CHAN_WEAPON, EMPTY_SOUND, 0.9, ATTN_NORM, 0, PITCH_NORM);
		wpnmod_set_offset_float(pItem, Offset_flNextPrimaryAttack, 1.5);
		return;
	}

	if (CPlasmab__Spawn(pPlayer))
	{
		wpnmod_set_offset_int(pPlayer, Offset_iWeaponVolume, NORMAL_GUN_VOLUME);
		wpnmod_set_offset_int(pPlayer, Offset_iWeaponFlash, DIM_GUN_FLASH);
		wpnmod_set_player_ammo(pPlayer, AMMO_NAME, rgAmmo - 25)
		entity_set_int(pPlayer, EV_INT_effects, entity_get_int(pPlayer, EV_INT_effects) | EF_MUZZLEFLASH);
		wpnmod_set_player_anim(pPlayer, PLAYER_ATTACK1);
		wpnmod_set_offset_float(pItem, Offset_flNextPrimaryAttack, WEAPON_REFIRE_RATE);
		wpnmod_set_offset_float(pItem, Offset_flTimeWeaponIdle, WEAPON_REFIRE_RATE + 3.0);
		emit_sound(pPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
		wpnmod_send_weapon_anim(pItem, DISPLACER_FIRE);
		entity_set_vector(pPlayer, EV_VEC_punchangle, Float:
		{-5.0, 0.0, 0.0 });
		wpnmod_set_offset_float(pItem, Offset_flNextPrimaryAttack, 3.00)
	}
}

public Displacer__WeaponIdle(pItem, pPlayer, iClip, iAmmo)
{
	wpnmod_reset_empty_sound(pItem);
	if (wpnmod_get_offset_float(pItem, Offset_flTimeWeaponIdle) > 0.0)
		return;

	wpnmod_send_weapon_anim(pItem, DISPLACER_IDLE);
	wpnmod_set_offset_float(pItem, Offset_flTimeWeaponIdle, random_float(5.0, 15.0));
}

CPlasmab__Spawn(pPlayer)
{
	new pPlasma = create_entity("env_sprite");
	respent = pPlasma;
	register_touch("trigger_once", "player", "FwdPlayerTouchTriggerOnce");
	if (pPlasma <= 0)
		return 0;
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_KILLBEAM);
	write_short(pPlasma);
	message_end();
	entity_set_string(pPlasma, EV_SZ_classname, CLASS_PLASMA);
	entity_set_model(pPlasma, PLASMA_MODEL);
	static Float: vecSrc[3];
	wpnmod_get_gun_position(pPlayer, vecSrc, 25.0, 16.0, -7.0);
	entity_set_origin(pPlasma, vecSrc);
	entity_set_int(pPlasma, EV_INT_movetype, MOVETYPE_FLY);
	entity_set_int(pPlasma, EV_INT_solid, SOLID_BBOX);
	entity_set_size(pPlasma, gVecZero, gVecZero);
	set_pev(pPlasma, pev_scale, 3.5)
	entity_set_float(pPlasma, EV_FL_renderamt, 255.0);
	entity_set_float(pPlasma, EV_FL_scale, 0.3);
	entity_set_int(pPlasma, EV_INT_rendermode, kRenderTransAdd);
	entity_set_int(pPlasma, EV_INT_renderfx, kRenderFxGlowShell);
	static Float: vecVelocity[3];
	velocity_by_aim(pPlayer, PLASMA_VELOCITY, vecVelocity);
	entity_set_vector(pPlasma, EV_VEC_velocity, vecVelocity);
	static Float: vecAngles[3];
	engfunc(EngFunc_VecToAngles, vecVelocity, vecAngles);
	entity_set_vector(pPlasma, EV_VEC_angles, vecAngles);
	entity_set_edict(pPlasma, EV_ENT_owner, pPlayer);
	wpnmod_set_touch(pPlasma, "CPlasmab__Touch");
	wpnmod_set_think(pPlasma, "Displacer_Time_To_Explode");
	set_pev(pPlasma, pev_nextthink, get_gametime() + DISPLACER_EXIT_ALIVE_TIME);
	return 1;
}

public Displacer_Time_To_Explode(pPlasma, iPlayer, iClip, iAmmo)
{
	if (!is_valid_ent(pPlasma))
		return;

	static Float: vecSrc[3];
	entity_get_vector(pPlasma, EV_VEC_origin, vecSrc);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecSrc, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecSrc[0]);
	engfunc(EngFunc_WriteCoord, vecSrc[1]);
	engfunc(EngFunc_WriteCoord, vecSrc[2]);
	write_short(g_sModelIndexExplode);
	write_byte(5);
	write_byte(15);
	write_byte(TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);
	message_end();

	emit_sound(pPlasma, CHAN_WEAPON, SOUND_EXPLODE, 1.0, 1.0, 0, 100);
	new Float: origin[3];
	pev(pPlasma, pev_origin, origin);
	UTIL_MakeBeamCylinder(origin, g_sModelIndexExplode);
	wpnmod_radius_damage(vecSrc, pPlasma, entity_get_edict(pPlasma, EV_ENT_owner), WEAPON_DAMAGE, WEAPON_RADIUS, CLASS_NONE, DMG_ACID | DMG_ENERGYBEAM);
	remove_entity(pPlasma);

}

public CPlasmab__Touch(pPlasma, pOther)
{
	if (!is_valid_ent(pPlasma))
		return;

	static Float: vecSrc[3];
	entity_get_vector(pPlasma, EV_VEC_origin, vecSrc);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecSrc, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord, vecSrc[0]);
	engfunc(EngFunc_WriteCoord, vecSrc[1]);
	engfunc(EngFunc_WriteCoord, vecSrc[2]);
	write_short(g_sModelIndexExplode);
	write_byte(5);
	write_byte(15);
	write_byte(TE_EXPLFLAG_NOPARTICLES | TE_EXPLFLAG_NOSOUND);
	message_end();

	emit_sound(pPlasma, CHAN_WEAPON, SOUND_EXPLODE, 1.0, 1.0, 0, 100);
	new Float: origin[3];
	pev(pPlasma, pev_origin, origin);
	UTIL_MakeBeamCylinder(origin, g_sModelIndexExplode);
	wpnmod_radius_damage(vecSrc, pPlasma, entity_get_edict(pPlasma, EV_ENT_owner), WEAPON_DAMAGE, WEAPON_RADIUS, CLASS_NONE, DMG_ACID | DMG_ENERGYBEAM);
	remove_entity(pPlasma);
}

public Displacer_SecondaryAttack(iItem, iPlayer, iClip, iAmmo)
{
	if (iAmmo - 25 < 0)
	{
		emit_sound(iPlayer, CHAN_WEAPON, EMPTY_SOUND, 0.9, ATTN_NORM, 0, PITCH_NORM);
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.5);
		return;
	}

	emit_sound(iPlayer, CHAN_WEAPON, DISPLACER_TELEPORT_SELF, 1.0, 1.0, 0, 100);
	wpnmod_set_player_ammo(iPlayer, AMMO_NAME, iAmmo - 25)
	new spawnId
	new Float: origin[3]
	new Float: angles[3]
	new player = pev(iPlayer, pev_owner)
	wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 1.3);

	wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
	wpnmod_send_weapon_anim(iItem, DISPLACER_SPINUP);

	wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 4.00);
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "cycler_sprite"))
	set_pev(ent, pev_rendermode, kRenderTransAdd)
	engfunc(EngFunc_SetModel, ent, "sprites/exit1.spr")
	set_pev(ent, pev_renderamt, 255.0)
	set_pev(ent, pev_animtime, 1.0)
	set_pev(ent, pev_framerate, 50.0)
	set_pev(ent, pev_frame, 10)

	pev(player, pev_origin, origin)

	set_pev(ent, pev_origin, origin)
	dllfunc(DLLFunc_Spawn, ent)
	set_pev(ent, pev_solid, SOLID_NOT)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_byte(35)
	write_byte(80)
	write_byte(255)
	write_byte(100)
	write_byte(80)
	write_byte(60)
	message_end()

	spawnId = g_SpawnsId[random_num(0, strlen(g_SpawnsId) - 1)]

	pev(spawnId, pev_origin, origin)
	pev(spawnId, pev_angles, angles)
	set_pev(iPlayer, pev_origin, origin)
	set_pev(iPlayer, pev_angles, angles)
	set_pev(iPlayer, pev_fixangle, 1)
	set_pev(iPlayer, pev_velocity,
	{
		0.0, 0.0, 0.0 })
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"),
	{ 0, 0, 0 }, iPlayer)
	write_short(1 << 10)
	write_short(1 << 3)
	write_short(0)
	write_byte(100)
	write_byte(255)
	write_byte(100)
	write_byte(150)
	message_end()

	set_pdata_float(iPlayer, m_flNextSecondaryAttack, 60.0, 4)
	set_task(0.5, "remove_telesprite_task", ent + 33453)

}

public start_map()
{
	new cfg_dir[64]
	new map_name[32]
	new equip_file[128]
	new no_eqip_file

	new ent
	new i
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_deathmatch")))
	{
		g_SpawnsId[i++] = ent
		if (i == sizeof g_SpawnsId)
			break
	}
}

public remove_telesprite_task(ent)
{
	ent -= 33453
	if (pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)
}

stock UTIL_MakeBeamCylinder(const Float: origin[3], const m_Sprite)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2]);
	engfunc(EngFunc_WriteCoord, origin[0]);
	engfunc(EngFunc_WriteCoord, origin[1]);
	engfunc(EngFunc_WriteCoord, origin[2] + 800.0);
	write_short(m_Sprite);
	write_byte(0);
	write_byte(10);
	write_byte(3);
	write_byte(20);
	write_byte(0);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(255);
	write_byte(0);
	message_end();
}
