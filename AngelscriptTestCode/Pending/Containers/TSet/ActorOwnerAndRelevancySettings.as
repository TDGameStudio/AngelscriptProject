/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Baseline
 */
// CompileScriptModule + spawn. Oracle: NetPriority 3.5, SetReplicates true, frequencies
// 24/6/4096 then ExerciseOwnerAndRelevancy writes bOwnerRoundTrip and bFrequencyRoundTrip true.
// Extra: local construct leaves both flags false; null owner still round-trips GetOwner.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageNetworkingOwnerRelevancyActor : AActor
{
	default SetReplicates(true);
	// NOTE: AActor replication bitfields (bOnlyRelevantToOwner, bAlwaysRelevant,
	// bNetUseOwnerRelevancy) are uint8 bitfield UPROPERTYs that the AngelScript binding
	// does not expose as settable `default` members ("'bOnlyRelevantToOwner' is not
	// declared"). Only float/typed replication members such as NetPriority are reachable
	// from AS class defaults, so this surface is limited to NetPriority + SetReplicates.
	// SetReplicates/SetNetUpdateFrequency* are method-call defaults on spawned instances,
	// not on the CDO (see UClassDefaultValueAndCDOMatrix).
	default NetPriority = 3.5f;
	default SetNetUpdateFrequency(24.0f);
	default SetMinNetUpdateFrequency(6.0f);
	default SetNetCullDistanceSquared(4096.0f);

	UPROPERTY()
	bool bOwnerRoundTrip = false;

	UPROPERTY()
	bool bFrequencyRoundTrip = false;

	UFUNCTION()
	void ExerciseOwnerAndRelevancy(AActor NewOwner)
	{
		SetOwner(NewOwner);
		bOwnerRoundTrip = GetOwner() == NewOwner;
		SetNetUpdateFrequency(12.0f);
		SetMinNetUpdateFrequency(4.0f);
		SetNetCullDistanceSquared(1024.0f);
		bFrequencyRoundTrip =
			GetNetUpdateFrequency() == 12.0f
			&& GetMinNetUpdateFrequency() == 4.0f
			&& GetNetCullDistanceSquared() == 1024.0f;
	}
}

bool Observe_OwnerRelevancy_DefaultEmpty(ACoverageNetworkingOwnerRelevancyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ActorOwnerAndRelevancySettings setup: required Actor is null");
	}
	return Actor.bOwnerRoundTrip == false && Actor.bFrequencyRoundTrip == false;
}

bool Observe_OwnerRelevancy_NullOwnerBoundary(ACoverageNetworkingOwnerRelevancyActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-CONT-0054 setup: required actor is null");
	}
	Actor.ExerciseOwnerAndRelevancy(nullptr);
	return Actor.bOwnerRoundTrip && Actor.bFrequencyRoundTrip;
}

bool Observe_OwnerRelevancy_Nominal(ACoverageNetworkingOwnerRelevancyActor Actor, AActor NewOwner)
{
	if (Actor == nullptr || NewOwner == nullptr)
	{
		throw("TS-CONT-0054 setup: required actor or owner is null");
	}
	Actor.ExerciseOwnerAndRelevancy(NewOwner);
	return Actor.bOwnerRoundTrip && Actor.bFrequencyRoundTrip;
}
/** @end */
