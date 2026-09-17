/**
 * @version v1
 * @summary TestFramework Commands Test_AdvancedCommandTimeoutAndClientPolicy
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Commands Test_AdvancedCommandTimeoutAndClientPolicy
 * @topic Baseline
 */
// Framework contract: bAllowTimeout and bAlsoRunOnClient are observable
// command policy. Supported client callbacks must finish or fail once.
// FinishClient cannot hang the suite when the host Update never completes.
// Payload: a PlayerController World, timeout 0.01, Update returning false,
// and completing client overrides are enough for the network-capable runner.
// Expected observations: policy flags are true on the command; the leaf
// ends without hanging; Describe remains unique.
// C++ oracle required: timeout/client bits, FinishClient completion, single
// terminal result, and that a disallowed-timeout command is distinguishable.

UCLASS()
class UTestSourceClientPolicyCommand : ULatentAutomationCommand
{
	default bAllowTimeout = true;
	default bAlsoRunOnClient = true;

	int ClientBeforeCount = 0;
	int ClientUpdateCount = 0;
	int ClientAfterCount = 0;

	UFUNCTION(BlueprintOverride)
	void Before()
	{
		UTestSourceAdvancedCommandTimeoutAndClientPolicySuite Suite =
			Cast<UTestSourceAdvancedCommandTimeoutAndClientPolicySuite>(GetCurrentSuite());
		Suite.AssertNotNull(Suite, "TS-FW-COMMANDS-007 Before missing suite");
		Suite.AssertTrue(bAllowTimeout, "TS-FW-COMMANDS-007 bAllowTimeout");
		Suite.AssertTrue(bAlsoRunOnClient, "TS-FW-COMMANDS-007 bAlsoRunOnClient");
		Suite.AssertTrue(HasAuthority(), "TS-FW-COMMANDS-007 HasAuthority");
	}

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		return false;
	}

	UFUNCTION(BlueprintOverride)
	bool BeforeOnClient()
	{
		ClientBeforeCount += 1;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	bool UpdateOnClient()
	{
		ClientUpdateCount += 1;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	bool AfterOnClient()
	{
		ClientAfterCount += 1;
		return true;
	}

	UFUNCTION(BlueprintOverride)
	void After()
	{
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "TS-FW-COMMANDS-007 client timeout policy";
	}

	UFUNCTION(BlueprintOverride)
	FString DescribeOnClient() const
	{
		return "TS-FW-COMMANDS-007 client describe";
	}
}

UCLASS()
class UTestSourceDisallowedTimeoutCommand : ULatentAutomationCommand
{
	default bAllowTimeout = false;
	default bAlsoRunOnClient = false;

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		return true;
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "TS-FW-COMMANDS-007 timeout disallowed";
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAdvancedCommandTimeoutAndClientPolicySuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAdvancedCommandTimeoutAndClientPolicy()
	{
		FAngelscriptTest::CreateTestWorld(false);
		FAngelscriptTest::SpawnActor(APlayerController::StaticClass());
		UTestSourceClientPolicyCommand Command =
			Cast<UTestSourceClientPolicyCommand>(
				NewObject(
					this,
					UTestSourceClientPolicyCommand::StaticClass()));
		Command.bAllowTimeout = true;
		Command.bAlsoRunOnClient = true;
		FAngelscriptTest::Commands()
			.OnCleanup(n"DestroyClientPolicyWorld")
			.AddLatentCommand(Command, 0.01);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyDisallowedTimeoutCommandCompletes()
	{
		UTestSourceDisallowedTimeoutCommand Command =
			Cast<UTestSourceDisallowedTimeoutCommand>(
				NewObject(
					this,
					UTestSourceDisallowedTimeoutCommand::StaticClass()));
		Command.bAllowTimeout = false;
		FAngelscriptTest::Commands()
			.AddLatentCommand(Command, 1.0)
			.Then(n"RecordDisallowedTimeoutFinished");
	}

	void RecordDisallowedTimeoutFinished()
	{
		AssertTrue(true, "TS-FW-COMMANDS-007 disallowed-timeout command finished");
	}

	void DestroyClientPolicyWorld()
	{
		FAngelscriptTest::DestroyTestWorld();
	}
}
/** @end */
