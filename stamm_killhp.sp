/**
 * -----------------------------------------------------
 * File        stamm_killhp.sp
 * Authors     David <popoklopsi> Ordnung
 * License     GPLv3
 * Web         http://popoklopsi.de
 * -----------------------------------------------------
 * 
 * Copyright (C) 2012-2014 David <popoklopsi> Ordnung
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */


// Includes
#include <sourcemod>
#include <autoexecconfig>

#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>


#pragma semicolon 1



new Handle:g_hHP;
new Handle:g_hMHP;



public Plugin:myinfo =
{
	name = "Stamm Feature KillHP",
	author = "Popoklopsi",
	version = "1.3.1",
	description = "Give VIP's HP every kill",
	url = "https://forums.alliedmods.net/showthread.php?t=142073"
};




// Add Feature
public OnAllPluginsLoaded()
{
	if (!STAMM_IsAvailable()) 
	{
		SetFailState("Can't Load Feature, Stamm is not installed!");
	}

	STAMM_LoadTranslation();
	STAMM_RegisterFeature("VIP KillHP");
}




// Auto updater
public STAMM_OnFeatureLoaded(const String:basename[])
{
	decl String:urlString[256];


	Format(urlString, sizeof(urlString), "http://popoklopsi.de/stamm/updater/update.php?plugin=%s", basename);

	if (LibraryExists("updater") && STAMM_AutoUpdate())
	{
		Updater_AddPlugin(urlString);
		Updater_ForceUpdate();
	}
}




// Add descriptions
public STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array)
{
	decl String:fmt[256];
	
	Format(fmt, sizeof(fmt), "%T", "GetKillHP", client, GetConVarInt(g_hHP));
	
	PushArrayString(array, fmt);
}




// Create config
public OnPluginStart()
{
	AutoExecConfig_SetFile("killhp", "stamm/features");
	AutoExecConfig_SetCreateFile(true);
	
	g_hHP = AutoExecConfig_CreateConVar("killhp_hp", "5", "HP a VIP gets every kill");
	g_hMHP = AutoExecConfig_CreateConVar("killhp_max", "100", "Max HP of a player");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
	

	HookEvent("player_death", PlayerDeath);
}





// Player died
public PlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new mhp = GetConVarInt(g_hMHP);
	

	if (STAMM_IsClientValid(client) && STAMM_IsClientValid(attacker))
	{
		// Give HP to Killer
		if (STAMM_HaveClientFeature(attacker))
		{
			new newHP = GetClientHealth(attacker) + GetConVarInt(g_hHP);
			
			// Not more than Max HP
			if (newHP >= mhp) 
			{
				newHP = mhp;
			}

			// Set health
			SetEntityHealth(attacker, newHP);
		}
	}
}