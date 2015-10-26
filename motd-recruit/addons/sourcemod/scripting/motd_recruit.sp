#include <sourcemod>
#include <csgocolors>

public Plugin:myinfo = {
    name = "MOTD Recruit",
    author = "gorgitko",
    description = "Shows MOTD for admin recruitment",
    version = "1.0",
    url = "ezpz.cz"
};

ConVar g_cvEnabled;
ConVar g_cvAdress;

public OnPluginStart() {
    RegConsoleCmd("sm_nabor", Recruit);
    RegConsoleCmd("sm_recruit", Recruit);
    g_cvEnabled = CreateConVar("sm_ezpz_motd_recruit_enabled", "1", "Enables or disables plugin.\n[0 = DISABLED, 1 = ENABLED, DEFAULT: 1]");
    g_cvAdress = CreateConVar("sm_ezpz_motd_recruit_adress", "motd-recruit.ezpz.cz", "Sets the MOTD adress.\nUse format 'adress' with quotes and without '/' on the end!\n[DEFAULT: motd-admin.ezpz.cz]");
}

public Action:Recruit(client, args)
{
    new String:language[10];
    new languageNumber = GetClientLanguage(client);
    GetLanguageInfo(languageNumber, language, sizeof(language));
    
    if (g_cvEnabled.IntValue == 1)
    {
      new String:adress[128];
      GetConVarString(g_cvAdress, adress, sizeof(adress));
      new String:result[512];
      
      //Format(result, sizeof(result), "http://motd-soutez.ezpz.cz/?lang=%s", language);
      
      Format(result, sizeof(result), "%s?lang=%s", adress, language);
      
      if (StrEqual(language, "cze"))
      {
        ShowMOTDPanel(client, "Nabor", result, MOTDPANEL_TYPE_URL);
      }
      else
      {
        ShowMOTDPanel(client, "Recruitment", result, MOTDPANEL_TYPE_URL);
      }
    }
}