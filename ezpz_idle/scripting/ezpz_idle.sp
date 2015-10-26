#include <sourcemod>
#include <cstrike>
#include <sdktools_functions>
#include <sdkhooks>

public Plugin:myinfo = {
    name = "EzPz.cz IDLE",
    author = "gorgitko",
    description = "Handles the IDLE actions",
    version = "1.1",
    url = "ezpz.cz"
};

ConVar g_cvTeamJoinTime;
new Handle:moveTimer;

public OnPluginStart() {
    g_cvTeamJoinTime = CreateConVar("sm_ezpz_idle_connecttimer", "5.0", "Determines how many seconds after connect will be player automatically moved to team.\n[MIN = 5.0, DEFAULT: 5.0]", _, true, 5.0);
    AutoExecConfig();
}

public OnClientPutInServer(client)
{
    PrintToConsole(client, "Waiting %d seconds to move to team...", GetConVarInt(g_cvTeamJoinTime));
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    moveTimer = CreateTimer(GetConVarFloat(g_cvTeamJoinTime), MovePlayer, GetClientSerial(client));
}

public Action:MovePlayer(Handle:timer, any:serial)
{
    new client = GetClientFromSerial(serial);
    
    if (!client == 0)
	  {
        if (!IsFakeClient(client))
        {
            PrintToConsole(client, "Preparing to move...");
            
            new CT_count = GetTeamClientCount(CS_TEAM_CT);
            new T_count = GetTeamClientCount(CS_TEAM_T);
            
            if (CT_count > T_count)
            {
                ChangeClientTeam(client, CS_TEAM_T);
            }
            else if (CT_count == T_count)
            {
                ChangeClientTeam(client, CS_TEAM_T);
            }
            else
            {
                ChangeClientTeam(client, CS_TEAM_CT);
            }
            
            PrintToConsole(client, "You have been moved.");
        }
    }
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
    return Plugin_Stop;
}