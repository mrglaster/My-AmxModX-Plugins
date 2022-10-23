//Developed special for Hegemoinus server
#include <amxmodx>
#include <hamsandwich>
#include <hl_wpnmod>
#include <beams>            
#include <xs>                       

                          
#define PLUGIN "[WPNMOD] Railgun"
#define VERSION "1.3"                                    
#define AUTHOR "Glaster"                                                  

                          
//задаем параметры оружия                   
#define WEAPON_NAME             "weapon_railgun"  
#define AMMOBOX_CLASSNAME        "ammo_railshell"
#define WEAPON_SLOT            6                        
#define WEAPON_POSITION            5    
#define WEAPON_PRIMARY_AMMO        "Railshells"
#define WEAPON_PRIMARY_AMMO_MAX        20
#define WEAPON_SECONDARY_AMMO        "" // NULL
#define WEAPON_SECONDARY_AMMO_MAX    -1
#define WEAPON_MAX_CLIP            1
#define WEAPON_DEFAULT_AMMO        30
#define WEAPON_FLAGS            0
#define WEAPON_WEIGHT            15
#define WEAPON_DAMAGE            150.0     
#define MODEL_CLIP            "models/w_railshell.mdl"

// Hud                                                        
#define WEAPON_HUD_TXT            "sprites/weapon_railgun.txt"
#define WEAPON_HUD_SPR            "sprites/weapon_railgun.spr"   
#define WEAPON_AMMO_SPRITE         "sprites/weapon_plasmagun.spr"
                                                                                              
// Models
#define MODEL_WORLD            "models/w_railgun.mdl"
#define MODEL_VIEW            "models/v_railgun.mdl"
#define MODEL_PLAYER            "models/p_railgun.mdl"

// Sounds
#define SOUND_FIRE            "weapons/railgun_fire.wav"
#define SOUND_DRAW            "weapons/railgun_draw.wav"
#define SOUND_IMPACT            "weapons/railgun_hit.wav"        
 

// Sprites
#define SPRITE_LIGHTNING        "sprites/lgtning.spr"

// Beam
#define BEAM_LIFE            0.13                                            
#define BEAM_COLOR            { 20.0, 180.0, 0.0}
#define BEAM_BRIGHTNESS            255.0
#define BEAM_SCROLLRATE            10.0

// Animation 
//база для игрока
#define ANIM_EXTENSION            "gauss"
    
//анимации самого оружия, которые видит игрок
enum _:Animation{
        RAILGUN_IDLE, 
        RAILGUN_IDLE2,
        RAILGUN_FIDGET,
        RAILGUN_SPINUP,
        RAILGUN_SPIN,
        RAILGUN_FIRE,
        RAILGUN_FIRE2,
        RAILGUN_HOLSTER,
        RAILGUN_DRAW,
}

#define Beam_SetLife(%0,%1) \
    wpnmod_set_think(%0, "Beam_Remove"); \                                                   
    set_pev(%0, pev_nextthink, get_gametime() + %1)
    

public plugin_precache()               
{       
    PRECACHE_MODEL(MODEL_CLIP);
    PRECACHE_MODEL(MODEL_VIEW);
    PRECACHE_MODEL(MODEL_WORLD);
    PRECACHE_MODEL(MODEL_PLAYER);
    PRECACHE_MODEL(SPRITE_LIGHTNING);   
    PRECACHE_SOUND(SOUND_FIRE);
    PRECACHE_SOUND(SOUND_DRAW);
    PRECACHE_SOUND(SOUND_IMPACT);          
    PRECACHE_GENERIC(WEAPON_HUD_TXT);
    PRECACHE_GENERIC(WEAPON_HUD_SPR);
    PRECACHE_GENERIC(WEAPON_AMMO_SPRITE); 
}

//инициализация
public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    new iRailgun = wpnmod_register_weapon
    
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
    new iRailshell= wpnmod_register_ammobox(AMMOBOX_CLASSNAME); 
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_Spawn, "Railgun_Spawn");
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_Deploy, "Railgun_Deploy");
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_Idle, "Railgun_Idle");
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_Reload, "Railgun_Reload");
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_Holster, "Railgun_Holster");
    wpnmod_register_weapon_forward(iRailgun, Fwd_Wpn_PrimaryAttack, "Railgun_PrimaryAttack");
    
    wpnmod_register_ammobox_forward(iRailshell, Fwd_Ammo_Spawn, "Railshell_Spawn");
    wpnmod_register_ammobox_forward(iRailshell, Fwd_Ammo_AddAmmo, "Railshell_AddAmmo");
}


public Railgun_Spawn(const iItem)
{
    SET_MODEL(iItem, MODEL_WORLD);
    wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}                             



public Railgun_Deploy(const iItem, const iPlayer)
{
    
    return wpnmod_default_deploy(iItem, MODEL_VIEW, MODEL_PLAYER, RAILGUN_DRAW, ANIM_EXTENSION);
}                                                              


public Railgun_Holster(const iItem, const iPlayer)
{
   
    wpnmod_set_offset_int(iItem, Offset_iInReload, 0);
    }


public Railgun_Idle(const iItem, const iPlayer)
{
    wpnmod_reset_empty_sound(iItem);

    if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
    {
        return;                    
    }
    
    wpnmod_send_weapon_anim(iItem, RAILGUN_IDLE);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 10.03);
}

public Railgun_PrimaryAttack(const iItem, const iPlayer, const iClip)
{
    if (pev(iPlayer, pev_waterlevel) == 3 || iClip <= 0)
    {
        
        wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.15);
        return;
    }
    
    new Float: vecSrc[3], Float: vecEnd[3], iBeam, iTrace = create_tr2();
                                                                  
    wpnmod_get_gun_position(iPlayer, vecSrc);
    global_get(glb_v_forward, vecEnd);
    
    xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd);
    xs_vec_add(vecSrc, vecEnd, vecEnd);
    
    engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, iPlayer, iTrace);
    get_tr2(iTrace, TR_vecEndPos, vecEnd);
                                                                                
    if (pev_valid((iBeam = Beam_Create(SPRITE_LIGHTNING, 100.0))))
    {
        Beam_PointEntInit(iBeam, vecEnd, iPlayer);
        Beam_SetEndAttachment(iBeam, 1);
        Beam_SetBrightness(iBeam, BEAM_BRIGHTNESS);
        Beam_SetScrollRate(iBeam, BEAM_SCROLLRATE);
        Beam_SetColor(iBeam, BEAM_COLOR);
        Beam_SetLife(iBeam, BEAM_LIFE);
    }
    
    wpnmod_radius_damage2(vecEnd, iPlayer, iPlayer, WEAPON_DAMAGE, WEAPON_DAMAGE * 2.0, CLASS_NONE, DMG_ENERGYBEAM | DMG_ALWAYSGIB);
    
    engfunc(EngFunc_EmitSound, iPlayer, CHAN_AUTO, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
    engfunc(EngFunc_EmitAmbientSound, 0, vecEnd, SOUND_IMPACT, 0.9, ATTN_NORM, 0, PITCH_NORM);
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEnd, 0);
    write_byte(TE_DLIGHT);
    engfunc(EngFunc_WriteCoord, vecEnd[0]);
    engfunc(EngFunc_WriteCoord, vecEnd[1]);
    engfunc(EngFunc_WriteCoord, vecEnd[2]);
    write_byte(10);
    write_byte(100);
    write_byte(50);
    write_byte(253);
    write_byte(255);
    write_byte(25);
    write_byte(1);
    message_end();
    
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEnd, 0);
    write_byte(TE_SPARKS);
    engfunc(EngFunc_WriteCoord, vecEnd[0]);
    engfunc(EngFunc_WriteCoord, vecEnd[1]);
    engfunc(EngFunc_WriteCoord, vecEnd[2]);
    message_end();
    
    wpnmod_decal_trace(iTrace, engfunc(EngFunc_DecalIndex, "{smscorch1"));
    
    wpnmod_set_offset_int(iItem, Offset_iClip, iClip - 1);               
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);
    
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.1);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 1.03);
    
    wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
    wpnmod_send_weapon_anim(iItem, RAILGUN_FIRE);
                   
    free_tr2(iTrace);
}                                          



public Railgun_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
    if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
    {
        return;
    }
    
    wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, RAILGUN_FIDGET, 1.4);
}                                                   


public Beam_Remove(const iBeam)
{
    set_pev(iBeam, pev_flags, FL_KILLME);
}       

public Railshell_Spawn(const iItem)
{
    // Setting world model
    SET_MODEL(iItem, MODEL_CLIP);
}

public Railshell_AddAmmo(const iItem, const iPlayer)
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
