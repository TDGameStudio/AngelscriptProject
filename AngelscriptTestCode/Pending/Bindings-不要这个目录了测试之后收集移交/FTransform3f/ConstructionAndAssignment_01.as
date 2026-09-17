/**
 * @version v1
 * @summary Observe FTransform3f assignment and composition with another transform or quaternion, including in-place multiply.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform3f assignment and composition with another transform or quaternion, including in-place multiply.
 * @topic Baseline
 */
// Result = Transform * OtherRotation; Transform *= OtherTransform;
// Transform *= OtherRotation.
// Inputs: Translation (1,0,0) and (2,0,0), Identity, yaw-90 quat, and a copied
// original.
// Expected observations: Assignment copies translation. Two translations
// compose to X=3. Identity * yaw-90 has yaw 90. *= mutates. Original copy
// stays X=1.
// Boundary/ownership: * returns a new transform. *= mutates the left operand.

namespace TS_FTransform3f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FTransform3f Transform;
		FTransform3f Other(FVector3f(1.0, 0.0, 0.0));
		FTransform3f Original = Other;
		Transform = Other;
		FTransform3f Combined = Transform * FTransform3f(FVector3f(2.0, 0.0, 0.0));
		FQuat4f Yaw90 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FTransform3f Rotated = FTransform3f::Identity * Yaw90;
		Other.SetTranslation(FVector3f(9.0, 0.0, 0.0));
		return Transform.GetTranslation().X == 1.0 &&
			Combined.GetTranslation().X == 3.0 &&
			Rotated.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0)) &&
			Original.GetTranslation().X == 1.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FTransform3f Transform(FVector3f(1.0, 0.0, 0.0));
		Transform *= FTransform3f(FVector3f(2.0, 0.0, 0.0));
		FTransform3f Rotated = FTransform3f::Identity;
		Rotated *= FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		return Transform.GetTranslation().X == 3.0 && Rotated.Rotator().Equals(FRotator3f(0.0, 90.0, 0.0));
	}
}
/** @end */
