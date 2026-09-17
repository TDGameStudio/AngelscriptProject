/**
 * @version v1
 * @summary Observe FVector remaining distance aliases, Rotation, and InitFromString success/failure.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector remaining distance aliases, Rotation, and InitFromString success/failure.
 * @topic Baseline
 */
// Rotation; InitFromString.
// Inputs: (0,0,0) to (3,4,12), identical points, ForwardVector, UE text
// "X=1 Y=2 Z=3", empty text.
// Expected observations: DistSquared is 169. Dist2D and DistXY are 5.
// DistSquaredXY and DistSquared2D are 25. Forward Rotation pitch/yaw are 0.
// InitFromString true parses (1,2,3); empty returns false.
// Boundary/ownership: DistXY aliases Dist2D. DistSquared2D aliases
// DistSquaredXY. InitFromString mutates the receiver. Rotation returns a
// new FRotator.

namespace TS_FVector_Behavior_05
{
	bool Observe_DistSquared_Nominal()
	{
		return FVector(0, 0, 0).DistSquared(FVector(3, 4, 12)) == 169.0 && FVector(1, 1, 1).DistSquared(FVector(1, 1, 1)) == 0.0;
	}

	bool Observe_Dist2D_Nominal()
	{
		return FVector(0, 0, 0).Dist2D(FVector(3, 4, 12)) == 5.0 && FVector(0, 0, 9).Dist2D(FVector(0, 0, 1)) == 0.0;
	}

	bool Observe_DistXY_Nominal()
	{
		return FVector(0, 0, 0).DistXY(FVector(3, 4, 12)) == 5.0;
	}

	bool Observe_DistSquaredXY_Nominal()
	{
		return FVector(0, 0, 0).DistSquaredXY(FVector(3, 4, 12)) == 25.0;
	}

	bool Observe_DistSquared2D_Nominal()
	{
		return FVector(0, 0, 0).DistSquared2D(FVector(3, 4, 12)) == 25.0;
	}

	bool Observe_Rotation_Nominal()
	{
		FRotator Forward = FVector::ForwardVector.Rotation();
		FRotator Up = FVector::UpVector.Rotation();
		return Forward.Pitch == 0.0 && Forward.Yaw == 0.0 && Up.Pitch == 90.0;
	}

	bool Observe_InitFromString_Nominal()
	{
		FVector Parsed;
		bool bValid = Parsed.InitFromString("X=1 Y=2 Z=3");
		FVector EmptyTarget(9, 9, 9);
		bool bEmpty = EmptyTarget.InitFromString("");
		return bValid && Parsed.Equals(FVector(1, 2, 3)) && !bEmpty;
	}
}
/** @end */
