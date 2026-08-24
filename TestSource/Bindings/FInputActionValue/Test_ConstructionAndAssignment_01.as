// Purpose: Observe in-place add and scale of FInputActionValue, including
// the returned alias from the compound operators.
// AS-facing API: Value += Other; Value *= Scalar;
// Inputs: Default zero value, explicit 1.0 and 2.0 axis values, scalar 2.0
// then 0.5, and a copied source that must remain independent.
// Expected observations: += adds axis values in place. *= scales in place.
// The returned reference aliases this value. A copied source is unchanged.
// Boundary/ownership: Compound operators mutate the receiver and return an
// alias to it. Other is borrowed.

namespace TS_FInputActionValue_ConstructionAndAssignment_01
{
	bool Observe_AddAssign_Nominal()
	{
		FInputActionValue Value(1.0);
		FInputActionValue Other(2.0);
		FInputActionValue Copied = Other;
		Value += Other;
		float32 AfterAdd = Value.GetAxis1D();
		FInputActionValue& Alias = Value.opAddAssign(Other);
		float32 AfterAlias = Value.GetAxis1D();
		FInputActionValue Empty;
		Empty += Value;
		return AfterAdd > 2.9 && AfterAdd < 3.1 &&
			Alias.GetAxis1D() == AfterAlias &&
			Copied.GetAxis1D() > 1.9 && Copied.GetAxis1D() < 2.1 &&
			Empty.IsNonZero();
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FInputActionValue Value(2.0);
		FInputActionValue Copied = Value;
		Value *= 2.0;
		float32 AfterScale = Value.GetAxis1D();
		FInputActionValue& Alias = Value.opMulAssign(0.5);
		float32 AfterAlias = Value.GetAxis1D();
		Value *= 0.0;
		return AfterScale > 3.9 && AfterScale < 4.1 &&
			Alias.GetAxis1D() == AfterAlias && AfterAlias > 1.9 && AfterAlias < 2.1 &&
			Copied.GetAxis1D() > 1.9 && Copied.GetAxis1D() < 2.1 &&
			!Value.IsNonZero();
	}
}
