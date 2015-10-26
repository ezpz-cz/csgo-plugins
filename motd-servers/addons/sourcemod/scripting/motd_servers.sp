#include <sourcemod>

public Plugin:myinfo = {
    name = "MOTD Servers",
    author = "Biosek, gorgitko",
    description = "Shows MOTD for ezpz.cz servers",
    version = "1.1",
    url = "ezpz.cz"
};

ConVar g_cvAdress;

public OnPluginStart() {
    RegConsoleCmd("sm_server", servers);
    RegConsoleCmd("sm_servery", servers);
    RegConsoleCmd("sm_servers", servers);
    g_cvAdress = CreateConVar("sm_ezpz_motd_servers_adress", "motd-servers.ezpz.cz", "Sets the MOTD-servers adress.\nUse format 'adress' with quotes and without '/' on the end!\n[DEFAULT: motd-servers.ezpz.cz]");
}

public Action:servers(client, args) {
    new String:adress[128];
    GetConVarString(g_cvAdress, adress, sizeof(adress));
    new String:result[512];
    Format(result, sizeof(result), "%s", adress);
        
    ShowMOTDPanel(client, "Servers", adress, MOTDPANEL_TYPE_URL); 

    return Plugin_Handled; 
}