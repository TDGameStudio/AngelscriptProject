/**
 * Network debug logging from BeginPlay, OnRep and an RPC helper. The CSV
 * NegativeDiagnostic label is a heuristic: C++ compiles this and verifies the flags
 * by path after BeginPlay, so this is a value oracle. The UPROPERTY names are part of
 * the contract and are kept verbatim.
 *
 * @Theme Gameplay.Net
 * @Subject Net.NetworkDebugLoggingPatterns
 * @Harness UClass
 * @Tag Gameplay.Net.NetworkDebugLoggingPatterns
 * @Provenance Theme: Gameplay.Net. WorldStory network debug logging; Error emits CoverageNetworkDebug_RPC.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::NetworkDebugLoggingPatterns
 * @Provenance CSV NegativeDiagnostic; C++ compiles. VerifyByPath after BeginPlay:
 * @Provenance bLoggedAuthority true, bLoggedOnRep true, bLoggedRpc true; DebugValue 17.
 * @Provenance Extra: defaults false/0. FixtureIsolated. Keep UPROPERTY names.
 */

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

	/**
	 * Emit the RPC debug Error line and mark bLoggedRpc.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkDebugLoggingPatterns
	 * @Inputs the debug value to include in the Error line
	 * @Return nothing; bLoggedRpc is set
	 * @Param InValue the value written into the Error line
	 */
	UFUNCTION()
	void LogRpcDebugValue(int InValue)
	{
		Error("CoverageNetworkDebug_RPC Value=" + InValue);
		bLoggedRpc = true;
	}

	/**
	 * RepNotify that prints the OnRep line and marks bLoggedOnRep.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkDebugLoggingPatterns
	 * @Inputs none
	 * @Return nothing; bLoggedOnRep is set
	 */
	UFUNCTION()
	void OnRep_DebugValue()
	{
		Print("CoverageNetworkDebug_OnRep DebugValue=" + DebugValue);
		bLoggedOnRep = true;
	}

	/**
	 * WorldStory: BeginPlay logs authority, writes DebugValue 17, runs OnRep and the
	 * RPC helper.
	 *
	 * @Kind WorldStory
	 * @Covers Net.NetworkDebugLoggingPatterns
	 * @Inputs none
	 * @Return the authority, OnRep and RPC log paths exercised
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("CoverageNetworkDebug_Authority=" + HasAuthority());
		bLoggedAuthority = true;
		DebugValue = 17;
		OnRep_DebugValue();
		LogRpcDebugValue(DebugValue);
	}

	/**
	 * Observe that a locally constructed actor keeps the false/zero defaults.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkDebugLoggingPatterns
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when DebugValue is 0 and all three log flags are false
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (DebugValue != 0)
		{
			return false;
		}
		if (bLoggedAuthority)
		{
			return false;
		}
		if (bLoggedOnRep)
		{
			return false;
		}
		return !bLoggedRpc;
	}

	/**
	 * Observe that driving OnRep and the RPC helper records DebugValue 17 and both
	 * log flags.
	 *
	 * @Kind Observe
	 * @Covers Net.NetworkDebugLoggingPatterns
	 * @Inputs none
	 * @Return true when DebugValue is 17 and bLoggedOnRep and bLoggedRpc are set
	 */
	UFUNCTION()
	bool OnRepAndRpc()
	{
		DebugValue = 17;
		OnRep_DebugValue();
		LogRpcDebugValue(DebugValue);

		if (DebugValue != 17)
		{
			return false;
		}
		if (!bLoggedOnRep)
		{
			return false;
		}
		return bLoggedRpc;
	}
}
