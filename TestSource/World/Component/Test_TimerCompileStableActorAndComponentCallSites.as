// Theme: World.Component. CSV NegativeDiagnostic; C++ compiles and
// VerifyByPath. Value/lifecycle oracle for System::SetTimer call sites.
// C++: AngelscriptCoverageTimerTests.cpp::TimerCompileStableActorAndComponentCallSites
// sha256=97d638a1ab054a6b2a9afda3833f4aaca7e3a7ebb6031a521ca2fba03e39faf3; lines 1636-1700.
// Oracle bNextTickCallSiteCompiled true, bFunctionNameCallSiteCompiled true.
// Extra: local construct flags false. FixtureIsolated.

UCLASS()
class UCoverageTimerComponentCallSite : UActorComponent
{
	FTimerHandle ComponentHandle;

	UFUNCTION()
	void ComponentCallback()
	{
	}

	UFUNCTION()
	bool ConfigureComponentTimer()
	{
		ComponentHandle = System::SetTimer(this, n"ComponentCallback", 1.0f, true);
		bool bActive = SystemLibrary::IsTimerActiveHandle(ComponentHandle);
		float Remaining = SystemLibrary::GetTimerRemainingTimeHandle(ComponentHandle);
		float Elapsed = SystemLibrary::GetTimerElapsedTimeHandle(ComponentHandle);

		System::PauseTimerHandle(ComponentHandle);
		bool bPaused = System::IsTimerPausedHandle(ComponentHandle);
		System::UnPauseTimerHandle(ComponentHandle);
		System::ClearAndInvalidateTimerHandle(ComponentHandle);

		return bActive && bPaused && Remaining >= 0.0f && Elapsed >= 0.0f && !SystemLibrary::TimerExistsHandle(ComponentHandle);
	}
}

UCLASS()
class ACoverageTimerCompileStableActor : AActor
{
	FTimerHandle NextTickHandle;
	FTimerHandle FunctionNameHandle;

	UPROPERTY()
	bool bNextTickCallSiteCompiled = false;

	UPROPERTY()
	bool bFunctionNameCallSiteCompiled = false;

	UFUNCTION()
	void NextTickCallback()
	{
	}

	UFUNCTION()
	void FunctionNameCallback()
	{
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		NextTickHandle = System::SetTimer(this, n"NextTickCallback", 0.0f, false);
		bNextTickCallSiteCompiled = SystemLibrary::TimerExistsHandle(NextTickHandle) || !System::IsTimerPausedHandle(NextTickHandle);
		System::ClearAndInvalidateTimerHandle(NextTickHandle);

		FunctionNameHandle = System::SetTimer(this, n"FunctionNameCallback", 0.25f, true);
		bFunctionNameCallSiteCompiled = SystemLibrary::IsTimerActiveHandle(FunctionNameHandle)
			&& SystemLibrary::GetTimerRemainingTimeHandle(FunctionNameHandle) >= 0.0f
			&& SystemLibrary::GetTimerElapsedTimeHandle(FunctionNameHandle) >= 0.0f;
		System::ClearAndInvalidateTimerHandle(FunctionNameHandle);
	}
}

bool Observe_TimerCompileStable_DefaultFalse(ACoverageTimerCompileStableActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerCompileStableActorAndComponentCallSites setup: required Actor is null");
	}
	return !Actor.bNextTickCallSiteCompiled && !Actor.bFunctionNameCallSiteCompiled;
}

bool Observe_TimerCompileStable_CopyIndependence(ACoverageTimerCompileStableActor First, ACoverageTimerCompileStableActor Second)
{
	if (First is null)
	{
		throw("Test_TimerCompileStableActorAndComponentCallSites setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TimerCompileStableActorAndComponentCallSites setup: required Second is null");
	}
	First.bNextTickCallSiteCompiled = true;
	return First.bNextTickCallSiteCompiled && !Second.bNextTickCallSiteCompiled;
}
