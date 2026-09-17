/**
 * @version v1
 * @summary TestFramework World Test_WorldActorComponentLifecycle
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework World Test_WorldActorComponentLifecycle
 * @topic Baseline
 */
// Framework contract: CreateTestWorld(false) owns a non-GameInstance World.
// SpawnActor/SpawnComponent, BeginPlay, TickActor/TickComponent, DestroyActor,
// and DestroyTestWorld are explicit. BeginPlay is idempotent.
// Payload: probe counters, location (10,20,30), two BeginPlay calls, two
// actor ticks, and three component ticks are enough.
// Expected observations: World/actor/component identities match; BeginPlayCount
// stays 1; Tick counts equal the requested ticks; DestroyTestWorld clears
// GetTestWorld.
// C++ oracle required: ownership tracking, idempotent BeginPlay, and that
// destruction leaves no World for the next leaf.

UCLASS()
class ATestSourceWorldProbeActor : AActor
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
class UTestSourceWorldProbeComponent : UActorComponent
{
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount += 1;
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceWorldActorComponentLifecycleSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyWorldActorComponentLifecycle()
	{
		FAngelscriptTest::CreateTestWorld(false);
		UWorld World = FAngelscriptTest::GetTestWorld();
		AssertNotNull(World, "TS-FW-WORLD-002 missing World");
		AssertSame(World, GetWorld(), "TS-FW-WORLD-002 suite World mismatch");
		AssertNull(World.GetGameInstance(), "TS-FW-WORLD-002 unexpected GameInstance");

		ATestSourceWorldProbeActor Actor =
			Cast<ATestSourceWorldProbeActor>(
				FAngelscriptTest::SpawnActor(
					ATestSourceWorldProbeActor::StaticClass(),
					FVector(10.0, 20.0, 30.0)));
		AssertNotNull(Actor, "TS-FW-WORLD-002 missing actor");
		AssertSame(World, Actor.GetWorld(), "TS-FW-WORLD-002 actor World mismatch");

		UTestSourceWorldProbeComponent Component =
			Cast<UTestSourceWorldProbeComponent>(
				FAngelscriptTest::SpawnComponent(
					UTestSourceWorldProbeComponent::StaticClass(),
					Actor,
					true));
		AssertNotNull(Component, "TS-FW-WORLD-002 missing component");
		AssertSame(Actor, Component.GetOwner(), "TS-FW-WORLD-002 component owner");
		AssertSame(World, Component.GetWorld(), "TS-FW-WORLD-002 component World");

		FAngelscriptTest::BeginPlay(Actor);
		FAngelscriptTest::BeginPlay(Actor);
		AssertEquals(1, Actor.BeginPlayCount, "TS-FW-WORLD-002 BeginPlay was not idempotent");

		FAngelscriptTest::TickActor(Actor, 0.01, 2);
		FAngelscriptTest::TickComponent(Component, 0.01, 3);
		AssertEquals(2, Actor.TickCount, "TS-FW-WORLD-002 actor tick count");
		AssertEquals(3, Component.TickCount, "TS-FW-WORLD-002 component tick count");

		FAngelscriptTest::DestroyActor(Actor, true);
		FAngelscriptTest::DestroyTestWorld();
		AssertNull(FAngelscriptTest::GetTestWorld(), "TS-FW-WORLD-002 World survived destroy");
	}
}
/** @end */
