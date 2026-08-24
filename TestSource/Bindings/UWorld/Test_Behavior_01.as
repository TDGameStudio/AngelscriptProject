// Purpose: Observe implicit world context, server travel, WorldType, and the
// global frame counter. ServerTravel is not default-executable.
// AS-facing API: UObject __WorldContext();
// bool UWorld.ServerTravel(const FString& FURL, bool bAbsolute, bool bShouldSkipGameNotify);
// EWorldType UWorld.WorldType; uint GFrameNumber;
// Inputs: Runner-owned expected WorldType and GFrameNumber lower bound.
// ServerTravel requires bAllowTravel=true plus runner World and URL.
// Expected observations: __WorldContext matches bExpectContext. ServerTravel
// returns the runner-supplied expected bool. WorldType equals Expected.
// GFrameNumber is >= ExpectedMinimum.
// Boundary/ownership: ServerTravel can change the running map (SubprocessOnly).
// WorldType aliases the world field. GFrameNumber is process global.
// Missing World or allow-flag is setup failure.

namespace TS_UWorld_Behavior_01
{
	// __WorldContext returns the implicit script world object, or null.
	bool Observe___WorldContext_Nominal(bool bExpectContext)
	{
		UObject Context = __WorldContext();
		if (bExpectContext)
		{
			return Context != nullptr;
		}
		return Context is null;
	}

	// ServerTravel changes the running map; runner must opt in.
	bool Observe_ServerTravel_Nominal(UWorld World, bool bAllowTravel, const FString& Url, bool bAbsolute, bool bShouldSkipGameNotify, bool bExpectTravel)
	{
		if (World is null)
		{
			throw("TS_UWorld_Behavior_01 setup: required World is null");
		}
		if (!bAllowTravel)
		{
			throw("TS_UWorld_Behavior_01 setup: ServerTravel requires SubprocessOnly host");
		}
		return World.ServerTravel(Url, bAbsolute, bShouldSkipGameNotify) == bExpectTravel;
	}

	// World.WorldType is the published EWorldType field; runner supplies the expected enumerator.
	bool Observe_Surface035_Nominal(UWorld World, EWorldType Expected)
	{
		if (World is null)
		{
			throw("TS_UWorld_Behavior_01 setup: required World is null");
		}
		return World.WorldType == Expected;
	}

	// GFrameNumber is the process-global unsigned frame counter; runner supplies a lower bound.
	bool Observe_Surface036_Nominal(uint ExpectedMinimum)
	{
		return GFrameNumber >= ExpectedMinimum;
	}
}
