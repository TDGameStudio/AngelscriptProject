// Theme: Feature.Inheritance. WorldStory Super:: BeginPlay/Tick/EndPlay order.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::MultiLevelInheritanceLifecycle
// sha256 from theme-refs TS-FEAT-0012; lines 773-875.
// Oracle after BeginPlay: BaseBeginPlayOrder==1; MidBeginPlayOrder==2; DeepBeginPlayOrder==3.
// Tick/EndPlay stay 0 unless the world dispatches them. Extra: all orders 0 on local construct.
// FixtureIsolated. Trailing CompileAndExpectFailure in the C++ file is the next method.

UCLASS()
class ABaseLifecycleActor : AActor
{
	UPROPERTY()
	int BaseBeginPlayOrder = 0;

	UPROPERTY()
	int BaseTickOrder = 0;

	UPROPERTY()
	int BaseEndPlayOrder = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseBeginPlayOrder = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		BaseTickOrder = 1;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		BaseEndPlayOrder = 1;
	}
}

UCLASS()
class AMidLifecycleActor : ABaseLifecycleActor
{
	UPROPERTY()
	int MidBeginPlayOrder = 0;

	UPROPERTY()
	int MidTickOrder = 0;

	UPROPERTY()
	int MidEndPlayOrder = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		MidBeginPlayOrder = 2;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		MidTickOrder = 2;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		Super::EndPlay(EndPlayReason);
		MidEndPlayOrder = 2;
	}
}

UCLASS()
class ADeepLifecycleActor : AMidLifecycleActor
{
	UPROPERTY()
	int DeepBeginPlayOrder = 0;

	UPROPERTY()
	int DeepTickOrder = 0;

	UPROPERTY()
	int DeepEndPlayOrder = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Super::BeginPlay();
		DeepBeginPlayOrder = 3;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		Super::Tick(DeltaSeconds);
		DeepTickOrder = 3;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		Super::EndPlay(EndPlayReason);
		DeepEndPlayOrder = 3;
	}
}

bool Observe_Lifecycle_DefaultEmpty(ADeepLifecycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultiLevelInheritanceLifecycle setup: required Actor is null");
	}
	return Actor.BaseBeginPlayOrder == 0
		&& Actor.MidBeginPlayOrder == 0
		&& Actor.DeepBeginPlayOrder == 0
		&& Actor.BaseTickOrder == 0
		&& Actor.DeepEndPlayOrder == 0;
}

int Observe_Lifecycle_BeginPlayChain(ADeepLifecycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultiLevelInheritanceLifecycle setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.BaseBeginPlayOrder * 100 + Actor.MidBeginPlayOrder * 10 + Actor.DeepBeginPlayOrder;
}

int Observe_Lifecycle_TickChain(ADeepLifecycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultiLevelInheritanceLifecycle setup: required Actor is null");
	}
	Actor.Tick(0.0);
	return Actor.BaseTickOrder * 100 + Actor.MidTickOrder * 10 + Actor.DeepTickOrder;
}

bool Observe_Lifecycle_TwoLocalsIndependent(ADeepLifecycleActor First, ADeepLifecycleActor Second)
{
	if (First is null)
	{
		throw("Test_MultiLevelInheritanceLifecycle setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_MultiLevelInheritanceLifecycle setup: required Second is null");
	}
	First.BeginPlay();
	return First.DeepBeginPlayOrder == 3 && Second.DeepBeginPlayOrder == 0;
}
