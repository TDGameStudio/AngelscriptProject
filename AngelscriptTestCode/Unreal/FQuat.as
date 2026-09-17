/**
 * @version v1
 * @summary FQuat host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FQuat
 *
 * quat
 * normalize
 * size
 * size-squared
 * log
 * exp
 * inverse
 * angular-distance
 * container-api
 * fquat-y-stores-constructed
 * fquat-z-stores-constructed
 * fquat-w-stores-constructed
 * enforce-shortest-arc-with
 * FQuat-Behavior_02-quat
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
 * divide-assign
 * FQuat-ConstructionAndAssignment_02-assignment
 * to-axis-and-angle
 * to-swing-twist
 * expected-observations
 * make-from-euler
 * make-from-rotator
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
 * find-between
 * find-between-vectors
 * find-between-normals
 * get-axis-x
 * get-axis-y
 * get-axis-z
 * get-forward-vector
 * get-right-vector
 * get-up-vector
 * get-rotation-axis
 * get-twist-angle
 * quat-advanced-operators-and-methods
 * quat-construction
 * quat-conversion-methods
 * quat-inverse-and-normalize
 * quat-member-access
 * quat-multiplication-operator
 * quat-rotate-vector
 * quat-static-methods
 */
/**
 * @begin quat
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveQuatNominal
 * @summary Observe the container API.
 * @covers FQuat.quat
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FQuat Quat(float64 X, float64 Y, float64 Z, float64 W);
// void Quat.Normalize(float64 Tolerance = SMALL_NUMBER);
// float64 Quat.Size() const; float64 Quat.SizeSquared() const;
// FQuat Quat.Log() const; FQuat Quat.Exp() const; FQuat Quat.Inverse() const;
// float64 Quat.AngularDistance(const FQuat& Q) const;
// Inputs: Default, copy of Identity, components (0,0,0,1) and (0,0,0,2),
// SMALL_NUMBER omitted and explicit, yaw 90, and Identity vs itself.
// Expected observations: Default and copy are Identity. Normalize of
// (0,0,0,2) yields W=1. Identity Size/SizeSquared are 1. Log/Exp of
// Identity round-trips. Inverse of Identity is Identity. AngularDistance to
// self is 0 and to yaw 90 is about HALF_PI.
// Boundary/ownership: Normalize mutates the receiver. Log/Exp/Inverse
// return new quaternions.
bool ObserveQuatNominal()
{
	FQuat DefaultQuat;
	FQuat Copied(DefaultQuat);
	FQuat Components(0.0, 0.0, 0.0, 1.0);
	return DefaultQuat.W == 1.0 && Copied.W == 1.0 && Components.W == 1.0 && DefaultQuat.X == 0.0;
}
/** @end */
/**
 * @begin normalize
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary return new quaternions.
 * @covers FQuat.normalize
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveNormalizeNominal()
{
	FQuat Doubled(0.0, 0.0, 0.0, 2.0);
	Doubled.Normalize();
	FQuat Explicit(0.0, 0.0, 0.0, 2.0);
	Explicit.Normalize(SMALL_NUMBER);
	return Doubled.W == 1.0 && Explicit.W == 1.0 && Doubled.IsNormalized();
}
/** @end */
/**
 * @begin size
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary return new quaternions.
 * @covers FQuat.size
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSizeNominal()
{
	return FQuat::Identity.Size() == 1.0 && FQuat(0.0, 0.0, 0.0, 2.0).Size() == 2.0;
}
/** @end */
/**
 * @begin size-squared
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquaredNominal
 * @summary return new quaternions.
 * @covers FQuat.size-squared
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSizeSquaredNominal()
{
	return FQuat::Identity.SizeSquared() == 1.0 && FQuat(0.0, 0.0, 0.0, 2.0).SizeSquared() == 4.0;
}
/** @end */
/**
 * @begin log
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveLogNominal
 * @summary return new quaternions.
 * @covers FQuat.log
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogNominal()
{
	FQuat Logged = FQuat::Identity.Log();
	return Logged.X == 0.0 && Logged.Y == 0.0 && Logged.Z == 0.0;
}
/** @end */
/**
 * @begin exp
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveExpNominal
 * @summary return new quaternions.
 * @covers FQuat.exp
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveExpNominal()
{
	FQuat RoundTrip = FQuat::Identity.Log().Exp();
	return RoundTrip.Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin inverse
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveInverseNominal
 * @summary return new quaternions.
 * @covers FQuat.inverse
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInverseNominal()
{
	FQuat IdentityInverse = FQuat::Identity.Inverse();
	FQuat Yaw = FQuat(FRotator(0, 90, 0));
	FQuat Restored = Yaw.Inverse() * Yaw;
	return IdentityInverse.Equals(FQuat::Identity) && Restored.IsIdentity();
}
/** @end */
/**
 * @begin angular-distance
 * @summary return new quaternions.
 * @topic Unreal
 */
/**
 * @function ObserveAngularDistanceNominal
 * @summary return new quaternions.
 * @covers FQuat.angular-distance
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAngularDistanceNominal()
{
	float64 Same = FQuat::Identity.AngularDistance(FQuat::Identity);
	float64 Yaw = FQuat::Identity.AngularDistance(FQuat(FRotator(0, 90, 0)));
	return Same == 0.0 && Yaw > 1.0;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface028Nominal
 * @summary Observe the container API.
 * @covers FQuat.container-api
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FQuat Quat(const FRotator& R); FQuat Quat(FVector Axis, float64 AngleRad);
// FQuat Quat(const FQuat4f& Quat); FVector Quat.Euler() const;
// FVector Quat.RotateVector(FVector V) const;
// Inputs: Components (0.1,0.2,0.3,0.9), flipped Identity vs Identity,
// Rotator (0,90,0), UpVector with HALF_PI, FQuat4f Identity, and Forward.
// Expected observations: Fields store the constructed components. Flipped W
// becomes positive after EnforceShortestArcWith. Rotator and axis-angle yaw
// turn Forward toward +Y. FQuat4f conversion keeps W=1. Identity Euler is 0.
// Boundary/ownership: Fields alias components. EnforceShortestArcWith
// mutates the receiver. Constructors copy values.
// FQuat.X stores the constructed X of (0.1, 0.2, 0.3, 0.9). Oracle: X == 0.1. Value copy.
bool ObserveSurface028Nominal()
{
	return FQuat(0.1, 0.2, 0.3, 0.9).X == 0.1;
}
/** @end */
/**
 * @begin fquat-y-stores-constructed
 * @summary FQuat.Y stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface029Nominal
 * @summary FQuat.Y stores the constructed
 * @covers FQuat.fquat-y-stores-constructed
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Y of (0.1, 0.2, 0.3, 0.9). Oracle: Y == 0.2. Value copy.
bool ObserveSurface029Nominal()
{
	return FQuat(0.1, 0.2, 0.3, 0.9).Y == 0.2;
}
/** @end */
/**
 * @begin fquat-z-stores-constructed
 * @summary FQuat.Z stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface030Nominal
 * @summary FQuat.Z stores the constructed
 * @covers FQuat.fquat-z-stores-constructed
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Z of (0.1, 0.2, 0.3, 0.9). Oracle: Z == 0.3. Value copy.
bool ObserveSurface030Nominal()
{
	return FQuat(0.1, 0.2, 0.3, 0.9).Z == 0.3;
}
/** @end */
/**
 * @begin fquat-w-stores-constructed
 * @summary FQuat.W stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface031Nominal
 * @summary FQuat.W stores the constructed
 * @covers FQuat.fquat-w-stores-constructed
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 W of (0.1, 0.2, 0.3, 0.9). Oracle: W == 0.9. Value copy.
bool ObserveSurface031Nominal()
{
	return FQuat(0.1, 0.2, 0.3, 0.9).W == 0.9;
}
/** @end */
/**
 * @begin enforce-shortest-arc-with
 * @summary EnforceShortestArcWith flips W into the same hemisphere as Other.
 * @topic Unreal
 */
/**
 * @function ObserveEnforceShortestArcWithNominal
 * @summary EnforceShortestArcWith flips W into the same hemisphere as Other.
 * @covers FQuat.enforce-shortest-arc-with
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEnforceShortestArcWithNominal()
{
	FQuat Flipped(0.0, 0.0, 0.0, -1.0);
	Flipped.EnforceShortestArcWith(FQuat::Identity);
	FQuat AlreadyShort = FQuat::Identity;
	AlreadyShort.EnforceShortestArcWith(FQuat::Identity);
	return Flipped.W > 0.0 && AlreadyShort.W == 1.0;
}
/** @end */
/**
 * @begin FQuat-Behavior_02-quat
 * @summary Rotator, axis-angle, and FQuat4f constructors.
 * @topic Unreal
 */
/**
 * @function ObserveQuatNominal
 * @summary Rotator, axis-angle, and FQuat4f constructors.
 * @covers FQuat.quat
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveQuatNominal()
{
	FQuat FromRotator(FRotator(0, 90, 0));
	FQuat FromAxis(FVector::UpVector, HALF_PI);
	FQuat FromSingle(FQuat4f::Identity);
	return FromRotator.RotateVector(FVector::ForwardVector).Y > 0.9 && FromAxis.RotateVector(FVector::ForwardVector).Y > 0.9 && FromSingle.W == 1.0;
}
/** @end */
/**
 * @begin euler
 * @summary Euler() of Identity is zero; yaw 90 has a non-zero yaw component.
 * @topic Unreal
 */
/**
 * @function ObserveEulerNominal
 * @summary Euler() of Identity is zero; yaw 90 has a non-zero yaw component.
 * @covers FQuat.euler
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEulerNominal()
{
	FVector IdentityEuler = FQuat::Identity.Euler();
	FVector YawEuler = FQuat(FRotator(0, 90, 0)).Euler();
	return IdentityEuler.X == 0.0 && IdentityEuler.Z == 0.0 && YawEuler.Z > 89.0;
}
/** @end */
/**
 * @begin rotate-vector
 * @summary RotateVector of Identity leaves Forward; yaw 90 sends Forward toward +Y.
 * @topic Unreal
 */
/**
 * @function ObserveRotateVectorNominal
 * @summary RotateVector of Identity leaves Forward; yaw 90 sends Forward toward +Y.
 * @covers FQuat.rotate-vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRotateVectorNominal()
{
	FVector IdentityForward = FQuat::Identity.RotateVector(FVector::ForwardVector);
	FVector YawForward = FQuat(FRotator(0, 90, 0)).RotateVector(FVector::ForwardVector);
	return IdentityForward.X == 1.0 && YawForward.Y > 0.9;
}
/** @end */
/**
 * @begin unrotate-vector
 * @summary Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveUnrotateVectorNominal
 * @summary Rotator return new values.
 * @covers FQuat.unrotate-vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnrotateVectorNominal()
{
	FQuat Yaw(FRotator(0, 90, 0));
	FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
	FVector Restored = Yaw.UnrotateVector(Rotated);
	FVector IdentityUnrotated = FQuat::Identity.UnrotateVector(FVector::ForwardVector);
	return Restored.X > 0.9 && IdentityUnrotated.X == 1.0;
}
/** @end */
/**
 * @begin vector
 * @summary Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Rotator return new values.
 * @covers FQuat.vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorNominal()
{
	FVector IdentityVector = FQuat::Identity.Vector();
	FVector YawVector = FQuat(FRotator(0, 90, 0)).Vector();
	return IdentityVector.Equals(FVector::ForwardVector) && YawVector.Y > 0.9;
}
/** @end */
/**
 * @begin rotator
 * @summary Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary Rotator return new values.
 * @covers FQuat.rotator
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotatorNominal()
{
	FRotator IdentityRotator = FQuat::Identity.Rotator();
	FRotator YawRotator = FQuat(FRotator(0, 90, 0)).Rotator();
	return IdentityRotator.Pitch == 0.0 && IdentityRotator.Yaw == 0.0 && YawRotator.Yaw > 0.0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary Rotator return new values.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary Rotator return new values.
 * @covers FQuat.init-from-string
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveInitFromStringNominal()
{
	FString Text = f"{FQuat::Identity}";
	FQuat Parsed;
	bool bParsed = Parsed.InitFromString(Text);
	FQuat Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bParsed && Parsed.Equals(FQuat::Identity) && !bEmptyFailed;
}
/** @end */
/**
 * @begin assignment
 * @summary Inputs: Identity, a
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Inputs: Identity, a
 * @covers FQuat.assignment
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Identity, a

 copy of (0,0,0,2), Other Identity, Scale 2.0, and a
// saved original for independence.
// Expected observations: Assignment copies W. Identity + Identity has W=2.
// += mutates in place. Identity * Identity remains identity. * 2 doubles W.
// / 2 restores W=1. The saved original stays identity.
// Boundary/ownership: Compound operators mutate Quat. Value-returning
// operators return a new quaternion.
bool ObserveAssignmentNominal()
{
	FQuat Left = FQuat::Identity;
	FQuat Right(0.0, 0.0, 0.0, 2.0);
	FQuat Original = Left;
	Left = Right;
	FQuat Sum = FQuat::Identity + FQuat::Identity;
	return Left.W == 2.0 && Original.W == 1.0 && Sum.W == 2.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary operators return a new quaternion.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary operators return a new quaternion.
 * @covers FQuat.add-assign
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Identity, a

bool ObserveAddAssignNominal()
{
	FQuat Quat = FQuat::Identity;
	Quat += FQuat::Identity;
	return Quat.W == 2.0 && FQuat::Identity.W == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary operators return a new quaternion.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary operators return a new quaternion.
 * @covers FQuat.subtract-assign
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Identity, a

bool ObserveSubtractAssignNominal()
{
	FQuat Quat(0.0, 0.0, 0.0, 2.0);
	FQuat Difference = Quat - FQuat::Identity;
	Quat -= FQuat::Identity;
	return Difference.W == 1.0 && Quat.W == 1.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary operators return a new quaternion.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary operators return a new quaternion.
 * @covers FQuat.multiply-assign
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Identity, a

bool ObserveMultiplyAssignNominal()
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
/** @end */
/**
 * @begin divide-assign
 * @summary The formatter copies text.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary The formatter copies text.
 * @covers FQuat.divide-assign
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FQuat Quat(0.0, 0.0, 0.0, 2.0);
	Quat /= 2.0;
	return Quat.W == 1.0 && Quat.X == 0.0;
}
/** @end */
/**
 * @begin FQuat-ConstructionAndAssignment_02-assignment
 * @summary The formatter copies text.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary The formatter copies text.
 * @covers FQuat.assignment
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector Forward = FQuat::Identity * FVector::ForwardVector;
	FQuat Yaw(FRotator(0, 90, 0));
	FVector Turned = Yaw * FVector::ForwardVector;
	FString Text = f"{FQuat::Identity}";
	return Forward.X == 1.0 && Turned.Y > 0.9 && Text.Len() > 0;
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
 * @covers FQuat.to-axis-and-angle
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToAxisAndAngleNominal()
{
	FVector IdentityAxis = FVector::ZeroVector;
	float32 IdentityAngle32 = 1.0;
	FQuat::Identity.ToAxisAndAngle(IdentityAxis, IdentityAngle32);
	FVector YawAxis = FVector::ZeroVector;
	float64 YawAngle64 = 0.0;
	FQuat Yaw(FRotator(0, 90, 0));
	Yaw.ToAxisAndAngle(YawAxis, YawAngle64);
	FVector YawAxis32 = FVector::ZeroVector;
	float32 YawAngle32 = 0.0;
	Yaw.ToAxisAndAngle(YawAxis32, YawAngle32);
	return IdentityAngle32 == 0.0 && YawAngle64 > 1.0 && YawAxis.Z > 0.9 && YawAngle32 > 1.0;
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
 * @covers FQuat.to-swing-twist
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToSwingTwistNominal()
{
	FQuat Swing = FQuat::Identity;
	FQuat Twist = FQuat::Identity;
	FQuat Yaw(FRotator(0, 90, 0));
	Yaw.ToSwingTwist(FVector::UpVector, Swing, Twist);
	FQuat IdentitySwing = FQuat(0.0, 0.0, 0.0, 2.0);
	FQuat IdentityTwist = FQuat(0.0, 0.0, 0.0, 2.0);
	FQuat::Identity.ToSwingTwist(FVector::UpVector, IdentitySwing, IdentityTwist);
	return Swing.IsIdentity() && !Twist.IsIdentity() && IdentitySwing.IsIdentity();
}
/** @end */
/**
 * @begin expected-observations
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSurface043Nominal
 * @summary Expected observations:
 * @covers FQuat.expected-observations
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Identity is (0,0,0,1). Euler/rotator yaw turns
// Forward toward +Y. Lerp/Slerp at 0 and 1 match the endpoints. Error of
// Identity vs itself is 0; vs yaw is positive.
// Boundary/ownership: Identity is a shared constant. Interpolation returns
// new values. Zero-length Slerp is the diagnostic companion.
// FQuat::Identity is the shared (0,0,0,1) constant. Oracle: exact components. Not owned by the caller.
bool ObserveSurface043Nominal()
{
	FQuat Identity = FQuat::Identity;
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
 * @covers FQuat.make-from-euler
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveMakeFromEulerNominal()
{
	FQuat Yaw = FQuat::MakeFromEuler(FVector(0, 0, 90));
	FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
	return Rotated.Y > 0.9;
}
/** @end */
/**
 * @begin make-from-rotator
 * @summary MakeFromRotator(0,90,0) is yaw 90.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromRotatorNominal
 * @summary MakeFromRotator(0,90,0) is yaw 90.
 * @covers FQuat.make-from-rotator
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveMakeFromRotatorNominal()
{
	FQuat Yaw = FQuat::MakeFromRotator(FRotator(0, 90, 0));
	FVector Rotated = Yaw.RotateVector(FVector::ForwardVector);
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
 * @covers FQuat.fast-lerp
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveFastLerpNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::FastLerp(From, To, 0.0);
	FQuat End = FQuat::FastLerp(From, To, 1.0);
	FQuat Mid = FQuat::FastLerp(From, To, 0.5);
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
 * @covers FQuat.fast-bilerp
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 identity at (0,0) and non-zero at (0.5,0.5). New values.
bool ObserveFastBilerpNominal()
{
	FQuat Identity = FQuat::Identity;
	FQuat Result = FQuat::FastBilerp(Identity, Identity, Identity, Identity, 0.5, 0.5);
	FQuat Corner = FQuat::FastBilerp(Identity, Identity, Identity, Identity, 0.0, 0.0);
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
 * @covers FQuat.slerp-not-normalized
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpNotNormalizedNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::Slerp_NotNormalized(From, To, 0.0);
	FQuat End = FQuat::Slerp_NotNormalized(From, To, 1.0);
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
 * @covers FQuat.slerp
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::Slerp(From, To, 0.0);
	FQuat End = FQuat::Slerp(From, To, 1.0);
	FQuat Mid = FQuat::Slerp(From, To, 0.5);
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
 * @covers FQuat.error
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveErrorNominal()
{
	float64 Same = FQuat::Error(FQuat::Identity, FQuat::Identity);
	float64 Different = FQuat::Error(FQuat::Identity, FQuat(FRotator(0, 90, 0)));
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
 * @covers FQuat.error-auto-normalize
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 ErrorAutoNormalize treats (0,0,0,2) as Identity; yaw 90 remains positive. Does not mutate inputs.
bool ObserveErrorAutoNormalizeNominal()
{
	FQuat Doubled(0.0, 0.0, 0.0, 2.0);
	float64 Same = FQuat::ErrorAutoNormalize(Doubled, FQuat::Identity);
	float64 Different = FQuat::ErrorAutoNormalize(FQuat::Identity, FQuat(FRotator(0, 90, 0)));
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
 * @covers FQuat.slerp-full-path-not-normalized
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSlerpFullPathNotNormalizedNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::SlerpFullPath_NotNormalized(From, To, 0.0);
	FQuat End = FQuat::SlerpFullPath_NotNormalized(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin slerp-full-path
 * @summary Tension 0, and OutTan
 * @topic Unreal
 */
/**
 * @function ObserveSlerpFullPathNominal
 * @summary Tension 0, and OutTan
 * @covers FQuat.slerp-full-path
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Tension 0, and OutTan

 seeded to (0,0,0,2) before CalcTangents.
// Expected observations: SlerpFullPath at 0/1 matches endpoints. Squad at 0
// is Quat1 and at 1 is Quat2. CalcTangents overwrites OutTan.
// Boundary/ownership: Interpolation returns new quaternions. OutTan is a
// writeback; the input quaternions are not mutated.
bool ObserveSlerpFullPathNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::SlerpFullPath(From, To, 0.0);
	FQuat End = FQuat::SlerpFullPath(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To);
}
/** @end */
/**
 * @begin squad
 * @summary writeback.
 * @topic Unreal
 */
/**
 * @function ObserveSquadNominal
 * @summary writeback.
 * @covers FQuat.squad
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Tension 0, and OutTan

bool ObserveSquadNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::Squad(From, FQuat::Identity, To, FQuat::Identity, 0.0);
	FQuat End = FQuat::Squad(From, FQuat::Identity, To, FQuat::Identity, 1.0);
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
 * @covers FQuat.squad-full-path
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Tension 0, and OutTan

bool ObserveSquadFullPathNominal()
{
	FQuat From = FQuat::Identity;
	FQuat To = FQuat(FRotator(0, 90, 0));
	FQuat Start = FQuat::SquadFullPath(From, FQuat::Identity, To, FQuat::Identity, 0.0);
	FQuat End = FQuat::SquadFullPath(From, FQuat::Identity, To, FQuat::Identity, 1.0);
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
 * @covers FQuat.calc-tangents
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
// Tension 0, and OutTan

bool ObserveCalcTangentsNominal()
{
	FQuat OutTan(0.0, 0.0, 0.0, 2.0);
	FQuat::CalcTangents(FQuat::Identity, FQuat::Identity, FQuat(FRotator(0, 90, 0)), 0.0, OutTan);
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
 * @covers FQuat.equality
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FQuat Left = FQuat::Identity;
	FQuat Right = FQuat::Identity;
	FQuat Doubled(0.0, 0.0, 0.0, 2.0);
	FQuat Yaw(FRotator(0, 90, 0));
	return Left == Right && !(Left == Doubled) && !(Left == Yaw);
}
/** @end */
/**
 * @begin equals
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary tolerance.
 * @covers FQuat.equals
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FQuat Identity = FQuat::Identity;
	FQuat Copy = FQuat::Identity;
	FQuat Perturbed(0.0, 0.0, 0.0, 1.0 + KINDA_SMALL_NUMBER * 0.5);
	FQuat Yaw(FRotator(0, 90, 0));
	bool bExact = Identity.Equals(Copy);
	bool bTolerant = Identity.Equals(Perturbed);
	bool bDefaultTolerance = Identity.Equals(Copy, KINDA_SMALL_NUMBER);
	bool bYawDiffers = Identity.Equals(Yaw);
	return bExact && bTolerant && bDefaultTolerance && !bYawDiffers;
}
/** @end */
/**
 * @begin is-identity
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsIdentityNominal
 * @summary tolerance.
 * @covers FQuat.is-identity
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsIdentityNominal()
{
	bool bIdentity = FQuat::Identity.IsIdentity();
	bool bExplicit = FQuat::Identity.IsIdentity(SMALL_NUMBER);
	bool bDoubled = FQuat(0.0, 0.0, 0.0, 2.0).IsIdentity();
	bool bYaw = FQuat(FRotator(0, 90, 0)).IsIdentity();
	return bIdentity && bExplicit && !bDoubled && !bYaw;
}
/** @end */
/**
 * @begin get-normalized
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetNormalizedNominal
 * @summary tolerance.
 * @covers FQuat.get-normalized
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNormalizedNominal()
{
	FQuat Doubled(0.0, 0.0, 0.0, 2.0);
	FQuat Normalized = Doubled.GetNormalized();
	FQuat Explicit = Doubled.GetNormalized(SMALL_NUMBER);
	return Normalized.W == 1.0 && Explicit.W == 1.0 && Doubled.W == 2.0;
}
/** @end */
/**
 * @begin is-normalized
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsNormalizedNominal
 * @summary tolerance.
 * @covers FQuat.is-normalized
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNormalizedNominal()
{
	return FQuat::Identity.IsNormalized() && !FQuat(0.0, 0.0, 0.0, 2.0).IsNormalized();
}
/** @end */
/**
 * @begin get-angle
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetAngleNominal
 * @summary tolerance.
 * @covers FQuat.get-angle
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAngleNominal()
{
	float64 IdentityAngle = FQuat::Identity.GetAngle();
	float64 YawAngle = FQuat(FRotator(0, 90, 0)).GetAngle();
	return IdentityAngle == 0.0 && YawAngle > 1.0;
}
/** @end */
/**
 * @begin contains-na-n
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary tolerance.
 * @covers FQuat.contains-na-n
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveContainsNaNNominal()
{
	bool bIdentityFinite = FQuat::Identity.ContainsNaN();
	float64 Zero = 0.0;
	FQuat NanQuat(0.0, 0.0, 0.0, Zero / Zero);
	bool bNan = NanQuat.ContainsNaN();
	return !bIdentityFinite && bNan;
}
/** @end */
/**
 * @begin find-between
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenNominal
 * @summary tolerance.
 * @covers FQuat.find-between
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenNominal()
{
	FQuat Same = FQuat::FindBetween(FVector::ForwardVector, FVector::ForwardVector);
	FQuat Turn = FQuat::FindBetween(FVector::ForwardVector, FVector::RightVector);
	FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
	return Same.IsIdentity() && Rotated.Y > 0.9;
}
/** @end */
/**
 * @begin find-between-vectors
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenVectorsNominal
 * @summary tolerance.
 * @covers FQuat.find-between-vectors
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenVectorsNominal()
{
	FQuat Turn = FQuat::FindBetweenVectors(FVector::ForwardVector, FVector::RightVector);
	FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
	return Rotated.Y > 0.9 && Rotated.X < 0.1;
}
/** @end */
/**
 * @begin find-between-normals
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveFindBetweenNormalsNominal
 * @summary tolerance.
 * @covers FQuat.find-between-normals
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindBetweenNormalsNominal()
{
	FQuat Turn = FQuat::FindBetweenNormals(FVector::ForwardVector, FVector::RightVector);
	FVector Rotated = Turn.RotateVector(FVector::ForwardVector);
	return Rotated.Y > 0.9;
}
/** @end */
/**
 * @begin get-axis-x
 * @summary tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisXNominal
 * @summary tolerance.
 * @covers FQuat.get-axis-x
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisXNominal()
{
	FVector IdentityX = FQuat::Identity.GetAxisX();
	FVector YawX = FQuat(FRotator(0, 90, 0)).GetAxisX();
	return IdentityX.X == 1.0 && YawX.Y > 0.9;
}
/** @end */
/**
 * @begin get-axis-y
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisYNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-axis-y
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisYNominal()
{
	FVector IdentityY = FQuat::Identity.GetAxisY();
	return IdentityY.Y == 1.0 && IdentityY.X == 0.0;
}
/** @end */
/**
 * @begin get-axis-z
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisZNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-axis-z
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisZNominal()
{
	FVector IdentityZ = FQuat::Identity.GetAxisZ();
	return IdentityZ.Z == 1.0 && IdentityZ.X == 0.0;
}
/** @end */
/**
 * @begin get-forward-vector
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetForwardVectorNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-forward-vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetForwardVectorNominal()
{
	FVector Forward = FQuat::Identity.GetForwardVector();
	FVector YawForward = FQuat(FRotator(0, 90, 0)).GetForwardVector();
	return Forward.X == 1.0 && YawForward.Y > 0.9;
}
/** @end */
/**
 * @begin get-right-vector
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetRightVectorNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-right-vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRightVectorNominal()
{
	FVector Right = FQuat::Identity.GetRightVector();
	return Right.Y == 1.0 && Right.X == 0.0;
}
/** @end */
/**
 * @begin get-up-vector
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetUpVectorNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-up-vector
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUpVectorNominal()
{
	FVector Up = FQuat::Identity.GetUpVector();
	return Up.Z == 1.0 && Up.X == 0.0;
}
/** @end */
/**
 * @begin get-rotation-axis
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetRotationAxisNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-rotation-axis
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRotationAxisNominal()
{
	FVector IdentityAxis = FQuat::Identity.GetRotationAxis();
	FVector YawAxis = FQuat(FRotator(0, 90, 0)).GetRotationAxis();
	return IdentityAxis.Size() > 0.0 && YawAxis.Z > 0.9;
}
/** @end */
/**
 * @begin get-twist-angle
 * @summary signed radians around InTwistAxis.
 * @topic Unreal
 */
/**
 * @function ObserveGetTwistAngleNominal
 * @summary signed radians around InTwistAxis.
 * @covers FQuat.get-twist-angle
 * @inputs FQuat values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTwistAngleNominal()
{
	float64 IdentityTwist = FQuat::Identity.GetTwistAngle(FVector::UpVector);
	float64 YawTwist = FQuat(FRotator(0, 90, 0)).GetTwistAngle(FVector::UpVector);
	return IdentityTwist == 0.0 && YawTwist > 1.0;
}
/** @end */
/**
 * @begin quat-advanced-operators-and-methods
 * @summary Observe that copy construction and assignment both reproduce the source, and that the equality operator agrees with the toleranced comparison.
 * @topic Unreal
 */
/**
 * @function CopyAssignAndEquality
 * @summary Observe that copy construction and assignment both reproduce the source, and that the equality operator agrees with the toleranced comparison.
 * @covers FQuat.AdvancedOperatorsAndMethods
 * @inputs a quarter-turn quaternion
 * @return true when the assignment compares equal both exactly and within tolerance
 */
bool CopyAssignAndEquality()
{
	FQuat Source = FQuat(FVector::UpVector, 1.5707963267948966);
	FQuat Copy(Source);
	FQuat Assigned;
	Assigned = Copy;

	if (Assigned != Source)
	{
		return false;
	}
	return Assigned.Equals(Source, 0.001);
}
/** @end */
/**
 * @begin quat-construction
 * @summary Construct a quaternion from an axis and an angle in radians.
 * @topic Unreal
 */
/**
 * @function DefaultIsIdentity
 * @summary Construct a quaternion from an axis and an angle in radians.
 * @covers FQuat.Construction
 * @inputs none
 * @return the quaternion for a ninety degree turn about the up axis
 */
eturn FQuat(axis, angleRad);
}

/**
 * Observe that the default constructor yields the identity rotation.
 *
 * @Kind Observe
 * @Covers FQuat.Construction
 * @Inputs none
 * @Return true when the default equals the identity constant
 */
UFUNCTION()
bool DefaultIsIdentity()
{
	return ConstructDefault().Equals(FQuat::Identity, 0.001);
}
/** @end */
/**
 * @begin quat-conversion-methods
 * @summary Read the up axis of an unrotated quaternion.
 * @topic Unreal
 */
/**
 * @function QuatToRotatorNominal
 * @summary Read the up axis of an unrotated quaternion.
 * @covers FQuat.ConversionMethods
 * @inputs none
 * @return the Z axis, which should be the up vector
 */
 equals FRotator(0, 90, 0)
 */
UFUNCTION()
bool QuatToRotatorNominal()
{
	return QuatToRotator().Equals(FRotator(0, 90, 0), 0.1);
}
/** @end */
/**
 * @begin quat-inverse-and-normalize
 * @summary Report whether the identity is normalized.
 * @topic Unreal
 */
/**
 * @function IsNormalized
 * @summary Report whether the identity is normalized.
 * @covers FQuat.InverseAndNormalize
 * @inputs none
 * @return the IsNormalized flag of the identity, expected true
 */
bool IsNormalized()
{
	FQuat q = FQuat::Identity;
	return q.IsNormalized();
}
/** @end */
/**
 * @begin quat-member-access
 * @summary Observe that all four getters read their own component.
 * @topic Unreal
 */
/**
 * @function GettersNominal
 * @summary Observe that all four getters read their own component.
 * @covers FQuat.MemberAccess
 * @inputs none
 * @return true when X, Y, Z and W read 0.1, 0.2, 0.3 and 0.9
 */
bool GettersNominal()
{
	if (GetX() != 0.1)
	{
		return false;
	}
	if (GetY() != 0.2)
	{
		return false;
	}
	if (GetZ() != 0.3)
	{
		return false;
	}
	return GetW() == 0.9;
}
/** @end */
/**
 * @begin quat-multiplication-operator
 * @summary Observe that composing two rotations matches the native product.
 * @topic Unreal
 */
/**
 * @function MultiplyQuatsNominal
 * @summary Observe that composing two rotations matches the native product.
 * @covers FQuat.MultiplicationOperator
 * @inputs none
 * @return true when the result equals q1
 */
bool MultiplyQuatsNominal()
{
	FQuat q1 = FQuat(FRotator(0, 45, 0));
	FQuat q2 = FQuat(FRotator(0, 45, 0));
	return MultiplyQuats().Equals(q1 * q2, 0.01);
}
/** @end */
/**
 * @begin quat-rotate-vector
 * @summary Observe that the rotation matches the native RotateVector result.
 * @topic Unreal
 */
/**
 * @function RotateForwardBy90Nominal
 * @summary Observe that the rotation matches the native RotateVector result.
 * @covers FQuat.RotateVector
 * @inputs none
 * @return true when the result equals q.RotateVector(FVector(1, 0, 0))
 */
bool RotateForwardBy90Nominal()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return RotateForwardBy90().Equals(q.RotateVector(FVector(1, 0, 0)), 0.01);
}
/** @end */
/**
 * @begin quat-static-methods
 * @summary Observe that the interpolation matches the native Slerp result.
 * @topic Unreal
 */
/**
 * @function SlerpQuatsNominal
 * @summary Observe that the interpolation matches the native Slerp result.
 * @covers FQuat.StaticMethods
 * @inputs none
 * @return true when the result equals FQuat::Slerp(q1, q2, 0.5)
 */
bool SlerpQuatsNominal()
{
	FQuat q1 = FQuat::Identity;
	FQuat q2 = FQuat(FRotator(0, 90, 0));
	return SlerpQuats().Equals(FQuat::Slerp(q1, q2, 0.5), 0.01);
}
/** @end */
