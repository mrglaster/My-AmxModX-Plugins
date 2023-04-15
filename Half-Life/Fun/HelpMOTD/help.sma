/*Includes Section*/
#include <amxmodx>

/*Information about the plugin*/
#define PLUGIN "Help MOTD"
#define VERSION "1.5"
#define AUTHOR "Glaster"

/*Plugin initialization*/
public plugin_init(){                                     
  register_clcmd("say /help", "motd");
  register_plugin(PLUGIN, VERSION, AUTHOR);                    
}


public client_putinserver(id){
    set_task(180.00, "help_chat_info", id, "", 0, "", 0);
    return 0;
}

/*Chat hint*/
public help_chat_info(id){
    client_print(id, print_chat, "Type /help to get help ");
    set_task(30.00, "help_chat_info", id, "", 0, "", 0);
    return 0;
}

/*Shows the motd*/
public motd(id){
    show_motd(id, "help.txt", "Help");
    return 0;
}
    
