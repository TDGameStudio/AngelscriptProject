/**
 * @version v1
 * @summary FRotator host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FRotator
 *
 * rotator
 * frotator-pitch-stores-constructed
 * frotator-yaw-stores-constructed
 * frotator-roll-stores-constructed
 * clamp
 * normalize
 * vector
 * quaternion
 * euler
 * rotate-vector
 * unrotate-vector
 * init-from-string
 * surface-001
 * assignment
 * add-assign
 * subtract-assign
 * multiply-assign
 * to-color-string
 * to-string
 * append
 * boundary-ownership
 * normalize-axis
 * clamp-axis
 * make-from-euler
 * make-from-x
 * make-from-y
 * make-from-z
 * make-from-xy
 * make-from-xz
 * make-from-yx
 * make-from-yz
 * make-from-zx
 * make-from-zy
 * addition
 * subtraction
 * prefix-rot
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
 * get-forward-vector
 * get-right-vector
 * get-up-vector
 * rotator-arithmetic-operators
 * rotator-comparison-operators
 * rotator-construction
 * rotator-conversion-methods
 * rotator-declarations-and-confirmed-methods
 * rotator-member-access
 * rotator-normalization-methods
 * rotator-static-methods
 * container-properties
 * declaration-defaults
 * write-round-trip
 * function-default-parameters
 * function-parameters-in
 * function-parameters-in-out
 * function-parameters-out
 * function-parameters-value
 * function-return-values

 */
/**
 * @begin rotator
 * @summary Component, default, scalar, copy, quat, and FRotator3f constructors.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorNominal
 * @summary Component, default, scalar, copy, quat, and FRotator3f constructors.
 * @covers FRotator.rotator
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotatorNominal()
{
	FRotator Components(10.0, 20.0, 30.0);
	FRotator DefaultRotator;
	FRotator Scalar(7.0);
	FRotator Copied(Components);
	FRotator FromQuat(FQuat::Identity);
	FRotator FromSingle(FRotator3f(1.0, 2.0, 3.0));
	Components.Pitch = 0.0;
	bool bComponents = Copied.Pitch == 10.0 && Copied.Yaw == 20.0 && Copied.Roll == 30.0;
	bool bDefaultZero = DefaultRotator.IsZero();
	bool bScalarFilled = Scalar.Pitch == 7.0 && Scalar.Yaw == 7.0 && Scalar.Roll == 7.0;
	bool bFromQuatZero = FromQuat.IsNearlyZero();
	bool bFromSingle = FromSingle.Pitch == 1.0 && FromSingle.Yaw == 2.0 && FromSingle.Roll == 3.0;
	return bComponents && bDefaultZero && bScalarFilled && bFromQuatZero && bFromSingle && Copied.Pitch == 10.0;
}
/** @end */
/**
 * @begin frotator-pitch-stores-constructed
 * @summary FRotator.Pitch stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FRotator.Pitch stores the constructed
 * @covers FRotator.frotator-pitch-stores-constructed
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
 pitch of (10,20,30). Oracle: Pitch == 10. Value copy.
bool ObserveSurface008Nominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	return Rotator.Pitch == 10.0;
}
/** @end */
/**
 * @begin frotator-yaw-stores-constructed
 * @summary FRotator.Yaw stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FRotator.Yaw stores the constructed
 * @covers FRotator.frotator-yaw-stores-constructed
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
 yaw of (10,20,30). Oracle: Yaw == 20. Value copy.
bool ObserveSurface009Nominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	return Rotator.Yaw == 20.0;
}
/** @end */
/**
 * @begin frotator-roll-stores-constructed
 * @summary FRotator.Roll stores the constructed
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FRotator.Roll stores the constructed
 * @covers FRotator.frotator-roll-stores-constructed
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
 roll of (10,20,30). Oracle: Roll == 30. Value copy.
bool ObserveSurface010Nominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	return Rotator.Roll == 30.0;
}
/** @end */
/**
 * @begin clamp
 * @summary Clamp of yaw 370 is 10 in [0,360); ZeroRotator stays zero.
 * @topic Unreal
 */
/**
 * @function ObserveClampNominal
 * @summary Clamp of yaw 370 is 10 in [0,360); ZeroRotator stays zero.
 * @covers FRotator.clamp
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClampNominal()
{
	FRotator Over(0.0, 370.0, 0.0);
	FRotator Clamped = Over.Clamp();
	FRotator ZeroClamped = FRotator::ZeroRotator.Clamp();
	return Clamped.Yaw == 10.0 && ZeroClamped.IsZero() && Over.Yaw == 370.0;
}
/** @end */
/**
 * @begin normalize
 * @summary Zero Quaternion is Identity.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Zero Quaternion is Identity.
 * @covers FRotator.normalize
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

 Euler of (10,20,30) is (30,10,20). Yaw 90
// rotates X onto Y. InitFromString succeeds for P/Y/R text and fails on empty.
// Boundary/ownership: Normalize mutates the receiver. InitFromString mutates
// and reports success. Euler is (Roll, Pitch, Yaw).
bool ObserveNormalizeNominal()
{
	FRotator Over(0.0, 270.0, 0.0);
	Over.Normalize();
	FRotator Zero;
	Zero.Normalize();
	return Over.Yaw == -90.0 && Zero.IsZero();
}
/** @end */
/**
 * @begin vector
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary and reports success.
 * @covers FRotator.vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveVectorNominal()
{
	FVector ZeroForward = FRotator::ZeroRotator.Vector();
	FVector Yaw90Forward = FRotator(0.0, 90.0, 0.0).Vector();
	return ZeroForward.Equals(FVector::ForwardVector) && Yaw90Forward.Equals(FVector::RightVector);
}
/** @end */
/**
 * @begin quaternion
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveQuaternionNominal
 * @summary and reports success.
 * @covers FRotator.quaternion
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveQuaternionNominal()
{
	FQuat Identity = FRotator::ZeroRotator.Quaternion();
	FQuat FromYaw = FRotator(0.0, 90.0, 0.0).Quaternion();
	return Identity.Equals(FQuat::Identity) && !FromYaw.Equals(FQuat::Identity);
}
/** @end */
/**
 * @begin euler
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveEulerNominal
 * @summary and reports success.
 * @covers FRotator.euler
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveEulerNominal()
{
	FVector Euler = FRotator(10.0, 20.0, 30.0).Euler();
	FVector ZeroEuler = FRotator::ZeroRotator.Euler();
	return Euler.X == 30.0 && Euler.Y == 10.0 && Euler.Z == 20.0 && ZeroEuler.IsNearlyZero();
}
/** @end */
/**
 * @begin rotate-vector
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveRotateVectorNominal
 * @summary and reports success.
 * @covers FRotator.rotate-vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveRotateVectorNominal()
{
	FRotator Yaw90(0.0, 90.0, 0.0);
	FVector Rotated = Yaw90.RotateVector(FVector::ForwardVector);
	FVector Unchanged = FRotator::ZeroRotator.RotateVector(FVector::ForwardVector);
	return Rotated.Equals(FVector::RightVector) && Unchanged.Equals(FVector::ForwardVector);
}
/** @end */
/**
 * @begin unrotate-vector
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveUnrotateVectorNominal
 * @summary and reports success.
 * @covers FRotator.unrotate-vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveUnrotateVectorNominal()
{
	FRotator Yaw90(0.0, 90.0, 0.0);
	FVector Unrotated = Yaw90.UnrotateVector(FVector::RightVector);
	FVector RoundTrip = Yaw90.UnrotateVector(Yaw90.RotateVector(FVector(1.0, 2.0, 3.0)));
	return Unrotated.Equals(FVector::ForwardVector) && RoundTrip.Equals(FVector(1.0, 2.0, 3.0));
}
/** @end */
/**
 * @begin init-from-string
 * @summary and reports success.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary and reports success.
 * @covers FRotator.init-from-string
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Zero Quaternion is Identity.

bool ObserveInitFromStringNominal()
{
	FRotator Parsed;
	bool bValid = Parsed.InitFromString("P=10 Y=20 R=30");
	FRotator Failed;
	bool bEmptyFailed = Failed.InitFromString("");
	return bValid && Parsed.Pitch == 10.0 && Parsed.Yaw == 20.0 && Parsed.Roll == 30.0 && !bEmptyFailed;
}
/** @end */
/**
 * @begin surface-001
 * @summary length.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary length.
 * @covers FRotator.surface-001
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// length. The copied

 original stays (10,20,30).
// Boundary/ownership: Compound operators mutate the left rotator. Text +=
// appends ToString text without mutating the rotator.
// Default FRotator is the zero rotator. Oracle: Pitch/Yaw/Roll == 0. Value construction.
bool ObserveSurface001Nominal()
{
	FRotator Rotator;
	return Rotator.Pitch == 0.0 && Rotator.Yaw == 0.0 && Rotator.Roll == 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Assignment copies components independently; Text += Rotator grows the prefix.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Assignment copies components independently; Text += Rotator grows the prefix.
 * @covers FRotator.assignment
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// length. The copied

bool ObserveAssignmentNominal()
{
	FRotator Rotator;
	FRotator Other(10.0, 20.0, 30.0);
	FRotator Original = Other;
	Rotator = Other;
	bool bCopied = Rotator.Pitch == 10.0 && Rotator.Yaw == 20.0 && Rotator.Roll == 30.0;
	Other.Yaw = 90.0;
	bool bIndependent = Original.Yaw == 20.0 && Rotator.Yaw == 20.0;
	FString Text = "rot:";
	int Before = Text.Len();
	Text += Rotator;
	return bCopied && bIndependent && Text.Len() > Before;
}
/** @end */
/**
 * @begin add-assign
 * @summary += adds degree components in place.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary += adds degree components in place.
 * @covers FRotator.add-assign
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// length. The copied

bool ObserveAddAssignNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FRotator Other(1.0, 2.0, 3.0);
	Rotator += Other;
	return Rotator.Pitch == 11.0 && Rotator.Yaw == 22.0 && Rotator.Roll == 33.0 && Other.Pitch == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary -= subtracts degree components in place.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary -= subtracts degree components in place.
 * @covers FRotator.subtract-assign
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// length. The copied

bool ObserveSubtractAssignNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	Rotator -= FRotator(1.0, 2.0, 3.0);
	return Rotator.Pitch == 9.0 && Rotator.Yaw == 18.0 && Rotator.Roll == 27.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary = scales degree components in place.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary = scales degree components in place.
 * @covers FRotator.multiply-assign
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// length. The copied

bool ObserveMultiplyAssignNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	Rotator *= 2.0;
	return Rotator.Pitch == 20.0 && Rotator.Yaw == 40.0 && Rotator.Roll == 60.0;
}
/** @end */
/**
 * @begin to-color-string
 * @summary Boundary/ownership: Both methods return new strings.
 * @topic Unreal
 */
/**
 * @function ObserveToColorStringNominal
 * @summary Boundary/ownership: Both methods return new strings.
 * @covers FRotator.to-color-string
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToColorStringNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FString ColorText = Rotator.ToColorString();
	FString ZeroText = FRotator::ZeroRotator.ToColorString();
	bool bHasComponents = ColorText.Contains("P=") && ColorText.Contains("Y=") && ColorText.Contains("R=");
	bool bHasColorTags = ColorText.Contains("<Green>") && ColorText.Contains("<Blue>") && ColorText.Contains("<Red>");
	return bHasComponents && bHasColorTags && ZeroText.Len() > 0 && Rotator.Pitch == 10.0;
}
/** @end */
/**
 * @begin to-string
 * @summary Boundary/ownership: Both methods return new strings.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary Boundary/ownership: Both methods return new strings.
 * @covers FRotator.to-string
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FString Text = Rotator.ToString();
	FString ZeroText = FRotator::ZeroRotator.ToString();
	return Text.Contains("P=") && Text.Contains("Y=") && Text.Contains("R=") && ZeroText.Len() > 0 && Rotator.Yaw == 20.0;
}
/** @end */
/**
 * @begin append
 * @summary The FRotator value is not mutated.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary The FRotator value is not mutated.
 * @covers FRotator.append
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
{
	FString Text = "rot:";
	FRotator Rotator(10.0, 20.0, 30.0);
	int Before = Text.Len();
	Text.Append(Rotator);
	int AfterFirst = Text.Len();
	Text.Append(Rotator);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Rotator.Pitch == 10.0;
}
/** @end */
/**
 * @begin boundary-ownership
 * @summary Boundary/ownership:
 * @topic Unreal
 */
/**
 * @function ObserveSurface030Nominal
 * @summary Boundary/ownership:
 * @covers FRotator.boundary-ownership
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

 NormalizeAxis uses (-180, 180]. ClampAxis uses [0, 360).
// MakeFrom* returns a new rotator and prioritizes the first named axis.
// FRotator::ZeroRotator is the shared zero constant. Oracle: IsZero and exact 0 components. Not owned by the caller.
bool ObserveSurface030Nominal()
{
	FRotator Zero = FRotator::ZeroRotator;
	return Zero.IsZero() && Zero.Pitch == 0.0 && Zero.Yaw == 0.0 && Zero.Roll == 0.0;
}
/** @end */
/**
 * @begin normalize-axis
 * @summary NormalizeAxis maps 270 to -90 and -270 to 90, leaving 0 unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeAxisNominal
 * @summary NormalizeAxis maps 270 to -90 and -270 to 90, leaving 0 unchanged.
 * @covers FRotator.normalize-axis
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

 Degrees in (-180, 180].
bool ObserveNormalizeAxisNominal()
{
	float64 Wrapped = FRotator::NormalizeAxis(270.0);
	float64 Negative = FRotator::NormalizeAxis(-270.0);
	float64 Unchanged = FRotator::NormalizeAxis(0.0);
	return Wrapped == -90.0 && Negative == 90.0 && Unchanged == 0.0;
}
/** @end */
/**
 * @begin clamp-axis
 * @summary ClampAxis maps -90 to 270 and 370 to 10, leaving 0 unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveClampAxisNominal
 * @summary ClampAxis maps -90 to 270 and 370 to 10, leaving 0 unchanged.
 * @covers FRotator.clamp-axis
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveClampAxisNominal()
{
	float64 FromNegative = FRotator::ClampAxis(-90.0);
	float64 FromOver = FRotator::ClampAxis(370.0);
	float64 Unchanged = FRotator::ClampAxis(0.0);
	return FromNegative == 270.0 && FromOver == 10.0 && Unchanged == 0.0;
}
/** @end */
/**
 * @begin make-from-euler
 * @summary MakeFromEuler(30,10,20) stores Roll/Pitch/Yaw as Pitch=10, Yaw=20, Roll=30.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromEulerNominal
 * @summary MakeFromEuler(30,10,20) stores Roll/Pitch/Yaw as Pitch=10, Yaw=20, Roll=30.
 * @covers FRotator.make-from-euler
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromEulerNominal()
{
	FRotator FromEuler = FRotator::MakeFromEuler(FVector(30.0, 10.0, 20.0));
	return FromEuler.Pitch == 10.0 && FromEuler.Yaw == 20.0 && FromEuler.Roll == 30.0;
}
/** @end */
/**
 * @begin make-from-x
 * @summary MakeFromX(Forward) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromXNominal
 * @summary MakeFromX(Forward) is ZeroRotator.
 * @covers FRotator.make-from-x
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromXNominal()
{
	FRotator FromX = FRotator::MakeFromX(FVector::ForwardVector);
	return FromX.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-y
 * @summary MakeFromY(Right) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromYNominal
 * @summary MakeFromY(Right) is ZeroRotator.
 * @covers FRotator.make-from-y
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromYNominal()
{
	FRotator FromY = FRotator::MakeFromY(FVector::RightVector);
	return FromY.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-z
 * @summary MakeFromZ(Up) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromZNominal
 * @summary MakeFromZ(Up) is ZeroRotator.
 * @covers FRotator.make-from-z
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromZNominal()
{
	FRotator FromZ = FRotator::MakeFromZ(FVector::UpVector);
	return FromZ.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-xy
 * @summary MakeFromXY(Forward, Right) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromXYNominal
 * @summary MakeFromXY(Forward, Right) is ZeroRotator.
 * @covers FRotator.make-from-xy
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromXYNominal()
{
	FRotator FromXY = FRotator::MakeFromXY(FVector::ForwardVector, FVector::RightVector);
	return FromXY.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-xz
 * @summary MakeFromXZ(Forward, Up) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromXZNominal
 * @summary MakeFromXZ(Forward, Up) is ZeroRotator.
 * @covers FRotator.make-from-xz
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromXZNominal()
{
	FRotator FromXZ = FRotator::MakeFromXZ(FVector::ForwardVector, FVector::UpVector);
	return FromXZ.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-yx
 * @summary MakeFromYX(Right, Forward) is ZeroRotator.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromYXNominal
 * @summary MakeFromYX(Right, Forward) is ZeroRotator.
 * @covers FRotator.make-from-yx
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Boundary/ownership:

bool ObserveMakeFromYXNominal()
{
	FRotator FromYX = FRotator::MakeFromYX(FVector::RightVector, FVector::ForwardVector);
	return FromYX.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-yz
 * @summary are new rotators.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromYZNominal
 * @summary are new rotators.
 * @covers FRotator.make-from-yz
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromYZNominal()
{
	FRotator FromYZ = FRotator::MakeFromYZ(FVector::RightVector, FVector::UpVector);
	return FromYZ.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-zx
 * @summary are new rotators.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromZXNominal
 * @summary are new rotators.
 * @covers FRotator.make-from-zx
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromZXNominal()
{
	FRotator FromZX = FRotator::MakeFromZX(FVector::UpVector, FVector::ForwardVector);
	return FromZX.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin make-from-zy
 * @summary are new rotators.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromZYNominal
 * @summary are new rotators.
 * @covers FRotator.make-from-zy
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromZYNominal()
{
	FRotator FromZY = FRotator::MakeFromZY(FVector::UpVector, FVector::RightVector);
	return FromZY.Equals(FRotator::ZeroRotator);
}
/** @end */
/**
 * @begin addition
 * @summary Expected observations: + is (11,22,33).
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Expected observations: + is (11,22,33).
 * @covers FRotator.addition
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (11,22,33). - is (9,18,27). *

 2 is (20,40,60).
// Identical copies compare true. Zero addition is stable. Text + Rotator is
// longer than the prefix. Left operands are unchanged.
// Boundary/ownership: These operators return new values. They do not mutate
// Rotator.
// FRotator + FRotator. Inputs (10,20,30) and (1,2,3). Sum is (11,22,33);
// adding ZeroRotator is stable. Value-returning; left rotator unchanged.
bool ObserveAdditionNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FRotator Other(1.0, 2.0, 3.0);
	FRotator Sum = Rotator + Other;
	FRotator WithZero = Rotator + FRotator::ZeroRotator;
	return Sum.Pitch == 11.0 && Sum.Yaw == 22.0 && Sum.Roll == 33.0 && WithZero.Pitch == 10.0 && Rotator.Pitch == 10.0;
}
/** @end */
/**
 * @begin subtraction
 * @summary (9,18,27).
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary (9,18,27).
 * @covers FRotator.subtraction
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (11,22,33). - is (9,18,27). *

bool ObserveSubtractionNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FRotator Difference = Rotator - FRotator(1.0, 2.0, 3.0);
	return Difference.Pitch == 9.0 && Difference.Yaw == 18.0 && Difference.Roll == 27.0 && Rotator.Yaw == 20.0;
}
/** @end */
/**
 * @begin prefix-rot
 * @summary and prefix "rot:".
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary and prefix "rot:".
 * @covers FRotator.prefix-rot
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (11,22,33). - is (9,18,27). *

 Scaled is (20,40,60); concat length exceeds 4.
// Value-returning; rotator unchanged.
bool ObserveSurface016Nominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FRotator Scaled = Rotator * 2.0;
	FString Text = "rot:" + Rotator;
	return Scaled.Pitch == 20.0 && Scaled.Yaw == 40.0 && Scaled.Roll == 60.0 && Text.Len() > 4 && Rotator.Roll == 30.0;
}
/** @end */
/**
 * @begin equality
 * @summary FRotator equality.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary FRotator equality.
 * @covers FRotator.equality
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (11,22,33). - is (9,18,27). *

 Inputs identical (10,20,30) copies and a 21 yaw.
// Identical copies are true; different yaw is false. Exact degrees.
bool ObserveEqualityNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	FRotator Same(10.0, 20.0, 30.0);
	FRotator Different(10.0, 21.0, 30.0);
	return (Rotator == Same) && !(Rotator == Different);
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
 * @covers FRotator.is-nearly-zero
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNearlyZeroNominal()
{
	FRotator Zero = FRotator::ZeroRotator;
	FRotator Offset(10.0, 0.0, 0.0);
	return Zero.IsNearlyZero() && Zero.IsNearlyZero(KINDA_SMALL_NUMBER) && !Offset.IsNearlyZero();
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
 * @covers FRotator.is-zero
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsZeroNominal()
{
	FRotator Zero;
	FRotator Offset(10.0, 0.0, 0.0);
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
 * @covers FRotator.equals
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FRotator Left(10.0, 20.0, 30.0);
	FRotator Right(10.0, 20.0, 30.0);
	FRotator Different(10.0, 90.0, 30.0);
	return Left.Equals(Right) && Left.Equals(Right, KINDA_SMALL_NUMBER) && !Left.Equals(Different);
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
 * @covers FRotator.get-inverse
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInverseNominal()
{
	FRotator Yaw90(0.0, 90.0, 0.0);
	FRotator Inverse = Yaw90.GetInverse();
	FRotator RoundTrip = Inverse.GetInverse();
	return Inverse.Equals(FRotator(0.0, -90.0, 0.0)) && RoundTrip.Equals(Yaw90);
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
 * @covers FRotator.get-normalized
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNormalizedNominal()
{
	FRotator Over(0.0, 270.0, 0.0);
	FRotator Normalized = Over.GetNormalized();
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
 * @covers FRotator.get-denormalized
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDenormalizedNominal()
{
	FRotator Signed(0.0, -90.0, 0.0);
	FRotator Denormalized = Signed.GetDenormalized();
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
 * @covers FRotator.get-winding-and-remainder
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetWindingAndRemainderNominal()
{
	FRotator Over(0.0, 370.0, 0.0);
	FRotator Winding;
	FRotator Remainder;
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
 * @covers FRotator.get-manhattan-distance
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetManhattanDistanceNominal()
{
	FRotator Rotator(10.0, 20.0, 30.0);
	float64 ToZero = Rotator.GetManhattanDistance(FRotator::ZeroRotator);
	float64 ToSelf = Rotator.GetManhattanDistance(Rotator);
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
 * @covers FRotator.contains-na-n
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveContainsNaNNominal()
{
	FRotator Finite(10.0, 20.0, 30.0);
	FRotator Zero;
	return !Finite.ContainsNaN() && !Zero.ContainsNaN();
}
/** @end */
/**
 * @begin get-forward-vector
 * @summary mutate the receiver except through those out parameters.
 * @topic Unreal
 */
/**
 * @function ObserveGetForwardVectorNominal
 * @summary mutate the receiver except through those out parameters.
 * @covers FRotator.get-forward-vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetForwardVectorNominal()
{
	FVector ZeroForward = FRotator::ZeroRotator.GetForwardVector();
	FVector Yaw90Forward = FRotator(0.0, 90.0, 0.0).GetForwardVector();
	return ZeroForward.Equals(FVector::ForwardVector) && Yaw90Forward.Equals(FVector::RightVector);
}
/** @end */
/**
 * @begin get-right-vector
 * @summary Boundary/ownership: Both queries return new unit vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetRightVectorNominal
 * @summary Boundary/ownership: Both queries return new unit vectors.
 * @covers FRotator.get-right-vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetRightVectorNominal()
{
	FRotator Zero;
	FRotator Yaw90(0.0, 90.0, 0.0);
	FVector ZeroRight = Zero.GetRightVector();
	FVector Yaw90Right = Yaw90.GetRightVector();
	return ZeroRight.Equals(FVector::RightVector) && Yaw90Right.Equals(FVector(-1.0, 0.0, 0.0)) && Yaw90.Yaw == 90.0;
}
/** @end */
/**
 * @begin get-up-vector
 * @summary Boundary/ownership: Both queries return new unit vectors.
 * @topic Unreal
 */
/**
 * @function ObserveGetUpVectorNominal
 * @summary Boundary/ownership: Both queries return new unit vectors.
 * @covers FRotator.get-up-vector
 * @inputs FRotator values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUpVectorNominal()
{
	FRotator Zero;
	FVector ZeroUp = Zero.GetUpVector();
	FVector Yaw90Up = FRotator(0.0, 90.0, 0.0).GetUpVector();
	return ZeroUp.Equals(FVector::UpVector) && Yaw90Up.Equals(FVector::UpVector);
}
/** @end */
/**
 * @begin rotator-arithmetic-operators
 * @summary Compound-multiply a rotator by a scalar.
 * @topic Unreal
 */
/**
 * @function OpAddNominal
 * @summary Compound-multiply a rotator by a scalar.
 * @covers FRotator.ArithmeticOperators
 * @inputs none
 * @return FRotator(30, 60, 90)
 */
 add yields (15, 30, 45).
 *
 * @Kind Observe
 * @Covers FRotator.ArithmeticOperators
 * @Inputs none
 * @Return true when OpAdd equals (15, 30, 45)
 */
UFUNCTION()
bool OpAddNominal()
{
	return OpAdd() == FRotator(15, 30, 45);
}
/** @end */
/**
 * @begin rotator-comparison-operators
 * @summary Compare two identical rotators for equality.
 * @topic Unreal
 */
/**
 * @function OpEquals_True
 * @summary Compare two identical rotators for equality.
 * @covers FRotator.ComparisonOperators
 * @inputs none
 * @return true
 */
bool OpEquals_True()
{
	FRotator a = FRotator(10, 20, 30);
	FRotator b = FRotator(10, 20, 30);
	return a == b;
}
/** @end */
/**
 * @begin rotator-construction
 * @summary Construct a rotator with only roll set.
 * @topic Unreal
 */
/**
 * @function DefaultIsZero
 * @summary Construct a rotator with only roll set.
 * @covers FRotator.Construction
 * @inputs none
 * @return FRotator(0, 0, 180)
 */
eturn FRotator(0, 0, 180);
}

/**
 * Observe that the default constructor yields the zero rotator.
 *
 * @Kind Observe
 * @Covers FRotator.Construction
 * @Inputs none
 * @Return true when the default equals ZeroRotator
 */
UFUNCTION()
bool DefaultIsZero()
{
	return ConstructDefault() == FRotator::ZeroRotator;
}
/** @end */
/**
 * @begin rotator-conversion-methods
 * @summary Observe that a zero rotator converts to the forward vector.
 * @topic Unreal
 */
/**
 * @function RotatorToVectorNominal
 * @summary Observe that a zero rotator converts to the forward vector.
 * @covers FRotator.ConversionMethods
 * @inputs none
 * @return true when RotatorToVector equals ForwardVector
 */
bool RotatorToVectorNominal()
{
	return RotatorToVector().Equals(FVector::ForwardVector, 0.01);
}
/** @end */
/**
 * @begin rotator-declarations-and-confirmed-methods
 * @summary Sum NormalizeAxis(450) and ClampAxis(-90).
 * @topic Unreal
 */
/**
 * @function WindingAndRemainder
 * @summary Sum NormalizeAxis(450) and ClampAxis(-90).
 * @covers FRotator.DeclarationsAndConfirmedMethods
 * @inputs none
 * @return 360
 */
const FRotator GlobalConstRotator = FRotator::ZeroRotator;

/**
 *

 winding is (0, 360, 0) and remainder is (0, 90, 0)
 */
UFUNCTION()
bool WindingAndRemainder()
{
	FRotator Winding;
	FRotator Remainder;
	FRotator(0, 450, 0).GetWindingAndRemainder(Winding, Remainder);

	if (!Winding.Equals(FRotator(0, 360, 0), 0.001))
	{
		return false;
	}
	return Remainder.Equals(FRotator(0, 90, 0), 0.001);
}
/** @end */
/**
 * @begin rotator-member-access
 * @summary Observe that all three getters read their own component.
 * @topic Unreal
 */
/**
 * @function GettersNominal
 * @summary Observe that all three getters read their own component.
 * @covers FRotator.MemberAccess
 * @inputs none
 * @return true when Pitch, Yaw and Roll read 10, 20 and 30
 */
bool GettersNominal()
{
	if (GetPitch() != 10.0)
	{
		return false;
	}
	if (GetYaw() != 20.0)
	{
		return false;
	}
	return GetRoll() == 30.0;
}
/** @end */
/**
 * @begin rotator-normalization-methods
 * @summary Ask whether the zero rotator is zero.
 * @topic Unreal
 */
/**
 * @function IsZero
 * @summary Ask whether the zero rotator is zero.
 * @covers FRotator.NormalizationMethods
 * @inputs none
 * @return true
 */
bool IsZero()
{
	FRotator r = FRotator::ZeroRotator;
	return r.IsZero();
}
/** @end */
/**
 * @begin rotator-static-methods
 * @summary Observe that MakeFromEuler matches the native conversion.
 * @topic Unreal
 */
/**
 * @function MakeFromEulerNominal
 * @summary Observe that MakeFromEuler matches the native conversion.
 * @covers FRotator.StaticMethods
 * @inputs none
 * @return true when the result equals the native MakeFromEuler
 */
bool MakeFromEulerNominal()
{
	return MakeFromEuler().Equals(FRotator::MakeFromEuler(FVector(10, 20, 30)), 0.001);
}
/** @end */
/**
 * @begin container-properties
 * @summary WorldStory: BeginPlay fills the array and the map with three rotators each.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay fills the array and the map with three rotators each.
 * @covers FRotator.ContainerProperties
 * @inputs none
 * @return RotatorArray and IntToRotatorMap each hold three rotators
 */
UCLASS()
class ACoverageFRotatorContainerActor : AActor
{
	UPROPERTY()
	TArray<FRotator> RotatorArray;

	UPROPERTY()
	TMap<int, FRotator> IntToRotatorMap;

	/**
	 * WorldStory: BeginPlay fills the array and the map with three rotators each.
	 *
	 * @Kind WorldStory
	 * @Covers FRotator.ContainerProperties
	 * @Inputs none
	 * @Return RotatorArray and IntToRotatorMap each hold three rotators
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		RotatorArray.Add(FRotator(0, 0, 0));
		RotatorArray.Add(FRotator(90, 0, 0));
		RotatorArray.Add(FRotator(0, 180, 0));

		IntToRotatorMap.Add(1, FRotator(45, 0, 0));
		IntToRotatorMap.Add(2, FRotator(0, 90, 0));
		IntToRotatorMap.Add(3, FRotator(0, 0, 45));
	}
/** @end */
/**
 * @begin declaration-defaults
 * @summary Observe that the zero-rotator default reads as the origin.
 * @topic Unreal
 */
/**
 * @function ZeroRotNominal
 * @summary Observe that the zero-rotator default reads as the origin.
 * @covers FRotator.DeclarationDefaults
 * @inputs none
 * @return true when all three components of ZeroRot are 0
 */
UCLASS()
class ACoverageFRotatorDefaultsActor : AActor
{
	UPROPERTY()
	FRotator ZeroRot = FRotator::ZeroRotator;

	UPROPERTY()
	FRotator CustomRot = FRotator(10, 20, 30);

	UPROPERTY()
	FRotator NoDefaultRot;

	UPROPERTY()
	FRotator PitchOnly = FRotator(45, 0, 0);

	bool ZeroRotNominal()
	{
		if (ZeroRot.Pitch != 0.0)
		{
			return false;
		}
		if (ZeroRot.Yaw != 0.0)
		{
			return false;
		}
		return ZeroRot.Roll == 0.0;
	}
/** @end */
/**
 * @begin write-round-trip
 * @summary Observe that an untouched property is the zero rotator.
 * @topic Unreal
 */
/**
 * @function DefaultEmpty
 * @summary Observe that an untouched property is the zero rotator.
 * @covers FRotator.WriteRoundTrip
 * @inputs none
 * @return true when Pitch, Yaw and Roll are 0
 */
UCLASS()
class ACoverageFRotatorWriteActor : AActor
{
	UPROPERTY()
	FRotator RotatorValue;

	bool DefaultEmpty()
	{
		if (RotatorValue.Pitch != 0.0)
		{
			return false;
		}
		if (RotatorValue.Yaw != 0.0)
		{
			return false;
		}
		return RotatorValue.Roll == 0.0;
	}
/** @end */
/**
 * @begin function-default-parameters
 * @summary A defaulted rotator parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Add two rotators, where the second defaults to the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator and an optional second rotator
	 * @Return the sum of the two
	 * @Param a the first rotator
	 * @Param b the second rotator, defaulting to the zero rotator
	 */
	UFUNCTION()
	FRotator AddWithDefault(FRotator a, FRotator b = FRotator::ZeroRotator)
	{
		return a + b;
	}

	/**
	 * Add to a rotator relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator
	 * @Return the rotator plus the zero rotator
	 * @Param a the rotator to add to
	 */
	UFUNCTION()
	FRotator AddWithImplicitDefault(FRotator a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FRotator(10, 20, 30)
	 */
	UFUNCTION()
	bool AddWithImplicitDefaultNominal()
	{
		return AddWithImplicitDefault(FRotator(10, 20, 30)) == FRotator(10, 20, 30);
	}

	/**
	 * Observe that adding an empty rotator to the default stays at the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a default-constructed rotator
	 * @Return true when the sum equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddWithDefaultEmptyZero()
	{
		return AddWithDefault(FRotator()) == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionDefaultParameters
	 * @Inputs a rotator and the mutated sum built from it
	 * @Return true when the argument still reads FRotator(10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddWithImplicitDefaultCopyIndependence()
	{
		FRotator Input = FRotator(10, 20, 30);
		FRotator Result = AddWithImplicitDefault(Input);
		Result.Pitch = 0.0;
		return Input == FRotator(10, 20, 30);
	}
}
/** @end */
/**
 * @begin function-parameters-in
 * @summary A FRotator passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Convert a rotator passed by read-only reference into its forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a rotator
	 * @Return the rotator's Vector()
	 * @Param r the rotator to convert
	 */
	UFUNCTION()
	FVector AcceptRotatorIn(FRotator&in r)
	{
		return r.Vector();
	}

	/**
	 * Observe that a yaw-90 rotator converts to the same vector as the native helper.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the result equals FRotator(0, 90, 0).Vector()
	 */
	UFUNCTION()
	bool AcceptRotatorInNominal()
	{
		FRotator Input = FRotator(0, 90, 0);
		return AcceptRotatorIn(Input).Equals(FRotator(0, 90, 0).Vector(), 0.001);
	}

	/**
	 * Observe that an empty rotator converts to the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a default-constructed rotator
	 * @Return true when the result equals the forward vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptRotatorInDefaultEmpty()
	{
		FRotator Empty = FRotator();
		return AcceptRotatorIn(Empty).Equals(FVector::ForwardVector, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's rotator alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a rotator read through the reference
	 * @Return true when the argument still reads FRotator(0, 90, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptRotatorInCopyIndependence()
	{
		FRotator Input = FRotator(0, 90, 0);
		FVector Result = AcceptRotatorIn(Input);
		Result.X = 0.0;
		return Input == FRotator(0, 90, 0);
	}
}
/** @end */
/**
 * @begin function-parameters-in-out
 * @summary A FRotator passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover a zero scale, the.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Scale a rotator in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a rotator and a scale factor
	 * @Return the rotator scaled in place
	 * @Param r the rotator to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleRotator(FRotator&inout r, float scale)
	{
		r = r * scale;
	}

	/**
	 * Observe that the caller's rotator is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FRotator(20, 40, 60)
	 */
	UFUNCTION()
	bool ScaleRotatorNominal()
	{
		FRotator Value = FRotator(10, 20, 30);
		ScaleRotator(Value, 2.0);
		return Value == FRotator(20, 40, 60);
	}

	/**
	 * Observe that a zero scale collapses the rotator to the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a rotator scaled by zero
	 * @Return true when the value equals the zero rotator
	 * @Boundary zero scale
	 */
	UFUNCTION()
	bool ScaleRotatorZeroScale()
	{
		FRotator Value = FRotator(10, 20, 30);
		ScaleRotator(Value, 0.0);
		return Value == FRotator::ZeroRotator;
	}

	/**
	 * Observe that scaling an empty rotator stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a default-constructed rotator
	 * @Return true when the value still equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleRotatorDefaultEmpty()
	{
		FRotator Value = FRotator();
		ScaleRotator(Value, 2.0);
		return Value == FRotator::ZeroRotator;
	}
}
/** @end */
/**
 * @begin function-parameters-out
 * @summary FRotators written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Write a fixed rotator into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FRotator(45, 90, 180)
	 * @Param r the rotator to write into
	 */
	UFUNCTION()
	void WriteRotator(FRotator&out r)
	{
		r = FRotator(45, 90, 180);
	}

	/**
	 * Write the zero rotator and a known triple into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as the zero rotator, the second as FRotator(10, 20, 30)
	 * @Param a the first rotator to write into
	 * @Param b the second rotator to write into
	 */
	UFUNCTION()
	void WriteMultipleRotators(FRotator&out a, FRotator&out b)
	{
		a = FRotator::ZeroRotator;
		b = FRotator(10, 20, 30);
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FRotator(45, 90, 180)
	 */
	UFUNCTION()
	bool WriteRotatorNominal()
	{
		FRotator OutValue;
		WriteRotator(OutValue);
		return OutValue == FRotator(45, 90, 180);
	}

	/**
	 * Observe that both out parameters receive their own value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads the zero rotator and the second reads (10, 20, 30)
	 */
	UFUNCTION()
	bool WriteMultipleRotatorsNominal()
	{
		FRotator OutA;
		FRotator OutB;
		WriteMultipleRotators(OutA, OutB);

		if (!(OutA == FRotator::ZeroRotator))
		{
			return false;
		}
		return OutB == FRotator(10, 20, 30);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteRotatorDefaultEmptyBeforeWrite()
	{
		FRotator OutValue;
		return OutValue == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads FRotator(10, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleRotatorsCopyIndependence()
	{
		FRotator OutA;
		FRotator OutB;
		WriteMultipleRotators(OutA, OutB);
		OutA.Pitch = 99.0;
		return OutB == FRotator(10, 20, 30);
	}
}
/** @end */
/**
 * @begin function-parameters-value
 * @summary FRotators passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Double every component of a rotator passed by value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs a rotator
	 * @Return the rotator with every component doubled
	 * @Param r the rotator to scale
	 */
	UFUNCTION()
	FRotator AcceptRotator(FRotator r)
	{
		return r * 2.0;
	}

	/**
	 * Add two rotators passed by value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs two rotators
	 * @Return the sum of the two
	 * @Param a the first rotator
	 * @Param b the second rotator
	 */
	UFUNCTION()
	FRotator AcceptTwoRotators(FRotator a, FRotator b)
	{
		return a + b;
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FRotator(20, 40, 60)
	 */
	UFUNCTION()
	bool AcceptRotatorNominal()
	{
		return AcceptRotator(FRotator(10, 20, 30)) == FRotator(20, 40, 60);
	}

	/**
	 * Observe that the sum of two value parameters matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool AcceptTwoRotatorsNominal()
	{
		return AcceptTwoRotators(FRotator(10, 20, 30), FRotator(5, 10, 15)) == FRotator(15, 30, 45);
	}

	/**
	 * Observe that doubling an empty rotator stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs a default-constructed rotator
	 * @Return true when the result equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptRotatorDefaultEmpty()
	{
		return AcceptRotator(FRotator()) == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating the returned sum leaves both of the caller's arguments alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersValue
	 * @Inputs two rotators and the mutated sum built from them
	 * @Return true when both arguments still hold their original values
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptTwoRotatorsCopyIndependence()
	{
		FRotator A = FRotator(10, 20, 30);
		FRotator B = FRotator(5, 10, 15);
		FRotator Sum = AcceptTwoRotators(A, B);
		Sum.Pitch = 0.0;

		if (!(A == FRotator(10, 20, 30)))
		{
			return false;
		}
		return B == FRotator(5, 10, 15);
	}
}
/** @end */
/**
 * @begin function-return-values
 * @summary Rotators returned from functions: a constant, a literal and a computed sum. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FRotatorTest
{
	/**
	 * Return a rotator constant.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return the zero rotator
	 */
	UFUNCTION()
	FRotator ReturnZeroRotator()
	{
		return FRotator::ZeroRotator;
	}

	/**
	 * Return a literal rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return FRotator(45, 90, 135)
	 */
	UFUNCTION()
	FRotator ReturnCustomRotator()
	{
		return FRotator(45, 90, 135);
	}

	/**
	 * Return a rotator computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return FRotator(15, 30, 45)
	 */
	UFUNCTION()
	FRotator ReturnComputedRotator()
	{
		FRotator a = FRotator(10, 20, 30);
		FRotator b = FRotator(5, 10, 15);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the zero rotator
	 */
	UFUNCTION()
	bool ReturnZeroRotatorNominal()
	{
		return ReturnZeroRotator() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FRotator(45, 90, 135)
	 */
	UFUNCTION()
	bool ReturnCustomRotatorNominal()
	{
		return ReturnCustomRotator() == FRotator(45, 90, 135);
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FRotator(15, 30, 45)
	 */
	UFUNCTION()
	bool ReturnComputedRotatorNominal()
	{
		return ReturnComputedRotator() == FRotator(15, 30, 45);
	}

	/**
	 * Observe that an empty rotator equals the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs a default-constructed rotator
	 * @Return true when it equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnZeroRotatorDefaultEmpty()
	{
		return FRotator() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that mutating a copy leaves a fresh computed return untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionReturnValues
	 * @Inputs a mutated copy of a computed return
	 * @Return true when a fresh computed return still reads (15, 30, 45)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnComputedRotatorCopyIndependence()
	{
		FRotator Result = ReturnComputedRotator();
		Result.Pitch = 0.0;
		return ReturnComputedRotator() == FRotator(15, 30, 45);
	}
}
/** @end */
