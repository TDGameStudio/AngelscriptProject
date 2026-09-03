/**
 * A console command dispatching over a matrix of common command strings. Each
 * known pair of arguments maps to its own score, and anything unrecognised
 * leaves the sentinel in place. The command and output CVar names come from the
 * runner so each execution gets unique names.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ConsoleCommandCommonStringMatrixDispatch
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ConsoleCommandCommonStringMatrixDispatch
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandCommonStringMatrixDispatch
 * @Provenance sha256=b1a6a8feecf67302bfd3e64115450637fe2d1cf5ab4cc94b274618591fbdcd67; lines 1049-1121.
 * @Provenance $ARG0$/$ARG1$ become runner name parameters. Oracle: CommandMatrixReady==1;
 * @Provenance stat fps=101, unit=102, game=103, gpu=104, memory=105, slow=106;
 * @Provenance show collision=201, bounds=202, bones=203, navmesh=204, paths=205;
 * @Provenance viewmode wireframe=301, unlit=302; r.SetRes 1920x1080w=401.
 * @Provenance Extra: empty Args leaves Score -1. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Scores a two-argument console command and writes it to an output CVar.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the command arguments and the output CVar name
	 * @Return nothing; the output CVar receives the score
	 * @Param Args the command arguments
	 * @Param OutputName the output CVar name
	 */
	void OnCoverageCommandMatrix(const TArray<FString>&in Args, const FString&in OutputName)
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

	/**
	 * Reports that the command matrix module is loaded.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int CommandMatrixReady()
	{
		return 1;
	}

	/**
	 * Dispatches one command pair and reads back the score.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the command name, output CVar name and two arguments
	 * @Return the score the handler wrote
	 * @Param CommandName the console command name
	 * @Param OutputName the output CVar name
	 * @Param Arg0 the first command argument
	 * @Param Arg1 the second command argument
	 */
	int DispatchCommandPair(const FString&in CommandName, const FString&in OutputName, const FString&in Arg0, const FString&in Arg1)
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

	/**
	 * Observe that the module reports itself ready.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs CommandMatrixReady()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool CommandMatrixReportsReady()
	{
		return CommandMatrixReady() == 1;
	}

	/**
	 * Observe that every command pair dispatches to its own score.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the command name, output CVar name and all fourteen argument pairs
	 * @Return true when all fourteen scores match
	 * @Param CommandName the console command name
	 * @Param OutputName the output CVar name
	 */
	UFUNCTION()
	bool CommandMatrixDispatchesAllScores(const FString&in CommandName, const FString&in OutputName)
	{
		if (DispatchCommandPair(CommandName, OutputName, "stat", "fps") != 101)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "stat", "unit") != 102)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "stat", "game") != 103)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "stat", "gpu") != 104)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "stat", "memory") != 105)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "stat", "slow") != 106)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "show", "collision") != 201)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "show", "bounds") != 202)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "show", "bones") != 203)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "show", "navmesh") != 204)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "show", "paths") != 205)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "viewmode", "wireframe") != 301)
		{
			return false;
		}

		if (DispatchCommandPair(CommandName, OutputName, "viewmode", "unlit") != 302)
		{
			return false;
		}

		return DispatchCommandPair(CommandName, OutputName, "r.SetRes", "1920x1080w") == 401;
	}

	/**
	 * Observe that an empty argument list leaves the sentinel in place.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the handler called with no arguments
	 * @Return true when the score is -1
	 * @Boundary empty arguments
	 * @Param OutputName the output CVar name
	 */
	UFUNCTION()
	bool CommandMatrixEmptyArgsBoundary(const FString&in OutputName)
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
}
