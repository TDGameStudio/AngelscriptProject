// Theme: Language.Syntax.EdgeCases. Positive FConsoleCommand string matrix.
// C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandCommonStringMatrixDispatch
// sha256=b1a6a8feecf67302bfd3e64115450637fe2d1cf5ab4cc94b274618591fbdcd67; lines 1049-1121.
// $ARG0$/$ARG1$ become runner name parameters. Oracle: CommandMatrixReady==1;
// stat fps=101, unit=102, game=103, gpu=104, memory=105, slow=106;
// show collision=201, bounds=202, bones=203, navmesh=204, paths=205;
// viewmode wireframe=301, unlit=302; r.SetRes 1920x1080w=401.
// Extra: empty Args leaves Score -1. DefaultSafe.

void OnCoverageCommandMatrix(const TArray<FString>& Args, const FString& OutputName)
{
	FConsoleVariable Output(OutputName, 0, "Coverage command matrix output");
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
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "collision")
	{
		Score = 201;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "bounds")
	{
		Score = 202;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "bones")
	{
		Score = 203;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "navmesh")
	{
		Score = 204;
	}
	else if (Args.Num() == 2 && Args[0] == "show" && Args[1] == "paths")
	{
		Score = 205;
	}
	else if (Args.Num() == 2 && Args[0] == "viewmode" && Args[1] == "wireframe")
	{
		Score = 301;
	}
	else if (Args.Num() == 2 && Args[0] == "viewmode" && Args[1] == "unlit")
	{
		Score = 302;
	}
	else if (Args.Num() == 2 && Args[0] == "r.SetRes" && Args[1] == "1920x1080w")
	{
		Score = 401;
	}

	Output.SetInt(Score);
}

int CommandMatrixReady()
{
	return 1;
}

int Observe_CommandMatrix_Dispatch(const FString& CommandName, const FString& OutputName, const FString& Arg0, const FString& Arg1)
{
	if (CommandName.Len() == 0 || OutputName.Len() == 0)
	{
		throw("TS-LANG-0085 setup: required command/output names are empty");
	}
	const FConsoleCommand Command(CommandName, n"OnCoverageCommandMatrix");
	TArray<FString> Args;
	Args.Add(Arg0);
	Args.Add(Arg1);
	OnCoverageCommandMatrix(Args, OutputName);
	FConsoleVariable Output(OutputName, 0, "Coverage command matrix output");
	return Output.GetInt();
}

bool Observe_CommandMatrix_Ready()
{
	return CommandMatrixReady() == 1;
}

bool Observe_CommandMatrix_NominalScores(const FString& CommandName, const FString& OutputName)
{
	return Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "fps") == 101
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "unit") == 102
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "game") == 103
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "gpu") == 104
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "memory") == 105
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "stat", "slow") == 106
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "show", "collision") == 201
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "show", "bounds") == 202
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "show", "bones") == 203
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "show", "navmesh") == 204
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "show", "paths") == 205
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "viewmode", "wireframe") == 301
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "viewmode", "unlit") == 302
		&& Observe_CommandMatrix_Dispatch(CommandName, OutputName, "r.SetRes", "1920x1080w") == 401;
}

bool Observe_CommandMatrix_EmptyArgsBoundary(const FString& OutputName)
{
	if (OutputName.Len() == 0)
	{
		throw("TS-LANG-0085 setup: required OutputName is empty");
	}
	TArray<FString> Args;
	OnCoverageCommandMatrix(Args, OutputName);
	FConsoleVariable Output(OutputName, 0, "Coverage command matrix output");
	return Output.GetInt() == -1;
}
