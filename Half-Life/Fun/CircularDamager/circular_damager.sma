/*Includes section*/
#include <amxmodx>
#include <hamsandwich>
  
/*Plugin information*/ 
#define PLUGIN_NAME "[.:HGS:.] Circular Damager"
#define PLUGIN_AUTHOR "Glaster"           
#define PLUGIN_VERSION "1.6"   
                   
/*Sound playing on damage*/                         
#define DAMAGE_SOUND "bvi/clk.wav" 
                                 
/*Colors for damage numbers*/                                       
new const g_szColors[][] =
{
    { 255, 228, 181 },
    { 30, 144, 255 },
    { 255, 255, 0 },                                                              
    { 50, 205, 50 },
    { 144, 238, 144 },
    { 104, 188, 230 },
    { 230, 104, 226 },                                            
    { 0, 255, 222 },
    { 26, 255, 0 },                
    { 250, 245, 86 },
    { 0, 51, 187 },
    { 8, 39, 245 },
    { 128, 0, 128 },
    { 255, 165, 0 },
    { 70, 117, 153 },   
    { 32,  73, 100 },
    { 121, 128, 74 },                                    
    { 48, 162, 117 },
    { 35, 95, 64 },
    { 129, 79, 165 },
    { 73, 143, 80 },
    { 141, 66, 91 },
    { 89, 163, 198 },
    { 60, 112, 78 },  
    { 123, 85, 128 },
    { 124, 153, 61 },
    { 99, 108, 53 },
    { 27, 173, 130 },
    { 110, 130, 195 },  
    { 69, 158, 201 },
    { 159, 93, 59 },
    { 57, 137, 170 },  
    { 111, 67, 101 },     
    { 84, 101, 135 },
    { 45, 79, 120 },
    { 92, 54, 93 },
    { 93, 123, 151 },
    { 72, 151, 122 },
    { 153, 58, 81 },
    { 61, 91, 60 },
    { 94, 175, 127 },
    { 155, 102, 122 },
    { 125, 145, 79 },
}                                      
                                                     
enum _:eData
{
    STATE,
    STYLE,
    TYPE,
    INCOMING,
    POSITION,                    
}  

       
new g_iDamagerData[MAX_PLAYERS+1][eData];       


new const Float: g_szCoords[][] =
{
    { 0.50, 0.40 },
    { 0.56, 0.44 },               
    { 0.60, 0.50 },
    { 0.56, 0.56 },
    { 0.50, 0.60 },
    { 0.44, 0.56 },
    { 0.40, 0.50 },
    { 0.44, 0.44 }
}   

/*Precaches resources*/
public plugin_precache(){
    precache_sound(DAMAGE_SOUND);
} 

/*Plugin initialization*/                  
public plugin_init(){                                                      
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
    RegisterHam(Ham_TakeDamage, "player",  "onDamage");                         
}                                                
                                  
/*Function invoking on getting damage: processes damager*/           
public onDamage(iVictim, iInflictor, iAttacker, Float:flDamage, iBitsDamageType)
{
    if(!is_user_connected(iAttacker) || flDamage <= 0.0)
    {
        return;                    
    }                                                                                            
        new iColor = random_num(0, sizeof(g_szColors) - 1);
        new iPos = ++g_iDamagerData[iAttacker][POSITION];
                           
        if(iPos == sizeof(g_szCoords))           
        {             
            iPos = g_iDamagerData[iAttacker][POSITION] = 0;
        }                                               
                         
        if (iAttacker == iVictim){
           set_dhudmessage(255, 0, 0, g_szCoords[iPos][0], g_szCoords[iPos][1]+0.06, 0, 0.1, 2.5, 0.02, 0.02);  
           show_dhudmessage(iVictim, "%.0f", flDamage * (-1) );
        }           
        
        else {                                                                                                                                                                                                                                      
            set_dhudmessage(g_szColors[iColor][0], g_szColors[iColor][1], g_szColors[iColor][2], g_szCoords[iPos][0], g_szCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02);    
            show_dhudmessage(iAttacker, "%.0f", flDamage);
            emit_sound(iAttacker, CHAN_AUTO, DAMAGE_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM);
       }       
         
}
                                     