#include <amxmodx>
#include <hl_wpnmod>
#include <fakemeta>
#include <hamsandwich>
#include <fun>   
#include <xs>
#define PLUGIN "[WPN] USAS-12"
#define VERSION "1.0.0"     
#define AUTHOR "Glaster"     

//Configs
#define WEAPON_NAME "weapon_usas"
#define WEAPON_SLOT    2
#define WEAPON_POSITION    5
#define WEAPON_PRIMARY_AMMO    "buckshot"
#define WEAPON_PRIMARY_AMMO_MAX    60
#define WEAPON_SECONDARY_AMMO    ""
#define WEAPON_SECONDARY_AMMO_MAX    0
#define WEAPON_MAX_CLIP    12
#define WEAPON_DEFAULT_AMMO     50
#define WEAPON_FLAGS    0
#define WEAPON_WEIGHT    20
#define WEAPON_DAMAGE    8.0
#define WEAPON_RATE_OF_FIRE    0.4
// Models
#define MODEL_WORLD    "models/w_usas.mdl"
#define MODEL_VIEW    "models/v_usas.mdl"
#define MODEL_PLAYER    "models/p_usas.mdl"

// Hud
#define WEAPON_HUD_TXT    "sprites/weapon_usas.txt"
#define WEAPON_HUD_BAR    "sprites/weapon_usas.spr"

// Sounds
#define SOUND_FIRE    "weapons/saiga_shoot1.wav"
#define SOUND_RELOAD    "weapons/usas_clipout.wav"
#define SOUND_DEPLOY "weapons/usas_slideback.wav"   
#define SOUND_MISS_1            "weapons/bayonet_slash1.wav"
#define SOUND_MISS_2            "weapons/bayonet_slash2.wav"
#define SOUND_MISS_3            "weapons/bayonet_slash3.wav"
#define SOUND_HIT_WALL            "weapons/bayonet_hit_wall.wav"
#define SOUND_HIT_FLESH_1        "weapons/knife_hit_flesh1.wav"
#define SOUND_HIT_FLESH_2        "weapons/knife_hit_flesh2.wav"

// Animation
#define ANIM_EXTENSION    "shotgun"

public plugin_init() 
{                                                                          
    register_plugin(
    
    PLUGIN,
    VERSION,
    AUTHOR
    );
    new saiga = wpnmod_register_weapon
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
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_Spawn,         "S12_Spawn" );
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_Deploy,         "S12_Deploy" );
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_Idle,         "S12_Idle" );
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_PrimaryAttack,    "S12_PrimaryAttack" );
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_Reload,         "S12_Reload" );
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_Holster,         "S12_Holster" ); 
    wpnmod_register_weapon_forward(saiga, Fwd_Wpn_SecondaryAttack, "S12_SecondaryAttack");
}
enum _:cz_VUL
{
    idle1,
    reload_1,
    draw,
    shot1,      
    stocks,

}; 
public plugin_precache()
{
    PRECACHE_MODEL(MODEL_VIEW);
    PRECACHE_MODEL(MODEL_WORLD);
    PRECACHE_MODEL(MODEL_PLAYER);
    
    PRECACHE_SOUND(SOUND_RELOAD);
    PRECACHE_SOUND(SOUND_FIRE);
    PRECACHE_SOUND(SOUND_DEPLOY);
    PRECACHE_SOUND(SOUND_MISS_1);
    PRECACHE_SOUND(SOUND_MISS_2);               
    PRECACHE_SOUND(SOUND_MISS_3);
    PRECACHE_SOUND(SOUND_HIT_WALL);
    PRECACHE_SOUND(SOUND_HIT_FLESH_1);
    PRECACHE_SOUND(SOUND_HIT_FLESH_2);
    
    PRECACHE_GENERIC(WEAPON_HUD_TXT);
    PRECACHE_GENERIC(WEAPON_HUD_BAR);   
    
}
public S12_Spawn(const iItem)
{
    //Set model to floor
    SET_MODEL(iItem, MODEL_WORLD);
    
    // Give a default ammo to weapon
    wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}
public S12_Deploy(const iItem, const iPlayer, const iClip)
{
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.0);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 1.2);
    emit_sound(iPlayer, CHAN_WEAPON, SOUND_DEPLOY, 1.0, ATTN_NORM, 0, PITCH_NORM);
    return wpnmod_default_deploy(iItem, MODEL_VIEW, MODEL_PLAYER, draw, ANIM_EXTENSION);
}
public S12_Holster(const iItem)
{
    // Cancel any reload in progress.
    wpnmod_set_offset_int(iItem, Offset_iInSpecialReload, 0);
}
public S12_Idle(const iItem)
{
    wpnmod_reset_empty_sound(iItem);

    if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
    {
        return;
    }

    wpnmod_send_weapon_anim(iItem, idle1);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 6.0);
}
public S12_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
    if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
    {
        return;
    }
    
    wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, reload_1,3.0);
    emit_sound(iPlayer, CHAN_WEAPON, SOUND_RELOAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
}
public S12_PrimaryAttack(const iItem, const iPlayer, iClip)
{
    if (pev(iPlayer, pev_waterlevel) == 3 || iClip <= 0)
    {
        wpnmod_play_empty_sound(iItem);
        wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.7);
        return;
    }
    wpnmod_set_offset_int(iItem, Offset_iClip, iClip -= 1);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);
    
    wpnmod_fire_bullets(
    iPlayer,
    iPlayer,
    10,
    VECTOR_CONE_15DEGREES,
    3048.0,
    WEAPON_DAMAGE,
    DMG_BULLET,
    15
    );
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, WEAPON_RATE_OF_FIRE);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 7.0);
    
    wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
    wpnmod_send_weapon_anim(iItem, shot1);

    emit_sound(iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
    
} 

public S12_SecondaryAttack(const iItem, const iPlayer)
{
    wpnmod_set_think(iItem, "AK47_Stab");
    wpnmod_send_weapon_anim(iItem, stocks);
    
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.65);
    wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 0.65);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 5.0);
    
    set_pev(iItem, pev_nextthink, get_gametime() + 0.15);
}
     
public AK47_Stab(const iItem, const iPlayer)
{
    #define Offset_trHit Offset_iuser1
    #define Instance(%0) ((%0 == -1) ? 0 : %0)
    
    new iClass;
    new iTrace;
    new iEntity;
    new iHitWorld;
    
    new Float: vecSrc[3];
    new Float: vecEnd[3];
    new Float: vecUp[3];
    new Float: vecAngle[3];
    new Float: vecRight[3];
    new Float: vecForward[3];
    
    new Float: flFraction;
    
    iTrace = create_tr2();
    
    wpnmod_get_gun_position(iPlayer, vecSrc);
    
    global_get(glb_v_up, vecUp);
    global_get(glb_v_right, vecRight);
    global_get(glb_v_forward, vecForward);

    xs_vec_mul_scalar(vecUp, -2.0, vecUp);
    xs_vec_mul_scalar(vecRight, 1.0, vecRight);
    xs_vec_mul_scalar(vecForward, 48.0, vecForward);
        
    xs_vec_add(vecUp, vecRight, vecRight);
    xs_vec_add(vecRight, vecForward, vecForward);
    xs_vec_add(vecForward, vecSrc, vecEnd);

    engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, iPlayer, iTrace);
    get_tr2(iTrace, TR_flFraction, flFraction);
    
    if (flFraction >= 1.0)
    {
        engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, iPlayer, iTrace);
        get_tr2(iTrace, TR_flFraction, flFraction);
        
        if (flFraction < 1.0)
        {
            new iHit = Instance(get_tr2(iTrace, TR_pHit));
            
            if (!iHit || ExecuteHamB(Ham_IsBSPModel, iHit))
            {
                FindHullIntersection(vecSrc, iTrace, Float: {-16.0, -16.0, -18.0}, Float: {16.0,  16.0,  18.0}, iPlayer);
            }
            
            get_tr2(iTrace, TR_vecEndPos, vecEnd);
        }                        
    }                                          
    
    get_tr2(iTrace, TR_flFraction, flFraction);
    
    switch (random_num(0, 2))
    {
        case 0: emit_sound(iPlayer, CHAN_WEAPON, SOUND_MISS_1, 1.0, ATTN_NORM, 0, PITCH_NORM);
        case 1: emit_sound(iPlayer, CHAN_WEAPON, SOUND_MISS_2, 1.0, ATTN_NORM, 0, PITCH_NORM);
        case 2: emit_sound(iPlayer, CHAN_WEAPON, SOUND_MISS_3, 1.0, ATTN_NORM, 0, PITCH_NORM);
    }
    
    if (flFraction < 1.0)
    {
        iHitWorld = true;
        iEntity = Instance(get_tr2(iTrace, TR_pHit));
        
        wpnmod_clear_multi_damage();
        
        pev(iPlayer, pev_v_angle, vecAngle);
        engfunc(EngFunc_MakeVectors, vecAngle);    
        
        global_get(glb_v_forward, vecForward);
        ExecuteHamB(Ham_TraceAttack, iEntity, iPlayer, WEAPON_DAMAGE * 10.0, vecForward, iTrace, DMG_CLUB | DMG_NEVERGIB);
        
        wpnmod_apply_multi_damage(iPlayer, iPlayer);
            
        if (iEntity && (iClass = ExecuteHamB(Ham_Classify, iEntity)) != CLASS_NONE && iClass != CLASS_MACHINE)
        {
            switch (random_num(0, 1))
            {
                case 0: emit_sound(iPlayer, CHAN_ITEM, SOUND_HIT_FLESH_1, 1.0, ATTN_NORM, 0, PITCH_NORM);
                case 1: emit_sound(iPlayer, CHAN_ITEM, SOUND_HIT_FLESH_2, 1.0, ATTN_NORM, 0, PITCH_NORM);
            }
                
            if (!ExecuteHamB(Ham_IsAlive, iEntity))
            {
                return;
            }
                
            iHitWorld = false;
        }
            
        if (iHitWorld)
        {
            wpnmod_set_offset_int(iItem, Offset_trHit, iTrace);
            emit_sound(iPlayer, CHAN_ITEM, SOUND_HIT_WALL, 1.0, ATTN_NORM, 0, PITCH_NORM);
        }
        
        wpnmod_set_think(iItem, "AK47_Smack");
        set_pev(iItem, pev_nextthink, get_gametime() + 0.1);
    }

    free_tr2(iTrace);
}

public AK47_Smack(const iItem)
{
    new iTrace = wpnmod_get_offset_int(iItem, Offset_trHit);
    
    if (iTrace)
    {
        wpnmod_decal_trace(iTrace, wpnmod_get_damage_decal(Instance(get_tr2(iTrace, TR_pHit))));
        free_tr2(iTrace);
    }
}         
stock FindHullIntersection(const Float: vecSrc[3], &iTrace, const Float: vecMins[3], const Float: vecMaxs[3], const iEntity)
{
    new i, j, k;
    new iTempTrace;
    
    new Float: vecEnd[3];
    new Float: flDistance;
    new Float: flFraction;
    new Float: vecEndPos[3];
    new Float: vecHullEnd[3];
    new Float: flThisDistance;
    new Float: vecMinMaxs[2][3];
    
    flDistance = 999999.0;
    
    xs_vec_copy(vecMins, vecMinMaxs[0]);
    xs_vec_copy(vecMaxs, vecMinMaxs[1]);
    
    get_tr2(iTrace, TR_vecEndPos, vecHullEnd);
    
    xs_vec_sub(vecHullEnd, vecSrc, vecHullEnd);
    xs_vec_mul_scalar(vecHullEnd, 2.0, vecHullEnd);
    xs_vec_add(vecHullEnd, vecSrc, vecHullEnd);
    
    engfunc(EngFunc_TraceLine, vecSrc, vecHullEnd, DONT_IGNORE_MONSTERS, iEntity, (iTempTrace = create_tr2()));
    get_tr2(iTempTrace, TR_flFraction, flFraction);
    
    if (flFraction < 1.0)
    {
        free_tr2(iTrace);
        
        iTrace = iTempTrace;
        return;
    }
    
    for (i = 0; i < 2; i++)
    {
        for (j = 0; j < 2; j++)
        {
            for (k = 0; k < 2; k++)
            {
                vecEnd[0] = vecHullEnd[0] + vecMinMaxs[i][0];
                vecEnd[1] = vecHullEnd[1] + vecMinMaxs[j][1];
                vecEnd[2] = vecHullEnd[2] + vecMinMaxs[k][2];
                
                engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, iEntity, iTempTrace);
                get_tr2(iTempTrace, TR_flFraction, flFraction);
                
                if (flFraction < 1.0)
                {
                    get_tr2(iTempTrace, TR_vecEndPos, vecEndPos);
                    xs_vec_sub(vecEndPos, vecSrc, vecEndPos);
                    
                    if ((flThisDistance = xs_vec_len(vecEndPos)) < flDistance)
                    {
                        free_tr2(iTrace);
                        
                        iTrace = iTempTrace;
                        flDistance = flThisDistance;
                    }
                }
            }
        }
    }
}

