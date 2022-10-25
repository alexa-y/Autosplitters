state("IndianaEpicGameStore-Win64-Shipping"){}
state("IndianaWindowsStore-Win64-Shipping"){}
state("Indiana-Win64-Shipping"){}

startup
{
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {        
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | The Outer Worlds",
            MessageBoxButtons.YesNo,MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes)
        {
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    vars.SetTextComponent = (Action<string, string>)((id, text) =>
	{
        var textSettings = timer.Layout.Components.Where(x => x.GetType().Name == "TextComponent").Select(x => x.GetType().GetProperty("Settings").GetValue(x, null));
        var textSetting = textSettings.FirstOrDefault(x => (x.GetType().GetProperty("Text1").GetValue(x, null) as string) == id);
        if (textSetting == null)
        {
            var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
            var textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
            timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
            textSetting = textComponent.GetType().GetProperty("Settings", BindingFlags.Instance | BindingFlags.Public).GetValue(textComponent, null);
            textSetting.GetType().GetProperty("Text1").SetValue(textSetting, id);
        }
        if (textSetting != null)
            textSetting.GetType().GetProperty("Text2").SetValue(textSetting, text);
	});

    //All of these state keys need to have a matching entry in the settings dict, otherwise we will look up non-existant keys there later
    vars.trackedStates = new List<String>() {
        "00_ADAGavePlayerSmugglerID",
        "PQ0002_ToldAboutUltimatumByReed",
        "0004_sfx_botanical_power_on",
        "0004_sfx_edgewater_power_on",
        "PQ0001_AcquiredPowerRegulator",
        "PQ0001_ReturnedAfterInstalling",
        "TA_0101_UdomChat",
        "02_PresentationChairmanFinished",
        "PQ0201_RetrievedChemicals",
        "PQ0201_ReturnedToScientist",
        "Ellie_Topics_BoardPath_Bug",
        "PQ0206_PodDoorState",
        "MaxDead",
        "PQ0206_KilledAllAutomechanicals",
        "PQ0206_ReturnedToSophia",
        "0903_Playerisonthebridge",
        "0903_SecretPanel",
    };

#region Settings
    settings.Add("splitEnding", true, "Ending Splits");
    settings.Add("dumbEnding", true, "Dumb Ending", "splitEnding");
    settings.Add("trueEnding", true, "True Ending", "splitEnding");
    settings.Add("dlc1Ending", true, "DLC1 Ending", "splitEnding");

    settings.Add("any_percent", false, "Any% Splits");
    settings.Add("00_ADAGavePlayerSmugglerID", false, "Obtained ID from ADA (Ship)", "any_percent");
    settings.Add("PQ0002_ToldAboutUltimatumByReed", false, "Met Reed (Edgewater 1)", "any_percent");
    settings.Add("0004_sfx_botanical_power_on", false, "Sent power to Deserters (Geothermal 1)", "any_percent");
    settings.Add("0004_sfx_edgewater_power_on", false, "Sent power to Edgewater (Geothermal 1)", "any_percent");
    settings.Add("PQ0001_AcquiredPowerRegulator", false, "Obtained power regulator (Edgewater 2)", "any_percent");
    settings.Add("PQ0001_ReturnedAfterInstalling", false, "Left Emerald Vale (Orbit)", "any_percent");
    settings.Add("TA_0101_UdomChat", false, "Left Groundbreaker (Groundbreaker)", "any_percent");
    settings.Add("02_PresentationChairmanFinished", false, "Watched chairman presentation (HHC Building 1)", "any_percent");
    settings.Add("PQ0201_RetrievedChemicals", false, "Stole chemicals (Ministry)", "any_percent");
    settings.Add("PQ0201_ReturnedToScientist", false, "Brought chemicals to Phineas (Phineas Lab 1, Sun/Phineas)", "any_percent");
    settings.Add("Ellie_Topics_BoardPath_Bug", false, "Tracked Phineas' terminal (Phineas Lab 1, Board)", "any_percent");
    settings.Add("PQ0206_PodDoorState", false, "Talked to Sophia about Edgewater (HHC Building 2)", "any_percent");
    settings.Add("MaxDead", false, "Ran Edgewater Termination Protocol (Geothermal 2)", "any_percent");
    settings.Add("PQ0206_KilledAllAutomechanicals", false, "Killed Robots in Edgewater (Edgewater 3)", "any_percent");
    settings.Add("PQ0206_ReturnedToSophia", false, "Talked to Sophia about the Hope (HHC Building 3)", "any_percent");
    settings.Add("0903_Playerisonthebridge", false, "Skipped the Hope (Hope)", "any_percent");
    settings.Add("0903_SecretPanel", false, "Opened the secret panel in Phineas' Lab (Phineas Lab 2)", "any_percent");

    settings.Add("debugTextComponents", false, "[DEBUG] Show tracked values in layout");
    settings.Add("debugProgressionStates", false, "[DEBUG] Show progression states in layout");
#endregion
    vars.doneSplits = new List<string>();
}

init
{
#region Base Pointer Scanning
    vars.GetStaticPointerFromSig = (Func<string, int, IntPtr>) ( (signature, instructionOffset) => {
        var scanner = new SignatureScanner(game, modules.First().BaseAddress, (int)modules.First().ModuleMemorySize);
        var pattern = new SigScanTarget(signature);
        var location = scanner.Scan(pattern);
        if (location == IntPtr.Zero) return IntPtr.Zero;
        int offset = game.ReadValue<int>((IntPtr)location + instructionOffset);
        return (IntPtr)location + offset + instructionOffset + 0x4;
    });

    vars.GameVersionPtr = vars.GetStaticPointerFromSig("4C 0F 45 0D ?? ?? ?? ?? 48 8D 15 ?? ?? ?? ?? 48 8D 4C 24 ?? 89 44 24", 0x4);
    vars.UWorld = vars.GetStaticPointerFromSig("0F 2E ?? 74 ?? 48 8B 1D ?? ?? ?? ?? 48 85 DB 74", 0x8);
    vars.GameInstance = vars.GetStaticPointerFromSig("48 8B 0D ?? ?? ?? ?? 48 8B 89 ?? ?? ?? ?? E8 ?? ?? ?? ?? F0 FF 4B ?? 48 8B 4B ?? 48 85 C9", 0x3);
    vars.CutsceneBase = vars.GetStaticPointerFromSig("0F 10 05 ?? ?? ?? ?? 0F 11 45 F0 66 0F 73 D8 08 66 48 0F 7E C0 48 85 C0", 0x3);
    vars.QuestStateBase = vars.GetStaticPointerFromSig("48 83 C7 30 83 EE 01 75 ?? 48 8B 3D ?? ?? ?? ??", 0xC);

    if(vars.GameVersionPtr == IntPtr.Zero || vars.UWorld == IntPtr.Zero || vars.GameInstance == IntPtr.Zero || vars.CutsceneBase == IntPtr.Zero || vars.QuestStateBase == IntPtr.Zero)
    {
        throw new Exception("One ore more Base Classes not found - trying again");
    }
#endregion
    
#region Version Detection
    vars.gameVersion = new DeepPointer((IntPtr)vars.GameVersionPtr, 0x0).DerefString(game, 64);

    if(String.IsNullOrEmpty(vars.gameVersion) || vars.gameVersion == "1.0.0")
    {
        throw new Exception("Version detection failed - trying again");
    }

    string storeFront = Path.GetFileNameWithoutExtension(game.MainModule.FileName).Replace("Indiana","").Replace("-Win64-Shipping","");
    version = vars.gameVersion + " (" + (!String.IsNullOrEmpty(storeFront) ? storeFront : "Steam") + ")";
#endregion

#region Memory Watcher Setup
    vars.watchers = new MemoryWatcherList
    {
        new MemoryWatcher<IntPtr>(new DeepPointer(vars.CutsceneBase, 0x8, 0xA8, 0xA8, 0x0, 0xA8)) { Name = "cutscenePathPtr" },
        new StringWatcher(new DeepPointer(vars.UWorld, 0x5D8, 0x0), 255) { Name = "mapPath"},
        new MemoryWatcher<IntPtr>(new DeepPointer(vars.QuestStateBase, 0x20, 0x0, 0x8, 0x18, 0x8, 0x0)) { Name = "statePtr" },
    };
    
    MemoryWatcher loadingWatcher;
    if(vars.gameVersion.StartsWith("1.0") || vars.gameVersion.StartsWith("1.1") || vars.gameVersion.StartsWith("1.3"))
    {
        loadingWatcher = new MemoryWatcher<bool>(new DeepPointer(vars.GameInstance, 0x210, 0x4D0)) { Name = "isLoading" };
    }
    else if(vars.gameVersion.StartsWith("1.4"))
    {
        loadingWatcher = new MemoryWatcher<bool>(new DeepPointer(vars.GameInstance, 0x220, 0x4E0)) { Name = "isLoading" };
    }
    else
    {
        loadingWatcher = new MemoryWatcher<bool>(new DeepPointer(vars.GameInstance, 0x220, 0x4F0)) { Name = "isLoading" };
    }
    vars.watchers.Add(loadingWatcher);
    vars.watchers.UpdateAll(game);
#endregion

#region Quest State Initialization
    if(String.IsNullOrEmpty(vars.watchers["mapPath"].Current) || vars.watchers["isLoading"].Current)
    { 
        throw new Exception("Quest states not initialized - trying again");
    }

    //Dont override the list of done splits if the timer is running and we rehook (e.g. after game crash)
    if(timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.doneSplits = new List<string>();
    }

    vars.stateOffsets = new Dictionary<string, int>();
    vars.currentStates = new Dictionary<string, int>();
    //Old States is currently completely unused, might consider removing it
    vars.oldStates = new Dictionary<string, int>();
    vars.dlc1Found = false;
    vars.dlc2Found = false;

    IntPtr currentStatePtr = vars.watchers["statePtr"].Current;
    for (int i = 0; i < 4000; i++)
    {
        string key = new DeepPointer(currentStatePtr + (i * 0x20), 0).DerefString(game, 255);

        //Sometimes certain state entries get deleted when they aren't useful anymore (e.g. clearing the path at the beginning of the game)
        //This will leave a nullptr gap in the array, hence we have to continue here rather than break
        if (String.IsNullOrEmpty(key))
        {
            continue;
        }

        if(key == "0701_CaptiveFreed")
        {
            vars.trueEndingOffset = (i * 0x20) + 0x10;
        }

        if(key == "XFH_n_StoryLoadingScreen_State")
        {
            vars.dlc1EndingOffset = (i * 0x20) + 0x10;
            vars.dlc1Found = true;
        }
        
        if(!vars.trackedStates.Contains(key) || vars.stateOffsets.ContainsKey(key))
            continue;
        
        int value = game.ReadValue<int>(currentStatePtr + (i * 0x20) + 0x10);
        vars.stateOffsets.Add(key, (i * 0x20) + 0x10);
        vars.currentStates.Add(key, value);
        vars.oldStates.Add(key, value);

        //If the timer is running, we disregard all states that were set completed during init
        if(timer.CurrentPhase == TimerPhase.Running && settings[key] && value > 0)
        {
            vars.doneSplits.Add(key);
            print(key + " was completed when running init - considering it done.");
        }
    }

    if(timer.CurrentPhase == TimerPhase.Running && vars.dlc1Found && (game.ReadValue<int>((IntPtr)(currentStatePtr + vars.dlc1EndingOffset)) > 0))
    {
        vars.doneSplits.Add("dlc1Ending");
        print("DLC1 Ending was completed when running init - considering it done.");
    }
#endregion

    current.map = "None";
    current.loading = true;
    current.cutscene = "None";
    current.dlc1Completed = true;
    vars.startAfterNextLoad = false;
    vars.splitOnNextLoad = false;
}

update
{
    vars.watchers.UpdateAll(game);
    current.loading = vars.watchers["isLoading"].Current;
    current.cutscene = vars.watchers["cutscenePathPtr"].Current == IntPtr.Zero ? "None" : Path.GetFileNameWithoutExtension(game.ReadString((IntPtr)(vars.watchers["cutscenePathPtr"].Current), 1024));
    var map = Path.GetFileNameWithoutExtension(vars.watchers["mapPath"].Current);
    current.map = !String.IsNullOrEmpty(map) ? map : current.map;

    IntPtr currentStatePtr = vars.watchers["statePtr"].Current;
    current.trueEndingCompleted = (game.ReadValue<int>((IntPtr)(currentStatePtr + vars.trueEndingOffset)) >= 2);
    current.dlc1Completed = (vars.dlc1Found ? (game.ReadValue<int>((IntPtr)(currentStatePtr + vars.dlc1EndingOffset)) > 0) : false);

    foreach (var kvp in vars.stateOffsets)
    {
        int newValue = game.ReadValue<int>((IntPtr)(currentStatePtr + vars.stateOffsets[kvp.Key]));
        vars.oldStates[kvp.Key] = vars.currentStates[kvp.Key];
        vars.currentStates[kvp.Key] = newValue;
    }

#region Debug Output
    if(settings["debugTextComponents"])
    {
        vars.SetTextComponent("map", current.map);
        vars.SetTextComponent("isLoading", current.loading.ToString());
        vars.SetTextComponent("Cutscene", current.cutscene);
        vars.SetTextComponent("Start after load", vars.startAfterNextLoad.ToString());
        vars.SetTextComponent("Split on load", vars.splitOnNextLoad.ToString());
        vars.SetTextComponent("Splits done", vars.doneSplits.Count.ToString());
        vars.SetTextComponent("True Ending Completed", current.trueEndingCompleted.ToString());
        vars.SetTextComponent("DLC1 Completed", current.dlc1Completed.ToString());
        vars.SetTextComponent("Game Version", vars.gameVersion);
    }

    if(settings["debugProgressionStates"])
    {
        foreach (var kvp in vars.currentStates)
        {
            vars.SetTextComponent(kvp.Key, kvp.Value.ToString());
        }
    }
#endregion
}

start
{
    if(current.cutscene == "Intro_PhinMonologue_compressed")
    {
        vars.startAfterNextLoad = true;
    }

    if (!current.loading && old.loading & vars.startAfterNextLoad == true)
    {
        vars.startAfterNextLoad = false;
        return true;
    }
}

onStart
{
    vars.watchers.UpdateAll(game);
    vars.startAfterNextLoad = false;
    vars.splitOnNextLoad = false;
    vars.doneSplits = new List<String>();
    IntPtr currentStatePtr = vars.watchers["statePtr"].Current;

    //Any states that are completed at the time of starting the timer will be disregarded for splitting
    foreach (var kvp in vars.stateOffsets)
    {
        int value = game.ReadValue<int>((IntPtr)(currentStatePtr + vars.stateOffsets[kvp.Key]));
        if(value > 0 && settings[kvp.Key])
        {
            vars.doneSplits.Add(kvp.Key);
            print(kvp.Key + " was completed when starting the timer - considering it done.");
        }
    }
    if(current.dlc1Completed)
    {
        vars.doneSplits.Add("dlc1Ending");
        print("DLC1 Ending was completed when starting the timer - considering it done.");
    }
}

split
{
    if (settings["dumbEnding"] && current.cutscene == "Hope_SkipSun" && old.cutscene != "Hope_SkipSun")
    {
        return true;
    }

    if (settings["trueEnding"] && current.trueEndingCompleted && current.loading && !old.loading)
    {
        return true;
    }

    if (settings["dlc1Ending"] && current.dlc1Completed && !old.dlc1Completed && !vars.doneSplits.Contains("dlc1Ending"))
    {
        vars.doneSplits.Add("dlc1Ending");
        return true;
    }

    foreach (var kvp in vars.currentStates)
    {
        if(settings[kvp.Key] && !vars.doneSplits.Contains(kvp.Key) && kvp.Value > 0)
        {
            vars.splitOnNextLoad = true;
            vars.doneSplits.Add(kvp.Key);
        }
    }

    if(current.loading && !old.loading && vars.splitOnNextLoad)
    {
        vars.splitOnNextLoad = false;
        return true;
    }
}

reset
{
    return current.map == "CharacterCreation";
}

isLoading
{
    return current.loading;
}

exit
{
    timer.IsGameTimePaused = true;
}
