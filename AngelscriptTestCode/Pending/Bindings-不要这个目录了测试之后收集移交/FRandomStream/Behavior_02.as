/**
 * @version v1
 * @summary Observe FRandomStream cone sampling, both symmetric and elliptical.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRandomStream cone sampling, both symmetric and elliptical.
 * @topic Baseline
 */
// FVector FRandomStream.VRandCone(const FVector& Dir, float32 HorizontalConeHalfAngleRad, float32 VerticalConeHalfAngleRad) const;
// Inputs: Seed 123, Dir = UpVector, symmetric half-angle 0 and 0.1, elliptical
// 0.1/0.2, and a same-seed twin for determinism.
// Expected observations: Zero half-angle stays near +Z. A small cone still
// has positive Z. Same seeds match the first sample. Size is near 1.
// Boundary/ownership: Half-angles are radians. Samples are new vectors; the
// stream current seed advances.

namespace TS_FRandomStream_Behavior_02
{
	bool Observe_VRandCone_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		FVector ZeroCone = Stream.VRandCone(FVector::UpVector, 0.0);
		FVector TwinZero = Twin.VRandCone(FVector::UpVector, 0.0);
		FVector SmallCone = Stream.VRandCone(FVector::UpVector, 0.1);
		FVector Ellipse = Stream.VRandCone(FVector::UpVector, 0.1, 0.2);
		return ZeroCone.Z > 0.9 && ZeroCone.Size() > 0.9 && TwinZero.Z == ZeroCone.Z && SmallCone.Z > 0.0 && Ellipse.Size() > 0.9 && Ellipse.Size() < 1.1;
	}
}
/** @end */
