/**
 * @version v1
 * @summary The stat and show command names dispatch through a registered console command, which reports each recognised name as its own score through a console variable. C++ supplies the command and output names so the runner can.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The stat and show command names dispatch through a registered console command, which reports each recognised name as its own score through a console variable. C++ supplies the command and output names so the runner can.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * The entrypoint C++ executes to confirm the fixture is ready.
	 *
	 * @Kind Observe
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs none
	 * @Return 1 once the console command fixture is ready
	 */
	UFUNCTION()
	int DebugCommandReady()
	{
		return 1;
	}

	/**
	 * Map each recognised stat or show name onto its own score, leaving the score at -1
	 * for anything unrecognised.
	 *
	 * @Kind Action
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs the command arguments and the output variable name
	 * @Return the score written into the output console variable
	 * @Param Args the command arguments, expected to hold a verb and a target
	 * @Param OutputName the console variable to write the score into
	 * @Boundary unrecognised arguments
	 */
	UFUNCTION()
	void OnCoverageDebugCommand(const TArray<FString>&in Args, const FString&in OutputName)
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

	/**
	 * Register the console command, dispatch one argument list through it, and read the
	 * score back.
	 *
	 * @Kind Observe
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs the command name, the output variable name and the arguments to dispatch
	 * @Return the score the handler wrote
	 * @Param CommandName the console command to register
	 * @Param OutputName the console variable to read back
	 * @Param Args the arguments to dispatch
	 */
	UFUNCTION()
	int ObserveDispatchArgs(const FString&in CommandName, const FString&in OutputName, const TArray<FString>&in Args)
	{
		const FConsoleCommand Command(CommandName, n"OnCoverageDebugCommand");
		OnCoverageDebugCommand(Args, OutputName);
		FConsoleVariable Output(OutputName, 0, "Coverage debug stat/show command output");
		return Output.GetInt();
	}

	/**
	 * Observe that the fixture reports itself ready.
	 *
	 * @Kind Observe
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs none
	 * @Return true when the entrypoint returned 1
	 */
	UFUNCTION()
	bool DebugCommandReadyNominal()
	{
		return DebugCommandReady() == 1;
	}

	/**
	 * Observe that every stat and show name maps onto its own score.
	 *
	 * @Kind Observe
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs the command and output names supplied by the runner
	 * @Return true when all ten names reported their expected score
	 * @Param CommandName the console command to register
	 * @Param OutputName the console variable to read back
	 */
	UFUNCTION()
	bool StatAndShowNominal(const FString&in CommandName, const FString&in OutputName)
	{
		if (CommandName.Len() == 0 || OutputName.Len() == 0)
		{
			throw("StatAndShowCommandNames setup: required CommandName or OutputName is empty");
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

		if (ObserveDispatchArgs(CommandName, OutputName, StatFps) != 101)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, StatUnit) != 102)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, StatGame) != 103)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, StatGpu) != 104)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, StatMemory) != 105)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, StatSlow) != 106)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, ShowCollision) != 201)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, ShowBones) != 202)
		{
			return false;
		}
		if (ObserveDispatchArgs(CommandName, OutputName, ShowNavmesh) != 203)
		{
			return false;
		}
		return ObserveDispatchArgs(CommandName, OutputName, ShowPaths) == 204;
	}

	/**
	 * Observe that an empty argument list leaves the score at its sentinel.
	 *
	 * @Kind Observe
	 * @Covers Debug.StatAndShowCommandNames
	 * @Inputs the command and output names supplied by the runner
	 * @Return true when the dispatch reported -1
	 * @Param CommandName the console command to register
	 * @Param OutputName the console variable to read back
	 * @Boundary empty args
	 */
	UFUNCTION()
	bool StatAndShowEmptyArgs(const FString&in CommandName, const FString&in OutputName)
	{
		if (CommandName.Len() == 0 || OutputName.Len() == 0)
		{
			throw("StatAndShowCommandNames setup: required CommandName or OutputName is empty");
		}
		TArray<FString> Args;
		return ObserveDispatchArgs(CommandName, OutputName, Args) == -1;
	}
}
/** @end */
