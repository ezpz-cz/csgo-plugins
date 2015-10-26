#include <sourcemod>

public Plugin:myinfo = {
    name = "MOTD Rules",
    author = "gorgitko",
    description = "Shows MOTD with server rules",
    version = "1.0",
    url = "ezpz.cz"
};

ConVar g_cvEnabled;
ConVar g_cvAdress;

public OnPluginStart() {
    RegConsoleCmd("sm_rule", Contest);
    RegConsoleCmd("sm_rules", Contest);
    RegConsoleCmd("sm_pravidla", Contest);
    RegConsoleCmd("sm_pravidlo", Contest);
    g_cvEnabled = CreateConVar("sm_ezpz_motd_rules_enabled", "1", "Enables or disables MOTD Rules plugin.\n[0 = DISABLED, 1 = ENABLED, DEFAULT: 1]");
    g_cvAdress = CreateConVar("sm_ezpz_motd_rules_adress", "motd.ezpz.cz", "Sets the MOTD Rules adress.\nUse format 'adress' with quotes and without '/' on the end!\n[DEFAULT: motd.ezpz.cz]");
}

public Action:Contest(client, args)
{
    if (g_cvEnabled.IntValue == 1)
    {
      new String:adress[128];
      GetConVarString(g_cvAdress, adress, sizeof(adress));

      ShowMOTDPanel(client, "Soutez", adress, MOTDPANEL_TYPE_URL);
    }
}