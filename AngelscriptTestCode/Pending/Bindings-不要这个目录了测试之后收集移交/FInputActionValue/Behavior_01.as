/**
 * @version v1
 * @summary Observe FInputActionValue constructors for 1D, 2D, 3D, and explicit value-type construction, plus the default empty value.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FInputActionValue constructors for 1D, 2D, 3D, and explicit value-type construction, plus the default empty value.
 * @topic Baseline
 */
// FInputActionValue Value(FVector2D InValue);
// FInputActionValue Value(FVector InValue);
// FInputActionValue Value(EInputActionValueType InValueType, FVector InValue);
// Inputs: 5.0, FVector2D(3,4), FVector(1,2,3), Boolean with (1,0,0), Axis3D
// with the same vector, and a default-constructed value.
// Expected observations: Each constructor stores the supplied components.
// Boolean typed construction reports Get true. Default construction is zero.
// Boundary/ownership: Constructors copy the supplied numbers into a new
// value. The source vectors remain independent.

namespace TS_FInputActionValue_Behavior_01
{
	bool Observe_Value_Nominal()
	{
		FInputActionValue Empty;
		FInputActionValue Axis1D(5.0);
		float32 One = Axis1D.GetAxis1D();

		FVector2D Source2D(3.0, 4.0);
		FInputActionValue Axis2D(Source2D);
		FVector2D Two = Axis2D.GetAxis2D();

		FVector Source3D(1.0, 2.0, 3.0);
		FInputActionValue Axis3D(Source3D);
		FVector Three = Axis3D.GetAxis3D();

		FInputActionValue BooleanValue(EInputActionValueType::Boolean, FVector(1.0, 0.0, 0.0));
		FInputActionValue TypedAxis(EInputActionValueType::Axis3D, FVector(1.0, 2.0, 3.0));
		FVector Typed = TypedAxis.GetAxis3D();
		return !Empty.IsNonZero() &&
			One > 4.9 && One < 5.1 &&
			Two.X > 2.9 && Two.X < 3.1 && Two.Y > 3.9 && Two.Y < 4.1 &&
			Source2D.X == 3.0 && Source2D.Y == 4.0 &&
			Three.X > 0.9 && Three.X < 1.1 && Three.Z > 2.9 && Three.Z < 3.1 &&
			Source3D.X == 1.0 && Source3D.Z == 3.0 &&
			BooleanValue.Get() &&
			Typed.Y > 1.9 && Typed.Y < 2.1;
	}
}
/** @end */
