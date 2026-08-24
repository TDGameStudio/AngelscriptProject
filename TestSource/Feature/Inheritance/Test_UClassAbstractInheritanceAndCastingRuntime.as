// Theme: Feature.Inheritance. CSV NegativeDiagnostic; C++ CompileUClassFixture + spawn + VerifyByPath.
// C++: AngelscriptCoverageUClassTests.cpp::UClassAbstractInheritanceAndCastingRuntime
// Oracle after BeginPlay: CallChain==123, UpcastWorked==1, DowncastWorked==1, InvalidCastFailed==1.
// Extra: pre-BeginPlay counters stay 0; empty handle is null. FixtureIsolated.
// Keep CallChain/UpcastWorked/DowncastWorked/InvalidCastFailed.

UCLASS(Abstract, Blueprintable)
class ACoverageUClassRuntimeAbstractBase : AActor
{
	UPROPERTY()
	int CallChain = 0;

	void ApplyStep()
	{
		CallChain = CallChain * 10 + 1;
	}
}

UCLASS()
class ACoverageUClassRuntimeMid : ACoverageUClassRuntimeAbstractBase
{
	void ApplyStep()
	{
		Super::ApplyStep();
		CallChain = CallChain * 10 + 2;
	}
}

UCLASS()
class ACoverageUClassRuntimeLeaf : ACoverageUClassRuntimeMid
{
	UPROPERTY()
	int UpcastWorked = 0;

	UPROPERTY()
	int DowncastWorked = 0;

	UPROPERTY()
	int InvalidCastFailed = 0;

	void ApplyStep()
	{
		Super::ApplyStep();
		CallChain = CallChain * 10 + 3;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ApplyStep();

		ACoverageUClassRuntimeAbstractBase BaseRef = this;
		if (BaseRef != nullptr && BaseRef.CallChain == 123)
		{
			UpcastWorked = 1;
		}

		ACoverageUClassRuntimeLeaf LeafRef = Cast<ACoverageUClassRuntimeLeaf>(BaseRef);
		if (LeafRef != nullptr)
		{
			DowncastWorked = 1;
		}

		ACoverageUClassRuntimeMid SpawnedMid = Cast<ACoverageUClassRuntimeMid>(SpawnActor(ACoverageUClassRuntimeMid::StaticClass()));
		ACoverageUClassRuntimeLeaf InvalidLeaf = Cast<ACoverageUClassRuntimeLeaf>(SpawnedMid);
		if (SpawnedMid != nullptr && InvalidLeaf == nullptr)
		{
			InvalidCastFailed = 1;
		}
	}
}

bool Observe_AbstractCasting_EmptyHandleIsNull()
{
	ACoverageUClassRuntimeLeaf Actor;
	return Actor == nullptr;
}

int Observe_AbstractCasting_CountersBeforeBeginPlay(ACoverageUClassRuntimeLeaf Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0117 setup: required ACoverageUClassRuntimeLeaf is null");
	}
	return Actor.CallChain + Actor.UpcastWorked + Actor.DowncastWorked + Actor.InvalidCastFailed;
}

bool Observe_AbstractCasting_AfterBeginPlay(ACoverageUClassRuntimeLeaf Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0117 setup: required ACoverageUClassRuntimeLeaf is null");
	}
	return Actor.CallChain == 123
		&& Actor.UpcastWorked == 1
		&& Actor.DowncastWorked == 1
		&& Actor.InvalidCastFailed == 1;
}
