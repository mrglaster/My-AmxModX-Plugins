#include <amxmodx>
#include <hl>
#include <fakemeta>
#include <amxmisc>
#include <hamsandwich>
#include <fun>
#define PLUGIN "Admin models"
#define VERSION "1.9"
#define AUTHOR "Glaster"
new g_player_model[33][32]
new g_ent_playermodel[33]
new g_ent_weaponmodel[33]

new
const PLAYERMODEL_CLASSNAME[] = "ent_playermodel"
new
const WEAPONMODEL_CLASSNAME[] = "ent_weaponmodel"
new pos = -1;
//Модели ВИП игроков             
new
const a_Skins[][] = { "ZSVM1",
	"ZSVM2",
	"ZSVM3",
	"ZSVM4",
	"ZSVM5",
	"ZSVM6",
	"ZSVM7",
	"ZSVM8",
	"ZSVM9",
	"ZSVM10",
	"ZSPVM0",
	"ZSPVM1",
	"VIP_CLASSIC",
	"ZSPVM2" };

public isvip(id)
{
	new team[32]
	get_user_team(id, team, 31)
	if (equal(team, "VIP", 1) && is_user_admin(id))
	{
		return 1
	}
	else
	{
		return 0
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /vipmodel", "VipModel", ADMIN_IMMUNITY, "Write /vipmodel in chat to change model");	//???®?¬? ?­?¤?  ???»?§?®???  ?¬???­??: /vipmodel ?? ?·? ??
	register_clcmd("setmodel_Glaster", "setmodel_Glaster", ADMIN_IMMUNITY)
	register_clcmd("setmodel_packman", "setmodel_packman", ADMIN_IMMUNITY)
	register_clcmd("setmodel_lastUnit", "setmodel_lastUnit", ADMIN_IMMUNITY)
	register_message(get_user_msgid("ClCorpse"), "message_clcorpse")
	RegisterHam(Ham_Spawn, "player", "player_spawn")
	RegisterHam(Ham_Spawn, "player", "player_respawn")

}

public plugin_precache()
{
	new arg[100], i;
	for (i = 0; i < sizeof(a_Skins); i++)
	{
		formatex(arg, charsmax(arg), "models/player/%s/%s.mdl", a_Skins[i], a_Skins[i]);
		precache_model(arg);
	}
}

public setmodel_lastUnit(id)
{
	if (isvip(id))
	{
		fhl_set_user_model(id, a_Skins[11]);
		pos = 11;
	}
}

public setmodel_Glaster(id)
{
	if (isvip(id))
	{
		fhl_set_user_model(id, a_Skins[10]);
		pos = 10;
	}
}

public setmodel_packman(id)
{
	if (isvip(id))
	{
		fhl_set_user_model(id, a_Skins[13]);
		pos = 13;
	}
}

//создаем меню
public VipModel(id)
{
	new team[32]
	get_user_team(id, team, 31)
	if (equal(team, "VIP", 3))
	{
		new menu = menu_create("\yVIP \ymodels", "vipmodel_handler");
		menu_additem(menu, "Classic", "", 0);
		menu_additem(menu, "Aquafresh", "", 1);
		menu_additem(menu, "Barneyrina", "", 2);
		menu_additem(menu, "Bert", "", 3);
		menu_additem(menu, "Sponge", "", 4);
		menu_additem(menu, "Snlckers", "", 5);
		menu_additem(menu, "Bunny", "", 6);
		menu_additem(menu, "Creature", "", 7);
		menu_additem(menu, "Sanic", "", 8);
		menu_additem(menu, "Worm", "", 9);
		menu_additem(menu, "Orb", "", 10);
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu, 0);
		return PLUGIN_HANDLED;
	}
	else
	{
		client_print(id, print_center, "Join VIP team firsts");
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public vipmodel_handler(id, menu, item)
{
	pos = item;
	if (pos == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;
	menu_item_getinfo(menu, pos, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch (pos)
	{
		case 0:
			fhl_set_user_model(id, a_Skins[12])
		case 1:
			fhl_set_user_model(id, a_Skins[0])
		case 2:
			fhl_set_user_model(id, a_Skins[1])
		case 3:
			fhl_set_user_model(id, a_Skins[2])
		case 4:
			fhl_set_user_model(id, a_Skins[3])
		case 5:
			fhl_set_user_model(id, a_Skins[4])
		case 6:
			fhl_set_user_model(id, a_Skins[5])
		case 7:
			fhl_set_user_model(id, a_Skins[6])
		case 8:
			fhl_set_user_model(id, a_Skins[7])
		case 9:
			fhl_set_user_model(id, a_Skins[8])
		case 10:
			fhl_set_user_model(id, a_Skins[9])
	}

	return PLUGIN_HANDLED
}

stock fm_remove_model_ents(id)
{
	set_pev(id, pev_rendermode, kRenderNormal)
	if (pev_valid(g_ent_playermodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_playermodel[id])
		g_ent_playermodel[id] = 0
	}

	if (pev_valid(g_ent_weaponmodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_weaponmodel[id])
		g_ent_weaponmodel[id] = 0
	}
}

//задаём модель пользователя
stock fhl_set_user_model(id, const modelname[])
{
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 15);
	set_pev(id, pev_rendermode, kRenderTransTexture)
	set_pev(id, pev_renderamt, 1.0)
	static modelpath[100]
	formatex(modelpath, charsmax(modelpath), "models/player/%s/%s.mdl", modelname, modelname)
	if (!pev_valid(g_ent_playermodel[id]))
	{
		g_ent_playermodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_playermodel[id])) return;
		set_pev(g_ent_playermodel[id], pev_classname, PLAYERMODEL_CLASSNAME)
		set_pev(g_ent_playermodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_playermodel[id], pev_aiment, id)
		set_pev(g_ent_playermodel[id], pev_owner, id)
	}

	engfunc(EngFunc_SetModel, g_ent_playermodel[id], modelpath)
}

stock fm_has_custom_model(id)
{
	return pev_valid(g_ent_playermodel[id]) ? true : false;
}

//работа с оружием в руках
stock fm_set_weaponmodel_ent(id)
{
	static model[100]
	pev(id, pev_weaponmodel2, model, charsmax(model))
	if (!pev_valid(g_ent_weaponmodel[id]))
	{
		g_ent_weaponmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_weaponmodel[id])) return;
		set_pev(g_ent_weaponmodel[id], pev_classname, WEAPONMODEL_CLASSNAME)
		set_pev(g_ent_weaponmodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_weaponmodel[id], pev_aiment, id)
		set_pev(g_ent_weaponmodel[id], pev_owner, id)
	}

	engfunc(EngFunc_SetModel, g_ent_weaponmodel[id], model)
}

public message_clcorpse()
{
	static id
	id = get_msg_arg_int(12)
	if (fm_has_custom_model(id))
	{
		set_msg_arg_string(1, g_player_model[id])
	}
}

public player_respawn(id)
{
	new team[32]
	get_user_team(id, team, 31)
	if (is_user_admin(id) && equal(team, "VIP", 3) && pos == -1)
	{
		fhl_set_user_model(id, a_Skins[12])
	}
	else if (is_user_admin(id) && equal(team, "VIP", 3) && pos != -1)
	{
		fhl_set_user_model(id, a_Skins[pos])
	}
	else
	{
		if (!equal(team, "VIP", 3))
		{
			fm_remove_model_ents(id)
		}
	}
}

public player_spawn(id)
{
	new team[32]
	get_user_team(id, team, 31)
	if (is_user_admin(id) && equal(team, "VIP", 3) && pos == -1)
	{
		fhl_set_user_model(id, a_Skins[12])
	}
	else if (is_user_admin(id) && equal(team, "VIP", 3) && pos != -1)
	{
		fhl_set_user_model(id, a_Skins[pos])
	}
	else
	{
		if (!equal(team, "VIP", 1))
		{
			fm_remove_model_ents(id)
		}
	}
}

public client_connect(id)
{
	new team[32]
	get_user_team(id, team, 31)
	if (is_user_admin(id) && equal(team, "VIP", 3))
	{
		fhl_set_user_model(id, a_Skins[12])
	}
}
