/**
 * @version v1
 * @summary Console command registration: an FConsoleCommand bound to a script handler, invoked with three arguments, and read back through an output CVar. The command and output names come from the runner so each execution is.
 * @topic Language
 */
/**
 * @version root
 * @summary Console command registration: an FConsoleCommand bound to a script handler, invoked with three arguments, and read back through an output CVar. The command and output names come from the runner so each execution is.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Handles the registered console command.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the command arguments and the output CVar name
	 * @Return nothing; the output CVar receives the score
	 * @Param Args the command arguments
	 * @Param OutputName the output CVar name
	 */
	void OnCoverageCommand(const TArray<FString>&in Args, const FString&in OutputName)
	{
		FConsoleVariable Output(OutputName, 0, "Coverage command output");
		int Score = Args.Num();
		if (Args.Num() == 3 && Args[0] == "stat" && Args[1] == "fps" && Args[2] == "show")
		{
			Score += 10;
		}
		Output.SetInt(Score);
	}

	/**
	 * Reports that the command module is loaded.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int CommandReady()
	{
		return 1;
	}

	/**
	 * Observe that the module reports itself ready.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs CommandReady()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool ConsoleCommandReportsReady()
	{
		return CommandReady() == 1;
	}

	/**
	 * Observe that the registered command receives its three arguments.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the command name, output CVar name and the stat/fps/show arguments
	 * @Return true when the output CVar reads 13
	 * @Param CommandName the console command name
	 * @Param OutputName the output CVar name
	 */
	UFUNCTION()
	bool ConsoleCommandReceivesArguments(const FString&in CommandName, const FString&in OutputName)
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

	/**
	 * Observe that an empty argument list writes zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the handler called with no arguments
	 * @Return true when the output CVar reads 0
	 * @Boundary empty arguments
	 * @Param OutputName the output CVar name
	 */
	UFUNCTION()
	bool ConsoleCommandEmptyArgsBoundary(const FString&in OutputName)
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
}
/** @end */
