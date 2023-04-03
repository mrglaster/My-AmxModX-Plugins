/**Includes section*/
#include <amxmodx>  
#include "hl.inc"

/**Information about the plugin*/                              
#define PLUGIN "[HGS] Batman vs Ironman: Team Menu" 
#define VERSION "1.8"                              
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
    register_dictionary("teram_menu.txt");              
    register_plugin(PLUGIN, VERSION, AUTHOR);        
    register_clcmd("say /team", "teamMenu");                   
}                                                                              
                                                                        
/**Team select menu Show*/                                                 
public teamMenu(id) {                    
    new szStringBuf[64]
    formatex(szStringBuf, charsmax(szStringBuf), "%L", LANG_PLAYER,"SELECT_YOUR_CONFLICT_SIDE");
    new i_Menu = menu_create(szStringBuf, "teamMenuHandler");
    formatex(szStringBuf, charsmax(szStringBuf),"%L", LANG_PLAYER,"BATMAN");
    menu_additem(i_Menu, szStringBuf, "1", 0);                          
    formatex(szStringBuf, charsmax(szStringBuf),"%L", LANG_PLAYER,"IRONMAN");
    menu_additem(i_Menu, szStringBuf, "2", 0);   
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
