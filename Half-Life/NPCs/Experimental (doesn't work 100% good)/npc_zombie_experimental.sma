#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <xs>

#define PLUGIN "Zombies NPC"
#define VERSION "0.1"
#define AUTHOR "Glaster"


const Float: VIDA = 100.0;
const Float: DAMAGE = 50.0;
const Float: SPEED = 100.0;
const Float: MIN_RANGE = 50.0;
const Float: ATTACK_RANGE = 60.0;
const SEC_APPEAR = 6;
const SEC_STAND = 33;
const SEC_WALK = 10;
new
const SEC_ATTACK[3] = { 1, 36, 38 };

new
const CLASSNAME[] = "NPC_ZOMBIE";
new
const MODEL[] = "models/zombie.mdl";
new Float: g_origin[3], g_model;
public plugin_precache()
{
	g_model = precache_model(MODEL);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_think(CLASSNAME, "fw_NpcThink");
	register_clcmd("say orign", "clcmd_origin");
	register_clcmd("say spawn", "clcmd_spawn");
}

public clcmd_origin(id)
{
	entity_get_vector(id, EV_VEC_origin, g_origin);

	client_print(id, print_chat, "Origins Seted!.");

	return PLUGIN_CONTINUE;
}

public clcmd_spawn(id)
{
	if (!g_origin[0] && !g_origin[1] && !g_origin[2])
	{
		client_print(id, print_chat, "Type origin to set the origin of the NPC.");
		return PLUGIN_HANDLED;
	}

	if (zombie_spawn(g_origin))
	{
		client_print(id, print_chat, "NPC created.");
	}
	else
	{
		client_print(id, print_chat, "The space is occupied, choose another origin.");
	}

	return PLUGIN_HANDLED;
}

public fw_NpcThink(ent)
{
	static victim, Float: dist;

	if (entity_get_int(ent, EV_INT_iuser1))
	{
		entity_set_int(ent, EV_INT_iuser1, 0);
		entity_set_int(ent, EV_INT_sequence, SEC_STAND);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.0);
		return;
	}

	victim = entity_get_edict(ent, EV_ENT_enemy);

	if (!victim)
	{
		victim = get_closest_player(ent, dist);
	}
	else
	{
		attack(ent);
		entity_set_edict(ent, EV_ENT_enemy, 0);
		entity_set_int(ent, EV_INT_iuser1, 1);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.7);
		return;
	}

	if (dist < MIN_RANGE)
	{
		entity_set_edict(ent, EV_ENT_enemy, victim);
		entity_set_vector(ent, EV_VEC_velocity, Float:
		{
			0.0, 0.0, 0.0 });

		entity_set_int(ent, EV_INT_sequence, SEC_ATTACK[random(sizeof(SEC_ATTACK))]);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.3);

		return;
	}

	if (victim)
	{
		entity_set_int(ent, EV_INT_sequence, SEC_WALK);
		static Float: origin[3], Float: originT[3];
		entity_get_vector(ent, EV_VEC_origin, origin);
		entity_get_vector(victim, EV_VEC_origin, originT);

		xs_vec_sub(originT, origin, originT);
		xs_vec_normalize(originT, originT);
		xs_vec_mul_scalar(originT, SPEED, originT);

		entity_set_vector(ent, EV_VEC_velocity, originT);
		originT[2] = 0.0;
		vector_to_angle(originT, originT);
		entity_set_vector(ent, EV_VEC_angles, originT);
	}
	else
	{
		entity_set_int(ent, EV_INT_sequence, SEC_STAND);
		entity_set_vector(ent, EV_VEC_velocity, Float:
		{
			0.0, 0.0, 0.0 });
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.0);
	}

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.2);
}

zombie_spawn(const Float: origin[3])
{
	if (!is_hull_vacant(origin, HULL_HUMAN))
		return 0;

	new ent = create_entity("info_target");
	entity_set_float(ent, EV_FL_takedamage, 1.0);
	entity_set_float(ent, EV_FL_health, VIDA);

	entity_set_string(ent, EV_SZ_classname, CLASSNAME);
	entity_set_model(ent, MODEL);

	entity_set_int(ent, EV_INT_modelindex, g_model);

	#
	define VEC_HUMAN_HULL_MIN
	{ -8.0, -8.0, 0.0 }#
	define VEC_HUMAN_HULL_MAX
	{ 8.0, 8.0, 36.0 }

	entity_set_size(ent, Float: VEC_HUMAN_HULL_MIN, Float: VEC_HUMAN_HULL_MAX);

	entity_set_int(ent, EV_INT_sequence, SEC_APPEAR);
	entity_set_float(ent, EV_FL_animtime, get_gametime());
	entity_set_float(ent, EV_FL_framerate, 1.0);

	entity_set_origin(ent, origin);
	drop_to_floor(ent);

	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP);
	entity_set_int(ent, EV_INT_flags, entity_get_int(ent, EV_INT_flags) | FL_MONSTER);
	entity_set_float(ent, EV_FL_gravity, 1.0);
	entity_set_float(ent, EV_FL_friction, 0.5);

	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);

	return ent;
}

attack(ent)
{
	new Float: origin[3], Float: originT[3];

	entity_get_vector(ent, EV_VEC_angles, originT);
	entity_get_vector(ent, EV_VEC_origin, origin);
	angle_vector(originT, ANGLEVECTOR_FORWARD, originT);
	xs_vec_normalize(originT, originT);
	xs_vec_mul_scalar(originT, 10.0, originT);
	xs_vec_add(origin, originT, originT);

	new victim = -1;
	while ((victim = find_ent_in_sphere(victim, originT, ATTACK_RANGE)) > 0)
	{
		if (!(1 <= victim <= 32))
			continue;

		if (!is_user_alive(victim))
			continue;

		ExecuteHamB(Ham_TakeDamage, victim, ent, ent, DAMAGE, DMG_CLUB);
	}
}

stock get_closest_player(ent, &Float: distance)
{
	static players[32], num;
	get_players(players, num, "a");

	new player = 0;
	static id, Float: dist, Float: mindist;
	mindist = 5000.0;

	for (new i = 0; i < num; i++)
	{
		player = players[i];

		dist = entity_range(player, ent);

		if (dist <= mindist)
		{
			id = player;
			mindist = dist;
		}
	}

	distance = mindist;
	return id;
}

stock bool: is_hull_vacant(const Float: origin[3], hull)
{
	return !trace_hull(origin, hull, 0, 0);
}
