#include <a_samp>
#include <Pawn.CMD>
#include <sscanf2>
#include <sampvoice>
main() 
{}

public OnFilterScriptInit()
{
    printf("");
    printf("// -------- Voice System & Radio System Loaded! -------- // ");
    printf("");
}     

public OnFilterScriptExit() 
{
    return 1;
}

#define     MAX_FREQUENCY	    150

new SV_LSTREAM:lstream[MAX_PLAYERS] = { SV_NULL, ... };
new SV_GSTREAM:Frequency[MAX_FREQUENCY] = SV_NULL;
new FrequencyConnect[MAX_PLAYERS],
    ToggleRadio[MAX_PLAYERS];

public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid, SV_UINT:keyid)
{
    if (keyid == 0x42 && ToggleRadio[playerid] == 1 && Frequency[FrequencyConnect[playerid]] >= 1)
	{
	    ApplyAnimation(playerid, "ped", "phone_talk", 4.1, 1, 1, 1, 0, 0, 0);
	    if(!IsPlayerAttachedObjectSlotUsed(playerid, 9)) SetPlayerAttachedObject(playerid, 9, 19942, 2, 0.0300, 0.1309, -0.1060, 118.8998, 19.0998, 164.2999);
	    SvAttachSpeakerToStream(Frequency[FrequencyConnect[playerid]], playerid);
    }

    if (keyid == 0x42 && ToggleRadio[playerid] == 0 && lstream[playerid])   SvAttachSpeakerToStream(lstream[playerid], playerid);
}

public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid, SV_UINT:keyid)
{
    if (keyid == 0x42 && ToggleRadio[playerid] == 1 && Frequency[FrequencyConnect[playerid]] >= 1)
	{
        SvDetachSpeakerFromStream(Frequency[FrequencyConnect[playerid]], playerid);
        ClearAnimations(playerid);
        if(IsPlayerAttachedObjectSlotUsed(playerid, 9)) RemovePlayerAttachedObject(playerid, 9);
	}

    if (keyid == 0x42 && ToggleRadio[playerid] == 0 && lstream[playerid])   SvDetachSpeakerFromStream(lstream[playerid], playerid);
}

public OnPlayerConnect(playerid)
{
    FrequencyConnect[playerid] = 0;
    ToggleRadio[playerid] = 0;
    
    if (SvGetVersion(playerid) == SV_NULL)
    {
        SendClientMessage(playerid, -1, "Could not find plugin sampvoice.");
    }
    else if (SvHasMicro(playerid) == SV_FALSE)
    {
        SendClientMessage(playerid, -1, "The microphone could not be found.");
    }
    else if ((lstream[playerid] = SvCreateDLStreamAtPlayer(15.0, SV_INFINITY, playerid, 0xff0000ff, "Local")))
    {
        SendClientMessage(playerid, -1, "Voice Only System");
        SvAddKey(playerid, 0x42);
    }
}

public OnPlayerDisconnect(playerid, reason)
{
    FrequencyConnect[playerid] = 0;
    ToggleRadio[playerid] = 0;
    
    if (lstream[playerid])
    {
        SvDeleteStream(lstream[playerid]);
        lstream[playerid] = SV_NULL;
    }
}

public OnGameModeInit()
{
    for(new i; i < MAX_FREQUENCY; i++)
    {        
        Frequency[i] = SvCreateGStream(0xffff0000, "Radio");
    }
}

public OnGameModeExit()
{

}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_YES ))
	{
        if(ToggleRadio[playerid] == 1)
        {
            SvDetachListenerFromStream(Frequency[FrequencyConnect[playerid]], playerid);
            new string[168];
	        format(string, sizeof(string), "{FFFF00}[RADIO]: {ffffff}%s disconnected to the frequency (%d Khz)", GetPName(playerid), FrequencyConnect[playerid]);
            SendClientMessage(playerid, 0xFF0000FF, string);
            ToggleRadio[playerid] = 0;
        }
        else if(ToggleRadio[playerid] == 0)
        {
            SvAttachListenerToStream(Frequency[FrequencyConnect[playerid]], playerid);
            new string[168];
	        format(string, sizeof(string), "{FFFF00}[RADIO]: {ffffff}%s connected to the frequency (%d Khz)", GetPName(playerid), FrequencyConnect[playerid]);
            SendClientMessage(playerid, 0xFF0000FF, string);
            ToggleRadio[playerid] = 1;
        }
    }
}
stock GetPName(playerid)
{
	new namep[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, namep, MAX_PLAYER_NAME+1);
	return namep;
}

CMD:rv(playerid, params[])
{
	new freq;
	if(sscanf(params, "d", freq)) 
        return SendClientMessage(playerid, -1,"USAGE: /rv [1 - 150]");
	if(freq > 150 || freq < 1) 
        return SendClientMessage(playerid, 0xFF0000FF, "Invalid Frequency!");
	
	new string[168];
    FrequencyConnect[playerid] = freq;
	format(string, 128, "{FFFF00}[RADIO]: {ffffff}set your freq to (%d Khz)", FrequencyConnect[playerid]);
	SendClientMessage(playerid, 0x00AE00FF, string);
    ToggleRadio[playerid] = 1;
	SvAttachListenerToStream(Frequency[FrequencyConnect[playerid]], playerid);
	return 1;
}
