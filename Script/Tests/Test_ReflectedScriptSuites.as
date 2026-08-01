// Runnable examples for the reflected AngelScript test-suite framework.
// Every test method is an ordinary reflected void() function marked with
// meta=(AngelscriptTest); names do not need a TEST_ prefix.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedPureScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void ArithmeticUsesNativeAssertions()
	{
		AssertEquals(42, 40 + 2);
		AssertNear(10.0, 10.001, 0.01);
		AssertTrue(FVector(1.0, 2.0, 3.0).Equals(
			FVector(1.0, 2.0, 3.0)));
		AssertNull(FAngelscriptTest::GetTestWorld());
	}
}

// A fixture is the suite instance plus its per-leaf state, lifecycle, and
// helpers. BeforeAll/AfterAll use a separate suite-scope instance, while each
// marked method receives a fresh method fixture.
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedFixtureScriptTests : UAngelscriptTestSuite
{
	int SuiteScopeValue = 0;
	int BeforeEachCount = 0;
	int AfterEachCount = 0;
	int PerLeafValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeforeAll()
	{
		// This state stays on the separate suite-scope instance.
		SuiteScopeValue = 100;
	}

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		BeforeEachCount += 1;
		PerLeafValue = 10;
		FAngelscriptTest::Commands()
			.OnCleanup(n"VerifyAfterEachRan");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FirstLeafGetsFreshFixtureState()
	{
		AssertEquals(0, SuiteScopeValue);
		AssertEquals(1, BeforeEachCount);
		AssertEquals(0, AfterEachCount);
		AssertEquals(10, PerLeafValue);
		PerLeafValue = 20;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void SecondLeafDoesNotSeeFirstLeafState()
	{
		AssertEquals(0, SuiteScopeValue);
		AssertEquals(1, BeforeEachCount);
		AssertEquals(0, AfterEachCount);
		AssertEquals(10, PerLeafValue);
	}

	UFUNCTION(BlueprintOverride)
	void AfterEach()
	{
		AfterEachCount += 1;
		PerLeafValue = 99;
	}

	void VerifyAfterEachRan()
	{
		AssertEquals(1, AfterEachCount);
		AssertEquals(99, PerLeafValue);
	}

	UFUNCTION(BlueprintOverride)
	void AfterAll()
	{
		SuiteScopeValue = 0;
	}
}

#if EDITOR
UCLASS()
class UReflectedPlainTestObject : UObject
{
	int Value = 0;

	void Increment()
	{
		Value += 1;
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedObjectScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void SpawnObjectDoesNotRequireAWorld()
	{
		UReflectedPlainTestObject Object =
			Cast<UReflectedPlainTestObject>(
				FAngelscriptTest::SpawnObject(
					UReflectedPlainTestObject::StaticClass()));
		AssertNotNull(Object);
		AssertSame(this, Object.GetOuter());

		Object.Increment();
		AssertEquals(1, Object.Value);
		AssertNull(FAngelscriptTest::GetTestWorld());
	}
}
#endif

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedExpectedErrorScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void MatchesExpectedErrorText()
	{
		ExpectError("intentional inventory warning", 1);
		Error("prefix intentional inventory warning suffix");
	}

	UFUNCTION(meta=(AngelscriptTest))
	void MatchesExpectedErrorRegexAndCount()
	{
		ExpectErrorRegex("item-[0-9]+ unavailable", 2);
		Error("item-12 unavailable");
		Error("item-34 unavailable");
	}
}

#if EDITOR
UCLASS()
class AReflectedWorldProbeActor : AActor
{
	int BeginPlayCount = 0;
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS()
class UReflectedWorldProbeComponent : UActorComponent
{
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedWorldScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void GameInstanceModeProvidesSubsystemContext()
	{
		FAngelscriptTest::CreateTestWorld(true);
		AssertNotNull(FAngelscriptTest::GetTestWorld());
		AssertNotNull(
			FAngelscriptTest::GetTestWorld().GetGameInstance());

		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld());
	}

	UFUNCTION(meta=(AngelscriptTest))
	void OwnsSpawnAndTickStateExplicitly()
	{
		FAngelscriptTest::CreateTestWorld(false);
		UWorld World = FAngelscriptTest::GetTestWorld();
		AssertNotNull(World);

		AReflectedWorldProbeActor Actor =
			Cast<AReflectedWorldProbeActor>(
				FAngelscriptTest::SpawnActor(
					AReflectedWorldProbeActor::StaticClass(),
					FVector(10.0, 20.0, 30.0)));
		AssertNotNull(Actor);
		AssertSame(World, Actor.GetWorld());

		UReflectedWorldProbeComponent Component =
			Cast<UReflectedWorldProbeComponent>(
				FAngelscriptTest::SpawnComponent(
					UReflectedWorldProbeComponent::StaticClass(),
					Actor,
					true));
		AssertNotNull(Component);

		FAngelscriptTest::BeginPlay(Actor);
		FAngelscriptTest::BeginPlay(Actor);
		AssertEquals(1, Actor.BeginPlayCount);

		FAngelscriptTest::TickActor(Actor, 0.01, 2);
		FAngelscriptTest::TickComponent(Component, 0.01, 3);
		AssertEquals(2, Actor.TickCount);
		AssertEquals(3, Component.TickCount);

		FAngelscriptTest::DestroyActor(Actor, true);
		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld());
	}
}
#endif

#if EDITOR
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedFluentScriptTests : UAngelscriptTestSuite
{
	bool bReady = false;
	int CleanupCount = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void DelayAndPollWithoutAwait()
	{
		FAngelscriptTest::Commands()
			.OnCleanup(n"RecordCleanup");
		FAngelscriptTest::Commands()
			.WaitDelay(0.01, "small monotonic delay")
			.Then(n"MarkReady")
			.Until(n"IsReady", 1.0, "ready flag")
			.Then(n"VerifyReady");
	}

	void MarkReady()
	{
		bReady = true;
	}

	bool IsReady()
	{
		return bReady;
	}

	void VerifyReady()
	{
		AssertTrue(bReady);
		AssertEquals(0, CleanupCount);
	}

	void RecordCleanup()
	{
		CleanupCount += 1;
	}
}
#endif

#if EDITOR
UCLASS()
class UReflectedCountingCommand : ULatentAutomationCommand
{
	UFUNCTION(BlueprintOverride)
	void Before()
	{
		UReflectedAdvancedScriptTests Suite =
			Cast<UReflectedAdvancedScriptTests>(GetCurrentSuite());
		Suite.AssertNotNull(Suite);
		Suite.Value = 1;
	}

	UFUNCTION(BlueprintOverride)
	bool Update()
	{
		UReflectedAdvancedScriptTests Suite =
			Cast<UReflectedAdvancedScriptTests>(GetCurrentSuite());
		Suite.Value += 1;
		return Suite.Value >= 3;
	}

	UFUNCTION(BlueprintOverride)
	void After()
	{
		UReflectedAdvancedScriptTests Suite =
			Cast<UReflectedAdvancedScriptTests>(GetCurrentSuite());
		Suite.AssertEquals(3, Suite.Value);
		Suite.Value = 4;
	}

	UFUNCTION(BlueprintOverride)
	FString Describe() const
	{
		return "count to three";
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedAdvancedScriptTests : UAngelscriptTestSuite
{
	int Value = 0;

	UFUNCTION(meta=(AngelscriptTest))
	void RunsAdvancedLatentCompatibilityCommand()
	{
		UReflectedCountingCommand Command =
			Cast<UReflectedCountingCommand>(
				NewObject(
					this,
					UReflectedCountingCommand::StaticClass()));
		FAngelscriptTest::Commands()
			.AddLatentCommand(Command, 1.0)
			.Then(n"VerifyCommandFinished");
	}

	void VerifyCommandFinished()
	{
		AssertEquals(4, Value);
	}
}
#endif

// Execution flags are an exact UE Automation mask. This suite is eligible in
// editor, client, server, and commandlet contexts; it is not an editor-only
// compile declaration.
UCLASS(meta=(AngelscriptTestFlags="EditorContext;ClientContext;ServerContext;CommandletContext;EngineFilter"))
class UReflectedRuntimeCapableScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void UsesAnExactMultiContextMask()
	{
		AssertTrue(true);
	}
}

// #if EDITOR controls whether this class is compiled at all. EditorContext
// independently controls where UE Automation is allowed to execute the leaf.
#if EDITOR
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UReflectedEditorOnlyScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void CompilesOnlyWithEditorSymbols()
	{
		AssertTrue(true);
	}
}
#endif
