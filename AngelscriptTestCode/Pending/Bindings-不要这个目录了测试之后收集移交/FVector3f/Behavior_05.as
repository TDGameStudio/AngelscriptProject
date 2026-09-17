/**
 * @version v1
 * @summary Observe FVector3f remaining distance aliases, Rotation, InitFromString, and FVector conversion construction.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f remaining distance aliases, Rotation, InitFromString, and FVector conversion construction.
 * @topic Baseline
 */
// FVector3f Vector(const FVector& Other).
// Inputs: (0,0,0) to (3,4,12), ForwardVector, UE text "X=1 Y=2 Z=3", empty
// text, FVector(4,5,6).
// Expected observations: DistSquaredXY and DistSquared2D are 25. Forward
// Rotation pitch/yaw are 0. InitFromString true parses (1,2,3); empty
// returns false. FVector conversion keeps 4/5/6.
// Boundary/ownership: DistSquared2D aliases DistSquaredXY. InitFromString
// mutates. FVector conversion copies components into float32.

namespace TS_FVector3f_Behavior_05
{
	bool Observe_DistSquaredXY_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).DistSquaredXY(FVector3f(3.0f, 4.0f, 12.0f)) == 25.0f;
	}

	bool Observe_DistSquared2D_Nominal()
	{
		return FVector3f(0.0f, 0.0f, 0.0f).DistSquared2D(FVector3f(3.0f, 4.0f, 12.0f)) == 25.0f;
	}

	bool Observe_Rotation_Nominal()
	{
		FRotator3f Forward = FVector3f::ForwardVector.Rotation();
		FRotator3f Up = FVector3f::UpVector.Rotation();
		return Forward.Pitch == 0.0f && Forward.Yaw == 0.0f && Up.Pitch == 90.0f;
	}

	bool Observe_InitFromString_Nominal()
	{
		FVector3f Parsed;
		bool bValid = Parsed.InitFromString("X=1 Y=2 Z=3");
		FVector3f EmptyTarget(9.0f, 9.0f, 9.0f);
		bool bEmpty = EmptyTarget.InitFromString("");
		return bValid && Parsed.Equals(FVector3f(1.0f, 2.0f, 3.0f)) && !bEmpty;
	}

	bool Observe_Vector_Nominal()
	{
		FVector3f FromDouble(FVector(4, 5, 6));
		return FromDouble.X == 4.0f && FromDouble.Y == 5.0f && FromDouble.Z == 6.0f;
	}
}
/** @end */
