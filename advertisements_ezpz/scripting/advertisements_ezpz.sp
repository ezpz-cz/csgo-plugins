#pragma semicolon 1

#include <sourcemod>
#include <csgocolors>

#define PL_VERSION    "1.0"
#define CVAR_DISABLED "OFF"
#define CVAR_ENABLED  "ON"

public Plugin:myinfo =
{
	name        = "EZPZ Advertisements",
	author      = "gorgitko",
	description = "Display colorful advertisements in different languages defined in file",
	version     = "1.1",
	url         = "ezpz.cz"
};

new g_iFrames = 0;
new g_iTickrate;
new bool:g_bTickrate = true;
new Float:g_flTime;

new Handle:g_hAdvertisements  = INVALID_HANDLE;

new Handle:g_hEnabled;
new Handle:g_hFile;
new Handle:g_hInterval;
new Handle:g_hTimer;

new MAX_PLAYERS;

public OnPluginStart()
{
  MAX_PLAYERS = GetMaxClients();

	CreateConVar("sm_ezpz_ad_version", PL_VERSION, "Displays EZPZ Advertisements version.", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_hEnabled        = CreateConVar("sm_ezpz_ad_enabled",  "1", "Enable/disable displaying advertisements.\n [DEFAULT: 1]");
	g_hFile           = CreateConVar("sm_ezpz_ad_file",     "advertisements_ezpz.txt", "File to read the advertisements from.\n[DEFAULT: 'advertisements_ezpz.txt']");
	g_hInterval       = CreateConVar("sm_ezpz_ad_interval", "30", "Amount of seconds between advertisements.\n[DEFAULT: 30]");
	
	HookConVarChange(g_hInterval, ConVarChange_Interval);
	RegServerCmd("sm_ad_reload", Command_ReloadAds, "Reload the advertisements");
  
  AutoExecConfig(true, "plugin.advertisements_ezpz");
}

public OnMapStart()
{
	ParseAds();
	
	g_hTimer = CreateTimer(GetConVarInt(g_hInterval) * 1.0, Timer_DisplayAds, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public OnGameFrame()
{
	if(g_bTickrate)
	{
		g_iFrames++;
		
		new Float:flTime = GetEngineTime();
		if(flTime >= g_flTime)
		{
			if(g_iFrames == g_iTickrate)
			{
				g_bTickrate = false;
			}
			else
			{
				g_iTickrate = g_iFrames;
				g_iFrames   = 0;    
				g_flTime    = flTime + 1.0;
			}
		}
	}
}

public Action:Timer_DisplayAds(Handle:timer)
{
	if(!GetConVarBool(g_hEnabled))
		return;
    
  decl String:adText[512];
  
  for (new i = 1; i <= MAX_PLAYERS; i++)
  {
      new String:language[10];
      
      decl languageNumber;
      
      if(IsClientInGame(i) && !IsFakeClient(i))
          languageNumber = GetClientLanguage(i);
      else
          continue;
      
      GetLanguageInfo(languageNumber, language, sizeof(language));

      if (StrEqual(language, "cze"))
      {
        KvGetString(g_hAdvertisements, "cze",  adText,  sizeof(adText));
      }
      else
      {
        KvGetString(g_hAdvertisements, "en",  adText,  sizeof(adText));
      }

      if(IsClientInGame(i) && !IsFakeClient(i))
          CPrintToChat(i, "%s", adText);
  }
    	
	if(!KvGotoNextKey(g_hAdvertisements))
	{
		KvRewind(g_hAdvertisements);
		KvGotoFirstSubKey(g_hAdvertisements);
	}
}

public ConVarChange_Interval(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(g_hTimer)
		KillTimer(g_hTimer);
	
	g_hTimer = CreateTimer(GetConVarInt(g_hInterval) * 1.0, Timer_DisplayAds, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Command_ReloadAds(args)
{
	ParseAds();
	return Plugin_Handled;
}

ParseAds()
{
	if(g_hAdvertisements)
		CloseHandle(g_hAdvertisements);
	
	g_hAdvertisements = CreateKeyValues("Advertisements");
	
	decl String:sFile[256], String:sPath[256];
	GetConVarString(g_hFile, sFile, sizeof(sFile));
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/%s", sFile);
	
	if(!FileExists(sPath))
		SetFailState("File Not Found: %s", sPath);
	
	FileToKeyValues(g_hAdvertisements, sPath);
	KvGotoFirstSubKey(g_hAdvertisements);
}