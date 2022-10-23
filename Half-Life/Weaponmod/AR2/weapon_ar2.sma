#include <amxmodx>      
#include <hl_wpnmod>
#include <xs>                                                       
#include <hamsandwich>        
new g_SpriteIndexExplode1;       
            
#define PLUGIN "[WPN] AR2"                                            
#define VERSION "1.3.0"                                              
#define AUTHOR "Glaster"                                    
#define WEAPON_NAME "weapon_ar2"                              
#define WEAPON_SLOT    3
#define WEAPON_POSITION    3
#define WEAPON_PRIMARY_AMMO    "ar2_clip"
#define WEAPON_PRIMARY_AMMO_MAX    90
#define WEAPON_SECONDARY_AMMO    "" 
#define WEAPON_SECONDARY_AMMO_MAX    -1 
#define WEAPON_MAX_CLIP    30     
#define WEAPON_DEFAULT_AMMO     30
#define WEAPON_FLAGS    0        
#define WEAPON_WEIGHT    20
#define WEAPON_DAMAGE    20.0  
#define AR2G_DAMAGE            100.0       
#define AR2G_BOUNCE_TIME        3.0       
#define AR2G_BOUNCE_VELOCITY        900
#define AR2G_FLY_VELOCITY        700     
#define MODEL_WORLD    "models/w_ar2.mdl"  
#define MODEL_VIEW    "models/v_ar2.mdl"      
#define MODEL_PLAYER    "models/p_ar2.mdl" 
#define MODEL_AMMO "models/w_ar2clip.mdl"
#define MODEL_AR2G            "models/ar2_grenade.mdl"
#define WEAPON_HUD_TXT    "sprites/weapon_ar2.txt"
#define WEAPON_CHOISEN    "sprites/ar2_choisen.spr"  
#define WEAPON_NOCHOISEN "sprites/ar2_nochoisen.spr"
#define MUZZLE_SPRITE "sprites/ar2_mf.spr"          
#define SPRITE_GLOW            "sprites/energy_ball.spr" 
#define SOUND_FIRE    "weapons/ar2_shoot.wav"
#define SOUND_RELOAD    "weapons/ar2_reload.wav"
#define SOUND_DEPLOY "weapons/ar2_deploy.wav"
#define SOUND_GRENADE "weapons/ar2_grenade.wav"    
#define SOUND_GRENADE_EXP "weapons/ar2gr.wav"
#define ANIM_EXTENSION    "crossbow"    
#define SET_SIZE(%0,%1,%2) engfunc(EngFunc_SetSize,%0,%1,%2)
#define SET_ORIGIN(%0,%1) engfunc(EngFunc_SetOrigin,%0,%1) 
#define NO_RECOIL  Float:{ 0.01, 0.01, 0.01 }              
#define Offset_iGlow Offset_iuser1
#define Offset_iBounce Offset_iuser2  
#define SET_ORIGIN(%0,%1) engfunc(EngFunc_SetOrigin,%0,%1) 
#define SPRITE_EXP "sprites/ar2_explo.spr"           
#define EMPTY_SOUND "weapons/ar2_empty1.wav"  
#define AMMOBOX_CLASSNAME "ammo_ar2" 
new sgb[1];    
public plugin_init() {   

register_plugin(PLUGIN,VERSION,AUTHOR);    
new iAR2Ammo= wpnmod_register_ammobox(AMMOBOX_CLASSNAME);                 
new ar2 = wpnmod_register_weapon
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
    
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_Spawn,         "AR2_Spawn" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_Deploy,         "AR2_Deploy" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_Idle,         "AR2_Idle" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_PrimaryAttack,    "AR2_PrimaryAttack" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_SecondaryAttack,    "AR2_SecondaryAttack" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_Reload,         "AR2_Reload" );
    wpnmod_register_weapon_forward(ar2, Fwd_Wpn_Holster,         "AR2_Holster" );
    wpnmod_register_ammobox_forward(iAR2Ammo, Fwd_Ammo_Spawn, "AR2Ammo_Spawn");
    wpnmod_register_ammobox_forward(iAR2Ammo, Fwd_Ammo_AddAmmo, "AR2Ammo_AddAmmo");

}

enum _:g_AR2
{
    AR2_LONGIDLE,
    AR2_IDLE1,
    AR2_GRENADE,   
    AR2_RELOAD,  
    AR2_DEPLOY,
    AR2_SHOOT1,    
    AR2_SHOOT2,
    AR2_SHOOT3   
}; 
public plugin_precache()    
{   PRECACHE_MODEL(MODEL_AR2G);
    PRECACHE_MODEL(MODEL_VIEW);
    PRECACHE_MODEL(MODEL_WORLD);  
    PRECACHE_MODEL(MODEL_AMMO);
    PRECACHE_SOUND ("weapons/ar2_grbounce.wav");
    PRECACHE_SOUND(SOUND_GRENADE_EXP);  
    PRECACHE_MODEL(MODEL_PLAYER);          
    PRECACHE_SOUND(SOUND_RELOAD);
    PRECACHE_SOUND(SOUND_FIRE);
    PRECACHE_SOUND(SOUND_DEPLOY);
    PRECACHE_SOUND(SOUND_GRENADE);
    PRECACHE_SOUND(EMPTY_SOUND);
    PRECACHE_GENERIC(WEAPON_HUD_TXT);  
    PRECACHE_GENERIC(SPRITE_GLOW);    
    PRECACHE_MODEL("sprites/energy_ball.spr") 
    //PRECACHE_MODEL(MUZZLE_SPRITE);
    PRECACHE_GENERIC(WEAPON_CHOISEN);
    PRECACHE_GENERIC(WEAPON_NOCHOISEN); 
    g_SpriteIndexExplode1 = PRECACHE_MODEL(SPRITE_EXP);
}

public AR2_Spawn(const iItem)
{
    //Set model to floor
    SET_MODEL(iItem, MODEL_WORLD);
    
    // Give a default ammo to weapon
    wpnmod_set_offset_int(iItem, Offset_iDefaultAmmo, WEAPON_DEFAULT_AMMO);
}
public AR2_Deploy(const iItem, const iPlayer, const iClip)
{
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 1.0);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 1.2);

    return wpnmod_default_deploy(iItem, MODEL_VIEW, MODEL_PLAYER, AR2_DEPLOY , ANIM_EXTENSION);
}
public AR2_Holster(const iItem)
{
    // Cancel any reload in progress.
    wpnmod_set_offset_int(iItem, Offset_iInSpecialReload, 0);
}
public AR2_Idle(const iItem)
{
    wpnmod_reset_empty_sound(iItem);     
                                                         
    if (wpnmod_get_offset_float(iItem, Offset_flTimeWeaponIdle) > 0.0)
    {
        return;                                                      
    }

    wpnmod_send_weapon_anim(iItem, AR2_IDLE1);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 15.0);
}
public AR2_Reload(const iItem, const iPlayer, const iClip, const iAmmo)
{
    if (iAmmo <= 0 || iClip >= WEAPON_MAX_CLIP)
    {
        return;                                 
    }                                                         
    wpnmod_default_reload(iItem, WEAPON_MAX_CLIP, AR2_RELOAD, 0.79); 
       emit_sound(iPlayer, CHAN_WEAPON, SOUND_RELOAD, 1.0, ATTN_NORM, 0, PITCH_NORM);
}  
public AR2_PrimaryAttack(const iItem, const iPlayer, iClip)
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
        
        wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.10);
        wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, 15.0);
        
        wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
        
        new reload = random_num(0 ,1);
        switch(reload)
            {
                case 0 :
                {
                    wpnmod_send_weapon_anim(iItem, AR2_SHOOT1);    
                }
                case 1 :
                {
                    wpnmod_send_weapon_anim(iItem, AR2_SHOOT2);
                }
            }                              
        
        wpnmod_fire_bullets
        (                                                                                
            iPlayer, 
            iPlayer, 
            1, 
            NO_RECOIL,                                     
            8192.0,                                 
            WEAPON_DAMAGE, 
            DMG_BULLET | DMG_NEVERGIB,                  
            4                        
        );
                                                             
        emit_sound(iPlayer, CHAN_WEAPON, SOUND_FIRE, 0.9, ATTN_NORM, 0, PITCH_NORM);
        
        set_pev(iPlayer, pev_effects, pev(iPlayer, pev_effects) | EF_MUZZLEFLASH); 
        set_pev(iPlayer, pev_punchangle, Float: {-4.0, 0.0, 0.0});
                                                        
}
public AR2_SecondaryAttack(iItem,iPlayer ,iClip,iAmmo, const bool: bBounce)
{
    if (iClip-15 < 0)
    {   
    emit_sound(iPlayer,0,EMPTY_SOUND,1.0, ATTN_NORM, 0, PITCH_NORM )
    wpnmod_set_offset_float( iItem, Offset_flNextPrimaryAttack, 1.5);
        return;
    }
                                                        
    AR2GG_Fire(iItem, iPlayer, iClip, iAmmo, true);    
             
}

                                   
AR2GR_Create(const Float: vecPosition[3], const Float: vecVelocity[3], const iOwner, const bool: bBounce)
{                                 
    new iAR2GR, Float: vecAngles[3], Float: flGametime = get_gametime();

    static iszAllocStringCached;
    if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "info_target")))
    {                                          
        iAR2GR = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
    }
    
    if (!pev_valid(iAR2GR))
    {
        return FM_NULLENT;
    }                                         
                    
    engfunc(EngFunc_VecToAngles, vecVelocity, vecAngles);

    set_pev(iAR2GR, pev_classname, "AR2GR");
    set_pev(iAR2GR, pev_solid, SOLID_BBOX);
    set_pev(iAR2GR, pev_dmg, AR2G_DAMAGE);
    set_pev(iAR2GR, pev_velocity, vecVelocity);
    set_pev(iAR2GR, pev_angles, vecAngles);
    set_pev(iAR2GR, pev_owner, iOwner);     
    set_pev(iAR2GR, pev_gravity, 0.1);
    set_pev(iAR2GR, pev_spawnflags, ~(1 << SF_EXPLOSION_NODEBRIS));
                               
    if (!bBounce)
    {
        set_pev(iAR2GR, pev_movetype, MOVETYPE_FLY);
        wpnmod_set_touch(iAR2GR, "AR2GR_RocketTouch");
    }
    else
    {
        set_pev(iAR2GR, pev_movetype, MOVETYPE_BOUNCE);
        set_pev(iAR2GR, pev_dmgtime, flGametime + AR2G_BOUNCE_TIME);
        wpnmod_set_touch(iAR2GR, "AR2GR_BounceTouch");
    }
    
    SET_MODEL(iAR2GR, MODEL_AR2G);
    SET_ORIGIN(iAR2GR, vecPosition);
    SET_SIZE(iAR2GR, Float: {0.0, 0.0, 0.0}, Float: {0.0, 0.0, 0.0});
    
    wpnmod_set_think(iAR2GR, "AR2GR_FlyThink");
    set_pev(iAR2GR, pev_nextthink, flGametime + 0.01);
    
    AR2GR_SetGlow(iAR2GR);
    wpnmod_set_offset_int(iAR2GR, Offset_iBounce, bBounce);
    
    return iAR2GR;
}

                                                   
AR2GR_SetGlow(const iAR2GR)
{
    new iGlowSprite;      
    
    static iszAllocStringCached;
    if (iszAllocStringCached || (iszAllocStringCached = engfunc(EngFunc_AllocString, "env_sprite")))
    {
        iGlowSprite = engfunc(EngFunc_CreateNamedEntity, iszAllocStringCached);
    }
    
    if (!pev_valid(iGlowSprite))
    {
        return;
    }
    
    wpnmod_set_offset_int(iAR2GR, Offset_iGlow, iGlowSprite);
    
    set_pev(iGlowSprite, pev_classname, "AR2GR_glow");
    set_pev(iGlowSprite, pev_movetype, MOVETYPE_FOLLOW);
    set_pev(iGlowSprite, pev_solid, SOLID_NOT);
    
    set_pev(iGlowSprite, pev_skin, iAR2GR);
    set_pev(iGlowSprite, pev_body, 0);
    set_pev(iGlowSprite, pev_aiment, iAR2GR);
            
    set_pev(iGlowSprite, pev_scale, 0.8);
            
    set_pev(iGlowSprite, pev_renderfx, kRenderFxDistort);
    set_pev(iGlowSprite, pev_rendercolor, Float: {180.0, 180.0, 40.0});
    set_pev(iGlowSprite, pev_rendermode, kRenderTransAdd);
    set_pev(iGlowSprite, pev_renderamt, 100.0);
    
    SET_MODEL(iGlowSprite, SPRITE_GLOW);
}


public AR2GR_FlyThink(const iAR2GR)
{
    static Float: flDmgTime;
    static Float: vecOrigin[3];
    
    pev(iAR2GR, pev_origin, vecOrigin);
    pev(iAR2GR, pev_dmgtime, flDmgTime);
    
    if (wpnmod_get_offset_int(iAR2GR, Offset_iBounce) && flDmgTime <= get_gametime())
    {
        wpnmod_explode_entity(iAR2GR, .szCallBack = "AR2GR_Explode");
        return;
    }

    // Sprite spray

    
    set_pev(iAR2GR, pev_nextthink, get_gametime () + 0.13);
}
                                                       

public AR2GR_RocketTouch(const iAR2GR)
{   emit_sound(iAR2GR, CHAN_VOICE, SOUND_GRENADE_EXP, 0.25, ATTN_NORM, 0, PITCH_NORM);   
    wpnmod_explode_entity(iAR2GR, .szCallBack = "AR2GR_Explode");
    
}

public AR2GR_BounceTouch(const iAR2GR, const iOther)
{

    new Float: flTakeDmg;
    new Float: vecVelocity[3];
    pev(iOther, pev_takedamage, flTakeDmg);
    pev(iAR2GR, pev_velocity, vecVelocity);
    
    if (flTakeDmg > DAMAGE_NO)
    {
        wpnmod_explode_entity(iAR2GR, .szCallBack = "AR2GR_Explode");
        return;
    }
    
    if (pev(iAR2GR, pev_flags) & FL_ONGROUND)
    {
        xs_vec_mul_scalar(vecVelocity, 0.5, vecVelocity);
        set_pev(iAR2GR, pev_velocity, vecVelocity);
    }
    else                                                                 
    {                                                                           
      emit_sound(iAR2GR, CHAN_VOICE, "weapons/ar2_grbounce.wav", 0.25, ATTN_NORM, 0, PITCH_NORM); 
    }                                                                                 
} 


                                                       
public AR2GR_Explode(const iAR2GR, const iTrace)
{   if(pev_valid(iAR2GR)){ 
    new iSpriteGlow = wpnmod_get_offset_int(iAR2GR, Offset_iGlow);
                                            
    if (pev_valid(iSpriteGlow))
    {
        set_pev(iSpriteGlow, pev_flags, FL_KILLME);
    }
                    
    new Float: vecSrc[3];
    new Float: vecOrigin[3];
                        
    pev(iAR2GR, pev_origin, vecOrigin);
    get_tr2(iTrace, TR_vecEndPos, vecSrc);
    
    
     // Explode effect   
    engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
    write_byte(TE_SPRITE);                                                          
    engfunc(EngFunc_WriteCoord, vecOrigin[0]);
    engfunc(EngFunc_WriteCoord, vecOrigin[1]);    
    engfunc(EngFunc_WriteCoord, vecOrigin[2]);    
    write_short(g_SpriteIndexExplode1);
    write_byte(20);                                                      
    write_byte(128);    
    emit_sound(iAR2GR, CHAN_VOICE, SOUND_GRENADE_EXP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
    message_end();                                    
}       
}
AR2GG_Fire(const iItem, const iPlayer, iClip, const iAmmo, const bool: bBounce)
{                     
    if (iClip-15 < 0)
    {                                                                        
        emit_sound(iPlayer,0,EMPTY_SOUND,1.0, ATTN_NORM, 0, PITCH_NORM )                                               
        return;
    }                                         

    new Float: vecOrigin[3];
    new Float: vecVelocity[3];                                      
                                                             
    wpnmod_set_offset_int(iItem, Offset_iClip, iClip -= 15);
    wpnmod_set_offset_int(iItem, Offset_iInSpecialReload, 0);
    
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponVolume, LOUD_GUN_VOLUME);
    wpnmod_set_offset_int(iPlayer, Offset_iWeaponFlash, BRIGHT_GUN_FLASH);
    
    wpnmod_set_offset_float(iItem, Offset_flNextPrimaryAttack, 0.5);
    wpnmod_set_offset_float(iItem, Offset_flNextSecondaryAttack, 0.5);
    wpnmod_set_offset_float(iItem, Offset_flTimeWeaponIdle, iClip != 0 ? 0.5 : 0.75);
    
    wpnmod_send_weapon_anim(iItem, AR2_GRENADE);
    wpnmod_set_player_anim(iPlayer, PLAYER_ATTACK1);
                                                              
    velocity_by_aim(iPlayer, bBounce ? AR2G_BOUNCE_VELOCITY : AR2G_FLY_VELOCITY, vecVelocity);
    wpnmod_get_gun_position(iPlayer, vecOrigin, 16.0, 8.0, -8.0);                   
    emit_sound(iPlayer, CHAN_WEAPON, SOUND_GRENADE, 0.9, ATTN_NORM, 0, PITCH_NORM); 
    AR2GR_Create(vecOrigin, vecVelocity, iPlayer, bBounce);
    
} 
   public AR2Ammo_Spawn(const iItem)
{                                           
    // Setting world model
    SET_MODEL(iItem, MODEL_AMMO);
}



public AR2Ammo_AddAmmo(const iItem, const iPlayer)
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

