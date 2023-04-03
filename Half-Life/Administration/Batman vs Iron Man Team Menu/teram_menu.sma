/**Includes section*/
#include <amxmodx>  
#include "hl.inc"

/**Information about the plugin*/                              
#define PLUGIN "[HGS] Batman vs Ironman: Team Menu" 
#define VERSION "1.0"                              
#define AUTHOR "Glaster"  

/**Team Names Definition*/
#define TEAM_BATMAN "Batman"
#define TEAM_IRONMAN "Ironman"
                           
                            
/**Defines models of the players*/
#define MODEL_BATMAN "models/player/Batman/Batman.mdl"                                                                                    
#define MODEL_IRONMAN "models/player/Ironman/Ironman.mdl"
                                
/**Precache game resources used by the plugin*/                                  
public plugin_precache(){         
    precache_model(MODEL_BATMAN);                                                  
    precache_model(MODEL_IRONMAN);   
}                                     
                                                
/**Plugin initialization*/                                                    
public plugin_init() {                                                
    register_plugin(PLUGIN, VERSION, AUTHOR);        
    register_clcmd("say /team", "teamMenu");                   
}                                                                              
                                                                        
/**Team select menu Show*/                                                 
public teamMenu(id) {                    
    new i_Menu = menu_create("Select Your Conflict Side", "teamMenuHandler");
    menu_additem(i_Menu, "Batman", "1", 0);                          
    menu_additem(i_Menu, "Ironman", "2", 0);   
    menu_setprop(i_Menu, MPROP_EXITNAME, "Exit");
    menu_display(id, i_Menu, 0)                                                             
}                                                   

/**Handler for the team menu*/           
public teamMenuHandler(id, menu, item) {                                                                                                                                     
    if( item < 0 ) return PLUGIN_CONTINUE;                    
    new cmd[3], access, callback;
    menu_item_getinfo(menu, item, access, cmd, 2,_,_, callback);
    new Choise = str_to_num(cmd);
    switch (Choise) {
        //Player choose Batman team     
        case 1: {                                         
           hl_set_user_team(id, TEAM_BATMAN);
           return PLUGIN_CONTINUE;     
                                         
        }                                
        //The player choose Ironman team                                                                     
        case 2: {  
            hl_set_user_team(id, TEAM_IRONMAN);
            return PLUGIN_CONTINUE;          
        }                                           
    }                                               
    return PLUGIN_HANDLED;                             
}                                                                               