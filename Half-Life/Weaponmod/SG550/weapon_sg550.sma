#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <hl_wpnmod>

                      
#define PLUGIN "[WPN] SG550"
#define VERSION "1.0"     
#define AUTHOR "Glaster"


// Weapon settings
#define WEAPON_NAME             "weapon_sg"
#define WEAPON_SLOT            3
#define WEAPON_POSITION            4
#define WEAPON_PRIMARY_AMMO        "762"
#define WEAPON_PRIMARY_AMMO_MAX        15
#define WEAPON_SECONDARY_AMMO        "" // NULL
#define WEAPON_SECONDARY_AMMO_MAX    -1
#define WEAPON_MAX_CLIP            5
#define WEAPON_DEFAULT_AMMO        5 
#define WEAPON_FLAGS            0
#define WEAPON_WEIGHT            10
#define WEAPON_DAMAGE            100.0

// Hud
#define WEAPON_HUD_TXT_1        "sprites/weapon_sg.txt"
#define WEAPON_HUD_SPR_1        "sprites/weapon_sg.spr"
#define WEAPON_HUD_SPR_2        "sprites/ofch2.spr"
                                                            
// Ammobox
#define AMMOBOX_CLASSNAME        "ammo_762"

// Models
#define MODEL_WORLD            "models/w_sg550.mdl"
#define MODEL_VIEW            "models/v_sg550.mdl"
#define MODEL_PLAYER            "models/p_sg550.mdl"
#define MODEL_CLIP            "models/w_m40a1clip.mdl"

// Sounds
#define SOUND_FIRE            "weapons/sg550-1.wav"
#define SOUND_ZOOM            "weapons/sniper_zoom.wav"
#define SOUND_BOLT_1            "weapons/sg550_boltpull.wav"
#define SOUND_BOLT_2            "weapons/sg550_boltpull.wav"
#define SOUND_RELOAD_1            "weapons/sg550_clipout.wav"
#define SOUND_RELOAD_2            "weapons/sg550_clipin.wav"
#define SOUND_RELOAD_3            "weapons/sg550_boltpull.wav"

// Animation
#define ANIM_EXTENSION            "gauss"

enum _:Animation
{                                                                                    
    ANIM_IDLE = 0,
    ANIM_FIRE,
    ANIM_FIRE2,
    ANIM_RELOAD,
    ANIM_DRAW
};

//**********************************************
//* Precache resources                         *
//**********************************************

public plugin_precache()
{
    PRECACHE_MODEL(MODEL_VIEW);
    PRECACHE_MODEL(MODEL_WORLD);
    PRECACHE_MODEL(MODEL_PLAYER);
    PRECACHE_MODEL(MODEL_CLIP);
    
    PRECACHE_SOUND(SOUND_FIRE);
    PRECACHE_SOUND(SOUND_ZOOM);
    PRECACHE_SOUND(SOUND_BOLT_1);
    PRECACHE_SOUND(SOUND_BOLT_2);
    PRECACHE_SOUND(SOUND_RELOAD_1);
    PRECACHE_SOUND(SOUND_RELOAD_2);
    PRECACHE_SOUND(SOUND_RELOAD_3);
    PRECACHE_GENERIC("sprites/weapon_sg_scp.txt")                             
    PRECACHE_GENERIC(WEAPON_HUD_TXT_1);
    PRECACHE_GENERIC(WEAPON_HUD_SPR_1);
    PRECACHE_GENERIC(WEAPON_HUD_SPR_2);
}



public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    new iM40A1 = wpnmod_register_weapon
    
    (
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
    
    new iAmmo762 = wpnmod_register_ammobox(AMMOBOX_CLASSNAME);
    
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_Spawn, "M40A1_Spawn");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_Deploy, "M40A1_Deploy");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_Idle, "M40A1_Idle");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_PrimaryAttack, "M40A1_PrimaryAttack");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_SecondaryAttack, "M40A1_SecondaryAttack");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_Reload, "M40A1_Reload");
    wpnmod_register_weapon_forward(iM40A1, Fwd_Wpn_Holster, "M40A1_Holster");
    
    wpnmod_register_ammobox_forward(iAmmo762, Fwd_Ammo_Spawn, "Ammo762_Spawn");
    wpnmod_register_ammobox_forward(iAmmo762, Fwd_Ammo_AddAmmo, "Ammo762_AddAmmo");
}

//**********************************************
//* Weapon spawn.                              *
//**********************************************

public M40A1_Spawn(const iItem)
{                              
    SET_MODEL(iItem, MODEL_WORLD);
    wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}


public M40A1_Deploy(const iItem, const iPlayer, const iClip)
{
    return wpnmod_default_deploy(iItem, MODEL_VIEW, MODEL_PLAYER, ANIM_DRAW, ANIM_EXTENSION);
}



public M40A1_Holster(const iItem, const iPlayer)
{
    new Float: flFov;                    
    
    if (pev(iPlayer, pev_fov, flFov) && flFov != 0.0)
    {
        M40A1_SecondaryAttack(iItem, iPlayer);
    }

    wpnmod_set_offset_int(iItem, Offset_iInReload, 0);
}



public M40A1_Idle(const iItem, const iPlayer, const iClip)
{
    wpnmod_reset_empty_sound(iItem);

    if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
    {
        return;
    }
    
    wpnmod_send_weapon_anim(iItem, iClip ? ANIM_IDLE : ANIM_IDLE);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 4.0);
}



public M40A1_PrimaryAttack(const iItem, const iPlayer, iClip)
{
    if (pev(iPlayer, pev_waterlevel) == 3 || iClip <= 0)
    {
        wpnmod_play_empty_sound(iItem);
        wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
        return;
    }
    
    wpnmod_set_offset_int(iItem, Offset_iClip, iClip -= 1);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);
    
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.3);
    wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 1.0);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 7.0);
    
    wpnmod_send_weapon_anim(iItem, iClip ? ANIM_FIRE : ANIM_FIRE);
    wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
    
    wpnmod_fire_bullets
    (
        iPlayer, 
        iPlayer, 
        1,                                                 
        Float: {0.0001, 0.0001, 0.0001}, 
        8192.0, 
        WEAPON_DAMAGE, 
        DMG_BULLET | DMG_NEVERGIB, 
        0
    );
    
    emit_sound(iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
    
    set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) | EF_MUZZLEFLASH);
    set_pev(iPlayer, pev_punchangle, Float: {-4.0, 0.0, 0.0});
}

                                                       
public M40A1_SecondaryAttack(const iItem, const iPlayer)
{
    new Float: flFov;                         
    
    if (pev(iPlayer, pev_fov, flFov) && flFov != 0.0)
    {
        MakeZoom(iItem, iPlayer, "weapon_sg", 0.0);
        
    }
    else if (flFov != 20.0)
    {
        MakeZoom(iItem, iPlayer, "weapon_sg_scp", 20.0);
    }
    
    emit_sound(iPlayer, CHAN_ITEM, SOUND_ZOOM, random_float(0.95, 1.0), ATTN_NORM, 0, PITCH_NORM);
    
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.1);
    wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 0.8);
}

MakeZoom(const iItem, const iPlayer, const szWeaponName[], const Float: flFov)
{
    static msgWeaponList;
    
    set_pev(iPlayer, pev_fov, flFov);
    wpnmod_set_offset_int(iPlayer, Offset_iFOV, _:flFov);
        
    if (msgWeaponList || (msgWeaponList = get_user_msgid("WeaponList")))        
    {
        message_begin(MSG_ONE, msgWeaponList, .player = iPlayer);
        write_string(szWeaponName);
        write_byte(wpnmod_get_offset_int(iItem, Offset_iPrimaryAmmoType));
        write_byte(WEAPON_PRIMARY_AMMO_MAX);
        write_byte(wpnmod_get_offset_int(iItem, Offset_iSecondaryAmmoType));
        write_byte(WEAPON_SECONDARY_AMMO_MAX);
        write_byte(WEAPON_SLOT - 1);
        write_byte(WEAPON_POSITION - 1);
        write_byte(get_user_weapon(iPlayer));
        write_byte(WEAPON_FLAGS);
        message_end();
    }
}


public M40A1_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
    if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
    {
        return;
    }
    
    new Float: flFov;
    
    if (pev(iPlayer, pev_fov, flFov) && flFov != 0.0)
    {
        M40A1_SecondaryAttack(iItem, iPlayer);
    }
     
        wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, ANIM_RELOAD, 3.8);
    

}


public Ammo762_Spawn(const iItem)
{
    // Setting world model
    SET_MODEL(iItem, MODEL_CLIP);
}



public Ammo762_AddAmmo(const iItem, const iPlayer)
{
    new iResult = 
    (
        ExecuteHamB
        (
            Ham_GiveAmmo, 
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
                                                                    
