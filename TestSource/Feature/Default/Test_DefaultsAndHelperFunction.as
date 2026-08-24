// Theme: Feature.Default. WorldStory actor default statements plus helper UFUNCTION.
// C++: AngelscriptActorLifecycleTests.cpp::DefaultsAndHelperFunction
// Oracle: GetIsReplicated true; Tags FunctionalActor; TickInterval 0.25;
// Health==125 DisplayName=="FunctionalActor" bBeginPlayTriggered==true; GetHealthValue()==125.
// Extra: empty handle is null; Health 0 boundary. Keep Health/DisplayName/bBeginPlayTriggered.
// FixtureIsolated.

UCLASS()
class ATestActorDefaultsAndHelperFunction : AActor
{
	UPROPERTY()
	int Health = 125;

	UPROPERTY()
	FString DisplayName = "FunctionalActor";

	UPROPERTY()
	bool bBeginPlayTriggered = false;

	default SetReplicates(true);
	default Tags.Add(n"FunctionalActor");
	default PrimaryActorTick.TickInterval = 0.25;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bBeginPlayTriggered = true;
	}

	UFUNCTION()
	int GetHealthValue()
	{
		return Health;
	}
}

bool Observe_DefaultsHelper_EmptyDefaultIsNull()
{
	ATestActorDefaultsAndHelperFunction Actor;
	return Actor == nullptr;
}

int Observe_DefaultsHelper_GetHealthValueNominal(ATestActorDefaultsAndHelperFunction Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0162 setup: required ATestActorDefaultsAndHelperFunction is null");
	}
	return Actor.GetHealthValue();
}

int Observe_DefaultsHelper_HealthZeroBoundary(ATestActorDefaultsAndHelperFunction Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0162 setup: required ATestActorDefaultsAndHelperFunction is null");
	}
	Actor.Health = 0;
	return Actor.GetHealthValue();
}

bool Observe_DefaultsHelper_CopyIndependent(
	ATestActorDefaultsAndHelperFunction First,
	ATestActorDefaultsAndHelperFunction Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0162 setup: required ATestActorDefaultsAndHelperFunction pair is null");
	}
	First.Health = 0;
	First.DisplayName = "";
	return Second.Health == 125 && Second.DisplayName == "FunctionalActor";
}
