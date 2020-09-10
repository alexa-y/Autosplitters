//The Outer Worlds Load Remover
//Created by MissyLexie & Micrologist
//2020-09-11.1

state("IndianaEpicGameStore-Win64-Shipping", "v1.0 (EGS)")
{
    bool isLoading : 0x03D98228, 0x1E8, 0x20, 0x210, 0x4D0;
    byte cutsceneId : 0x03FD8AC8, 0x0, 0x10, 0x48, 0x30, 0x120, 0xC8;
    byte tartarusFinalCellOpened : 0x03D9C7F8, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0xE8B0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.1 (EGS)")
{
    bool isLoading : 0x03D9F3A8, 0x1E8, 0x20, 0x210, 0x4D0;
    byte cutsceneId : 0x03D9ABC8, 0x8, 0xA8, 0xA8, 0x0, 0xB0;
    byte tartarusFinalCellOpened : 0x03DA3978, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0xE8B0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.4 (EGS)")
{
    bool isLoading : 0x03E6A900, 0x1E8, 0x20, 0x220, 0x4E0;
    byte cutsceneId : 0x03E659E8, 0x8, 0xA8, 0xA8, 0x0, 0xB0;
    byte tartarusFinalCellOpened : 0x03E70180, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0, 0xE8B0;
    string250 map : 0x040D1520, 0x5D8, 0x0;
}

startup
{
    settings.Add("splitEnding", true, "Ending Splits");
    settings.Add("dumbEnding", true, "Dumb Ending", "splitEnding");
    settings.Add("trueEnding", true, "True Ending", "splitEnding");

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

    vars.startAfterNextLoad = false;
    vars.cutsceneOffset = -9999;
    vars.lastCutsceneId = -1;
    vars.thisCutsceneId = -1;
}

update
{
    // Disable the autosplitter if the version is incorrect
    if (version.Contains("Unsupported"))
        return false;

    //There HAS to be a better way to do this
    if (current.cutsceneId != old.cutsceneId && current.cutsceneId != 0)
    {
        vars.lastCutsceneId = vars.thisCutsceneId;
        vars.thisCutsceneId = current.cutsceneId;
        if (vars.thisCutsceneId - vars.lastCutsceneId == 1)
        {
            vars.cutsceneOffset = vars.thisCutsceneId - 97;
        }
    }
}

start
{
    if (current.cutsceneId == 89 + vars.cutsceneOffset)
    {
        vars.startAfterNextLoad = true;
    }
    if (!current.isLoading && old.isLoading & vars.startAfterNextLoad == true)
    {
        vars.startAfterNextLoad = false;
        return true;
    }
}

split
{
    if (settings["dumbEnding"] && current.cutsceneId == 71 + vars.cutsceneOffset & old.cutsceneId == 0)
    {
        return true;
    }
    if (settings["trueEnding"] && current.tartarusFinalCellOpened == 2 && current.isLoading)
    {
        return true;
    }
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
