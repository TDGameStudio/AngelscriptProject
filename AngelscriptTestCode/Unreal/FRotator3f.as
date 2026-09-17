/**
 * @version v1
 * @summary FRotator3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FRotator3f
 *
 * rotator
 * frotator3f-pitch
 * frotator3f-yaw
 * frotator3f-roll
 * clamp
 * normalize
 * vector
 * quaternion
 * euler
 * rotate-vector
 * unrotate-vector
 * FRotator3f-Behavior_02-rotator
 * init-from-string
 * assignment
 * add-assign
 * subtract-assign
 * multiply-assign
 * to-color-string
 * inputs-270-270-90
 * normalize-axis
 * clamp-axis
 * make-from-euler
 * equality
 * is-nearly-zero
 * is-zero
 * equals
 * get-inverse
 * get-normalized
 * get-denormalized
 * get-winding-and-remainder
 * get-manhattan-distance
 * contains-na-n
 */
/**
 * @begin rotator
 * @summary default, 7, and a mutated source.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary default, 7, and a mutated source.
 * @covers FRotator3f.rotator
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
 Copy stays (10,20,30); default is zero;
// scalar fills axes. Constructors return values; copy is independent.
bool ObserveRotatorNominal()
{
	FRotator3f Components(10.0, 20.0, 30.0);
	FRotator3f DefaultRotator;
	FRotator3f Scalar(7.0);
	FRotator3f Copied(Components);
	Components.Pitch = 0.0;
	return Copied.Pitch == 10.0 && Copied.Yaw == 20.0 && Copied.Roll == 30.0 && DefaultRotator.IsZero() && Scalar.Pitch == 7.0 && Scalar.Yaw == 7.0 && Scalar.Roll == 7.0;
}
/** @end */
/**
 * @begin frotator3f-pitch
 * @summary FRotator3f.Pitch.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FRotator3f.Pitch.
 * @covers FRotator3f.frotator3f-pitch
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	return FRotator3f(10.0, 20.0, 30.0).Pitch == 10.0;
}
/** @end */
/**
 * @begin frotator3f-yaw
 * @summary FRotator3f.Yaw.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FRotator3f.Yaw.
 * @covers FRotator3f.frotator3f-yaw
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
{
	return FRotator3f(10.0, 20.0, 30.0).Yaw == 20.0;
}
/** @end */
/**
 * @begin frotator3f-roll
 * @summary FRotator3f.Roll.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FRotator3f.Roll.
 * @covers FRotator3f.frotator3f-roll
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface007Nominal()
{
	return FRotator3f(10.0, 20.0, 30.0).Roll == 30.0;
}
/** @end */
/**
 * @begin clamp
 * @summary Returns a new rotator in [0, 360).
 * @topic Unreal
 */
/**
 * @function ObserveClampNominal
 * @summary Returns a new rotator in [0, 360).
 * @covers FRotator3f.clamp
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClampNominal()
{
	FRotator3f Over(0.0, 370.0, 0.0);
	FRotator3f Clamped = Over.Clamp();
	return Clamped.Yaw == 10.0 && Over.Yaw == 370.0;
}
/** @end */
/**
 * @begin normalize
 * @summary Mutates the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Mutates the receiver.
 * @covers FRotator3f.normalize
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNormalizeNominal()
{
	FRotator3f Over(0.0, 270.0, 0.0);
	Over.Normalize();
	return Over.Yaw == -90.0;
}
/** @end */
/**
 * @begin vector
 * @summary ForwardVector; yaw 90 is RightVector.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary ForwardVector; yaw 90 is RightVector.
 * @covers FRotator3f.vector
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorNominal()
{
	FVector3f ZeroForward = FRotator3f::ZeroRotator.Vector();
	FVector3f Yaw90Forward = FRotator3f(0.0, 90.0, 0.0).Vector();
	return ZeroForward.Equals(FVector3f::ForwardVector) && Yaw90Forward.Equals(FVector3f::RightVector);
}
/** @end */
/**
 * @begin quaternion
 * @summary Expected observations: Zero Quaternion is Identity.
 * @topic Unreal
 */
/**
 * @function ObserveQuaternionNominal
 * @summary Expected observations: Zero Quaternion is Identity.
 * @covers FRotator3f.quaternion
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

 Euler of (10,20,30) is
// (30,10,20). Yaw 90 rotates X onto Y. Identity quat constructs zero. FRotator
// converts. InitFromString succeeds for P/Y/R text and fails on empty.
// Boundary/ownership: Euler is (Roll, Pitch, Yaw). InitFromString mutates the
// receiver.
bool ObserveQuaternionNominal()
{
	FQuat4f Identity = FRotator3f::ZeroRotator.Quaternion();
	FQuat4f FromYaw = FRotator3f(0.0, 90.0, 0.0).Quaternion();
	return Identity.Equals(FQuat4f::Identity) && !FromYaw.Equals(FQuat4f::Identity);
}
/** @end */
/**
 * @begin euler
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveEulerNominal
 * @summary receiver.
 * @covers FRotator3f.euler
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

bool ObserveEulerNominal()
{
	FVector3f Euler = FRotator3f(10.0, 20.0, 30.0).Euler();
	FVector3f ZeroEuler = FRotator3f::ZeroRotator.Euler();
	return Euler.X == 30.0 && Euler.Y == 10.0 && Euler.Z == 20.0 && ZeroEuler.Equals(FVector3f::ZeroVector);
}
/** @end */
/**
 * @begin rotate-vector
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveRotateVectorNominal
 * @summary receiver.
 * @covers FRotator3f.rotate-vector
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

bool ObserveRotateVectorNominal()
{
	FRotator3f Yaw90(0.0, 90.0, 0.0);
	FVector3f Rotated = Yaw90.RotateVector(FVector3f::ForwardVector);
	FVector3f Unchanged = FRotator3f::ZeroRotator.RotateVector(FVector3f::ForwardVector);
	return Rotated.Equals(FVector3f::RightVector) && Unchanged.Equals(FVector3f::ForwardVector);
}
/** @end */
/**
 * @begin unrotate-vector
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveUnrotateVectorNominal
 * @summary receiver.
 * @covers FRotator3f.unrotate-vector
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

bool ObserveUnrotateVectorNominal()
{
	FRotator3f Yaw90(0.0, 90.0, 0.0);
	FVector3f Unrotated = Yaw90.UnrotateVector(FVector3f::RightVector);
	FVector3f RoundTrip = Yaw90.UnrotateVector(Yaw90.RotateVector(FVector3f(1.0, 2.0, 3.0)));
	return Unrotated.Equals(FVector3f::ForwardVector) && RoundTrip.Equals(FVector3f(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin FRotator3f-Behavior_02-rotator
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary receiver.
 * @covers FRotator3f.rotator
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

bool ObserveRotatorNominal()
{
	FRotator3f FromQuat(FQuat4f::Identity);
	FRotator3f FromDouble(FRotator(1.0, 2.0, 3.0));
	return FromQuat.IsNearlyZero() && FromDouble.Pitch == 1.0 && FromDouble.Yaw == 2.0 && FromDouble.Roll == 3.0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary receiver.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary receiver.
 * @covers FRotator3f.init-from-string
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Zero Quaternion is Identity.

bool ObserveInitFromStringNominal()
{
	FRotator3f Parsed;
	bool bValid = Parsed.InitFromString("P=10 Y=20 R=30");
	FRotator3f Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bValid && Parsed.Pitch == 10.0 && Parsed.Yaw == 20.0 && Parsed.Roll == 30.0 && !bEmptyFailed;
}
/** @end */
/**
 * @begin assignment
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Observe the container API.
 * @covers FRotator3f.assignment
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 copy stays (10,20,30).
// Boundary/ownership: Value-returning operators do not mutate Left. Compound
// operators mutate the left operand.
bool ObserveAssignmentNominal()
{
	FRotator3f Left;
	FRotator3f Right(10.0, 20.0, 30.0);
	FRotator3f Original = Right;
	Left = Right;
	FRotator3f Sum = Left + FRotator3f(1.0, 2.0, 3.0);
	Right.Yaw = 90.0;
	FString Text = f"{Left}";
	return Left.Pitch == 10.0 && Left.Yaw == 20.0 && Left.Roll == 30.0 && Sum.Pitch == 11.0 && Original.Yaw == 20.0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin add-assign
 * @summary operators mutate the left operand.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary operators mutate the left operand.
 * @covers FRotator3f.add-assign
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAddAssignNominal()
{
	FRotator3f Left(10.0, 20.0, 30.0);
	FRotator3f Right(1.0, 2.0, 3.0);
	Left += Right;
	return Left.Pitch == 11.0 && Left.Yaw == 22.0 && Left.Roll == 33.0 && Right.Pitch == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary operators mutate the left operand.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary operators mutate the left operand.
 * @covers FRotator3f.subtract-assign
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSubtractAssignNominal()
{
	FRotator3f Left(10.0, 20.0, 30.0);
	FRotator3f Difference = Left - FRotator3f(1.0, 2.0, 3.0);
	Left -= FRotator3f(1.0, 2.0, 3.0);
	return Difference.Pitch == 9.0 && Difference.Yaw == 18.0 && Difference.Roll == 27.0 && Left.Pitch == 9.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary operators mutate the left operand.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary operators mutate the left operand.
 * @covers FRotator3f.multiply-assign
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveMultiplyAssignNominal()
{
	FRotator3f Rotator(10.0, 20.0, 30.0);
	FRotator3f Scaled = Rotator * 2.0;
	Rotator *= 2.0;
	return Scaled.Pitch == 20.0 && Scaled.Yaw == 40.0 && Rotator.Roll == 60.0;
}
/** @end */
/**
 * @begin to-color-string
 * @summary Boundary/ownership: ToColorString returns a new string.
 * @topic Unreal
 */
/**
 * @function ObserveToColorStringNominal
 * @summary Boundary/ownership: ToColorString returns a new string.
 * @covers FRotator3f.to-color-string
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToColorStringNominal()
{
	FRotator3f Rotator(10.0, 20.0, 30.0);
	FString ColorText = Rotator.ToColorString();
	FString ZeroText = FRotator3f::ZeroRotator.ToColorString();
	return ColorText.Contains("P=") && ColorText.Contains("Y=") && ColorText.Contains("R=") && ColorText.Contains("<Green>") && ColorText.Contains("<Blue>") && ColorText.Contains("<Red>") && ZeroText.Len() > 0 && Rotator.Pitch == 10.0;
}
/** @end */
/**
 * @begin inputs-270-270-90
 * @summary Inputs: 270, -270, -90, 370, 0,
 * @topic Unreal
 */
/**
 * @function ObserveSurface027Nominal
 * @summary Inputs: 270, -270, -90, 370, 0,
 * @covers FRotator3f.inputs-270-270-90
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: 270, -270, -90, 370, 0,

 and Euler (30,10,20) as Roll/Pitch/Yaw.
// Expected observations: ZeroRotator is zero. NormalizeAxis(270) is -90.
// ClampAxis(-90) is 270. MakeFromEuler stores Pitch 10, Yaw 20, Roll 30.
// Boundary/ownership: NormalizeAxis uses the signed axis range. ClampAxis uses
// [0, 360). MakeFromEuler returns a new rotator.
// FRotator3f::ZeroRotator. No extra inputs. Pitch/Yaw/Roll are 0 and
// IsZero is true. Shared constant; not owned by the caller.
bool ObserveSurface027Nominal()
{
	FRotator3f Zero = FRotator3f::ZeroRotator;
	return Zero.IsZero() && Zero.Pitch == 0.0 && Zero.Yaw == 0.0 && Zero.Roll == 0.0;
}
/** @end */
/**
 * @begin normalize-axis
 * @summary and 0.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeAxisNominal
 * @summary and 0.
 * @covers FRotator3f.normalize-axis
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: 270, -270, -90, 370, 0,

bool ObserveNormalizeAxisNominal()
{
	float32 Wrapped = FRotator3f::NormalizeAxis(270.0);
	float32 Negative = FRotator3f::NormalizeAxis(-270.0);
	float32 Unchanged = FRotator3f::NormalizeAxis(0.0);
	return Wrapped == -90.0 && Negative == 90.0 && Unchanged == 0.0;
}
/** @end */
/**
 * @begin clamp-axis
 * @summary in [0, 360).
 * @topic Unreal
 */
/**
 * @function ObserveClampAxisNominal
 * @summary in [0, 360).
 * @covers FRotator3f.clamp-axis
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: 270, -270, -90, 370, 0,

bool ObserveClampAxisNominal()
{
	float32 FromNegative = FRotator3f::ClampAxis(-90.0);
	float32 FromOver = FRotator3f::ClampAxis(370.0);
	float32 Unchanged = FRotator3f::ClampAxis(0.0);
	return FromNegative == 270.0 && FromOver == 10.0 && Unchanged == 0.0;
}
/** @end */
/**
 * @begin make-from-euler
 * @summary FRotator3f::MakeFromEuler.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromEulerNominal
 * @summary FRotator3f::MakeFromEuler.
 * @covers FRotator3f.make-from-euler
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: 270, -270, -90, 370, 0,

 Input FVector3f(30,10,20) as Roll/Pitch/Yaw.
// Pitch 10, Yaw 20, Roll 30. Returns a new rotator.
bool ObserveMakeFromEulerNominal()
{
	FRotator3f FromEuler = FRotator3f::MakeFromEuler(FVector3f(30.0, 10.0, 20.0));
	return FromEuler.Pitch == 10.0 && FromEuler.Yaw == 20.0 && FromEuler.Roll == 30.0;
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: == compares raw degree components exactly.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: == compares raw degree components exactly.
 * @covers FRotator3f.equality
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FRotator3f Left(10.0, 20.0, 30.0);
	FRotator3f Right(10.0, 20.0, 30.0);
	FRotator3f Different(10.0, 21.0, 30.0);
	FRotator3f Zero;
	return (Left == Right) && !(Left == Different) && (Zero == FRotator3f::ZeroRotator);
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.is-nearly-zero
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNearlyZeroNominal()
{
	FRotator3f Zero = FRotator3f::ZeroRotator;
	FRotator3f Offset(10.0, 0.0, 0.0);
	return Zero.IsNearlyZero() && Zero.IsNearlyZero(__KINDA_SMALL_NUMBER_flt) && !Offset.IsNearlyZero();
}
/** @end */
/**
 * @begin is-zero
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.is-zero
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsZeroNominal()
{
	FRotator3f Zero;
	FRotator3f Offset(10.0, 0.0, 0.0);
	return Zero.IsZero() && !Offset.IsZero();
}
/** @end */
/**
 * @begin equals
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.equals
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FRotator3f Left(10.0, 20.0, 30.0);
	FRotator3f Right(10.0, 20.0, 30.0);
	FRotator3f Different(10.0, 90.0, 30.0);
	return Left.Equals(Right) && Left.Equals(Right, __KINDA_SMALL_NUMBER_flt) && !Left.Equals(Different);
}
/** @end */
/**
 * @begin get-inverse
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetInverseNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.get-inverse
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInverseNominal()
{
	FRotator3f Yaw90(0.0, 90.0, 0.0);
	FRotator3f Inverse = Yaw90.GetInverse();
	FRotator3f RoundTrip = Inverse.GetInverse();
	return Inverse.Equals(FRotator3f(0.0, -90.0, 0.0)) && RoundTrip.Equals(Yaw90);
}
/** @end */
/**
 * @begin get-normalized
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetNormalizedNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.get-normalized
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNormalizedNominal()
{
	FRotator3f Over(0.0, 270.0, 0.0);
	FRotator3f Normalized = Over.GetNormalized();
	return Normalized.Yaw == -90.0 && Over.Yaw == 270.0;
}
/** @end */
/**
 * @begin get-denormalized
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetDenormalizedNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.get-denormalized
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDenormalizedNominal()
{
	FRotator3f Signed(0.0, -90.0, 0.0);
	FRotator3f Denormalized = Signed.GetDenormalized();
	return Denormalized.Yaw == 270.0 && Signed.Yaw == -90.0;
}
/** @end */
/**
 * @begin get-winding-and-remainder
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetWindingAndRemainderNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.get-winding-and-remainder
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetWindingAndRemainderNominal()
{
	FRotator3f Over(0.0, 370.0, 0.0);
	FRotator3f Winding;
	FRotator3f Remainder;
	Over.GetWindingAndRemainder(Winding, Remainder);
	return Winding.Yaw == 360.0 && Remainder.Yaw == 10.0 && Over.Yaw == 370.0;
}
/** @end */
/**
 * @begin get-manhattan-distance
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetManhattanDistanceNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.get-manhattan-distance
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetManhattanDistanceNominal()
{
	FRotator3f Rotator(10.0, 20.0, 30.0);
	float32 ToZero = Rotator.GetManhattanDistance(FRotator3f::ZeroRotator);
	float32 ToSelf = Rotator.GetManhattanDistance(Rotator);
	return ToZero == 60.0 && ToSelf == 0.0;
}
/** @end */
/**
 * @begin contains-na-n
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator3f.contains-na-n
 * @inputs FRotator3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveContainsNaNNominal()
{
	FRotator3f Finite(10.0, 20.0, 30.0);
	FRotator3f Zero;
	return !Finite.ContainsNaN() && !Zero.ContainsNaN();
}
/** @end */
