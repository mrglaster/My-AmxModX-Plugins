#include <amxmodx>
#include <hl_wpnmod>
#include <xs>
#include <hamsandwich>
#include <engine>
#include <amxmisc>
#include <fun>

#define PLUGIN "[WPN] MG42"
#define VERSION "1.0"
#define AUTHOR "Glaster"

#define WEAPON_NAME "weapon_mg42"
#define WEAPON_SLOT 3
#define WEAPON_POSITION 3
#define WEAPON_PRIMARY_AMMO "mg42_clip"
#define WEAPON_PRIMARY_AMMO_MAX 240
#define WEAPON_SECONDARY_AMMO ""
#define WEAPON_SECONDARY_AMMO_MAX - 1
#define WEAPON_MAX_CLIP 120
#define WEAPON_DEFAULT_AMMO 100
#define WEAPON_FLAGS 0
#define WEAPON_WEIGHT 20
#define WEAPON_DAMAGE 6.0

#define NO_RECOIL Float:
{
	0.01, 0.01, 0.01
}
#define MODEL_WORLD "models/w_mg42.mdl"
#define MODEL_VIEW "models/v_mg42.mdl"
#define MODEL_PLAYER "models/p_mg42.mdl"
#define MODEL_AMMO "models/w_mg42_box.mdl"
#define WEAPON_HUD_SPRITE "sprites/weapon_mg42.spr"
#define WEAPON_HUD_TXT "sprites/weapon_mg42.txt"
#define SHOOT_SOUND "weapons/mg42_shoot.wav"
#define RELOAD_SOUND "weapons/mg42_reload.wav"
#define PICKUPDOWN_SOUND "weapons/mg42_pickup.wav"
#define AMMOBOX_CLASSNAME "ammo_mg42"
#define ANIM_EXTENSION "crossbow"


new mg42_player_sit[32];
public plugin_precache()
{
	precache_model(MODEL_WORLD)
	precache_model(MODEL_VIEW)
	precache_model(MODEL_PLAYER)
	precache_model(MODEL_AMMO)
	precache_model(WEAPON_HUD_SPRITE)
	precache_generic(WEAPON_HUD_TXT)
	precache_sound(SHOOT_SOUND)
	precache_sound(RELOAD_SOUND)
	precache_sound(PICKUPDOWN_SOUND)

}

public plugin_init()
{
	RegisterHam(Ham_Spawn, "player", "fwPlayerSpawn", 1)
	register_plugin(PLUGIN, VERSION, AUTHOR);
	new iMG42Ammo = wpnmod_register_ammobox(AMMOBOX_CLASSNAME);
	new mg42 = wpnmod_register_weapon(		WEAPON_NAME,
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
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_Spawn, "mg42_Spawn");
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_Deploy, "mg42_Deploy");
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_Idle, "mg42_Idle");
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_PrimaryAttack, "mg42_PrimaryAttack");
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_SecondaryAttack, "mg42_SecondaryAttack");
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_Reload, "mg42_Reload");\
	wpnmod_register_weapon_forward(mg42, Fwd_Wpn_Holster, "mg42_Holster");
	wpnmod_register_ammobox_forward(iMG42Ammo, Fwd_Ammo_Spawn, "mg42Ammo_Spawn");
	wpnmod_register_ammobox_forward(iMG42Ammo, Fwd_Ammo_AddAmmo, "mg42Ammo_AddAmmo");

}

public fwPlayerSpawn(id)
{
	mg42_player_sit[id] = 0;
}

public mg42_Spawn(const iItem)
{
	SET_MODEL(iItem, MODEL_WORLD);
	wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}

public mg42_Holster(const iItem, const iPlayer, const iClip)
{
	client_cmd(iPlayer, "-duck")
	set_user_normal_velocity(iPlayer)
}

public mg42_Deploy(const iItem, const iPlayer, const iClip)
{
	wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.5);
	wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 3.0);
	mg42_player_sit[iPlayer] = 0;
	return wpnmod_default_deploy(iItem, MODEL_VIEW, MODEL_PLAYER, 28, ANIM_EXTENSION);
	client_cmd(iPlayer, "-duck")
}

public mg42_Idle(const iItem, const iPlayer)
{
	wpnmod_reset_empty_sound(iItem);

	if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
	{
		return;
	}

	if (mg42_player_sit[iPlayer] == 0)
	{
		wpnmod_send_weapon_anim(iItem, 0);
	}
	else
	{
		wpnmod_send_weapon_anim(iItem, 10);
	}

	wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 2.0);
}

public mg42_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
	if (mg42_player_sit[iPlayer] == 1)
	{
		if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
		{
			if (mg42_player_sit[iPlayer] == 1)
			{
				mg42_player_sit[iPlayer] = 0;
				set_user_normal_velocity(iPlayer)
			}

			return;
		}

		wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, 58, 7.0);
		emit_sound(iPlayer, CHAN_WEAPON, RELOAD_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	else
	{
		client_print(iPlayer, print_center, "Place the machine gun on the bipod to ^r reload. To do this, press the ^r right mouse button")

	}
}

public mg42_SecondaryAttack(const iItem, const iPlayer, iClip, iAmmo)
{
	if (mg42_player_sit[iPlayer] == 0)
	{
		mg42_player_sit[iPlayer] = 1;
		client_cmd(iPlayer, "+duck")
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.5);
		wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 3.0);
		wpnmod_send_weapon_anim(iItem, 30);
		set_user_maxspeed(iPlayer, 1.0)
	}
	else if (mg42_player_sit[iPlayer] == 1)
	{
		mg42_player_sit[iPlayer] = 0;
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.5);
		wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 3.0);
		wpnmod_send_weapon_anim(iItem, 20);
		client_cmd(iPlayer, "-duck")
		set_user_normal_velocity(iPlayer)
	}
}

public mg42_PrimaryAttack(const iItem, const iPlayer, iClip, iAmmo)
{
	if (iClip <= 0 && iAmmo <= 0)
	{
		wpnmod_send_weapon_anim(iItem, 30);
		mg42_player_sit[iPlayer] = 0;
		set_user_maxspeed(iPlayer, 100.0)
		client_cmd(iPlayer, "-duck")

	}

	if (pev(iPlayer, pev_waterlevel) == 3 || iClip <= 0)
	{
		wpnmod_play_empty_sound(iItem);
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.09);
		return;
	}

	wpnmod_set_offset_int(iItem, Offset_iClip, iClip -= 1);
	wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
	wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);

	if (mg42_player_sit[iPlayer] == 1)
	{
		if (find(iPlayer))
		{
			wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.08);
		}
		else
		{
			wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
		}
	}
	else
	{
		wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
	}

	wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
	wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 3.0);

	wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
	if (mg42_player_sit[iPlayer] == 1)
	{
		wpnmod_send_weapon_anim(iItem, 49);
	}
	else
	{
		wpnmod_send_weapon_anim(iItem, 40);
	}

	wpnmod_fire_bullets
		(			iPlayer,
			iPlayer,
			6,
			NO_RECOIL,
			8192.0,
			WEAPON_DAMAGE,
			DMG_BULLET | DMG_NEVERGIB,
			4
	);

	emit_sound(iPlayer, CHAN_WEAPON, SHOOT_SOUND, 0.9, ATTN_NORM, 0, PITCH_NORM);
	set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) | EF_MUZZLEFLASH);

	if (mg42_player_sit[iPlayer] == 0)
	{
		set_recoil(iPlayer);
	}
}

public find(iPlayer)
{
	new Float: coords[3]
	pev(iPlayer, pev_origin, coords)
	new player = -1
	while ((player = engfunc(EngFunc_FindEntityInSphere, player, coords, 100.0)))
	{
		if (!is_user_alive(iPlayer))
		{
			break;
		}

		if (!is_user_alive(player))
		{
			continue;
		}

		if (get_user_team(player) == get_user_team(iPlayer) && player != iPlayer && mg42_player_sit[iPlayer] == 1)
		{
			client_print(iPlayer, print_center, "Somebody helps you to load the machine ^r gun belt! ^r The rate of fire is doubled! ")
			remove_entity(player)
			return 1
			break;
		}
	}
}

public set_recoil(iPlayer)
{
	new fAngles[3]
	static Float: flZVel;
	static Float: vecAngle[3];
	static Float: vecForward[3];
	static Float: vecVelocity[3];
	static Float: vecPunchangle[3];
	global_get(glb_v_forward, vecForward);
	pev(iPlayer, pev_v_angle, vecAngle);
	pev(iPlayer, pev_velocity, vecVelocity);
	pev(iPlayer, pev_punchangle, vecPunchangle);

	xs_vec_add(vecAngle, vecPunchangle, vecPunchangle);
	engfunc(EngFunc_MakeVectors, vecPunchangle);

	flZVel = vecVelocity[2];

	xs_vec_mul_scalar(vecForward, 1.0, vecPunchangle);
	xs_vec_sub(vecVelocity, vecPunchangle, vecVelocity);

	vecPunchangle[2] = 0.0;
	vecVelocity[2] = flZVel;

	vecPunchangle[0] = random_float(-8.0, 8.0);
	vecPunchangle[1] = random_float(-4.0, 4.0);

	set_pev(iPlayer, pev_velocity, vecVelocity);
	set_pev(iPlayer, pev_punchangle, vecPunchangle);
}

public mg42Ammo_Spawn(const iItem)
{
	SET_MODEL(iItem, MODEL_AMMO);
}

public mg42Ammo_AddAmmo(const iItem, const iPlayer)
{
	new iResult =
		(ExecuteHamB(	Ham_GiveAmmo,
				iPlayer,
				WEAPON_MAX_CLIP,
				WEAPON_PRIMARY_AMMO,
				WEAPON_PRIMARY_AMMO_MAX
		) != -1
	);

	if (iResult)
	{
		emit_sound(iItem, CHAN_ITEM, "items/9mmclip1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	}

	return iResult;
}

public set_user_normal_velocity(iPlayer)
{
	set_user_maxspeed(iPlayer, 330.0)
}
