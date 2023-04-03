#include <amxmodx>
#include <hlsdk_const>
#include <hamsandwich>

#define AUTHOR "Glaster"
#define PLUGIN_NAME "Fall Damage Remover"
#define VERSION "1.0"

/**Initialization of the plugin*/
public plugin_init() {
    register_plugin( PLUGIN_NAME, VERSION, AUTHOR);
    RegisterHam(Ham_TakeDamage, "player", "OnCBasePlayer_TakeDamage")
}

/**Function invoking on fall damage getting*/
public OnCBasePlayer_TakeDamage( id, iInflictor, iAttacker, Float:flDamage, bitsDamageType ) {
    if( bitsDamageType & DMG_FALL ) {
		return HAM_SUPERCEDE
    }
    return HAM_IGNORED
}  