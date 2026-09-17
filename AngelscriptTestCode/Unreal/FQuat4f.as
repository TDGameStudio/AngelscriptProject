/**
 * @version v1
 * @summary FQuat4f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FQuat4f
 *
 * container-api
 * copy-components-rotator-axis
 * fquat4f-x-stores-constructed
 * fquat4f-y-stores-constructed
 * fquat4f-z-stores-constructed
 * FQuat4f-Behavior_02-container-api
 * normalize
 * size
 * size-squared
 * log
 * exp
 * inverse
 * angular-distance
 * enforce-shortest-arc-with
 * euler
 * rotate-vector
 * unrotate-vector
 * vector
 * rotator
 * init-from-string
 * assignment
 * add-assign
 * subtract-assign
 * multiply-assign
 * FQuat4f-ConstructionAndAssignment_02-assignment
 * divide-assign
 * to-axis-and-angle
 * to-swing-twist
 * expected-observations
 * make-from-euler
 * fast-lerp
 * fast-bilerp
 * slerp-not-normalized
 * slerp
 * error
 * error-auto-normalize
 * slerp-full-path-not-normalized
 * slerp-full-path
 * squad
 * squad-full-path
 * calc-tangents
 * equality
 * equals
 * is-identity
 * get-normalized
 * is-normalized
 * get-angle
 * contains-na-n
 * get-axis-x
 * get-axis-y
 * get-axis-z
 * get-forward-vector
 * get-right-vector
 * get-up-vector
 * get-rotation-axis
 * get-twist-angle
 * find-between
 * find-between-vectors
 * find-between-normals
 */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Observe the container API.
 * @covers FQuat4f.container-api
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FQuat4f Value(float32 X, float32 Y, float32 Z, float32 W);
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
// Default FQuat4f is identity (0,0,0,1). Oracle: exact components. Value construction.
bool ObserveSurface001Nominal()
{
	FQuat4f Value;
	return Value.X == 0.0 && Value.Y == 0.0 && Value.Z == 0.0 && Value.W == 1.0;
}
/** @end */
/**
 * @begin copy-components-rotator-axis
 * @summary Default, copy, components, rotator, axis-angle, and FQuat conversion constructors.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Default, copy, components, rotator, axis-angle, and FQuat conversion constructors.
 * @covers FQuat4f.copy-components-rotator-axis
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveValueNominal()
{
	FQuat4f DefaultValue;
	FQuat4f Copied(DefaultValue);
	FQuat4f Components(0.0, 0.0, 0.0, 1.0);
	FQuat4f FromRotator(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f FromAxis(FVector3f::UpVector, HALF_PI);
	FQuat4f FromDouble(FQuat::Identity);
	return DefaultValue.W == 1.0 && Copied.W == 1.0 && Components.W == 1.0 && FromRotator.RotateVector(FVector3f::ForwardVector).Y > 0.9 && FromAxis.RotateVector(FVector3f::ForwardVector).Y > 0.9 && FromDouble.W == 1.0;
}
/** @end */
/**
 * @begin fquat4f-x-stores-constructed
 * @summary FQuat4f.X stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FQuat4f.X stores the constructed
 * @covers FQuat4f.fquat4f-x-stores-constructed
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 X of (0.1, 0.2, 0.3, 0.9). Oracle: X == 0.1. Value copy.
bool ObserveSurface008Nominal()
{
	return FQuat4f(0.1, 0.2, 0.3, 0.9).X == 0.1;
}
/** @end */
/**
 * @begin fquat4f-y-stores-constructed
 * @summary FQuat4f.Y stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FQuat4f.Y stores the constructed
 * @covers FQuat4f.fquat4f-y-stores-constructed
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Y of (0.1, 0.2, 0.3, 0.9). Oracle: Y == 0.2. Value copy.
bool ObserveSurface009Nominal()
{
	return FQuat4f(0.1, 0.2, 0.3, 0.9).Y == 0.2;
}
/** @end */
/**
 * @begin fquat4f-z-stores-constructed
 * @summary FQuat4f.Z stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FQuat4f.Z stores the constructed
 * @covers FQuat4f.fquat4f-z-stores-constructed
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Z of (0.1, 0.2, 0.3, 0.9). Oracle: Z == 0.3. Value copy.
bool ObserveSurface010Nominal()
{
	return FQuat4f(0.1, 0.2, 0.3, 0.9).Z == 0.3;
}
/** @end */
/**
 * @begin FQuat4f-Behavior_02-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Observe the container API.
 * @covers FQuat4f.container-api
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Components (0.1,0.2,0.3,0.9), (0,0,0,2), SMALL_NUMBER omitted and
// explicit, Identity, yaw 90, and flipped Identity.
// Expected observations: W stores 0.9. Normalize of (0,0,0,2) yields W=1.
// Identity Size/SizeSquared are 1. Log/Exp of Identity round-trips. Inverse
// of Identity is Identity. AngularDistance to self is 0. Flipped W becomes
// positive. Identity Euler is 0.
// Boundary/ownership: Normalize and EnforceShortestArcWith mutate the
// receiver. Log/Exp/Inverse return new quaternions.
// FQuat4f.W stores the constructed W of (0.1, 0.2, 0.3, 0.9). Oracle: W == 0.9. Value copy.
bool ObserveSurface011Nominal()
{
	return FQuat4f(0.1, 0.2, 0.3, 0.9).W == 0.9;
}
/** @end */
/**
 * @begin normalize
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Observe the container API.
 * @covers FQuat4f.normalize
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Normalize of (0,0,0,2) with default and SMALL_NUMBER yields W=1. Mutates the receiver.
bool ObserveNormalizeNominal()
{
	FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
	Doubled.Normalize();
	FQuat4f Explicit(0.0, 0.0, 0.0, 2.0);
	Explicit.Normalize(SMALL_NUMBER);
	return Doubled.W == 1.0 && Explicit.W == 1.0 && Doubled.IsNormalized();
}
/** @end */
/**
 * @begin size
 * @summary Identity Size is 1; (0,0,0,2) Size is 2.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary Identity Size is 1; (0,0,0,2) Size is 2.
 * @covers FQuat4f.size
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSizeNominal()
{
	return FQuat4f::Identity.Size() == 1.0 && FQuat4f(0.0, 0.0, 0.0, 2.0).Size() == 2.0;
}
/** @end */
/**
 * @begin size-squared
 * @summary Identity SizeSquared is 1; (0,0,0,2) SizeSquared is 4.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquaredNominal
 * @summary Identity SizeSquared is 1; (0,0,0,2) SizeSquared is 4.
 * @covers FQuat4f.size-squared
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSizeSquaredNominal()
{
	return FQuat4f::Identity.SizeSquared() == 1.0 && FQuat4f(0.0, 0.0, 0.0, 2.0).SizeSquared() == 4.0;
}
/** @end */
/**
 * @begin log
 * @summary Log of Identity has zero XYZ.
 * @topic Unreal
 */
/**
 * @function ObserveLogNominal
 * @summary Log of Identity has zero XYZ.
 * @covers FQuat4f.log
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogNominal()
{
	FQuat4f Logged = FQuat4f::Identity.Log();
	return Logged.X == 0.0 && Logged.Y == 0.0 && Logged.Z == 0.0;
}
/** @end */
/**
 * @begin exp
 * @summary Exp of Identity.Log() round-trips to Identity.
 * @topic Unreal
 */
/**
 * @function ObserveExpNominal
 * @summary Exp of Identity.Log() round-trips to Identity.
 * @covers FQuat4f.exp
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveExpNominal()
{
	FQuat4f RoundTrip = FQuat4f::Identity.Log().Exp();
	return RoundTrip.Equals(FQuat4f::Identity);
}
/** @end */
/**
 * @begin inverse
 * @summary Inverse of Identity is Identity; yaw * inverse(yaw) is identity.
 * @topic Unreal
 */
/**
 * @function ObserveInverseNominal
 * @summary Inverse of Identity is Identity; yaw * inverse(yaw) is identity.
 * @covers FQuat4f.inverse
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseNominal()
{
	FQuat4f IdentityInverse = FQuat4f::Identity.Inverse();
	FQuat4f Yaw = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Restored = Yaw.Inverse() * Yaw;
	return IdentityInverse.Equals(FQuat4f::Identity) && Restored.IsIdentity();
}
/** @end */
/**
 * @begin angular-distance
 * @summary AngularDistance to self is 0; to yaw 90 is about HALF_PI.
 * @topic Unreal
 */
/**
 * @function ObserveAngularDistanceNominal
 * @summary AngularDistance to self is 0; to yaw 90 is about HALF_PI.
 * @covers FQuat4f.angular-distance
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAngularDistanceNominal()
{
	float32 Same = FQuat4f::Identity.AngularDistance(FQuat4f::Identity);
	float32 Yaw = FQuat4f::Identity.AngularDistance(FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
	return Same == 0.0 && Yaw > 1.0;
}
/** @end */
/**
 * @begin enforce-shortest-arc-with
 * @summary EnforceShortestArcWith flips W=-1 into the Identity hemisphere.
 * @topic Unreal
 */
/**
 * @function ObserveEnforceShortestArcWithNominal
 * @summary EnforceShortestArcWith flips W=-1 into the Identity hemisphere.
 * @covers FQuat4f.enforce-shortest-arc-with
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEnforceShortestArcWithNominal()
{
	FQuat4f Flipped(0.0, 0.0, 0.0, -1.0);
	Flipped.EnforceShortestArcWith(FQuat4f::Identity);
	FQuat4f AlreadyShort = FQuat4f::Identity;
	AlreadyShort.EnforceShortestArcWith(FQuat4f::Identity);
	return Flipped.W > 0.0 && AlreadyShort.W == 1.0;
}
/** @end */
/**
 * @begin euler
 * @summary Euler of Identity is zero; yaw 90 has a non-zero yaw component.
 * @topic Unreal
 */
/**
 * @function ObserveEulerNominal
 * @summary Euler of Identity is zero; yaw 90 has a non-zero yaw component.
 * @covers FQuat4f.euler
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEulerNominal()
{
	FVector3f IdentityEuler = FQuat4f::Identity.Euler();
	FVector3f YawEuler = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Euler();
	return IdentityEuler.X == 0.0 && IdentityEuler.Z == 0.0 && YawEuler.Z > 89.0;
}
/** @end */
/**
 * @begin rotate-vector
 * @summary Vector/Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveRotateVectorNominal
 * @summary Vector/Rotator return new values.
 * @covers FQuat4f.rotate-vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotateVectorNominal()
{
	FVector3f IdentityForward = FQuat4f::Identity.RotateVector(FVector3f::ForwardVector);
	FVector3f YawForward = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).RotateVector(FVector3f::ForwardVector);
	return IdentityForward.X == 1.0 && YawForward.Y > 0.9;
}
/** @end */
/**
 * @begin unrotate-vector
 * @summary Vector/Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveUnrotateVectorNominal
 * @summary Vector/Rotator return new values.
 * @covers FQuat4f.unrotate-vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnrotateVectorNominal()
{
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	FVector3f Rotated = Yaw.RotateVector(FVector3f::ForwardVector);
	FVector3f Restored = Yaw.UnrotateVector(Rotated);
	FVector3f IdentityUnrotated = FQuat4f::Identity.UnrotateVector(FVector3f::ForwardVector);
	return Restored.X > 0.9 && IdentityUnrotated.X == 1.0;
}
/** @end */
/**
 * @begin vector
 * @summary Vector/Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Vector/Rotator return new values.
 * @covers FQuat4f.vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorNominal()
{
	FVector3f IdentityVector = FQuat4f::Identity.Vector();
	FVector3f YawVector = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Vector();
	return IdentityVector.X == 1.0 && IdentityVector.Z == 0.0 && YawVector.Y > 0.9;
}
/** @end */
/**
 * @begin rotator
 * @summary Vector/Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary Vector/Rotator return new values.
 * @covers FQuat4f.rotator
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotatorNominal()
{
	FRotator3f IdentityRotator = FQuat4f::Identity.Rotator();
	FRotator3f YawRotator = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).Rotator();
	return IdentityRotator.Pitch == 0.0 && IdentityRotator.Yaw == 0.0 && YawRotator.Yaw > 0.0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary Vector/Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary Vector/Rotator return new values.
 * @covers FQuat4f.init-from-string
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveInitFromStringNominal()
{
	FString Text = f"{FQuat4f::Identity}";
	FQuat4f Parsed;
	bool bParsed = Parsed.InitFromString(Text);
	FQuat4f Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bParsed && Parsed.Equals(FQuat4f::Identity) && !bEmptyFailed;
}
/** @end */
/**
 * @begin assignment
 * @summary operators return a new quaternion or vector.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary operators return a new quaternion or vector.
 * @covers FQuat4f.assignment
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FQuat4f Left = FQuat4f::Identity;
	FQuat4f Right(0.0, 0.0, 0.0, 2.0);
	FQuat4f Original = Left;
	Left = Right;
	FQuat4f Sum = FQuat4f::Identity + FQuat4f::Identity;
	return Left.W == 2.0 && Original.W == 1.0 && Sum.W == 2.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary operators return a new quaternion or vector.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary operators return a new quaternion or vector.
 * @covers FQuat4f.add-assign
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FQuat4f Quat = FQuat4f::Identity;
	Quat += FQuat4f::Identity;
	return Quat.W == 2.0 && FQuat4f::Identity.W == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary operators return a new quaternion or vector.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary operators return a new quaternion or vector.
 * @covers FQuat4f.subtract-assign
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
	FQuat4f Difference = Quat - FQuat4f::Identity;
	Quat -= FQuat4f::Identity;
	return Difference.W == 1.0 && Quat.W == 1.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary operators return a new quaternion or vector.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary operators return a new quaternion or vector.
 * @covers FQuat4f.multiply-assign
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FQuat4f Product = FQuat4f::Identity * FQuat4f::Identity;
	FQuat4f Composed = FQuat4f::Identity;
	Composed *= FQuat4f::Identity;
	FQuat4f Scaled = FQuat4f::Identity * 2.0;
	FQuat4f ScaledInPlace = FQuat4f::Identity;
	ScaledInPlace *= 2.0;
	FVector3f Forward = FQuat4f::Identity * FVector3f::ForwardVector;
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	FVector3f Turned = Yaw * FVector3f::ForwardVector;
	return Product.W == 1.0 && Composed.W == 1.0 && Scaled.W == 2.0 && ScaledInPlace.W == 2.0 && Forward.X == 1.0 && Turned.Y > 0.9;
}
/** @end */
/**
 * @begin FQuat4f-ConstructionAndAssignment_02-assignment
 * @summary must be non-zero.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary must be non-zero.
 * @covers FQuat4f.assignment
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
	FQuat4f Original = Quat;
	FQuat4f Result = Quat / 2.0;
	return Result.W == 1.0 && Original.W == 2.0 && Quat.W == 2.0;
}
/** @end */
/**
 * @begin divide-assign
 * @summary must be non-zero.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary must be non-zero.
 * @covers FQuat4f.divide-assign
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
	Quat /= 2.0;
	return Quat.W == 1.0 && Quat.X == 0.0;
}
/** @end */
/**
 * @begin to-axis-and-angle
 * @summary receiver quaternion is not mutated.
 * @topic Unreal
 */
/**
 * @function ObserveToAxisAndAngleNominal
 * @summary receiver quaternion is not mutated.
 * @covers FQuat4f.to-axis-and-angle
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToAxisAndAngleNominal()
{
	FVector3f IdentityAxis = FVector3f::ZeroVector;
	float32 IdentityAngle = 1.0;
	FQuat4f::Identity.ToAxisAndAngle(IdentityAxis, IdentityAngle);
	FVector3f YawAxis = FVector3f::ZeroVector;
	float32 YawAngle = 0.0;
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	Yaw.ToAxisAndAngle(YawAxis, YawAngle);
	return IdentityAngle == 0.0 && YawAngle > 1.0 && YawAxis.Z > 0.9;
}
/** @end */
/**
 * @begin to-swing-twist
 * @summary receiver quaternion is not mutated.
 * @topic Unreal
 */
/**
 * @function ObserveToSwingTwistNominal
 * @summary receiver quaternion is not mutated.
 * @covers FQuat4f.to-swing-twist
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToSwingTwistNominal()
{
	FQuat4f Swing = FQuat4f::Identity;
	FQuat4f Twist = FQuat4f::Identity;
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	Yaw.ToSwingTwist(FVector3f::UpVector, Swing, Twist);
	FQuat4f IdentitySwing(0.0, 0.0, 0.0, 2.0);
	FQuat4f IdentityTwist(0.0, 0.0, 0.0, 2.0);
	FQuat4f::Identity.ToSwingTwist(FVector3f::UpVector, IdentitySwing, IdentityTwist);
	return Swing.IsIdentity() && !Twist.IsIdentity() && IdentitySwing.IsIdentity();
}
/** @end */
/**
 * @begin expected-observations
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSurface055Nominal
 * @summary Expected observations:
 * @covers FQuat4f.expected-observations
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Identity is (0,0,0,1). Euler yaw turns Forward
// toward +Y. Lerp/Slerp at 0 and 1 match the endpoints. Error of Identity
// vs itself is 0; vs yaw is positive.
// Boundary/ownership: Identity is a shared constant. Interpolation returns
// new values. Zero-length Slerp is the diagnostic companion.
// FQuat4f::Identity is the shared (0,0,0,1) constant. Oracle: exact components. Not owned by the caller.
bool ObserveSurface055Nominal()
{
	FQuat4f Identity = FQuat4f::Identity;
	return Identity.X == 0.0 && Identity.Y == 0.0 && Identity.Z == 0.0 && Identity.W == 1.0;
}
/** @end */
/**
 * @begin make-from-euler
 * @summary MakeFromEuler(0,0,90) is yaw 90.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromEulerNominal
 * @summary MakeFromEuler(0,0,90) is yaw 90.
 * @covers FQuat4f.make-from-euler
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveMakeFromEulerNominal()
{
	FQuat4f Yaw = FQuat4f::MakeFromEuler(FVector3f(0, 0, 90));
	FVector3f Rotated = Yaw.RotateVector(FVector3f::ForwardVector);
	return Rotated.Y > 0.9;
}
/** @end */
/**
 * @begin fast-lerp
 * @summary FastLerp at 0/1 matches endpoints; mid has non-zero size.
 * @topic Unreal
 */
/**
 * @function ObserveFastLerpNominal
 * @summary FastLerp at 0/1 matches endpoints; mid has non-zero size.
 * @covers FQuat4f.fast-lerp
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveFastLerpNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::FastLerp(From, To, 0.0);
	FQuat4f End = FQuat4f::FastLerp(From, To, 1.0);
	FQuat4f Mid = FQuat4f::FastLerp(From, To, 0.5);
	return Start.Equals(From) && End.Equals(To) && Mid.Size() > 0.0;
}
/** @end */
/**
 * @begin fast-bilerp
 * @summary FastBilerp of all-identity corners is
 * @topic Unreal
 */
/**
 * @function ObserveFastBilerpNominal
 * @summary FastBilerp of all-identity corners is
 * @covers FQuat4f.fast-bilerp
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 identity at (0,0) and non-zero at (0.5,0.5). New values.
bool ObserveFastBilerpNominal()
{
	FQuat4f Identity = FQuat4f::Identity;
	FQuat4f Result = FQuat4f::FastBilerp(Identity, Identity, Identity, Identity, 0.5, 0.5);
	FQuat4f Corner = FQuat4f::FastBilerp(Identity, Identity, Identity, Identity, 0.0, 0.0);
	return Result.Size() > 0.0 && Corner.Equals(Identity);
}
/** @end */
/**
 * @begin slerp-not-normalized
 * @summary Slerp_NotNormalized at 0/1 matches endpoints.
 * @topic Unreal
 */
/**
 * @function ObserveSlerpNotNormalizedNominal
 * @summary Slerp_NotNormalized at 0/1 matches endpoints.
 * @covers FQuat4f.slerp-not-normalized
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpNotNormalizedNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::Slerp_NotNormalized(From, To, 0.0);
	FQuat4f End = FQuat4f::Slerp_NotNormalized(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin slerp
 * @summary Slerp at 0/1 matches endpoints; mid is normalized.
 * @topic Unreal
 */
/**
 * @function ObserveSlerpNominal
 * @summary Slerp at 0/1 matches endpoints; mid is normalized.
 * @covers FQuat4f.slerp
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::Slerp(From, To, 0.0);
	FQuat4f End = FQuat4f::Slerp(From, To, 1.0);
	FQuat4f Mid = FQuat4f::Slerp(From, To, 0.5);
	return Start.Equals(From) && End.Equals(To) && Mid.IsNormalized();
}
/** @end */
/**
 * @begin error
 * @summary Error of Identity vs itself is 0; vs yaw 90 is positive.
 * @topic Unreal
 */
/**
 * @function ObserveErrorNominal
 * @summary Error of Identity vs itself is 0; vs yaw 90 is positive.
 * @covers FQuat4f.error
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveErrorNominal()
{
	float32 Same = FQuat4f::Error(FQuat4f::Identity, FQuat4f::Identity);
	float32 Different = FQuat4f::Error(FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
	return Same == 0.0 && Different > 0.0;
}
/** @end */
/**
 * @begin error-auto-normalize
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveErrorAutoNormalizeNominal
 * @summary Observe the container API.
 * @covers FQuat4f.error-auto-normalize
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 ErrorAutoNormalize treats (0,0,0,2) as Identity; yaw 90 remains positive. Does not mutate inputs.
bool ObserveErrorAutoNormalizeNominal()
{
	FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
	float32 Same = FQuat4f::ErrorAutoNormalize(Doubled, FQuat4f::Identity);
	float32 Different = FQuat4f::ErrorAutoNormalize(FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)));
	return Same == 0.0 && Different > 0.0;
}
/** @end */
/**
 * @begin slerp-full-path-not-normalized
 * @summary SlerpFullPath_NotNormalized at 0/1 matches endpoints.
 * @topic Unreal
 */
/**
 * @function ObserveSlerpFullPathNotNormalizedNominal
 * @summary SlerpFullPath_NotNormalized at 0/1 matches endpoints.
 * @covers FQuat4f.slerp-full-path-not-normalized
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpFullPathNotNormalizedNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::SlerpFullPath_NotNormalized(From, To, 0.0);
	FQuat4f End = FQuat4f::SlerpFullPath_NotNormalized(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin slerp-full-path
 * @summary SlerpFullPath at 0/1 matches endpoints.
 * @topic Unreal
 */
/**
 * @function ObserveSlerpFullPathNominal
 * @summary SlerpFullPath at 0/1 matches endpoints.
 * @covers FQuat4f.slerp-full-path
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpFullPathNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::SlerpFullPath(From, To, 0.0);
	FQuat4f End = FQuat4f::SlerpFullPath(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin squad
 * @summary and OutTan
 * @topic Unreal
 */
/**
 * @function ObserveSquadNominal
 * @summary and OutTan
 * @covers FQuat4f.squad
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// and OutTan

 seeded to (0,0,0,2) before CalcTangents.
// Expected observations: Squad at 0 is Quat1 and at 1 is Quat2. SquadFullPath
// matches the same endpoints. CalcTangents overwrites OutTan.
// Boundary/ownership: Interpolation returns new quaternions. OutTan is a
// writeback; Tension controls curve tightness.
bool ObserveSquadNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::Squad(From, FQuat4f::Identity, To, FQuat4f::Identity, 0.0);
	FQuat4f End = FQuat4f::Squad(From, FQuat4f::Identity, To, FQuat4f::Identity, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin squad-full-path
 * @summary writeback.
 * @topic Unreal
 */
/**
 * @function ObserveSquadFullPathNominal
 * @summary writeback.
 * @covers FQuat4f.squad-full-path
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// and OutTan

bool ObserveSquadFullPathNominal()
{
	FQuat4f From = FQuat4f::Identity;
	FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Start = FQuat4f::SquadFullPath(From, FQuat4f::Identity, To, FQuat4f::Identity, 0.0);
	FQuat4f End = FQuat4f::SquadFullPath(From, FQuat4f::Identity, To, FQuat4f::Identity, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin calc-tangents
 * @summary writeback.
 * @topic Unreal
 */
/**
 * @function ObserveCalcTangentsNominal
 * @summary writeback.
 * @covers FQuat4f.calc-tangents
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
// and OutTan

bool ObserveCalcTangentsNominal()
{
	FQuat4f OutTan(0.0, 0.0, 0.0, 2.0);
	FQuat4f::CalcTangents(FQuat4f::Identity, FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)), 0.0, OutTan);
	return OutTan.Size() > 0.0 && OutTan.W != 2.0;
}
/** @end */
/**
 * @begin equality
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary tolerance.
 * @covers FQuat4f.equality
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FQuat4f Left = FQuat4f::Identity;
	FQuat4f Right = FQuat4f::Identity;
	FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	return Left == Right && !(Left == Doubled) && !(Left == Yaw);
}
/** @end */
/**
 * @begin equals
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.equals
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FQuat4f Identity = FQuat4f::Identity;
	FQuat4f Copy = FQuat4f::Identity;
	FQuat4f Perturbed(0.0, 0.0, 0.0, 1.0 + KINDA_SMALL_NUMBER * 0.5);
	FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
	bool bExact = Identity.Equals(Copy);
	bool bTolerant = Identity.Equals(Perturbed);
	bool bDefaultTolerance = Identity.Equals(Copy, KINDA_SMALL_NUMBER);
	bool bYawDiffers = Identity.Equals(Yaw);
	return bExact && bTolerant && bDefaultTolerance && !bYawDiffers;
}
/** @end */
/**
 * @begin is-identity
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveIsIdentityNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.is-identity
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsIdentityNominal()
{
	bool bIdentity = FQuat4f::Identity.IsIdentity();
	bool bExplicit = FQuat4f::Identity.IsIdentity(SMALL_NUMBER);
	bool bDoubled = FQuat4f(0.0, 0.0, 0.0, 2.0).IsIdentity();
	bool bYaw = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).IsIdentity();
	return bIdentity && bExplicit && !bDoubled && !bYaw;
}
/** @end */
/**
 * @begin get-normalized
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetNormalizedNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-normalized
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNormalizedNominal()
{
	FQuat4f Doubled(0.0, 0.0, 0.0, 2.0);
	FQuat4f Normalized = Doubled.GetNormalized();
	FQuat4f Explicit = Doubled.GetNormalized(SMALL_NUMBER);
	return Normalized.W == 1.0 && Explicit.W == 1.0 && Doubled.W == 2.0;
}
/** @end */
/**
 * @begin is-normalized
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveIsNormalizedNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.is-normalized
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNormalizedNominal()
{
	return FQuat4f::Identity.IsNormalized() && !FQuat4f(0.0, 0.0, 0.0, 2.0).IsNormalized();
}
/** @end */
/**
 * @begin get-angle
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetAngleNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-angle
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAngleNominal()
{
	float32 IdentityAngle = FQuat4f::Identity.GetAngle();
	float32 YawAngle = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetAngle();
	return IdentityAngle == 0.0 && YawAngle > 1.0;
}
/** @end */
/**
 * @begin contains-na-n
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.contains-na-n
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveContainsNaNNominal()
{
	bool bIdentityFinite = FQuat4f::Identity.ContainsNaN();
	float32 Zero = 0.0;
	FQuat4f NanQuat(0.0, 0.0, 0.0, Zero / Zero);
	bool bNan = NanQuat.ContainsNaN();
	return !bIdentityFinite && bNan;
}
/** @end */
/**
 * @begin get-axis-x
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisXNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-axis-x
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisXNominal()
{
	FVector3f IdentityX = FQuat4f::Identity.GetAxisX();
	FVector3f YawX = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetAxisX();
	return IdentityX.X == 1.0 && YawX.Y > 0.9;
}
/** @end */
/**
 * @begin get-axis-y
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisYNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-axis-y
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisYNominal()
{
	FVector3f IdentityY = FQuat4f::Identity.GetAxisY();
	return IdentityY.Y == 1.0 && IdentityY.X == 0.0;
}
/** @end */
/**
 * @begin get-axis-z
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisZNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-axis-z
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisZNominal()
{
	FVector3f IdentityZ = FQuat4f::Identity.GetAxisZ();
	return IdentityZ.Z == 1.0 && IdentityZ.X == 0.0;
}
/** @end */
/**
 * @begin get-forward-vector
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveGetForwardVectorNominal
 * @summary Boundary/ownership: GetNormalized returns a copy.
 * @covers FQuat4f.get-forward-vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetForwardVectorNominal()
{
	FVector3f Forward = FQuat4f::Identity.GetForwardVector();
	FVector3f YawForward = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetForwardVector();
	return Forward.X == 1.0 && YawForward.Y > 0.9;
}
/** @end */
/**
 * @begin get-right-vector
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetRightVectorNominal
 * @summary new vectors.
 * @covers FQuat4f.get-right-vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRightVectorNominal()
{
	FVector3f Right = FQuat4f::Identity.GetRightVector();
	return Right.Y == 1.0 && Right.X == 0.0;
}
/** @end */
/**
 * @begin get-up-vector
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetUpVectorNominal
 * @summary new vectors.
 * @covers FQuat4f.get-up-vector
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUpVectorNominal()
{
	FVector3f Up = FQuat4f::Identity.GetUpVector();
	return Up.Z == 1.0 && Up.X == 0.0;
}
/** @end */
/**
 * @begin get-rotation-axis
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetRotationAxisNominal
 * @summary new vectors.
 * @covers FQuat4f.get-rotation-axis
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRotationAxisNominal()
{
	FVector3f IdentityAxis = FQuat4f::Identity.GetRotationAxis();
	FVector3f YawAxis = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetRotationAxis();
	return IdentityAxis.Size() > 0.0 && YawAxis.Z > 0.9;
}
/** @end */
/**
 * @begin get-twist-angle
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetTwistAngleNominal
 * @summary new vectors.
 * @covers FQuat4f.get-twist-angle
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTwistAngleNominal()
{
	float32 IdentityTwist = FQuat4f::Identity.GetTwistAngle(FVector3f::UpVector);
	float32 YawTwist = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetTwistAngle(FVector3f::UpVector);
	return IdentityTwist == 0.0 && YawTwist > 1.0;
}
/** @end */
/**
 * @begin find-between
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenNominal
 * @summary new vectors.
 * @covers FQuat4f.find-between
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenNominal()
{
	FQuat4f Same = FQuat4f::FindBetween(FVector3f::ForwardVector, FVector3f::ForwardVector);
	FQuat4f Turn = FQuat4f::FindBetween(FVector3f::ForwardVector, FVector3f::RightVector);
	FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
	return Same.IsIdentity() && Rotated.Y > 0.9;
}
/** @end */
/**
 * @begin find-between-vectors
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenVectorsNominal
 * @summary new vectors.
 * @covers FQuat4f.find-between-vectors
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenVectorsNominal()
{
	FQuat4f Turn = FQuat4f::FindBetweenVectors(FVector3f::ForwardVector, FVector3f::RightVector);
	FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
	return Rotated.Y > 0.9 && Rotated.X < 0.1;
}
/** @end */
/**
 * @begin find-between-normals
 * @summary new vectors.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenNormalsNominal
 * @summary new vectors.
 * @covers FQuat4f.find-between-normals
 * @inputs FQuat4f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenNormalsNominal()
{
	FQuat4f Turn = FQuat4f::FindBetweenNormals(FVector3f::ForwardVector, FVector3f::RightVector);
	FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
	return Rotated.Y > 0.9;
}
/** @end */
