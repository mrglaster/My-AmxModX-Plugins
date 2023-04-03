/*Includes section*/
#include <amxmodx>
#include <fakemeta> 
#include <hamsandwich>  
#include <engine>

/*Information about the plugin and it's author*/                
#define PLUGIN "[.:HGS:.] Pushing Guns"     
#define VERSION "1.81"                       
#define AUTHOR "Glaster"                                                           
                                        
                                             
/*Offset on looking down*/                          
new DOWN_OFFSET = 45.0;                                 
                                                                                   
/**Plugin initialization*/                                                              
public plugin_init() {                                                                   
    register_plugin(PLUGIN, VERSION, AUTHOR);                                              
    RegisterHam(Ham_Weapon_PrimaryAttack ,"weapon_357","onPythonPrimary");                               
    RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_shotgun", "onShotgunSecondary");            
}                                                                                                 
                                                     
/**On Python375 primary attack*/                                                
public onPythonPrimary(weapon){
    new id = pev(weapon, pev_owner);
    if (isLookingDown(id)){
        pushPlayer(id, 240.0, 280.0);
    }                              
}                                                            
                              
/**Invokes on shotgun's secondary attack*/                       
public onShotgunSecondary(weapon){                  
    new id = pev(weapon, pev_owner);                                                    
    if (isLookingDown(id)){   
        pushPlayer(id, 300.0, 360.0);
    }                                       
} 

/**Pushes the player with the force between 2 float values*/ 
public pushPlayer(id, minForce, maxForce){  
       
       if(!is_user_alive(id) || !is_user_connected(id)){
           return FMRES_HANDLED
       }
       
       new Float:velocity[3];                            
       entity_get_vector(id, EV_VEC_velocity, velocity);                
       velocity[2] = random_float(minForce, maxForce);                         
       entity_set_vector(id, EV_VEC_velocity, velocity);  
}
                                                                                                                                                                                          
/**Checks if player looks down*/                          
public isLookingDown(id){    
    if(!is_user_alive(id) || !is_user_connected(id))
        return FMRES_HANDLED 
    new currentViewAngle[3];   
    pev(id, pev_v_angle, currentViewAngle);                              
    return currentViewAngle[0] >= 0.0 + DOWN_OFFSET
}               
  
