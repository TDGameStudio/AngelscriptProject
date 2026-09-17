/**
 * @version v1
 * @summary Observe FQuat4f type declaration, constructors, and XYZ fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FQuat4f type declaration, constructors, and XYZ fields.
 * @topic Baseline
 */
// FQuat4f Value(float32 X, float32 Y, float32 Z, float32 W);
// FQuat4f Value(const FRotator3f& R); FQuat4f Value(FVector3f Axis, float32 AngleRad);
// FQuat4f Value(const FQuat& Quat); float32 FQuat4f.X; float32 FQuat4f.Y;
// float32 FQuat4f.Z;
// Inputs: Default identity, copy, components (0,0,0,1) and (0.1,0.2,0.3,0.9),
// Rotator3f (0,90,0), UpVector with HALF_PI, and FQuat::Identity.
// Expected observations: Default/copy/components store W=1. Rotator and
// axis-angle yaw turn Forward toward +Y. FQuat conversion keeps W=1. X/Y/Z
// fields match the constructed components.
// Boundary/ownership: Default construction is identity (0,0,0,1), not
// uninitialized. Constructors copy values.

namespace TS_FQuat4f_Behavior_01
{
	// Default FQuat4f is identity (0,0,0,1). Oracle: exact components. Value construction.
	bool Observe_Surface001_Nominal()
	{
		FQuat4f Value;
		return Value.X == 0.0 && Value.Y == 0.0 && Value.Z == 0.0 && Value.W == 1.0;
	}

	// Default, copy, components, rotator, axis-angle, and FQuat conversion constructors. Oracle: W=1 and yaw Forward.Y > 0.9.
	bool Observe_Value_Nominal()
	{
		FQuat4f DefaultValue;
		FQuat4f Copied(DefaultValue);
		FQuat4f Components(0.0, 0.0, 0.0, 1.0);
		FQuat4f FromRotator(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f FromAxis(FVector3f::UpVector, HALF_PI);
		FQuat4f FromDouble(FQuat::Identity);
		return DefaultValue.W == 1.0 && Copied.W == 1.0 && Components.W == 1.0 && FromRotator.RotateVector(FVector3f::ForwardVector).Y > 0.9 && FromAxis.RotateVector(FVector3f::ForwardVector).Y > 0.9 && FromDouble.W == 1.0;
	}

	// FQuat4f.X stores the constructed X of (0.1, 0.2, 0.3, 0.9). Oracle: X == 0.1. Value copy.
	bool Observe_Surface008_Nominal()
	{
		return FQuat4f(0.1, 0.2, 0.3, 0.9).X == 0.1;
	}

	// FQuat4f.Y stores the constructed Y of (0.1, 0.2, 0.3, 0.9). Oracle: Y == 0.2. Value copy.
	bool Observe_Surface009_Nominal()
	{
		return FQuat4f(0.1, 0.2, 0.3, 0.9).Y == 0.2;
	}

	// FQuat4f.Z stores the constructed Z of (0.1, 0.2, 0.3, 0.9). Oracle: Z == 0.3. Value copy.
	bool Observe_Surface010_Nominal()
	{
		return FQuat4f(0.1, 0.2, 0.3, 0.9).Z == 0.3;
	}
}
/** @end */
