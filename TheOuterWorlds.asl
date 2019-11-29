//The Outer Worlds Load Remover
//Originally created by Jabo
//Updated by MissyLexie & Micrologist
//Version 1.1.5 (2019-11-27)

state("IndianaEpicGameStore-Win64-Shipping", "v1.0 (EGS)")
{
	byte isLoading : 0x3FD3900, 0x38, 0x5D8, 0x2A0, 0x5A0, 0x450;
	byte TellAdaHawthorneDead : 0x03D9C7F8, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0x3110;
	byte MeetReed : 0x03D9C7F8, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0x7390;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.1 (EGS)")
{
	byte isLoading : 0x3F0E710, 0x20, 0x10, 0x28, 0x10, 0x160;
	byte TellAdaHawthorneDead : 0x03DA3978, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0x3110;
	byte MeetReed : 0x03DA3978, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0x7390;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.0 (MS)")
{
	byte isLoading : 0x42200F0, 0x38, 0x5D8, 0x5A0, 0x450;
	byte TellAdaHawthorneDead : 0x0;
	byte MeetReed : 0x0;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.1 (MS)")
{
	byte isLoading : 0x03C372C0, 0x0, 0x8, 0x140, 0x8, 0x28, 0x28, 0x190;
	byte TellAdaHawthorneDead : 0x0;
	byte MeetReed : 0x0;
}

startup
{
	vars.splitsUsed = new Dictionary<string, int>(); // 0 for quest stage not yet fulfilled, 1 for fulfilled but not yet splitted, 2 for splitted

	Action<string, bool, string, string> AddSplit = (key, enabled, name, group) => {
		settings.Add(key, enabled, name, group);
		vars.splitsUsed.Add(key, 0);
	};

	settings.Add("any_percent", true, "Any%");
	AddSplit("TellAdaHawthorneDead", true, "Tell ADA that Hawthorne is dead", "any_percent");
	AddSplit("MeetReed", true, "Meet with Reed", "any_percent");
}

exit
{
    timer.IsGameTimePaused = true;
}

isLoading
{
	return current.isLoading == 1;
}

split
{
	IDictionary<string, Object> currenctDict = (IDictionary<string, Object>) current;
	IDictionary<string, Object> oldDict = (IDictionary<string, Object>) old;
	foreach (string key in vars.splitsUsed.Keys)
	{
		int value = vars.splitsUsed[key];
		if (value == 0 && Convert.ToInt32(currenctDict[key]) == 1 && Convert.ToInt32(oldDict[key]) == 0)
		{
			vars.splitsUsed[key] = 1;
			return false;
		}
		if (settings[key] && value == 1 && current.isLoading == 1)
		{
			vars.splitsUsed[key] = 2;
			return true;
		}
	}
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	if (moduleSize == 71692288)
	{
		version = "v1.0 (EGS)";
	} else if (moduleSize == 71729152)
	{
		version = "v1.1 (EGS)";
	} else if (moduleSize == 74125312)
	{
		version = "v1.1 (MS)";
	} else
	{
		version = "v1.0 (MS)";
	}
}
