// Purpose: Observe FVector2f.ToDirectionAndLength for nonzero and zero
// vectors.
// AS-facing API: void FVector2f.ToDirectionAndLength(FVector2f& OutDir, float32& OutLength) const;
// Inputs: (3,4) so length is 5, and zero.
// Expected observations: Direction of (3,4) is (0.6,0.8) and length is 5.
// Zero writes a zero direction and length 0. The source vector is unchanged.
// Boundary/ownership: OutDir/OutLength are writebacks. Zero-length vectors
// produce a zero direction rather than an exception.

namespace TS_FVector2f_ConversionAndFormatting_01
{
	bool Observe_ToDirectionAndLength_Nominal()
	{
		FVector2f Source(3.0f, 4.0f);
		FVector2f Dir;
		float32 Length = -1.0f;
		Source.ToDirectionAndLength(Dir, Length);
		FVector2f ZeroDir = FVector2f::UnitVector;
		float32 ZeroLength = -1.0f;
		FVector2f::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
		return Dir.Equals(FVector2f(0.6f, 0.8f)) && Length == 5.0f && ZeroDir.IsZero() && ZeroLength == 0.0f && Source.X == 3.0f;
	}
}
