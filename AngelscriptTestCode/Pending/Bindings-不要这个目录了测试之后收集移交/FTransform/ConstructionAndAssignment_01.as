/**
 * @version v1
 * @summary Observe FTransform assignment, composition with another transform or quaternion, in-place multiply, and formatter interpolation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTransform assignment, composition with another transform or quaternion, in-place multiply, and formatter interpolation.
 * @topic Baseline
 */
// Result = Transform * OtherQuat; Transform *= OtherTransform;
// Transform *= OtherQuat; FString Text = f"{Transform}";
// Inputs: Translation (1,0,0) and (2,0,0), Identity, yaw-90 quat, and a copied
// original.
// Expected observations: Assignment copies translation. Two translations
// compose to X=3. Identity * yaw-90 has yaw 90. *= mutates. f"{Transform}" is
// non-empty. Original copy stays X=1.
// Boundary/ownership: * returns a new transform. *= mutates the left operand.

namespace TS_FTransform_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FTransform Left;
		FTransform Right(FVector(1.0, 0.0, 0.0));
		FTransform Original = Right;
		Left = Right;
		FTransform Combined = Left * FTransform(FVector(2.0, 0.0, 0.0));
		FQuat Yaw90 = FQuat(FRotator(0.0, 90.0, 0.0));
		FTransform Rotated = FTransform::Identity * Yaw90;
		Right.SetTranslation(FVector(9.0, 0.0, 0.0));
		FString Text = f"{Left}";
		return Left.GetTranslation().X == 1.0 &&
			Combined.GetTranslation().X == 3.0 &&
			Rotated.Rotator().Equals(FRotator(0.0, 90.0, 0.0)) &&
			Original.GetTranslation().X == 1.0 &&
			Text.Len() > 0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FTransform Transform(FVector(1.0, 0.0, 0.0));
		Transform *= FTransform(FVector(2.0, 0.0, 0.0));
		FTransform Rotated = FTransform::Identity;
		Rotated *= FQuat(FRotator(0.0, 90.0, 0.0));
		return Transform.GetTranslation().X == 3.0 && Rotated.Rotator().Equals(FRotator(0.0, 90.0, 0.0));
	}
}
/** @end */
