/**
 * @version v1
 * @summary Observe FRotator3f::ZeroRotator, axis wrap helpers, and Euler construction.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRotator3f::ZeroRotator, axis wrap helpers, and Euler construction.
 * @topic Baseline
 */
// float32 FRotator3f::NormalizeAxis(float32 Angle);
// float32 FRotator3f::ClampAxis(float32 Angle);
// FRotator3f FRotator3f::MakeFromEuler(const FVector3f& Euler);
// Inputs: 270, -270, -90, 370, 0, and Euler (30,10,20) as Roll/Pitch/Yaw.
// Expected observations: ZeroRotator is zero. NormalizeAxis(270) is -90.
// ClampAxis(-90) is 270. MakeFromEuler stores Pitch 10, Yaw 20, Roll 30.
// Boundary/ownership: NormalizeAxis uses the signed axis range. ClampAxis uses
// [0, 360). MakeFromEuler returns a new rotator.

namespace TS_FRotator3f_NamespaceAndGlobalFunctions_01
{
	// FRotator3f::ZeroRotator. No extra inputs. Pitch/Yaw/Roll are 0 and
	// IsZero is true. Shared constant; not owned by the caller.
	bool Observe_Surface027_Nominal()
	{
		FRotator3f Zero = FRotator3f::ZeroRotator;
		return Zero.IsZero() && Zero.Pitch == 0.0 && Zero.Yaw == 0.0 && Zero.Roll == 0.0;
	}

	// FRotator3f::NormalizeAxis. Inputs 270, -270, and 0. Results are -90, 90,
	// and 0. Pure helper; no rotator ownership.
	bool Observe_NormalizeAxis_Nominal()
	{
		float32 Wrapped = FRotator3f::NormalizeAxis(270.0);
		float32 Negative = FRotator3f::NormalizeAxis(-270.0);
		float32 Unchanged = FRotator3f::NormalizeAxis(0.0);
		return Wrapped == -90.0 && Negative == 90.0 && Unchanged == 0.0;
	}

	// FRotator3f::ClampAxis. Inputs -90, 370, and 0. Results are 270, 10, and 0
	// in [0, 360). Pure helper; no rotator ownership.
	bool Observe_ClampAxis_Nominal()
	{
		float32 FromNegative = FRotator3f::ClampAxis(-90.0);
		float32 FromOver = FRotator3f::ClampAxis(370.0);
		float32 Unchanged = FRotator3f::ClampAxis(0.0);
		return FromNegative == 270.0 && FromOver == 10.0 && Unchanged == 0.0;
	}

	// FRotator3f::MakeFromEuler. Input FVector3f(30,10,20) as Roll/Pitch/Yaw.
	// Pitch 10, Yaw 20, Roll 30. Returns a new rotator.
	bool Observe_MakeFromEuler_Nominal()
	{
		FRotator3f FromEuler = FRotator3f::MakeFromEuler(FVector3f(30.0, 10.0, 20.0));
		return FromEuler.Pitch == 10.0 && FromEuler.Yaw == 20.0 && FromEuler.Roll == 30.0;
	}
}
/** @end */
