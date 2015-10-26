#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "gorgitko"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <csgocolors>

ConVar g_cvEnabled;
ConVar g_cvFraglimit;

public Plugin myinfo = 
{
	name = "EzPz.cz Fraglimiter",
	author = PLUGIN_AUTHOR,
	description = "Ends map after fraglimit is reached by some player.",
	version = PLUGIN_VERSION,
	url = "ezpz.cz"
};

public void OnPluginStart()
{
	g_cvEnabled = CreateConVar("sm_ezpz_fraglimiter_enabled", "1", "Enables or disables plugin.\n[0 = DISABLED, 1 = ENABLED, DEFAULT: 1]");
	g_cvFraglimit = CreateConVar("sm_ezpz_fraglimiter_limit", "0", "Sets the fraglimit.\n[DEFAULT: 0]");
	
	AutoExecConfig(true);
	
	HookEvent("player_death", Event_PlayerDeath);
}

public OnClientPostAdminCheck(client)
{
	CreateTimer(5.0, ShowFraglimit, GetClientSerial(client));
}

public Action:ShowFraglimit(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	
	if (IsClientInGame(client) && !IsFakeClient(client) && client > 0)
	{
		CPrintToChat(client, "{DARKRED}FRAGLIMIT {NORMAL}is set to {GREEN}%d {NORMAL}frags", GetConVarInt(g_cvFraglimit));
	}              
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker_id = event.GetInt("attacker");
	int attacker_real_id = GetClientOfUserId(attacker_id);
	
	if (attacker_real_id <= 0) return;
	
 	int attacker_frags = GetClientFrags(attacker_real_id);
 	int fraglimit = GetConVarInt(g_cvFraglimit);
 
 	//PrintToChatAll("attacker_id: %d, attacker_real_id: %d, attacker_name: %s, attacker frags: %d, fraglimit: %d", attacker_id, attacker_real_id, attacker_name, attacker_frags, fraglimit);
 	 
 	if (attacker_frags >= fraglimit)
 	{
 		new String:attacker_name[128];
		GetClientName(attacker_real_id, attacker_name, 128);
		CPrintToChatAll("{DARKRED}WINNER{NORMAL}: {GREEN}%s", attacker_name);
 		ServerCommand("mp_timelimit 1");
 		
 		CS_TerminateRound(1.0, CSRoundEndReason);
 	}
}
