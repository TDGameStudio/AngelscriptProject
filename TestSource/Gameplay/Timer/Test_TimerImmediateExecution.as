// Theme: Gameplay.Timer. WorldStory short-delay single-shot remaining-time query.
// C++: AngelscriptCoverageTimerTests.cpp::TimerImmediateExecution
// Oracle after BeginPlay: bImmediateTimerSetup true, bImmediateRemainingIsBounded true.
// Extra: setup false, remaining 0, CallbackCount 0. Do not spawn from script.

UCLASS()
class ACoverageTimerImmediateExecutionActor : AActor
{
	UPROPERTY()
	bool bImmediateTimerSetup = false;

	UPROPERTY()
	float ImmediateRemaining = 0.0f;

	UPROPERTY()
	bool bImmediateRemainingIsBounded = false;

	UPROPERTY()
	int CallbackCount = 0;

	FTimerHandle ImmediateHandle;

	UFUNCTION()
	void ImmediateCallback()
	{
		CallbackCount++;
		Print("ImmediateCallback executed on next tick, count: " + CallbackCount);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerImmediateExecution: Testing short-delay single-shot timer execution");

		ImmediateHandle = System::SetTimer(this, n"ImmediateCallback", 0.001f, false);

		bImmediateTimerSetup = SystemLibrary::IsTimerActiveHandle(ImmediateHandle);
		ImmediateRemaining = SystemLibrary::GetTimerRemainingTimeHandle(ImmediateHandle);
		bImmediateRemainingIsBounded = (ImmediateRemaining >= 0.0f && ImmediateRemaining <= 0.01f);

		Print("Immediate timer set, active: " + bImmediateTimerSetup);
		Print("Remaining: " + ImmediateRemaining + " seconds");
	}
}

bool Observe_TimerImmediate_DefaultEmpty(ACoverageTimerImmediateExecutionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerImmediateExecution setup: required Actor is null");
	}
	return Actor.bImmediateTimerSetup == false
		&& Actor.ImmediateRemaining == 0.0f
		&& Actor.bImmediateRemainingIsBounded == false
		&& Actor.CallbackCount == 0;
}

bool Observe_TimerImmediate_DirectCallback(ACoverageTimerImmediateExecutionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerImmediateExecution setup: required Actor is null");
	}
	Actor.ImmediateCallback();
	return Actor.CallbackCount == 1;
}
