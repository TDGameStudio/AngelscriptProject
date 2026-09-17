/**
 * @version v1
 * @summary Observe FVector3f direction/length split and orientation conversion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f direction/length split and orientation conversion.
 * @topic Baseline
 */
// ToOrientationRotator; ToOrientationQuat.
// Inputs: (3,4,0) so length is 5, zero vector, ForwardVector, UpVector.
// Expected observations: Direction of (3,4,0) is (0.6,0.8,0) and length is
// 5. Zero writes zero direction and length 0. Forward orientation rotator
// is identity. Up rotator pitch is 90. Forward quat W is 1.
// Boundary/ownership: OutDir/OutLength are writebacks. Orientation helpers
// return FRotator3f / FQuat4f.

namespace TS_FVector3f_ConversionAndFormatting_01
{
	bool Observe_ToDirectionAndLength_Nominal()
	{
		FVector3f Dir;
		float32 Length = -1.0f;
		FVector3f(3.0f, 4.0f, 0.0f).ToDirectionAndLength(Dir, Length);
		FVector3f ZeroDir = FVector3f::OneVector;
		float32 ZeroLength = -1.0f;
		FVector3f::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
		return Dir.Equals(FVector3f(0.6f, 0.8f, 0.0f)) && Length == 5.0f && ZeroDir.IsZero() && ZeroLength == 0.0f;
	}

	bool Observe_ToOrientationRotator_Nominal()
	{
		FRotator3f Forward = FVector3f::ForwardVector.ToOrientationRotator();
		FRotator3f Up = FVector3f::UpVector.ToOrientationRotator();
		return Forward.Pitch == 0.0f && Forward.Yaw == 0.0f && Up.Pitch == 90.0f;
	}

	bool Observe_ToOrientationQuat_Nominal()
	{
		FQuat4f Forward = FVector3f::ForwardVector.ToOrientationQuat();
		FQuat4f Up = FVector3f::UpVector.ToOrientationQuat();
		return Forward.W == 1.0f && Forward.X == 0.0f && Up.W != 1.0f;
	}
}
/** @end */
