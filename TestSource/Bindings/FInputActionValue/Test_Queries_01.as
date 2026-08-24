// Purpose: Observe FInputActionValue zero checks, digital/axis getters, and
// the key-implied value type.
// AS-facing API: bool FInputActionValue.IsNonZero(float32 Tolerance =
// KINDA_SMALL_NUMBER) const;
// bool FInputActionValue.Get() const;
// float32 FInputActionValue.GetAxis1D() const;
// FVector2D FInputActionValue.GetAxis2D() const;
// FVector FInputActionValue.GetAxis3D() const;
// EInputActionValueType FInputActionValue::GetValueTypeFromKey(FKey Key);
// Inputs: Default zero value, 1.0 / (3,4) / (1,2,3) constructors, a value
// below KINDA_SMALL_NUMBER, FKey from n"SpaceBar" and n"MouseX", and a
// default FKey.
// Expected observations: Default IsNonZero is false. Non-zero 1D Get is true.
// Axis getters return the constructed components. SpaceBar implies Boolean.
// Empty keys still return a value type.
// Boundary/ownership: Getters do not mutate the value. GetValueTypeFromKey
// borrows the key.

namespace TS_FInputActionValue_Queries_01
{
	bool Observe_IsNonZero_Nominal()
	{
		FInputActionValue Empty;
		FInputActionValue One(1.0);
		FInputActionValue Tiny(KINDA_SMALL_NUMBER * 0.5);
		return !Empty.IsNonZero() &&
			One.IsNonZero() &&
			One.IsNonZero(KINDA_SMALL_NUMBER) &&
			!Tiny.IsNonZero() &&
			Tiny.IsNonZero(0.0);
	}

	bool Observe_Get_Nominal()
	{
		FInputActionValue Empty;
		FInputActionValue One(1.0);
		FInputActionValue Zero(0.0);
		return !Empty.Get() && One.Get() && !Zero.Get();
	}

	bool Observe_GetAxis1D_Nominal()
	{
		FInputActionValue Empty;
		FInputActionValue One(5.0);
		return Empty.GetAxis1D() == 0.0 && One.GetAxis1D() > 4.9 && One.GetAxis1D() < 5.1;
	}

	bool Observe_GetAxis2D_Nominal()
	{
		FInputActionValue Empty;
		FVector2D EmptyAxis = Empty.GetAxis2D();
		FInputActionValue Value(FVector2D(3.0, 4.0));
		FVector2D Axis = Value.GetAxis2D();
		return EmptyAxis.X == 0.0 &&
			EmptyAxis.Y == 0.0 &&
			Axis.X > 2.9 &&
			Axis.X < 3.1 &&
			Axis.Y > 3.9 &&
			Axis.Y < 4.1;
	}

	bool Observe_GetAxis3D_Nominal()
	{
		FInputActionValue Empty;
		FVector EmptyAxis = Empty.GetAxis3D();
		FInputActionValue Value(FVector(1.0, 2.0, 3.0));
		FVector Axis = Value.GetAxis3D();
		return EmptyAxis.X == 0.0 &&
			EmptyAxis.Y == 0.0 &&
			EmptyAxis.Z == 0.0 &&
			Axis.X > 0.9 &&
			Axis.X < 1.1 &&
			Axis.Y > 1.9 &&
			Axis.Y < 2.1 &&
			Axis.Z > 2.9 &&
			Axis.Z < 3.1;
	}

	bool Observe_GetValueTypeFromKey_Nominal()
	{
		FKey EmptyKey;
		FKey SpaceBar = n"SpaceBar";
		FKey MouseX = n"MouseX";
		EInputActionValueType EmptyType = FInputActionValue::GetValueTypeFromKey(EmptyKey);
		EInputActionValueType SpaceType = FInputActionValue::GetValueTypeFromKey(SpaceBar);
		EInputActionValueType MouseType = FInputActionValue::GetValueTypeFromKey(MouseX);
		return SpaceType == EInputActionValueType::Boolean &&
			MouseType == EInputActionValueType::Axis1D &&
			EmptyType == EInputActionValueType::Boolean;
	}
}
