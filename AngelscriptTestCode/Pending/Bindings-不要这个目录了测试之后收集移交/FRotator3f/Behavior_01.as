/**
 * @version v1
 * @summary Observe FRotator3f constructors, Pitch/Yaw/Roll, Clamp, Normalize, and the forward vector.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRotator3f constructors, Pitch/Yaw/Roll, Clamp, Normalize, and the forward vector.
 * @topic Baseline
 */
// FRotator3f(Other); Pitch; Yaw; Roll; Clamp(); Normalize(); Vector().
// Inputs: (10,20,30), default, scalar 7, copy, 370 yaw, 270 yaw, ZeroRotator,
// and yaw 90.
// Expected observations: Component ctor stores Pitch,Yaw,Roll. Default is
// zero. Scalar fills all axes. Copy is independent. Clamp of 370 is 10.
// Normalize writes -90. Zero Vector is ForwardVector.
// Boundary/ownership: Constructors are Pitch,Yaw,Roll. Clamp returns a new
// rotator. Normalize mutates in place.

namespace TS_FRotator3f_Behavior_01
{
	// FRotator3f component/default/scalar/copy constructors. Inputs (10,20,30),
	// default, 7, and a mutated source. Copy stays (10,20,30); default is zero;
	// scalar fills axes. Constructors return values; copy is independent.
	bool Observe_Rotator_Nominal()
	{
		FRotator3f Components(10.0, 20.0, 30.0);
		FRotator3f DefaultRotator;
		FRotator3f Scalar(7.0);
		FRotator3f Copied(Components);
		Components.Pitch = 0.0;
		return Copied.Pitch == 10.0 && Copied.Yaw == 20.0 && Copied.Roll == 30.0 && DefaultRotator.IsZero() && Scalar.Pitch == 7.0 && Scalar.Yaw == 7.0 && Scalar.Roll == 7.0;
	}

	// FRotator3f.Pitch. Input (10,20,30). Pitch is 10. Field read; no mutation.
	bool Observe_Surface005_Nominal()
	{
		return FRotator3f(10.0, 20.0, 30.0).Pitch == 10.0;
	}

	// FRotator3f.Yaw. Input (10,20,30). Yaw is 20. Field read; no mutation.
	bool Observe_Surface006_Nominal()
	{
		return FRotator3f(10.0, 20.0, 30.0).Yaw == 20.0;
	}

	// FRotator3f.Roll. Input (10,20,30). Roll is 30. Field read; no mutation.
	bool Observe_Surface007_Nominal()
	{
		return FRotator3f(10.0, 20.0, 30.0).Roll == 30.0;
	}

	// FRotator3f.Clamp(). Input yaw 370. Clamped yaw is 10; source stays 370.
	// Returns a new rotator in [0, 360).
	bool Observe_Clamp_Nominal()
	{
		FRotator3f Over(0.0, 370.0, 0.0);
		FRotator3f Clamped = Over.Clamp();
		return Clamped.Yaw == 10.0 && Over.Yaw == 370.0;
	}

	// FRotator3f.Normalize(). Input yaw 270. In-place yaw becomes -90.
	// Mutates the receiver.
	bool Observe_Normalize_Nominal()
	{
		FRotator3f Over(0.0, 270.0, 0.0);
		Over.Normalize();
		return Over.Yaw == -90.0;
	}

	// FRotator3f.Vector(). Inputs ZeroRotator and yaw 90. Zero forward is
	// ForwardVector; yaw 90 is RightVector. Returns a new unit vector.
	bool Observe_Vector_Nominal()
	{
		FVector3f ZeroForward = FRotator3f::ZeroRotator.Vector();
		FVector3f Yaw90Forward = FRotator3f(0.0, 90.0, 0.0).Vector();
		return ZeroForward.Equals(FVector3f::ForwardVector) && Yaw90Forward.Equals(FVector3f::RightVector);
	}
}
/** @end */
