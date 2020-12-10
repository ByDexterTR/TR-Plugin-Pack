#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include <store>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "İsyancı Level Sistemi", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

Handle Gardiyanoldurme = null;
Handle Seviye = null;

ConVar Seviye1_oldurme = null, Seviye2_oldurme = null, Seviye3_oldurme = null, Seviye4_oldurme = null, Seviye5_oldurme = null;
ConVar Seviye1_odul = null, Seviye2_odul = null, Seviye3_odul = null, Seviye4_odul = null, Seviye5_odul = null;

public void OnPluginStart()
{
	RegConsoleCmd("sm_rebel", Command_Rebel);
	
	Gardiyanoldurme = RegClientCookie("Dexter-GardiyanOldurme", "Isyancı Sisteminde Gardiyanlarin oldurmesini ceker", CookieAccess_Protected);
	Seviye = RegClientCookie("Dexter-IsyanciOldurme", "Isyancı Seviyesi", CookieAccess_Protected);
	
	Seviye1_oldurme = CreateConVar("sm_seviye1_oldurme", "15", "1. Seviye olunmak için gereken öldürme sayısı", 0, true, 1.0);
	Seviye2_oldurme = CreateConVar("sm_seviye2_oldurme", "30", "2. Seviye olunmak için gereken öldürme sayısı", 0, true, 2.0);
	Seviye3_oldurme = CreateConVar("sm_seviye3_oldurme", "50", "3. Seviye olunmak için gereken öldürme sayısı", 0, true, 3.0);
	Seviye4_oldurme = CreateConVar("sm_seviye4_oldurme", "70", "4. Seviye olunmak için gereken öldürme sayısı", 0, true, 4.0);
	Seviye5_oldurme = CreateConVar("sm_seviye5_oldurme", "100", "5. Seviye olunmak için gereken öldürme sayısı", 0, true, 5.0);
	
	Seviye1_odul = CreateConVar("sm_seviye1_odul", "500", "1. Seviye olunduğunda kredi ödülü", 0, true, 1.0);
	Seviye2_odul = CreateConVar("sm_seviye2_odul", "500", "2. Seviye olunduğunda kredi ödülü", 0, true, 2.0);
	Seviye3_odul = CreateConVar("sm_seviye3_odul", "500", "3. Seviye olunduğunda kredi ödülü", 0, true, 3.0);
	Seviye4_odul = CreateConVar("sm_seviye4_odul", "500", "4. Seviye olunduğunda kredi ödülü", 0, true, 4.0);
	Seviye5_odul = CreateConVar("sm_seviye5_odul", "500", "5. Seviye olunduğunda kredi ödülü", 0, true, 5.0);
	
	AutoExecConfig(true, "Isyanci-Level", "ByDexter");
	
	HookEvent("player_death", OnClientDead);
	for (int i = 1; i <= MaxClients; i++)if (IsValidClient(i))
	{
		OnClientCookiesCached(i);
	}
}

public Action OnClientDead(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (IsValidClient(attacker))
	{
		if (GetClientTeam(attacker) != CS_TEAM_T)return;
		int victim = GetClientOfUserId(event.GetInt("client"));
		if (GetClientTeam(victim) != CS_TEAM_CT)return;
		char buffer2[128];
		GetClientCookie(attacker, Seviye, buffer2, sizeof(buffer2));
		if (StrEqual(buffer2, "5", true))return;
		char buffer[128];
		GetClientCookie(attacker, Gardiyanoldurme, buffer, sizeof(buffer));
		Format(buffer, sizeof(buffer), "%d", StringToInt(buffer) + 1);
		SetClientCookie(attacker, Gardiyanoldurme, buffer);
		if (StrEqual(buffer2, "0", true))
		{
			if (Seviye1_oldurme.IntValue == StringToInt(buffer))
			{
				Store_SetClientCredits(attacker, Store_GetClientCredits(attacker) + Seviye1_odul.IntValue);
				SetClientCookie(attacker, Seviye, "1");
			}
		}
		else if (StrEqual(buffer2, "1", true))
		{
			if (Seviye2_oldurme.IntValue == StringToInt(buffer))
			{
				Store_SetClientCredits(attacker, Store_GetClientCredits(attacker) + Seviye2_odul.IntValue);
				SetClientCookie(attacker, Seviye, "2");
			}
		}
		else if (StrEqual(buffer2, "2", true))
		{
			if (Seviye3_oldurme.IntValue == StringToInt(buffer))
			{
				Store_SetClientCredits(attacker, Store_GetClientCredits(attacker) + Seviye3_odul.IntValue);
				SetClientCookie(attacker, Seviye, "3");
			}
		}
		else if (StrEqual(buffer2, "3", true))
		{
			if (Seviye4_oldurme.IntValue == StringToInt(buffer))
			{
				Store_SetClientCredits(attacker, Store_GetClientCredits(attacker) + Seviye4_odul.IntValue);
				SetClientCookie(attacker, Seviye, "4");
			}
		}
		else if (StrEqual(buffer2, "4", true))
		{
			if (Seviye5_oldurme.IntValue == StringToInt(buffer))
			{
				Store_SetClientCredits(attacker, Store_GetClientCredits(attacker) + Seviye5_odul.IntValue);
				SetClientCookie(attacker, Seviye, "5");
			}
		}
	}
}

public Action Command_Rebel(int client, int args)
{
	char buffer[128];
	GetClientCookie(client, Gardiyanoldurme, buffer, sizeof(buffer));
	char buffer2[128];
	GetClientCookie(client, Seviye, buffer2, sizeof(buffer2));
	Menu menu = new Menu(Menu_CallBack);
	menu.SetTitle("★ İsyancı Sistemi ★\n \n→ İsyancı Seviyesi: %s\n→ Gardiyan Öldürme Sayısı: %s", buffer2, buffer);
	menu.AddItem("1", "→ Seviye Sistemi");
	menu.AddItem("2", "→ Seviye Ödülleri\n ");
	menu.AddItem("3", "→ Kapat");
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	menu.Display(client, 20);
}

public int Menu_CallBack(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (StrEqual(Item, "1", true))
		{
			Seviyesistemi().Display(client, MENU_TIME_FOREVER);
		}
		else if (StrEqual(Item, "2", true))
		{
			Seviyeodulleri().Display(client, MENU_TIME_FOREVER);
		}
		else if (StrEqual(Item, "3", true))
		{
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

Menu Seviyeodulleri()
{
	Menu menu3 = new Menu(SeviyeOdul_CallBack);
	menu3.SetTitle("★ İsyancı Seviye Ödülleri ★\n \n→ Seviye 1: %d Kredi\n→ Seviye 2: %d Kredi\n→ Seviye 3: %d Kredi\n→ Seviye 4: %d Kredi\n→ Seviye 5: %d Kredi\n ", Seviye1_odul.IntValue, Seviye2_odul.IntValue, Seviye3_odul.IntValue, Seviye4_odul.IntValue, Seviye5_odul.IntValue);
	menu3.AddItem("1", "→ Geri");
	menu3.ExitBackButton = false;
	menu3.ExitButton = false;
	return menu3;
}

public int SeviyeOdul_CallBack(Menu menu3, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		Command_Rebel(client, 0);
	}
	else if (action == MenuAction_End)
	{
		delete menu3;
	}
}

Menu Seviyesistemi()
{
	Menu menu2 = new Menu(SeviyeSistem_CallBack);
	menu2.SetTitle("★ İsyancı Seviye Sistemi ★\n \n→ Seviye 1: %d Öldürme\n→ Seviye 2: %d Öldürme\n→ Seviye 3: %d Öldürme\n→ Seviye 4: %d Öldürme\n→ Seviye 5: %d Öldürme\n ", Seviye1_oldurme.IntValue, Seviye2_oldurme.IntValue, Seviye3_oldurme.IntValue, Seviye4_oldurme.IntValue, Seviye5_oldurme.IntValue);
	menu2.AddItem("1", "→ Geri");
	menu2.ExitBackButton = false;
	menu2.ExitButton = false;
	return menu2;
}

public int SeviyeSistem_CallBack(Menu menu2, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		Command_Rebel(client, 0);
	}
	else if (action == MenuAction_End)
	{
		delete menu2;
	}
}

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

public void OnClientCookiesCached(int client)
{
	char buffer[128];
	GetClientCookie(client, Gardiyanoldurme, buffer, sizeof(buffer));
	char buffer2[128];
	GetClientCookie(client, Seviye, buffer2, sizeof(buffer2));
	if (StrEqual(buffer, "", false) || StrEqual(buffer2, "", false))
	{
		SetClientCookie(client, Seviye, "0");
		SetClientCookie(client, Gardiyanoldurme, "0");
	}
} 