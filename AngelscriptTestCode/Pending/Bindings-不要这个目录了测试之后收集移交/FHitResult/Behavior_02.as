/**
 * @version v1
 * @summary Observe the remaining FHitResult vector and bone-name fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe the remaining FHitResult vector and bone-name fields.
 * @topic Baseline
 */
// FVector Hit.ImpactPoint; FVector Hit.Location; FVector Hit.Normal;
// FName Hit.BoneName; FName Hit.MyBoneName;
// Inputs: Trace hit (0,0,0)-(100,0,0), ImpactNormal (0,0,1), ImpactPoint
// (50,0,0), Location (50,0,0), Normal (0,1,0), BoneName n"spine_01",
// MyBoneName n"weapon_r".
// Expected observations: TraceEnd matches the constructor end. Each vector
// field round-trips. Bone names intern as FName and differ from NAME_None.
// Boundary/ownership: Fields are copies of contact data. BoneName is the
// target bone; MyBoneName is the source bone.

namespace TS_FHitResult_Behavior_02
{
	// FHitResult.TraceEnd. Inputs: constructor end (100,0,0), assign (200,0,0).
	// Oracle: default equals constructor end, assigned equals (200,0,0).
	bool Observe_Surface011_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		FVector DefaultEnd = Hit.TraceEnd;
		Hit.TraceEnd = FVector(200.0, 0.0, 0.0);
		FVector Assigned = Hit.TraceEnd;
		return DefaultEnd.Equals(FVector(100.0, 0.0, 0.0)) && Assigned.Equals(FVector(200.0, 0.0, 0.0));
	}

	// FHitResult.ImpactNormal. Inputs: assign (0,0,1). Oracle: assigned equals (0,0,1).
	bool Observe_Surface012_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.ImpactNormal = FVector(0.0, 0.0, 1.0);
		FVector Assigned = Hit.ImpactNormal;
		return Assigned.Equals(FVector(0.0, 0.0, 1.0));
	}

	// FHitResult.ImpactPoint. Inputs: assign (50,0,0). Oracle: assigned equals (50,0,0).
	bool Observe_Surface013_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.ImpactPoint = FVector(50.0, 0.0, 0.0);
		FVector Assigned = Hit.ImpactPoint;
		return Assigned.Equals(FVector(50.0, 0.0, 0.0));
	}

	// FHitResult.Location. Inputs: assign (50,0,0). Oracle: assigned equals (50,0,0).
	bool Observe_Surface014_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.Location = FVector(50.0, 0.0, 0.0);
		FVector Assigned = Hit.Location;
		return Assigned.Equals(FVector(50.0, 0.0, 0.0));
	}

	// FHitResult.Normal. Inputs: assign (0,1,0). Oracle: assigned equals (0,1,0).
	bool Observe_Surface015_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.Normal = FVector(0.0, 1.0, 0.0);
		FVector Assigned = Hit.Normal;
		return Assigned.Equals(FVector(0.0, 1.0, 0.0));
	}

	// FHitResult.BoneName. Inputs: default NAME_None, assign n"spine_01".
	// Oracle: default is NAME_None, assigned is spine_01.
	bool Observe_Surface016_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		FName DefaultName = Hit.BoneName;
		Hit.BoneName = n"spine_01";
		FName Assigned = Hit.BoneName;
		return DefaultName == NAME_None && Assigned == n"spine_01";
	}

	// FHitResult.MyBoneName. Inputs: default NAME_None, assign n"weapon_r".
	// Oracle: default is NAME_None, assigned is weapon_r.
	bool Observe_Surface017_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		FName DefaultName = Hit.MyBoneName;
		Hit.MyBoneName = n"weapon_r";
		FName Assigned = Hit.MyBoneName;
		return DefaultName == NAME_None && Assigned == n"weapon_r";
	}
}
/** @end */
