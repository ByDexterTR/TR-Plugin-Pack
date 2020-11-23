#include <sourcemod>
#include <sdktools>
#include <warden>
#include <cstrike>
#include <clientprefs>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = 
{
	name = "[JB] Ct Rev Menu", 
	author = "quantum.", 
	description = "Ölen ct korumalarının revlenmesi için komutçuya bir menü gönderir", 
	version = "1.1", 
	url = "https://forum.pluginmerkezi.com"
};

int revhak = 0;
int revsure[MAXPLAYERS] = 0;
bool dokun[MAXPLAYERS] = false;

ConVar hak = null, revle = null, revflag = null;
Cookie menuactive = null;

public void OnPluginStart()
{
	RegConsoleCmd("sm_ctrevmenu", RevMenu);
	RegConsoleCmd("sm_haksifir", HakSifir);
	RegConsoleCmd("sm_otorevmenu", Toggle);
	
	HookEvent("round_start", ElBasi, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnClientDeath);
	
	menuactive = new Cookie("PM-RevMenu", "CT Rev Menu Cookie Handle", CookieAccess_Protected);
	
	hak = CreateConVar("sm_ctrev_hak", "3", "CT Rev Menüsünün Kaç Hakkı Olsun!");
	revle = CreateConVar("sm_ctrev_sure", "5", "Revlenecek oyuncu kaç saniye sonra revlenebilsin?");
	revflag = CreateConVar("sm_ctrev_flag", "b", "CT Rev menüsüne erişim ve hakları sıfırlamak için gereken yetki bayrağı.(Komutçunun otomatik olarak erişimi olur)");
	
	AutoExecConfig(true, "CtRevMenu", "PluginMerkezi");
}

public void OnMapStart()
{
	char map[32];
	GetCurrentMap(map, sizeof(map));
	if (strncmp(map, "workshop/", 9, false) == 0)
	{
		if (StrContains(map, "/jb_", false) == -1 && StrContains(map, "/jail_", false) == -1 && StrContains(map, "/ba_jail", false) == -1)
		{
			SetFailState("[PM] CtRevMenu sadece Jailbreak modunda çalışır.");
		}
	}
	else if (strncmp(map, "jb_", 3, false) != 0 && strncmp(map, "jail_", 5, false) != 0 && strncmp(map, "ba_jail", 3, false) != 0)
	{
		SetFailState("[PM] CtRevMenu sadece Jailbreak modunda çalışır.");
	}
}

public void OnClientCookiesCached(int client)
{
	char buffer[4];
	menuactive.Get(client, buffer, sizeof(buffer));
	if (strcmp(buffer, "") == 0)
	{
		menuactive.Set(client, "1");
	}
}

public Action RevMenu(int client, int args)
{
	char adminflag[4];
	revflag.GetString(adminflag, sizeof(adminflag));
	if (warden_iswarden(client) || CheckAdminFlag(client, adminflag))
	{
		if (revhak > 0)
		{
			ReviveMenu().Display(client, MENU_TIME_FOREVER);
			return Plugin_Handled;
		}
		else
		{
			PrintHintText(client, "Rev hakkı bittmiş kimseyi revleyemezsin!");
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Sadece \x0CKomutçu \x01veya \x04Yetkili \x01bu menüye erişebilir!");
		return Plugin_Handled;
	}
}

public Action HakSifir(int client, int args)
{
	char adminflag[4];
	revflag.GetString(adminflag, sizeof(adminflag));
	if (warden_iswarden(client) || CheckAdminFlag(client, adminflag))
	{
		revhak = hak.IntValue;
		ReplyToCommand(client, "[SM] \x04Başarıyla \x01kalan hak \x10%d \x01olarak güncellendi!", revhak);
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[SM] \x01Sadece \x0CKomutçu \x01veya \x04Yetkili \x01bu komutu kullanabilir!");
		return Plugin_Handled;
	}
}

public Action Toggle(int client, int args)
{
	char buffer[4];
	menuactive.Get(client, buffer, sizeof(buffer));
	if (strcmp(buffer, "0") == 0)
	{
		menuactive.Set(client, "1");
		ReplyToCommand(client, "[SM] \x01Artık \x04CT Rev Menüsü \x0Cotomatik açılacak!");
	}
	else
	{
		menuactive.Set(client, "0");
		ReplyToCommand(client, "[SM] \x01Artık \x04CT Rev Menüsü \x0Cotomatik açılmayacak!");
	}
	return Plugin_Handled;
}

Menu ReviveMenu()
{
	Menu menu = new Menu(RevHandle);
	menu.SetTitle("★Revlenecek Oyuncuyu Seçiniz★\n          ★ Kalan hak: %d ★", revhak);
	menu.AddItem("reload", "! Sayfayı Yenile !\n ");
	for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT && !IsPlayerAlive(i))
	{
		char name[MAX_NAME_LENGTH], id[8];
		GetClientName(i, name, sizeof(name));
		Format(id, sizeof(id), "%d", i);
		if (dokun[i])
		{
			Format(name, sizeof(name), "%s(Hazır!)", name);
			menu.AddItem(id, name);
		}
		else
		{
			Format(name, sizeof(name), "%s(%d Saniye)", name, revsure[i]);
			menu.AddItem(id, name, ITEMDRAW_DISABLED);
		}
	}
	return menu;
}

public int RevHandle(Menu menu, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char item[16];
		menu.GetItem(position, item, sizeof(item));
		if (strcmp(item, "reload") == 0)
			ReviveMenu().Display(client, MENU_TIME_FOREVER);
		else
		{
			int revkisi = StringToInt(item);
			CS_RespawnPlayer(revkisi);
			revhak--;
			PrintToChatAll("[SM] \x0E%N \x09isimli koruma revledi. \x0CKalan hak: \x10%d.", revkisi, revhak);
			dokun[revkisi] = false;
			if (revhak > 0)
				ReviveMenu().Display(client, MENU_TIME_FOREVER);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action OnClientDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		revsure[client] = revle.IntValue;
		CreateTimer(1.0, MenuUpdate, client, TIMER_REPEAT);
		char buffer[4];
		for (int i = 1; i <= MaxClients; i++)if (IsClientInGame(i) && !IsFakeClient(i) && warden_iswarden(i))
		{
			menuactive.Get(i, buffer, sizeof(buffer));
			if (strcmp(buffer, "1") == 0)
			{
				if (revhak != 0)
					ReviveMenu().Display(i, MENU_TIME_FOREVER);
				else
					PrintHintText(i, "Rev hakkı bittmiş kimseyi revleyemezsin!");
			}
		}
	}
}

public Action MenuUpdate(Handle timer, int client)
{
	revsure[client]--;
	if (revsure[client] == 0)
	{
		dokun[client] = true;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action ElBasi(Handle event, const char[] name, bool dontBroadcast)
{
	if (revhak != hak.IntValue)
		revhak = hak.IntValue;
}

bool CheckAdminFlag(int client, const char[] flags)
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