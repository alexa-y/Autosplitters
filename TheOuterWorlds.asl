//The Outer Worlds Load Remover
//Originally created by Jabo
//Updated by MissyLexie & Micrologist
//Version 1.1.5 (2019-11-27)


state("IndianaEpicGameStore-Win64-Shipping", "v1.0 (EGS)")
{
	byte isLoading : 0x3FD3900, 0x38, 0x5D8, 0x2A0, 0x5A0, 0x450;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.1 (EGS)")
{
	byte isLoading : 0x3F0E710, 0x20, 0x10, 0x28, 0x10, 0x160;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.0 (MS)")
{
	byte isLoading : 0x42200F0, 0x38, 0x5D8, 0x5A0, 0x450;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.1 (MS)")
{
	byte isLoading : 0x03C372C0, 0x0, 0x8, 0x140, 0x8, 0x28, 0x28, 0x190;
}

exit
{
    timer.IsGameTimePaused = true;
}


isLoading
{
    return (current.isLoading == 1);
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
	} else {
		version = "v1.0 (MS)";
	}
}
