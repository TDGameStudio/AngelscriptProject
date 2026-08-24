// Purpose: Observe FVector direction/length split, orientation conversion,
// and ToString.
// AS-facing API: ToDirectionAndLength(FVector&, float64&);
// ToDirectionAndLength(FVector&, float32&); ToOrientationRotator;
// ToOrientationQuat; ToString.
// Inputs: (3,4,0) so length is 5, zero vector, ForwardVector, UpVector.
// Expected observations: Direction of (3,4,0) is (0.6,0.8,0) for both
// overloads. Zero writes zero direction and length 0. Forward orientation
// rotator is identity. Up rotator pitch is 90. Forward quat W is 1. ToString
// is non-empty.
// Boundary/ownership: OutDir/OutLength are writebacks. Orientation helpers
// return new rotator/quat values. ToString returns a new FString.

namespace TS_FVector_ConversionAndFormatting_01
{
	bool Observe_ToDirectionAndLength_Nominal()
	{
		FVector Dir;
		float64 Length64 = -1.0;
		FVector(3, 4, 0).ToDirectionAndLength(Dir, Length64);
		FVector Dir32;
		float32 Length32 = -1.0f;
		FVector(3, 4, 0).ToDirectionAndLength(Dir32, Length32);
		FVector ZeroDir = FVector::OneVector;
		float64 ZeroLength = -1.0;
		FVector::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
		return Dir.Equals(FVector(0.6, 0.8, 0)) &&
			Length64 == 5.0 &&
			Dir32.Equals(FVector(0.6, 0.8, 0)) &&
			Length32 == 5.0f &&
			ZeroDir.IsZero() &&
			ZeroLength == 0.0;
	}

	bool Observe_ToOrientationRotator_Nominal()
	{
		FRotator Forward = FVector::ForwardVector.ToOrientationRotator();
		FRotator Up = FVector::UpVector.ToOrientationRotator();
		return Forward.Pitch == 0.0 && Forward.Yaw == 0.0 && Up.Pitch == 90.0;
	}

	bool Observe_ToOrientationQuat_Nominal()
	{
		FQuat Forward = FVector::ForwardVector.ToOrientationQuat();
		FQuat Up = FVector::UpVector.ToOrientationQuat();
		return Forward.W == 1.0 && Forward.X == 0.0 && Up.W != 0.0;
	}

	bool Observe_ToString_Nominal()
	{
		FVector Vector(1, 2, 3);
		FString Text = Vector.ToString();
		FString ZeroText = FVector::ZeroVector.ToString();
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1.0;
	}
}
