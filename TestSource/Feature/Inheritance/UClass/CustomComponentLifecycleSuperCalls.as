/**
 * Component Super:: BeginPlay and Tick. C++ verifies after spawn+BeginPlay+two
 * 0.025 ticks: SuperProbe BaseBeginPlayCount==1, DerivedBeginPlayCount==1,
 * BaseTickCount==2, DerivedTickCount==2, LastDeltaMillis==25. Tick(0) is the
 * zero-delta boundary.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.CustomComponentLifecycleSuperCalls
 * @Harness UClass
 * @Tag Feature.Inheritance.CustomComponentLifecycleSuperCalls
 * @Provenance Theme: Feature.Inheritance. WorldStory component Super:: BeginPlay and Tick.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::CustomComponentLifecycleSuperCalls
 * @Provenance sha256 from theme-refs TS-FEAT-0013; lines 1445-1502.
 * @Provenance Oracle after spawn+BeginPlay+two ticks of 0.025: SuperProbe BaseBeginPlayCount==1;
 * @Provenance DerivedBeginPlayCount==1; BaseTickCount==2; DerivedTickCount==2; LastDeltaMillis==25.
 * @Provenance Extra: local construct zeros; Tick(0) is the zero-delta boundary. FixtureIsolated.
 */

UCLASS()
class UCoverageBaseLifecycleSuperComponent : UActorComponent
{
	UPROPERTY()
	int BaseBeginPlayCount = 0;

	UPROPERTY()
	int BaseTickCount = 0;

	/**
	 * WorldStory: base component BeginPlay increments BaseBeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs none
	 * @Return BaseBeginPlayCount incremented
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseBeginPlayCount++;
	}

	/**
	 * WorldStory: base component Tick increments BaseTickCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs the frame delta
	 * @Return BaseTickCount incremented
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		BaseTickCount++;
	}
}

UCLASS()
class UCoverageDerivedLifecycleSuperComponent : UCoverageBaseLifecycleSuperComponent
{
	UPROPERTY()
	int DerivedBeginPlayCount = 0;

	UPROPERTY()
	int DerivedTickCount = 0;

	UPROPERTY()
	int LastDeltaMillis = 0;

	/**
	 * WorldStory: derived BeginPlay Super-calls then increments DerivedBeginPlayCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs Super::BeginPlay()
	 * @Return BaseBeginPlayCount 1 and DerivedBeginPlayCount 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		DerivedBeginPlayCount++;
	}

	/**
	 * WorldStory: derived Tick Super-calls then records LastDeltaMillis.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs Super::Tick(DeltaTime)
	 * @Return DerivedTickCount incremented; LastDeltaMillis from DeltaTime
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		Super::Tick(DeltaTime);
		DerivedTickCount++;
		LastDeltaMillis = int(DeltaTime * 1000.0f);
	}

	/**
	 * Observe BeginPlay Super counts packed as Base*10 + Derived.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs BeginPlay()
	 * @Return BaseBeginPlayCount * 10 + DerivedBeginPlayCount, expected to be 11
	 */
	UFUNCTION()
	int BeginPlayCounts()
	{
		BeginPlay();
		return BaseBeginPlayCount * 10 + DerivedBeginPlayCount;
	}

	/**
	 * Observe Tick(0.0) writing LastDeltaMillis to 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs Tick(0.0f)
	 * @Return LastDeltaMillis, expected to be 0
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int ZeroDeltaTick()
	{
		Tick(0.0f);
		return LastDeltaMillis;
	}

	/**
	 * Observe Tick(0.025) writing LastDeltaMillis to 25.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs Tick(0.025f)
	 * @Return LastDeltaMillis, expected to be 25
	 */
	UFUNCTION()
	int TwentyFiveMillisTick()
	{
		Tick(0.025f);
		return LastDeltaMillis;
	}
}

UCLASS()
class ACoverageComponentLifecycleSuperActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDerivedLifecycleSuperComponent SuperProbe;

	/**
	 * Observe that a locally constructed actor has a null or zeroed SuperProbe.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CustomComponentLifecycleSuperCalls
	 * @Inputs an actor that has not begun play
	 * @Return true when SuperProbe is null or its counts are 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ActorDefaultEmpty()
	{
		if (SuperProbe == nullptr)
		{
			return true;
		}
		if (SuperProbe.BaseBeginPlayCount != 0)
		{
			return false;
		}
		return SuperProbe.LastDeltaMillis == 0;
	}
}
