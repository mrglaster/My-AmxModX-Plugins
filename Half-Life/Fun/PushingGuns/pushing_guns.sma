/*Includes section*/
#include <amxmodx>
#include <fakemeta> 
#include <hamsandwich>  
#include <engine>

/*Information about the plugin and it's author*/                
#define PLUGIN "[.:HGS:.] Guns pusher"     
#define VERSION "1.9"                       
#define AUTHOR "Glaster"                                                           

                    
/*Offset on looking down*/                          
new DOWN_OFFSET = 45.0  ;                                 
                                 
/**Plugin initialization*/                                                              
public plugin_init() {                                                                   
    register_plugin(PLUGIN, VERSION, AUTHOR);                                              
    RegisterHam(Ham_Weapon_PrimaryAttack ,"weapon_357","onPythonPrimary");                               
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_shotgun", "onShotgunSecondary");            
}                                                                                              

/**On Python375 primary attack*/                     
public onPythonPrimary(weapon){
    new id = pev(weapon, pev_owner);
    new currentViewAngle[3];
    if (isLookingDown(id)){
        pushPlayer(id, 240.0, 280.0);
    }                              
}                                                            
                              
/**Invokes on shotgun's secondary attack*/                       
public onShotgunSecondary(weapon){  
    new id = pev(weapon, pev_owner);                                                    
    if (isLookingDown(id)){   
        pushPlayer(id, 300.0, 350.0);
    }                                       
}                                                                    

/**Player pushing function*/
public pushPlayer(id, minForce, maxForce){
       new Float:velocity[3];                            
       entity_get_vector(id, EV_VEC_velocity, velocity);
       velocity[2] = random_float(minForce, maxForce);                         
       entity_set_vector(id, EV_VEC_velocity, velocity);  
}
                                                                                                                                                                                          
/**Checks if player looks down*/                          
public isLookingDown(id){   
    new currentViewAngle[3];   
    pev(id, pev_v_angle, currentViewAngle);                              
    return currentViewAngle[0] >= 0.0 + DOWN_OFFSET
}               
  
