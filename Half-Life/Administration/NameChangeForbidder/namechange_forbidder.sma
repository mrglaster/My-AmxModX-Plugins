#include <amxmodx>
#include <fakemeta>
#include <amxmisc>

#define PLUGIN "Name Change Forbidder" 
#define VERSION "1.2"        
#define AUTHOR "Glaster"                                                      

                         
public plugin_init() {                                                   
    register_plugin(PLUGIN, VERSION, AUTHOR);                             
    register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged");   
                                   
}                                                                
                                              
public ClientUserInfoChanged(id) {                                                          
    static szOldName[32], szNewName[32]                                                
    pev(id, pev_netname, szOldName, charsmax(szOldName))  
    if( szOldName[0] )                 
    {        
        get_user_info(id, "name", szNewName, charsmax(szNewName)) 
        if(!equal(szOldName, szNewName))                                                                         
        {   
            client_print(id, print_center, "You may change the name when you aren't connected to this server!")   
            client_print(0, print_chat, "%s is trying to change the name, but not successfull", szOldName)  
            set_user_info(id, "name", szOldName) 
            return FMRES_HANDLED
        } 
    }                       
    return FMRES_IGNORED 
}
