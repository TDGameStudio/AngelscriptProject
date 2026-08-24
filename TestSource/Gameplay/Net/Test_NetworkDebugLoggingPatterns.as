// Theme: Gameplay.Net. WorldStory network debug logging; Error emits CoverageNetworkDebug_RPC.
// C++: AngelscriptCoverageLoggingTests.cpp::NetworkDebugLoggingPatterns
// CSV NegativeDiagnostic; C++ compiles. VerifyByPath after BeginPlay:
// bLoggedAuthority true, bLoggedOnRep true, bLoggedRpc true; DebugValue 17.
// Extra: defaults false/0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ANetworkDebugLogTestActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(ReplicatedUsing=OnRep_DebugValue)
	int DebugValue = 0;

	UPROPERTY()
	bool bLoggedAuthority = false;

	UPROPERTY()
	bool bLoggedOnRep = false;

	UPROPERTY()
	bool bLoggedRpc = false;

	void LogRpcDebugValue(int InValue)
	{
		Error("CoverageNetworkDebug_RPC Value=" + InValue);
		bLoggedRpc = true;
	}

	UFUNCTION()
	void OnRep_DebugValue()
	{
		Print("CoverageNetworkDebug_OnRep DebugValue=" + DebugValue);
		bLoggedOnRep = true;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("CoverageNetworkDebug_Authority=" + HasAuthority());
		bLoggedAuthority = true;
		DebugValue = 17;
		OnRep_DebugValue();
		LogRpcDebugValue(DebugValue);
	}
}

bool Observe_NetworkDebugLog_Defaults(ANetworkDebugLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkDebugLoggingPatterns setup: required Actor is null");
	}
	return Actor.DebugValue == 0
		&& Actor.bLoggedAuthority == false
		&& Actor.bLoggedOnRep == false
		&& Actor.bLoggedRpc == false;
}

bool Observe_NetworkDebugLog_OnRepAndRpc(ANetworkDebugLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_NetworkDebugLoggingPatterns setup: required Actor is null");
	}
	Actor.DebugValue = 17;
	Actor.OnRep_DebugValue();
	Actor.LogRpcDebugValue(Actor.DebugValue);
	return Actor.DebugValue == 17
		&& Actor.bLoggedOnRep == true
		&& Actor.bLoggedRpc == true;
}
