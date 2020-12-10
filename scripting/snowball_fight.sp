#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

bool BunnyAktifmi = true, Oyunaktifmi = false, Gravity = false, OyuncuHiz = false;
Handle h_timer = null;
int sure = -1;
ConVar g_KullaniciFlag = null;

public Plugin myinfo = 
{
	name = "[JB] Kartopu Savaşı", 
	author = "ByDexter", 
	description = "30 Satır 30₺ za ^-^ ( Beleş eklentiyi satacak değiliz ya )", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	g_KullaniciFlag = CreateConVar("sm_snowball_flag", "f", "Komutçu harici kimler sm_kartopu komutuna erişsin!");
	RegConsoleCmd("sm_kartopu", Command_Kartopu);
	RegConsoleCmd("sm_snowball", Command_Kartopu);
	HookEvent("weapon_fire", WeaponFire);
	AutoExecConfig(true, "Kartopu-Savasi", "ByDexter");
	for (int i = 1; i <= MaxClients; i++)
	if (IsClientInGame(i))
		OnClientPostAdminCheck(i);
}

public void OnPluginEnd() { if (Oyunaktifmi) { Duzelt(); } }

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Command_Kartopu(int client, int args)
{
	char Flag[4];
	g_KullaniciFlag.GetString(Flag, sizeof(Flag));
	if (warden_iswarden(client) || CheckAdminFlag(client, Flag))
	{
		Menu_Snowball().Display(client, MENU_TIME_FOREVER);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
}

Menu Menu_Snowball()
{
	Menu menu = new Menu(Menu_Callback);
	menu.SetTitle("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n   ★ Kar Topu - Ayarlar ★\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	
	if (!Oyunaktifmi)
		menu.AddItem("0", "→ Başlat");
	else
		menu.AddItem("1", "→ Durdur");
	
	if (BunnyAktifmi)
		menu.AddItem("2", "→ Bunny: Aktif");
	else
		menu.AddItem("2", "→ Bunny: Kapalı");
	
	if (OyuncuHiz)
		menu.AddItem("3", "→ Hızlı Yürüme: Açık");
	else
		menu.AddItem("3", "→ Hızlı Yürüme: Kapalı");
	
	if (Gravity)
		menu.AddItem("4", "→ Gravity: Açık\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	else
		menu.AddItem("4", "→ Gravity: Kapalı\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	
	menu.AddItem("5", "→ Kapat");
	
	menu.ExitBackButton = false;
	menu.ExitButton = false;
	
	return menu;
}

public int Menu_Callback(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu.GetItem(position, Item, sizeof(Item));
		if (strcmp(Item, "0") == 0)
		{
			if (!Oyunaktifmi)
			{
				if (BunnyAktifmi)
					BunnyAyarla(true);
				else
					BunnyAyarla(false);
				
				if (Gravity)
					SetCvar("sv_gravity", 400);
				else
					SetCvar("sv_gravity", 800);
				
				Oyunaktifmi = true;
				sure = 10;
				if (h_timer != null)
					delete h_timer;
				h_timer = CreateTimer(1.0, Sureeksilt, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
			}
			else
			{
				PrintToChat(client, "[SM] Hata Algılandı!");
				Menu_Snowball().Display(client, MENU_TIME_FOREVER);
			}
		}
		else if (strcmp(Item, "1") == 0)
		{
			if (Oyunaktifmi)
			{
				Duzelt();
			}
			else
			{
				PrintToChat(client, "[SM] Hata Algılandı!");
				Menu_Snowball().Display(client, MENU_TIME_FOREVER);
			}
		}
		else if (strcmp(Item, "2") == 0)
		{
			if (BunnyAktifmi)
				BunnyAktifmi = false;
			else
				BunnyAktifmi = true;
			Menu_Snowball().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "3") == 0)
		{
			if (OyuncuHiz)
				OyuncuHiz = false;
			else
				OyuncuHiz = true;
			Menu_Snowball().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "4") == 0)
		{
			if (Gravity)
				Gravity = false;
			else
				Gravity = true;
			Menu_Snowball().Display(client, MENU_TIME_FOREVER);
		}
		else if (strcmp(Item, "5") == 0)
		{
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

void Duzelt()
{
	BunnyAyarla(true);
	FFAyarla(false);
	SetCvar("sv_gravity", 800);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			ClearWeaponEx(i);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			GivePlayerItem(i, "weapon_knife");
		}
	}
	if (h_timer != null)
	{
		delete h_timer;
		h_timer = null;
	}
	Oyunaktifmi = false;
}

public Action Sureeksilt(Handle timer, any data)
{
	sure--;
	if (sure > 0)
	{
		PrintHintTextToAll("→ %d Saniye sonra Kar Topu savaşı başlayacak ←", sure);
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
			{
				ClearWeaponEx(i);
				GivePlayerItem(i, "weapon_snowball");
				if (OyuncuHiz)
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.4);
			}
		}
		PrintToChatAll("[SM] \x01Kar Topu savaşı başladı!");
		PrintHintTextToAll("→ KAR TOPU SAVASI BASLADI ←");
		FFAyarla(true);
		h_timer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	if (Oyunaktifmi)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		char WeaponName[32];
		GetClientWeapon(client, WeaponName, sizeof(WeaponName));
		if (strcmp(WeaponName, "weapon_snowball") == 0 && IsClientInGame(client))
		{
			CreateTimer(0.3, kartopuver, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (strcmp(WeaponName, "weapon_snowball") != 0)
		{
			ClearWeaponEx(client);
			EquipPlayerWeapon(client, GivePlayerItem(client, "weapon_snowball"));
		}
	}
}

public Action kartopuver(Handle timer, int client)
{
	GivePlayerItem(client, "weapon_snowball");
	RemovePlayerItem(client, GivePlayerItem(client, "weapon_awp"));
	FakeClientCommand(client, "use weapon_snowball");
	return Plugin_Stop;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (Oyunaktifmi && GetClientTeam(attacker) == CS_TEAM_T)
	{
		if (GetClientTeam(victim) == CS_TEAM_T)
		{
			char WeaponName[32];
			GetClientWeapon(attacker, WeaponName, sizeof(WeaponName));
			if (strcmp(WeaponName, "weapon_snowball") == 0)
			{
				damage = 10000.0;
				PrintToChatAll("[SM] \x10%N \x01, kar topu ile \x10%N \x01kafasını yardı!", attacker, victim);
				return Plugin_Changed;
			}
		}
		else
		{
			damage = 0.0;
			PrintToChat(attacker, "[SM] Ahbap yanlış adamın kafasına atıyorsun kartopunu");
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

stock void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

stock void SetCvarFloat(char[] cvarName, float value)
{
	ConVar FloatCvar = FindConVar(cvarName);
	if (FloatCvar == null)return;
	int flags = FloatCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
	FloatCvar.FloatValue = value;
	flags |= FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
}

stock void FFAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
	}
	else
	{
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
	}
}

stock void BunnyAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("sv_enablebunnyhopping", 1);
		SetCvar("sv_autobunnyhopping", 1);
		SetCvar("sv_airaccelerate", 2000);
		SetCvar("sv_staminajumpcost", 0);
		SetCvar("sv_staminalandcost", 0);
		SetCvar("sv_staminamax", 0);
		SetCvar("sv_staminarecoveryrate", 60);
	}
	else
	{
		SetCvar("sv_enablebunnyhopping", 0);
		SetCvar("sv_autobunnyhopping", 0);
		SetCvar("sv_airaccelerate", 101);
		SetCvarFloat("sv_staminajumpcost", 0.080);
		SetCvarFloat("sv_staminalandcost", 0.050);
		SetCvar("sv_staminamax", 80);
		SetCvar("sv_staminarecoveryrate", 60);
	}
}

stock bool CheckAdminFlag(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
}

stock void ClearWeaponEx(int client)
{
	int wepIdx;
	for (int i; i < 12; i++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEntity(wepIdx);
		}
	}
} 