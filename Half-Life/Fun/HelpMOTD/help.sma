#include <amxmodx>
#define PLUGIN "help MOTD"
#define VERSION "1.5"
#define AUTHOR "Glaster"

public plugin_init(){                                     
  register_clcmd("say /help", "motd");
  register_plugin(PLUGIN, VERSION, AUTHOR);
                    
}

public client_putinserver(id)
{
    set_task(180.00, "example", id, "", 0, "", 0);
    return 0;
}

public example(id)
{
    client_print(id, print_chat, "Type /help to get help ");
    set_task(30.00, "example", id, "", 0, "", 0);
    return 0;
}

public motd(id)
{
    show_motd(id, "help.txt", "Help");
    return 0;
}
    
