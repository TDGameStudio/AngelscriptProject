// Purpose: Observe FHitResult constructors and the first block of contact
// fields through TraceStart.
// AS-facing API: FHitResult Hit(AActor InActor, UPrimitiveComponent InComponent, const FVector& HitLoc, const FVector& HitNorm);
// FHitResult Hit(const FVector& TraceStart, const FVector& TraceEnd);
// int Hit.FaceIndex; uint8 Hit.ElementIndex; int Hit.Item; int Hit.MyItem;
// float32 Hit.PenetrationDepth; float32 Hit.Distance; float32 Hit.Time;
// FVector Hit.TraceStart;
// Inputs: AActor CDO, UBoxComponent CDO, HitLoc (1,2,3), HitNorm (0,0,1),
// TraceStart ZeroVector, TraceEnd (100,0,0), FaceIndex 3, ElementIndex 2,
// Item 7, MyItem 8, PenetrationDepth 1.5, Distance 50, Time 0.5.
// Expected observations: Actor/component constructor stores location and
// normal. Trace constructor stores start/end. Each field round-trips.
// Boundary/ownership: Constructors copy contact data. FaceIndex is the
// triangle index. Null actor/component is the diagnostic companion.

namespace TS_FHitResult_Behavior_01
{
	// FHitResult actor/component and trace-segment constructors.
	// Inputs: Actor CDO, Box CDO, HitLoc (1,2,3), HitNorm (0,0,1), start Zero, end (100,0,0).
	// Oracle: stored handles and vectors match. Null CDO is setup failure.
	bool Observe_Hit_Nominal()
	{
		AActor ActorCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		UBoxComponent BoxCdo = TSubclassOf<UBoxComponent>(UBoxComponent::StaticClass()).GetDefaultObject();
		if (ActorCdo is null)
		{
			throw("TS_FHitResult_Behavior_01 setup: required Actor CDO is null");
		}
		if (BoxCdo is null)
		{
			throw("TS_FHitResult_Behavior_01 setup: required UBoxComponent CDO is null");
		}
		FVector HitLoc(1.0, 2.0, 3.0);
		FVector HitNorm(0.0, 0.0, 1.0);
		FHitResult Contact(ActorCdo, BoxCdo, HitLoc, HitNorm);
		FVector TraceStart = FVector::ZeroVector;
		FVector TraceEnd(100.0, 0.0, 0.0);
		FHitResult Trace(TraceStart, TraceEnd);
		return Contact.GetActor() == ActorCdo && Contact.GetComponent() == BoxCdo && Contact.Location.Equals(HitLoc) && Contact.Normal.Equals(HitNorm) && Trace.TraceStart.Equals(TraceStart) && Trace.TraceEnd.Equals(TraceEnd);
	}

	// FHitResult.FaceIndex. Inputs: default trace hit, assign 3. Oracle: assigned value is 3 and differs from default.
	bool Observe_Surface003_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		int DefaultIndex = Hit.FaceIndex;
		Hit.FaceIndex = 3;
		int Assigned = Hit.FaceIndex;
		return Assigned == 3 && DefaultIndex != 3;
	}

	// FHitResult.ElementIndex. Inputs: default trace hit, assign 2. Oracle: assigned value is 2.
	bool Observe_Surface004_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.ElementIndex = 2;
		uint8 Assigned = Hit.ElementIndex;
		return Assigned == 2;
	}

	// FHitResult.Item. Inputs: default trace hit, assign 7. Oracle: assigned value is 7.
	bool Observe_Surface005_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.Item = 7;
		int Assigned = Hit.Item;
		return Assigned == 7;
	}

	// FHitResult.MyItem. Inputs: default trace hit, assign 8. Oracle: assigned value is 8.
	bool Observe_Surface006_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.MyItem = 8;
		int Assigned = Hit.MyItem;
		return Assigned == 8;
	}

	// FHitResult.PenetrationDepth. Inputs: default trace hit, assign 1.5. Oracle: assigned value is 1.5.
	bool Observe_Surface007_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.PenetrationDepth = 1.5;
		float32 Assigned = Hit.PenetrationDepth;
		return Assigned == 1.5;
	}

	// FHitResult.Distance. Inputs: default trace hit, assign 50. Oracle: assigned value is 50.
	bool Observe_Surface008_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.Distance = 50.0;
		float32 Assigned = Hit.Distance;
		return Assigned == 50.0;
	}

	// FHitResult.Time. Inputs: default trace hit, assign 0.5. Oracle: assigned value is 0.5.
	bool Observe_Surface009_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		Hit.Time = 0.5;
		float32 Assigned = Hit.Time;
		return Assigned == 0.5;
	}

	// FHitResult.TraceStart. Inputs: constructor start ZeroVector, assign (5,6,7).
	// Oracle: default equals ZeroVector, assigned equals (5,6,7).
	bool Observe_Surface010_Nominal()
	{
		FHitResult Hit(FVector::ZeroVector, FVector(100.0, 0.0, 0.0));
		FVector DefaultStart = Hit.TraceStart;
		Hit.TraceStart = FVector(5.0, 6.0, 7.0);
		FVector Assigned = Hit.TraceStart;
		return DefaultStart.Equals(FVector::ZeroVector) && Assigned.Equals(FVector(5.0, 6.0, 7.0));
	}

	void ExerciseExpectedFailure()
	{
		AActor NullActor;
		UPrimitiveComponent NullComponent;
		FHitResult Hit(NullActor, NullComponent, FVector::ZeroVector, FVector(0.0, 0.0, 1.0));
	}
}
