//The Outer Worlds Load Remover
//Created by MissyLexie & Micrologist
//Version 1.1.7 (2020-01-04)


state("IndianaEpicGameStore-Win64-Shipping", "v1.0 (EGS)")
{
  byte isLoading : 0x03D98228, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.1 (EGS)")
{
  byte isLoading : 0x03D9F3A8, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaEpicGameStore-Win64-Shipping", "v1.2 (EGS)")
{
  byte isLoading : 0x03DC2648, 0x1E8, 0x20, 0x210, 0x4D0;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.0 (MS)")
{
  byte isLoading : 0x42200F0, 0x38, 0x5D8, 0x5A0, 0x450;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.1 (MS)")
{
  byte isLoading : 0x03C372C0, 0x0, 0x8, 0x140, 0x8, 0x28, 0x28, 0x190;
}

state("IndianaWindowsStore-Win64-Shipping", "v1.2 (MS)")
{
    byte isLoading : 0x0400DD68, 0x1E8, 0x20, 0x210, 0x4D0;
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
  } else if (moduleSize == 71880704)
  {
    version = "v1.2 (EGS)";
  } else if (moduleSize == 74272768)
  {
    version = "v1.2 (MS)";
  } else if (moduleSize == 74125312)
  {
    version = "v1.1 (MS)";
  } else {
    version = "v1.0 (MS)";
  }
}
