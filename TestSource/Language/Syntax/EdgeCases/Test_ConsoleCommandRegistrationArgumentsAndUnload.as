// Theme: Language.Syntax.EdgeCases. Positive FConsoleCommand registration.
// C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandRegistrationArgumentsAndUnload
// sha256=4404a6b43b4d54477ced5449b40873ac8aee71ec83e394bbe73cf9b4645c005b; lines 988-1006.
// $ARG0$/$ARG1$ become runner name parameters. Oracle: CommandReady==1;
// Args stat/fps/show writes Output 13. Extra: empty Args writes 0. DefaultSafe.

void OnCoverageCommand(const TArray<FString>& Args, const FString& OutputName)
{
	FConsoleVariable Output(OutputName, 0, "Coverage command output");
	int Score = Args.Num();
	if (Args.Num() == 3 && Args[0] == "stat" && Args[1] == "fps" && Args[2] == "show")
	{
		Score += 10;
	}
	Output.SetInt(Score);
}

int CommandReady()
{
	return 1;
}

bool Observe_ConsoleCommand_Ready()
{
	return CommandReady() == 1;
}

bool Observe_ConsoleCommand_Nominal(const FString& CommandName, const FString& OutputName)
{
	if (CommandName.Len() == 0 || OutputName.Len() == 0)
	{
		throw("TS-LANG-0084 setup: required command/output names are empty");
	}
	const FConsoleCommand Command(CommandName, n"OnCoverageCommand");
	TArray<FString> Args;
	Args.Add("stat");
	Args.Add("fps");
	Args.Add("show");
	OnCoverageCommand(Args, OutputName);
	FConsoleVariable Output(OutputName, 0, "Coverage command output");
	return Output.GetInt() == 13;
}

bool Observe_ConsoleCommand_EmptyArgsBoundary(const FString& OutputName)
{
	if (OutputName.Len() == 0)
	{
		throw("TS-LANG-0084 setup: required OutputName is empty");
	}
	TArray<FString> Args;
	OnCoverageCommand(Args, OutputName);
	FConsoleVariable Output(OutputName, 0, "Coverage command output");
	return Output.GetInt() == 0;
}
