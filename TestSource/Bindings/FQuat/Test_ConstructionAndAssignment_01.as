// Purpose: Observe FQuat assignment plus add/subtract/multiply compound and
// value-returning arithmetic, including scalar divide.
// AS-facing API: Left = Right; FQuat Result = Quat + Other; FQuat Result =
// Quat - Other; Quat += Other; Quat -= Other; FQuat Result = Quat * Other;
// Quat *= Other; FQuat Result = Quat * Scale; Quat *= Scale;
// FQuat Result = Quat / Scale;
// Inputs: Identity, a copy of (0,0,0,2), Other Identity, Scale 2.0, and a
// saved original for independence.
// Expected observations: Assignment copies W. Identity + Identity has W=2.
// += mutates in place. Identity * Identity remains identity. * 2 doubles W.
// / 2 restores W=1. The saved original stays identity.
// Boundary/ownership: Compound operators mutate Quat. Value-returning
// operators return a new quaternion.

namespace TS_FQuat_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FQuat Left = FQuat::Identity;
		FQuat Right(0.0, 0.0, 0.0, 2.0);
		FQuat Original = Left;
		Left = Right;
		FQuat Sum = FQuat::Identity + FQuat::Identity;
		return Left.W == 2.0 && Original.W == 1.0 && Sum.W == 2.0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FQuat Quat = FQuat::Identity;
		Quat += FQuat::Identity;
		return Quat.W == 2.0 && FQuat::Identity.W == 1.0;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FQuat Quat(0.0, 0.0, 0.0, 2.0);
		FQuat Difference = Quat - FQuat::Identity;
		Quat -= FQuat::Identity;
		return Difference.W == 1.0 && Quat.W == 1.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FQuat Product = FQuat::Identity * FQuat::Identity;
		FQuat Composed = FQuat::Identity;
		Composed *= FQuat::Identity;
		FQuat Scaled = FQuat::Identity * 2.0;
		FQuat ScaledInPlace = FQuat::Identity;
		ScaledInPlace *= 2.0;
		FQuat Divided = Scaled / 2.0;
		return Product.W == 1.0 && Composed.W == 1.0 && Scaled.W == 2.0 && ScaledInPlace.W == 2.0 && Divided.W == 1.0;
	}
}
