//The Outer Worlds Load Remover
//Created by MissyLexie & Micrologist
//2020-09-10.2

state("IndianaEpicGameStore-Win64-Shipping", "v1.0 (EGS)")
{
    bool isLoading : 0x03D98228, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.1 (EGS)")
{
    bool isLoading : 0x03D9F3A8, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.2 (EGS)")
{
    bool isLoading : 0x03DC2648, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.2 (MS)")
{
    bool isLoading : 0x0400DD68, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.4 (EGS)")
{
    bool isLoading : 0x03E6A900, 0x1E8, 0x20, 0x220, 0x4E0;
    string250 map : 0x040D1520, 0x5D8, 0x0;
}

startup
{
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show(
            "This game uses Time without Loads (Game Time) as the main timing method.\n"
            + "LiveSplit is currently set to show Real Time (RTA).\n"
            + "Would you like to set the timing method to Game Time?",
            "The Outer Worlds | LiveSplit",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }
    vars.startNextEV = false;
}

init
{
    int moduleSize = modules.First().ModuleMemorySize;
    switch (moduleSize)
    {
        case 71692288:
            version = "v1.0 (EGS)";
            break;
        case 71729152:
            version = "v1.1 (EGS)";
            break;
        case 71880704:
            version = "v1.2 (EGS)";
            break;
        case 74272768:
            version = "v1.2 (MS)";
            break;
        case 72634368:
            version = "v1.4 (EGS)";
            break;
        default:
            version = "Unsupported - " + moduleSize.ToString();
            // Display popup if version is incorrect
            MessageBox.Show("This game version is currently not supported.", "LiveSplit Auto Splitter - Unsupported Game Version");
            break;
    }
}

update
{
    // Disable the autosplitter if the version is incorrect
    if (version.Contains("Unsupported"))
        return false;
}

start
{
    if (!vars.startNextEV && current.map == "/Game/Maps/CharacterCreation")
        vars.startNextEV = true;

    if (vars.startNextEV && !current.isLoading && current.map == "/Game/Maps/00_EmeraldVale/0001_EmeraldVale/0001_EmeraldVale_P")
    {
        vars.startNextEV = false;
        return true;
    }
    if (current.map == "/Game/Maps/Main")
        vars.startNextEV = false;
}

reset
{
    return current.map == "/Game/Maps/CharacterCreation";
}

isLoading
{
    return current.isLoading;
}

exit
{
    timer.IsGameTimePaused = true;
}
