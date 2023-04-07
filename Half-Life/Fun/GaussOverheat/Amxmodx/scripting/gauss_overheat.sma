/*Includes section*/
#include <amxmodx>     
#include <hamsandwich>     
#include <fakemeta> 
   
/*Information about the plugin*/  
#define PLUGIN "[.:HGS:.] Gauss Overheat" 
#define VERSION "1.30"                  
#define AUTHOR "Glaster"                                           

/*Constants the plugin uses*/                           
#define ELECTRICITY_DAMAGE_PRIMARY 5.0       
#define ELECTRICITY_DAMAGE_SECONDARY 7.0        
#define ALLOWED_KILLS_AMOUNT 5                         
#define GAUSS_SECONDARY_DELAY 3.0                                                                      
 
#define GAUSS_CLASSNAME "weapon_gauss"   
#define ELECTRO_SOUND "weapons/electro5.wav"     
   
const LINUX_OFFSET_WEAPONS     = 4;  
const m_flNextSecondaryAttack  = 36;    
                                                                                          
/*Array containing information about the amount of kills made with Gauss*/  
new iGaussKills[32];    
                                                                                                     
/*Initialization section*/                                                                     
public plugin_init() {                                         
    register_dictionary("gauss_overheat.txt");
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_event("DeathMsg", "event_DeathMsg", "a", "1>0")
    RegisterHam(Ham_Weapon_PrimaryAttack, GAUSS_CLASSNAME, "onGaussPrimary", 1);
    RegisterHam(Ham_Weapon_SecondaryAttack, GAUSS_CLASSNAME, "onGaussSecondary", 1); 
}                                                                                            
 
/*Invokes on player's death. */       
public event_DeathMsg()                                                                   
{
    static iKiller, iVictim;                                                       
    iKiller = read_data(1);
    iVictim = read_data(2);                 
    if(!is_user_alive(iKiller)){ 
        iGaussKills[iKiller] = 0;
        return PLUGIN_CONTINUE
    }
    iGaussKills[iVictim] = 0;                 
    new wpnName[32];
    get_weaponname(get_user_weapon(iKiller), wpnName, 31);  
    if (equal(wpnName, GAUSS_CLASSNAME)){
        iGaussKills[iKiller] += 1;                        
    }                            
    return PLUGIN_CONTINUE
}  
                                                                                        


/*When client is entering the game.*/ 
public client_putinserver(id){
    iGaussKills[id] = 0;
}

/*When user disconnects from the game*/
public client_disconnected(id){                                        
    iGaussKills[id] = 0;                         
}                          
                                                          
/*On Gauss Primary Attack*/                                                           
public onGaussPrimary(weapon){        
    new userId = pev(weapon, pev_owner);                    
    processOverheat(userId, weapon, iGaussKills[userId] * ELECTRICITY_DAMAGE_PRIMARY, 0, 0);                                                                               
}                                                                    
                                                              
/*On Gauss Secondary Attack*/    
public onGaussSecondary(weapon){                              
      new userId = pev(weapon, pev_owner);  
      processOverheat(userId, weapon, iGaussKills[userId] * ELECTRICITY_DAMAGE_SECONDARY, 1, GAUSS_SECONDARY_DELAY);   
}                                                                                     
             
/*Checks if player's Gauss is overheated*/        
public isOverheated(id){                                  
    return iGaussKills[id] >= ALLOWED_KILLS_AMOUNT;
}   
             
/*Sets effects on player when he uses an overheated Gauss*/  
public processOverheat(userId, weapon, damage, doDelay, delayTime){                                      
    if (isOverheated(userId)){
        ExecuteHam(Ham_TakeDamage, userId, userId, userId, damage, DMG_SHOCK);
        set_dhudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 0.1, 0.2)               
        show_dhudmessage(userId, "%L", LANG_PLAYER,"ATTENTION_OVERHEATING_GAUSS")                
        makeOrangeScreenfade(userId);                                                  
        emit_sound(userId, CHAN_WEAPON, ELECTRO_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM); 
        if (doDelay >= 1){
             set_pdata_float(weapon, m_flNextSecondaryAttack, delayTime, LINUX_OFFSET_WEAPONS);  
        }
    }                                                                                   
                                                            
}
  
/*Makes orange Screenfade for the plugin*/
stock makeOrangeScreenfade(userId){
     message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, userId)
     write_short(1<<10)                             
     write_short(1<<10)
     write_short(0x0000)
     write_byte(255) //R   
     write_byte(127) // G  
     write_byte(0) // B      
     write_byte(75)
     message_end()    
}
                                                    

         
           
