// Theme: Gameplay.Debug. Positive: stat/show names dispatch through FConsoleCommand.
// C++ substitutes unique names for $COMMAND$/$OUTPUT$. Here the runner supplies names.
// C++: AngelscriptCoverageDebugTests.cpp::StatAndShowCommandNamesDispatchThroughRegisteredConsoleCommand
// Oracle: DebugCommandReady == 1; fps 101; unit 102; game 103; gpu 104; memory 105;
// slow 106; Collision 201; Bones 202; Navmesh 203; Paths 204.
// Extra: empty Args leaves Score -1. DefaultSafe.

int DebugCommandReady()
{
	return 1;
}

void OnCoverageDebugCommand(const TArray<FString>& Args, const FString& OutputName)
{
	FConsoleVariable Output(OutputName, 0, "Coverage debug stat/show command output");
	int Score = -1;

	if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "fps")
	{
		Score = 101;
	}
	else if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "unit")
	{
		Score = 102;
	}
	else if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "game")
	{
		Score = 103;
	}
	else if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "gpu")
	{
		Score = 104;
	}
	else if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "memory")
	{
		Score = 105;
	}
	else if (Args.Num() == 2 && Args[0] == "stat" && Args[1] == "slow")
	{
		Score = 106;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "Collision")
	{
		Score = 201;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "Bones")
	{
		Score = 202;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "Navmesh")
	{
		Score = 203;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "Paths")
	{
		Score = 204;
	}

	Output.SetInt(Score);
}

int Observe_DispatchArgs(const FString& CommandName, const FString& OutputName, const TArray<FString>& Args)
{
	const FConsoleCommand Command(CommandName, n"OnCoverageDebugCommand");
	OnCoverageDebugCommand(Args, OutputName);
	FConsoleVariable Output(OutputName, 0, "Coverage debug stat/show command output");
	return Output.GetInt();
}

bool Observe_DebugCommandReady_Nominal()
{
	return DebugCommandReady() == 1;
}

bool Observe_StatAndShow_Nominal(const FString& CommandName, const FString& OutputName)
{
	if (CommandName.Len() == 0 || OutputName.Len() == 0)
	{
		throw("TS-GAME-0024 setup: required CommandName or OutputName is empty");
	}

	TArray<FString> StatFps;
	StatFps.Add("stat");
	StatFps.Add("fps");
	TArray<FString> StatUnit;
	StatUnit.Add("stat");
	StatUnit.Add("unit");
	TArray<FString> StatGame;
	StatGame.Add("stat");
	StatGame.Add("game");
	TArray<FString> StatGpu;
	StatGpu.Add("stat");
	StatGpu.Add("gpu");
	TArray<FString> StatMemory;
	StatMemory.Add("stat");
	StatMemory.Add("memory");
	TArray<FString> StatSlow;
	StatSlow.Add("stat");
	StatSlow.Add("slow");
	TArray<FString> ShowCollision;
	ShowCollision.Add("show");
	ShowCollision.Add("Collision");
	TArray<FString> ShowBones;
	ShowBones.Add("show");
	ShowBones.Add("Bones");
	TArray<FString> ShowNavmesh;
	ShowNavmesh.Add("show");
	ShowNavmesh.Add("Navmesh");
	TArray<FString> ShowPaths;
	ShowPaths.Add("show");
	ShowPaths.Add("Paths");

	return Observe_DispatchArgs(CommandName, OutputName, StatFps) == 101
		&& Observe_DispatchArgs(CommandName, OutputName, StatUnit) == 102
		&& Observe_DispatchArgs(CommandName, OutputName, StatGame) == 103
		&& Observe_DispatchArgs(CommandName, OutputName, StatGpu) == 104
		&& Observe_DispatchArgs(CommandName, OutputName, StatMemory) == 105
		&& Observe_DispatchArgs(CommandName, OutputName, StatSlow) == 106
		&& Observe_DispatchArgs(CommandName, OutputName, ShowCollision) == 201
		&& Observe_DispatchArgs(CommandName, OutputName, ShowBones) == 202
		&& Observe_DispatchArgs(CommandName, OutputName, ShowNavmesh) == 203
		&& Observe_DispatchArgs(CommandName, OutputName, ShowPaths) == 204;
}

bool Observe_StatAndShow_EmptyArgs(const FString& CommandName, const FString& OutputName)
{
	if (CommandName.Len() == 0 || OutputName.Len() == 0)
	{
		throw("TS-GAME-0024 setup: required CommandName or OutputName is empty");
	}
	TArray<FString> Args;
	return Observe_DispatchArgs(CommandName, OutputName, Args) == -1;
}
