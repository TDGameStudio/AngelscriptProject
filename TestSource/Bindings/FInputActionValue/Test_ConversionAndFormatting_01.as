// Purpose: Observe in-place ConvertToType by enum and by another value,
// proving the returned reference aliases the receiver.
// AS-facing API: FInputActionValue& FInputActionValue.ConvertToType(
// EInputActionValueType Type);
// FInputActionValue& FInputActionValue.ConvertToType(const FInputActionValue& Other);
// Inputs: FVector(7,8,9) as the non-empty source, a default zero value, Axis1D
// and Axis2D target types, and another 2D value as the type donor.
// Expected observations: ConvertToType(Axis1D) keeps X as the 1D axis.
// ConvertToType(Other) adopts Other's type. Follow-up *= through the returned
// reference mutates the original value.
// Boundary/ownership: ConvertToType mutates this value and returns an alias.
// Other is borrowed as a type source.

namespace TS_FInputActionValue_ConversionAndFormatting_01
{
	bool Observe_ConvertToType_Nominal()
	{
		FInputActionValue Value(FVector(7.0, 8.0, 9.0));
		FInputActionValue& Converted1D = Value.ConvertToType(EInputActionValueType::Axis1D);
		float32 Axis1 = Converted1D.GetAxis1D();
		Converted1D *= 2.0;

		FInputActionValue Empty;
		FInputActionValue& ConvertedEmpty = Empty.ConvertToType(EInputActionValueType::Axis2D);
		FVector2D EmptyAxis = ConvertedEmpty.GetAxis2D();

		FInputActionValue Donor(FVector2D(1.0, 2.0));
		FInputActionValue& ConvertedFromOther = Value.ConvertToType(Donor);
		FVector2D FromOther = ConvertedFromOther.GetAxis2D();
		return Axis1 > 6.9 && Axis1 < 7.1 &&
			Value.GetAxis1D() == Converted1D.GetAxis1D() &&
			EmptyAxis.X == 0.0 && EmptyAxis.Y == 0.0 &&
			FromOther.X == Value.GetAxis2D().X &&
			Donor.GetAxis2D().X > 0.9 && Donor.GetAxis2D().X < 1.1;
	}
}
