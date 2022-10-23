#include <amxmodx>

#define PLUGIN "Weaponlist (for weaponbox models)"

#define VERSION "1.0"         
#define AUTHOR "Glaster"

public plugin_init() {             
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("wlist","wlist");
}  

public wlist(id){
  for (new i=1; i<31;i++){ 
	  new name[32];
	  get_weaponname(i, name, 31 );
	  console_print(id,name,"",i);         
	 }                                                                           
}                              
