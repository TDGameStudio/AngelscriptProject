// Framework contract: ULatentAutomationCommand runs Before once, Update
// until it returns true, then After once. Describe is observable.
// GetCurrentSuite remains the owning suite. HasAuthority is true while the
// command is bound to the leaf.
// Payload: a counter that completes at 3 is enough to prove the phase
// counts without World or client policy.
// Expected observations: Before sets Value=1; Update reaches 3; After sets
// 4; VerifyAdvancedLatentCommandLifecycle then sees 4.
// C++ oracle required: exact Before/Update/After counts, Describe text
// "TS-FW-COMMANDS-006 count to three", and stable suite identity.

UCLASS()
class UTestSourceAdvancedLifecycleCommand : ULatentAutomationCommand
{
	int BeforeCount = 0;
	int UpdateCount = 0;
	int AfterCount = 0;

	UFUNCTION(BlueprintOverride)
	void Before()
	{
		UTestSourceAdvancedLatentCommandLifecycleSuite Suite =
			Cast<UTestSourceAdvancedLatentCommandLifecycleSuite>(GetCurrentSuite());
		Suite.AssertNotNull(Suite, "TS-FW-COMMANDS-006 Before missing suite");
		Suite.AssertTrue(HasAuthority(), "TS-FW-COMMANDS-006 Before HasAuthority");
		Suite.AssertEquals(0, Suite.Value, "TS-FW-COMMANDS-006 Before starting value");
		BeforeCount += 1;
		Suite.Value = 1;
	}

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		UTestSourceAdvancedLatentCommandLifecycleSuite Suite =
			Cast<UTestSourceAdvancedLatentCommandLifecycleSuite>(GetCurrentSuite());
		Suite.AssertSame(Suite, GetCurrentSuite(), "TS-FW-COMMANDS-006 Update suite identity");
		UpdateCount += 1;
		Suite.Value += 1;
		return Suite.Value >= 3;
	}

	UFUNCTION(BlueprintOverride)
	void After()
	{
		UTestSourceAdvancedLatentCommandLifecycleSuite Suite =
			Cast<UTestSourceAdvancedLatentCommandLifecycleSuite>(GetCurrentSuite());
		Suite.AssertEquals(3, Suite.Value, "TS-FW-COMMANDS-006 After value");
		AfterCount += 1;
		Suite.Value = 4;
		Suite.BeforeCount = BeforeCount;
		Suite.UpdateCount = UpdateCount;
		Suite.AfterCount = AfterCount;
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "TS-FW-COMMANDS-006 count to three";
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceAdvancedLatentCommandLifecycleSuite : UAngelscriptTestSuite
{
	int Value = 0;
	int BeforeCount = 0;
	int UpdateCount = 0;
	int AfterCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyAdvancedLatentCommandLifecycle()
	{
		UTestSourceAdvancedLifecycleCommand Command =
			Cast<UTestSourceAdvancedLifecycleCommand>(
				NewObject(
					this,
					UTestSourceAdvancedLifecycleCommand::StaticClass()));
		FAngelscriptTest::Commands()
			.AddLatentCommand(Command, 1.0)
			.Then(n"VerifyCommandFinished");
	}

	void VerifyCommandFinished()
	{
		AssertEquals(4, Value, "TS-FW-COMMANDS-006 final value");
		AssertEquals(1, BeforeCount, "TS-FW-COMMANDS-006 Before count");
		AssertEquals(2, UpdateCount, "TS-FW-COMMANDS-006 Update count");
		AssertEquals(1, AfterCount, "TS-FW-COMMANDS-006 After count");
	}
}
