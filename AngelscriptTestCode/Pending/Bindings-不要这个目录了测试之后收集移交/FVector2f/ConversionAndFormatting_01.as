/**
 * @version v1
 * @summary Observe FVector2f.ToDirectionAndLength for nonzero and zero vectors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f.ToDirectionAndLength for nonzero and zero vectors.
 * @topic Baseline
 */
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
/** @end */
