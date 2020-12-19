#include <sourcemod>
#include <clientprefs>
#include <basecomm>

#pragma semicolon 1
#pragma newdecls required

Cookie Uyari = null;
Handle g_Uyarilan[MAXPLAYERS] = null;

ConVar uyari_1ceza = null, uyari_1sure = null, uyari_1sebep = null;
ConVar uyari_2ceza = null, uyari_2sure = null, uyari_2sebep = null;
ConVar uyari_3ceza = null, uyari_3sure = null, uyari_3sebep = null;

public Plugin myinfo = 
{
	name = "Gelişmiş Uyarı", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_uyari", Command_Uyari, ADMFLAG_BAN);
	RegConsoleCmd("sm_uyarim", Command_Uyarim);
	RegConsoleCmd("sm_uyarigor", Command_Uyarigor);
	Uyari = new Cookie("ByDexter-Uyari", "Oyuncu Uyarısı", CookieAccess_Protected);
	
	uyari_1ceza = CreateConVar("sm_uyari1_ceza", "0", "0 = GAG & MUTE | 1 = Kick", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	uyari_1sure = CreateConVar("sm_uyari1_gagmute_sure", "5", "Uyarı 1 de Gag mute süre (Dakika)", 0, true, 1.0);
	uyari_1sebep = CreateConVar("sm_uyari1_kick_sebep", "Sunucumuzda yaptığın davranışlarını lütfen düzelt!", "Uyarı 1de kick yiyen oyuncuların sebepi");
	
	uyari_2ceza = CreateConVar("sm_uyari2_ceza", "0", "0 = GAG & MUTE | 1 = Kick", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	uyari_2sure = CreateConVar("sm_uyari2_gagmute_sure", "15", "Uyarı 2 de Gag mute süre (Dakika)", 0, true, 1.0);
	uyari_2sebep = CreateConVar("sm_uyari2_kick_sebep", "Sunucumuzda yaptığın davranışlarını lütfen düzelt!", "Uyarı 2de kick yiyen oyuncuların sebepi");
	
	uyari_3ceza = CreateConVar("sm_uyari3_ceza", "0", "0 = Ban | 1 = Kick", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	uyari_3sure = CreateConVar("sm_uyari3_ban_sure", "30", "Uyarı 3 de Ban süre (Dakika)", 0, true, 1.0);
	uyari_3sebep = CreateConVar("sm_uyari3_kickban_sebep", "Sunucumuzda yaptığın davranışlarını lütfen düzelt!", "Uyarı 3de kick/ban yiyen oyuncuların sebepi");
	
	AutoExecConfig(true, "Gelismis_Uyari", "ByDexter");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			OnClientPostAdminCheck(i);
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (AreClientCookiesCached(client))
	{
		char buffer[128];
		Uyari.Get(client, buffer, sizeof(buffer));
		if (StrEqual(buffer, "", false))
		{
			Uyari.Set(client, "0");
		}
	}
}

public Action Command_Uyari(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_uyari <Hedef>");
		return Plugin_Handled;
	}
	char aptalinargi1[192];
	GetCmdArg(1, aptalinargi1, sizeof(aptalinargi1));
	int target = FindTarget(client, aptalinargi1, true, true);
	if (target == COMMAND_TARGET_NONE || target == COMMAND_TARGET_AMBIGUOUS || target == COMMAND_TARGET_IMMUNE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	char buffer[128];
	Uyari.Get(target, buffer, sizeof(buffer));
	PrintToChatAll("[SM] \x10%N \x01tarafından \x10%N \x01kişisine uyarı verildi!", client, target);
	if (StrEqual(buffer, "0", false))
	{
		Uyari.Set(target, "1");
		if (!uyari_1ceza.BoolValue)
		{
			PrintToChat(target, "[SM] \x04%d Dakika \x01GAG & Mute yedin!", uyari_1sure.IntValue);
			BaseComm_SetClientGag(target, true);
			BaseComm_SetClientMute(target, true);
			if (g_Uyarilan[target] != null)
			{
				delete g_Uyarilan[target];
				g_Uyarilan[target] = null;
			}
			g_Uyarilan[target] = CreateTimer(uyari_1sure.FloatValue * 60.0, Cezakaldir, target, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
		else
		{
			char KickMesaj[512];
			uyari_1sebep.GetString(KickMesaj, sizeof(KickMesaj));
			KickClient(target, KickMesaj);
			return Plugin_Handled;
		}
	}
	else if (StrEqual(buffer, "1", false))
	{
		Uyari.Set(target, "2");
		if (!uyari_2ceza.BoolValue)
		{
			PrintToChat(target, "[SM] \x04%d Dakika \x01GAG & Mute yedin!", uyari_2sure.IntValue);
			BaseComm_SetClientGag(target, true);
			BaseComm_SetClientMute(target, true);
			if (g_Uyarilan[target] != null)
			{
				delete g_Uyarilan[target];
				g_Uyarilan[target] = null;
			}
			g_Uyarilan[target] = CreateTimer(uyari_2sure.FloatValue * 60.0, Cezakaldir, target, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Handled;
		}
		else
		{
			char KickMesaj[1024];
			uyari_2sebep.GetString(KickMesaj, sizeof(KickMesaj));
			KickClient(target, KickMesaj);
			return Plugin_Handled;
		}
	}
	else if (StrEqual(buffer, "2", false))
	{
		Uyari.Set(target, "0");
		char Sebep[1024];
		uyari_3sebep.GetString(Sebep, sizeof(Sebep));
		if (!uyari_3ceza.BoolValue)
		{
			BanClient(target, uyari_3sure.IntValue, BANFLAG_AUTO, Sebep, Sebep);
			return Plugin_Handled;
		}
		else
		{
			KickClient(target, Sebep);
			return Plugin_Handled;
		}
	}
	return Plugin_Handled;
}

public Action Command_Uyarim(int client, int args)
{
	if (args != 0)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_uyarim");
		return Plugin_Handled;
	}
	char buffer[128];
	Uyari.Get(client, buffer, sizeof(buffer));
	PrintToChat(client, "[SM] Uyarın: \x04%s", buffer);
	return Plugin_Handled;
}

public Action Command_Uyarigor(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Kullanım: sm_uyarigor <Hedef>");
		return Plugin_Handled;
	}
	char aptalinargi1[192];
	GetCmdArg(1, aptalinargi1, sizeof(aptalinargi1));
	int target = FindTarget(client, aptalinargi1, true, true);
	if (target == COMMAND_TARGET_NONE || target == COMMAND_TARGET_AMBIGUOUS || target == COMMAND_TARGET_IMMUNE)
	{
		ReplyToTargetError(client, target);
		return Plugin_Handled;
	}
	char buffer[128];
	Uyari.Get(target, buffer, sizeof(buffer));
	PrintToChat(client, "[SM] \x10%N \x01adlı kullanıcının uyarısı: \x04%s", target, buffer);
	return Plugin_Handled;
}

public Action Cezakaldir(Handle timer, int target)
{
	BaseComm_SetClientGag(target, false);
	BaseComm_SetClientMute(target, false);
	PrintToChat(target, "[SM] \x01Cezan sona erdi!");
	return Plugin_Stop;
} 