// Theme: World.Component. CSV NegativeDiagnostic; C++ compiles this actor
// then ExpectBoolByPath / ExpectComponentRegisteredByPath. The unsupported
// registration surface is a separate C++ CompileAndExpectFailure, not this
// body. Value/lifecycle oracle.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentRegistrationAndActivation
// sha256=0b176bfaacd286b2b3b25388286297f5399f1a39084e5ba9013db36586f67f03; lines 1857-1902.
// Oracle after Create+Activate+Deactivate: RegisteredAfterCreate, ActiveAfterActivate,
// InactiveAfterDeactivate, OwnerMatched, WorldMatched all true. Extra: local
// construct RuntimeComp is null and flags stay false. FixtureIsolated.

UCLASS()
class UCoverageRuntimeLogicComponent : UActorComponent
{
	UPROPERTY()
	int Value = 17;
}

UCLASS()
class ACoverageComponentRegistrationActivationActor : AActor
{
	UPROPERTY()
	UCoverageRuntimeLogicComponent RuntimeComp;

	UPROPERTY()
	bool RegisteredAfterCreate = false;

	UPROPERTY()
	bool ActiveAfterActivate = false;

	UPROPERTY()
	bool InactiveAfterDeactivate = false;

	UPROPERTY()
	bool OwnerMatched = false;

	UPROPERTY()
	bool WorldMatched = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RuntimeComp = UCoverageRuntimeLogicComponent::Create(this, n"RuntimeComp");
		RegisteredAfterCreate = RuntimeComp != nullptr;

		RuntimeComp.Activate(true);
		ActiveAfterActivate = RuntimeComp.IsActive();

		RuntimeComp.Deactivate();
		InactiveAfterDeactivate = !RuntimeComp.IsActive();

		OwnerMatched = RuntimeComp.GetOwner() == this;
		WorldMatched = RuntimeComp.GetWorld() == GetWorld();
	}
}

bool Observe_ComponentRegistration_DefaultNull(ACoverageComponentRegistrationActivationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentRegistrationAndActivation setup: required Actor is null");
	}
	return Actor.RuntimeComp == nullptr
		&& !Actor.RegisteredAfterCreate
		&& !Actor.ActiveAfterActivate
		&& !Actor.InactiveAfterDeactivate
		&& !Actor.OwnerMatched
		&& !Actor.WorldMatched;
}

bool Observe_ComponentRegistration_CopyIndependence(ACoverageComponentRegistrationActivationActor First, ACoverageComponentRegistrationActivationActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentRegistrationAndActivation setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentRegistrationAndActivation setup: required Second is null");
	}
	First.RegisteredAfterCreate = true;
	return First.RegisteredAfterCreate && !Second.RegisteredAfterCreate && Second.RuntimeComp == nullptr;
}
