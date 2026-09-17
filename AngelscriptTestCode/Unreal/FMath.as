/**
 * @version v1
 * @summary FMath host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FMath
 *
 * asin
 * closest-point-on-infinite-line
 * rand-helper
 * rand-range
 * rand-bool
 * v-rand
 * v-rand-cone
 * rand-point-in-circle
 * make-pulsating-value
 * smooth-step
 * clamp
 * fast-asin
 * radians-to-degrees
 * degrees-to-radians
 * clamp-angle
 * unwind-degrees
 * unwind-radians
 * lerp-stable
 * lerp
 * v-lerp
 * cubic-interp
 * cubic-interp-derivative
 * FMath-NamespaceAndGlobalFunctions_06-cubic-interp-derivative
 * v-interp-normal-rotation-to
 * v-interp-constant-to
 * v-interp-to
 * vector-2-d-interp-constant-to
 * vector-2-d-interp-to
 * r-interp-constant-to
 * r-interp-to
 * rotator-from-axis-and-angle
 * random-point-in-bounding-box
 * random-rotator
 * q-interp-constant-to
 * q-interp-to
 * f-interp-constant-to
 * f-interp-to
 * c-interp-to
 * sphere-aabb-intersection
 * ray-plane-intersection
 * line-plane-intersection
 * line-sphere-intersection
 * line-box-intersection
 * compute-bounding-sphere-for-cone
 * trunc-to-int
 * trunc-to-float
 * trunc-to-double
 * round-to-int
 * round-to-float
 * round-to-double
 * floor-to-int
 * floor-to-float
 * floor-to-double
 * ceil-to-int
 * ceil-to-float
 * ceil-to-double
 * round-from-zero
 * inv-sqrt
 * inv-sqrt-est
 * fractional
 * frac
 * exp
 * exp-2
 * loge
 * log-2
 * log-x
 * fmod
 * sin
 * sinh
 * cos
 * acos
 * tan
 * atan
 * atan-2
 * sqrt
 * pow
 * FMath-NamespaceAndGlobalFunctions_14-exp
 * FMath-NamespaceAndGlobalFunctions_14-exp-2
 * FMath-NamespaceAndGlobalFunctions_14-loge
 * FMath-NamespaceAndGlobalFunctions_14-log-2
 * FMath-NamespaceAndGlobalFunctions_14-log-x
 * FMath-NamespaceAndGlobalFunctions_14-fmod
 * FMath-NamespaceAndGlobalFunctions_14-sin
 * FMath-NamespaceAndGlobalFunctions_15-sinh
 * FMath-NamespaceAndGlobalFunctions_15-cos
 * FMath-NamespaceAndGlobalFunctions_15-acos
 * FMath-NamespaceAndGlobalFunctions_15-tan
 * FMath-NamespaceAndGlobalFunctions_15-atan
 * FMath-NamespaceAndGlobalFunctions_15-atan-2
 * FMath-NamespaceAndGlobalFunctions_15-sqrt
 * FMath-NamespaceAndGlobalFunctions_15-pow
 * rand
 * f-rand
 * abs
 * sign
 * square
 * perlin-noise-1-d
 * perlin-noise-2-d
 * perlin-noise-3-d
 * grid-snap
 * segment-intersection-2-d
 * float-spring-interp
 * vector-spring-interp
 * quaternion-spring-interp
 * ease-in
 * ease-out
 * ease-in-out
 * sinusoidal-in
 * sinusoidal-out
 * sinusoidal-in-out
 * expo-in
 * expo-out
 * expo-in-out
 * circular-in
 * circular-out
 * circular-in-out
 * FMath-NamespaceAndGlobalFunctions_19-ease-in
 * FMath-NamespaceAndGlobalFunctions_19-ease-out
 * FMath-NamespaceAndGlobalFunctions_19-ease-in-out
 * FMath-NamespaceAndGlobalFunctions_19-sinusoidal-in
 * FMath-NamespaceAndGlobalFunctions_19-sinusoidal-out
 * FMath-NamespaceAndGlobalFunctions_19-sinusoidal-in-out
 * FMath-NamespaceAndGlobalFunctions_19-expo-in
 * FMath-NamespaceAndGlobalFunctions_19-expo-out
 * FMath-NamespaceAndGlobalFunctions_19-expo-in-out
 * FMath-NamespaceAndGlobalFunctions_20-circular-in
 * FMath-NamespaceAndGlobalFunctions_20-circular-out
 * FMath-NamespaceAndGlobalFunctions_20-circular-in-out
 * FMath-NamespaceAndGlobalFunctions_20-ease-in
 * FMath-NamespaceAndGlobalFunctions_20-ease-out
 * FMath-NamespaceAndGlobalFunctions_20-ease-in-out
 * FMath-NamespaceAndGlobalFunctions_20-sinusoidal-in
 * FMath-NamespaceAndGlobalFunctions_20-sinusoidal-out
 * FMath-NamespaceAndGlobalFunctions_20-sinusoidal-in-out
 * FMath-NamespaceAndGlobalFunctions_20-expo-in
 * FMath-NamespaceAndGlobalFunctions_21-expo-out
 * FMath-NamespaceAndGlobalFunctions_21-expo-in-out
 * FMath-NamespaceAndGlobalFunctions_21-circular-in
 * FMath-NamespaceAndGlobalFunctions_21-circular-out
 * FMath-NamespaceAndGlobalFunctions_21-circular-in-out
 * normalize-to-range
 * integer-division-trunc
 * get-reflection-vector
 * is-nearly-equal
 * is-nearly-zero
 * is-power-of-two
 * find-delta-angle-degrees
 * find-delta-angle-radians
 * is-within
 * is-within-inclusive
 * is-na-n
 * is-finite
 * min
 * max-3
 * max
 * get-mapped-range-value-clamped
 * get-mapped-range-value-unclamped
 * is-point-in-box
 * is-point-in-box-with-transform
 * find-nearest-points-on-line-segments
 */
/**
 * @begin asin
 * @summary never FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveAsinNominal
 * @summary never FMath::.
 * @covers FMath.asin
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsinNominal()
{
	float64 AsinZero64 = Math::Asin(0.0);
	float64 AsinOne64 = Math::Asin(1.0);
	float64 AsinNeg64 = Math::Asin(-1.0);
	float64 AsinHalf64 = Math::Asin(0.5);
	bool bAsin64 = Math::IsNearlyEqual(AsinZero64, 0.0) &&
		Math::IsNearlyEqual(AsinOne64, HALF_PI, KINDA_SMALL_NUMBER) &&
		Math::IsNearlyEqual(AsinNeg64, -HALF_PI, KINDA_SMALL_NUMBER) &&
		AsinHalf64 > 0.0 &&
		AsinHalf64 < HALF_PI;

	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 Neg32 = -1.0;
	float32 Half32 = 0.5;
	float32 AsinZero32 = Math::Asin(Zero32);
	float32 AsinOne32 = Math::Asin(One32);
	float32 AsinNeg32 = Math::Asin(Neg32);
	float32 AsinHalf32 = Math::Asin(Half32);
	float32 HalfPi32 = float32(HALF_PI);
	bool bAsin32 = Math::IsNearlyEqual(AsinZero32, Zero32) &&
		Math::IsNearlyEqual(AsinOne32, HalfPi32, float32(KINDA_SMALL_NUMBER)) &&
		Math::IsNearlyEqual(AsinNeg32, -HalfPi32, float32(KINDA_SMALL_NUMBER)) &&
		AsinHalf32 > 0.0 &&
		AsinHalf32 < HalfPi32;
	return bAsin64 && bAsin32;
}
/** @end */
/**
 * @begin closest-point-on-infinite-line
 * @summary endpoints are not mutated.
 * @topic Unreal
 */
/**
 * @function ObserveClosestPointOnInfiniteLineNominal
 * @summary endpoints are not mutated.
 * @covers FMath.closest-point-on-infinite-line
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Interior closest

bool ObserveClosestPointOnInfiniteLineNominal()
{
	FVector LineStart(0.0, 0.0, 0.0);
	FVector LineEnd(10.0, 0.0, 0.0);
	FVector Interior = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(5.0, 5.0, 0.0));
	FVector PastEnd = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(15.0, 5.0, 0.0));
	FVector Repeated = Math::ClosestPointOnInfiniteLine(LineStart, LineEnd, FVector(15.0, 5.0, 0.0));
	return Interior.Equals(FVector(5.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
		PastEnd.Equals(FVector(15.0, 0.0, 0.0), KINDA_SMALL_NUMBER) &&
		Repeated.Equals(PastEnd, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin rand-helper
 * @summary float;
 * @topic Unreal
 */
/**
 * @function ObserveRandHelperNominal
 * @summary float;
 * @covers FMath.rand-helper
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

 VRandCone axis (0,0,1) with half-angle PI/4 and the two-arg cone;
// circle radius 4; pulse time 0.25 at 1 Hz with omitted and explicit phase;
// zero DDir as the diagnostic companion.
// Expected observations: RandHelper is in [0, Max) and nonpositive Max
// returns 0. RandRange stays in [Min, Max]. VRand and VRandCone are unit
// length. Circle samples stay within Radius. Pulse is in [0, 1].
// Boundary/ownership: Results are random; observe range/unit-length/boolean,
// not exact values. DDir is expected to be normalized. Call Math::.
bool ObserveRandHelperNominal()
{
	int32 InRange = Math::RandHelper(10);
	int32 InRangeAgain = Math::RandHelper(10);
	int32 ZeroMax = Math::RandHelper(0);
	int32 NegativeMax = Math::RandHelper(-5);
	return InRange >= 0 && InRange < 10 &&
		InRangeAgain >= 0 && InRangeAgain < 10 &&
		ZeroMax == 0 &&
		NegativeMax == 0;
}
/** @end */
/**
 * @begin rand-range
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveRandRangeNominal
 * @summary not exact values.
 * @covers FMath.rand-range
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveRandRangeNominal()
{
	int32 IntSample = Math::RandRange(1, 5);
	int32 IntEqual = Math::RandRange(3, 3);
	float64 Min64 = 1.0;
	float64 Max64 = 5.0;
	float64 Float64Sample = Math::RandRange(Min64, Max64);
	float32 Min32 = 1.0;
	float32 Max32 = 5.0;
	float32 Float32Sample = Math::RandRange(Min32, Max32);
	return IntSample >= 1 && IntSample <= 5 &&
		IntEqual == 3 &&
		Float64Sample >= 1.0 && Float64Sample <= 5.0 &&
		Float32Sample >= 1.0 && Float32Sample <= 5.0;
}
/** @end */
/**
 * @begin rand-bool
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveRandBoolNominal
 * @summary not exact values.
 * @covers FMath.rand-bool
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveRandBoolNominal()
{
	int32 TrueCount = 0;
	if (Math::RandBool())
	{
		TrueCount += 1;
	}
	if (Math::RandBool())
	{
		TrueCount += 1;
	}
	if (Math::RandBool())
	{
		TrueCount += 1;
	}
	return TrueCount >= 0 && TrueCount <= 3;
}
/** @end */
/**
 * @begin v-rand
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveVRandNominal
 * @summary not exact values.
 * @covers FMath.v-rand
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveVRandNominal()
{
	FVector Unit = Math::VRand();
	FVector UnitAgain = Math::VRand();
	return Unit.IsNormalized() && UnitAgain.IsNormalized();
}
/** @end */
/**
 * @begin v-rand-cone
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveVRandConeNominal
 * @summary not exact values.
 * @covers FMath.v-rand-cone
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveVRandConeNominal()
{
	FVector Axis(0.0, 0.0, 1.0);
	float32 Horizontal = float32(HALF_PI * 0.5);
	float32 Vertical = float32(HALF_PI * 0.5);
	FVector Anisotropic = Math::VRandCone(Axis, Horizontal, Vertical);
	float32 HalfAngle = float32(HALF_PI);
	FVector Isotropic = Math::VRandCone(Axis, HalfAngle);
	float64 AnisotropicDot = Anisotropic.DotProduct(Axis);
	float64 IsotropicDot = Isotropic.DotProduct(Axis);
	return Anisotropic.IsNormalized() &&
		AnisotropicDot >= 0.0 &&
		Isotropic.IsNormalized() &&
		IsotropicDot >= -KINDA_SMALL_NUMBER;
}
/** @end */
/**
 * @begin rand-point-in-circle
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveRandPointInCircleNominal
 * @summary not exact values.
 * @covers FMath.rand-point-in-circle
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveRandPointInCircleNominal()
{
	float32 Radius = 4.0;
	FVector2D Inside = Math::RandPointInCircle(Radius);
	FVector2D InsideAgain = Math::RandPointInCircle(Radius);
	float32 ZeroRadius = 0.0;
	FVector2D Origin = Math::RandPointInCircle(ZeroRadius);
	return Inside.Size() <= 4.0 + KINDA_SMALL_NUMBER &&
		InsideAgain.Size() <= 4.0 + KINDA_SMALL_NUMBER &&
		Origin.Size() <= KINDA_SMALL_NUMBER;
}
/** @end */
/**
 * @begin make-pulsating-value
 * @summary not exact values.
 * @topic Unreal
 */
/**
 * @function ObserveMakePulsatingValueNominal
 * @summary not exact values.
 * @covers FMath.make-pulsating-value
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// float;

bool ObserveMakePulsatingValueNominal()
{
	float64 Time = 0.25;
	float32 Pulses = 1.0;
	float32 PulseDefault = Math::MakePulsatingValue(Time, Pulses);
	float32 Phase = 0.5;
	float32 PulsePhased = Math::MakePulsatingValue(Time, Pulses, Phase);
	float32 PulseZeroTime = Math::MakePulsatingValue(0.0, Pulses);
	return PulseDefault >= 0.0 && PulseDefault <= 1.0 &&
		PulsePhased >= 0.0 && PulsePhased <= 1.0 &&
		PulseZeroTime >= 0.0 && PulseZeroTime <= 1.0;
}
/** @end */
/**
 * @begin smooth-step
 * @summary FastAsin is an approximation.
 * @topic Unreal
 */
/**
 * @function ObserveSmoothStepNominal
 * @summary FastAsin is an approximation.
 * @covers FMath.smooth-step
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSmoothStepNominal()
{
	float64 Below64 = Math::SmoothStep(0.0, 1.0, -1.0);
	float64 Start64 = Math::SmoothStep(0.0, 1.0, 0.0);
	float64 Mid64 = Math::SmoothStep(0.0, 1.0, 0.5);
	float64 End64 = Math::SmoothStep(0.0, 1.0, 1.0);
	float64 Above64 = Math::SmoothStep(0.0, 1.0, 2.0);

	float32 A32 = 0.0;
	float32 B32 = 1.0;
	float32 BelowX32 = -1.0;
	float32 MidX32 = 0.5;
	float32 EndX32 = 1.0;
	float32 Below32 = Math::SmoothStep(A32, B32, BelowX32);
	float32 Start32 = Math::SmoothStep(A32, B32, A32);
	float32 Mid32 = Math::SmoothStep(A32, B32, MidX32);
	float32 End32 = Math::SmoothStep(A32, B32, EndX32);
	return Below64 == 0.0 && Start64 == 0.0 && Math::IsNearlyEqual(Mid64, 0.5) && End64 == 1.0 && Above64 == 1.0 &&
		Below32 == 0.0 && Start32 == 0.0 && Math::IsNearlyEqual(Mid32, float32(0.5)) && End32 == 1.0;
}
/** @end */
/**
 * @begin clamp
 * @summary FastAsin is an approximation.
 * @topic Unreal
 */
/**
 * @function ObserveClampNominal
 * @summary FastAsin is an approximation.
 * @covers FMath.clamp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClampNominal()
{
	float64 Low64 = Math::Clamp(-1.0, 0.0, 10.0);
	float64 Mid64 = Math::Clamp(5.0, 0.0, 10.0);
	float64 High64 = Math::Clamp(15.0, 0.0, 10.0);

	float32 Neg32 = -1.0;
	float32 MidX32 = 5.0;
	float32 HighX32 = 15.0;
	float32 Min32 = 0.0;
	float32 Max32 = 10.0;
	float32 Low32 = Math::Clamp(Neg32, Min32, Max32);
	float32 Mid32 = Math::Clamp(MidX32, Min32, Max32);
	float32 High32 = Math::Clamp(HighX32, Min32, Max32);

	int32 LowI = Math::Clamp(int32(-1), int32(0), int32(10));
	int32 MidI = Math::Clamp(int32(5), int32(0), int32(10));
	int32 HighI = Math::Clamp(int32(15), int32(0), int32(10));

	uint32 LowU = Math::Clamp(uint32(0), uint32(1), uint32(10));
	uint32 MidU = Math::Clamp(uint32(5), uint32(1), uint32(10));
	uint32 HighU = Math::Clamp(uint32(15), uint32(1), uint32(10));

	int64 Low64i = Math::Clamp(int64(-1), int64(0), int64(10));
	int64 Mid64i = Math::Clamp(int64(5), int64(0), int64(10));
	int64 High64i = Math::Clamp(int64(15), int64(0), int64(10));

	uint64 LowU64 = Math::Clamp(uint64(0), uint64(1), uint64(10));
	uint64 MidU64 = Math::Clamp(uint64(5), uint64(1), uint64(10));
	uint64 HighU64 = Math::Clamp(uint64(15), uint64(1), uint64(10));
	return Low64 == 0.0 && Mid64 == 5.0 && High64 == 10.0 &&
		Low32 == 0.0 && Mid32 == 5.0 && High32 == 10.0 &&
		LowI == 0 && MidI == 5 && HighI == 10 &&
		LowU == 1 && MidU == 5 && HighU == 10 &&
		Low64i == 0 && Mid64i == 5 && High64i == 10 &&
		LowU64 == 1 && MidU64 == 5 && HighU64 == 10;
}
/** @end */
/**
 * @begin fast-asin
 * @summary FastAsin is an approximation.
 * @topic Unreal
 */
/**
 * @function ObserveFastAsinNominal
 * @summary FastAsin is an approximation.
 * @covers FMath.fast-asin
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFastAsinNominal()
{
	float64 FastZero64 = Math::FastAsin(0.0);
	float64 FastOne64 = Math::FastAsin(1.0);
	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 FastZero32 = Math::FastAsin(Zero32);
	float32 FastOne32 = Math::FastAsin(One32);
	float32 HalfPi32 = float32(HALF_PI);
	return Math::IsNearlyEqual(FastZero64, 0.0, KINDA_SMALL_NUMBER) &&
		Math::IsNearlyEqual(FastOne64, HALF_PI, 0.01) &&
		Math::IsNearlyEqual(FastZero32, Zero32, float32(KINDA_SMALL_NUMBER)) &&
		Math::IsNearlyEqual(FastOne32, HalfPi32, float32(0.01));
}
/** @end */
/**
 * @begin radians-to-degrees
 * @summary ClampAngle uses wrapped degree bounds.
 * @topic Unreal
 */
/**
 * @function ObserveRadiansToDegreesNominal
 * @summary ClampAngle uses wrapped degree bounds.
 * @covers FMath.radians-to-degrees
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRadiansToDegreesNominal()
{
	float64 Deg64 = Math::RadiansToDegrees(PI);
	float64 Zero64 = Math::RadiansToDegrees(0.0);
	float32 Pi32 = float32(PI);
	float32 Zero32 = 0.0;
	float32 Deg32 = Math::RadiansToDegrees(Pi32);
	float32 ZeroDeg32 = Math::RadiansToDegrees(Zero32);
	return Math::IsNearlyEqual(Deg64, 180.0) &&
		Zero64 == 0.0 &&
		Math::IsNearlyEqual(Deg32, float32(180.0), float32(KINDA_SMALL_NUMBER)) &&
		ZeroDeg32 == 0.0;
}
/** @end */
/**
 * @begin degrees-to-radians
 * @summary ClampAngle uses wrapped degree bounds.
 * @topic Unreal
 */
/**
 * @function ObserveDegreesToRadiansNominal
 * @summary ClampAngle uses wrapped degree bounds.
 * @covers FMath.degrees-to-radians
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDegreesToRadiansNominal()
{
	float64 Rad64 = Math::DegreesToRadians(180.0);
	float64 Zero64 = Math::DegreesToRadians(0.0);
	float32 Deg32 = 180.0;
	float32 Zero32 = 0.0;
	float32 Rad32 = Math::DegreesToRadians(Deg32);
	float32 ZeroRad32 = Math::DegreesToRadians(Zero32);
	return Math::IsNearlyEqual(Rad64, PI) &&
		Zero64 == 0.0 &&
		Math::IsNearlyEqual(Rad32, float32(PI), float32(KINDA_SMALL_NUMBER)) &&
		ZeroRad32 == 0.0;
}
/** @end */
/**
 * @begin clamp-angle
 * @summary ClampAngle uses wrapped degree bounds.
 * @topic Unreal
 */
/**
 * @function ObserveClampAngleNominal
 * @summary ClampAngle uses wrapped degree bounds.
 * @covers FMath.clamp-angle
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClampAngleNominal()
{
	float32 Angle32 = 0.0;
	float32 Min32 = -45.0;
	float32 Max32 = 45.0;
	float32 Inside32 = Math::ClampAngle(Angle32, Min32, Max32);
	float32 Wide32 = Math::ClampAngle(float32(90.0), Min32, Max32);
	float64 Inside64 = Math::ClampAngle(0.0, -45.0, 45.0);
	float64 Wide64 = Math::ClampAngle(90.0, -45.0, 45.0);
	return Math::IsNearlyEqual(Inside32, float32(0.0)) &&
		Wide32 >= -45.0 && Wide32 <= 45.0 &&
		Math::IsNearlyEqual(Inside64, 0.0) &&
		Wide64 >= -45.0 && Wide64 <= 45.0;
}
/** @end */
/**
 * @begin unwind-degrees
 * @summary ClampAngle uses wrapped degree bounds.
 * @topic Unreal
 */
/**
 * @function ObserveUnwindDegreesNominal
 * @summary ClampAngle uses wrapped degree bounds.
 * @covers FMath.unwind-degrees
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnwindDegreesNominal()
{
	float64 Unwound64 = Math::UnwindDegrees(270.0);
	float64 Negative64 = Math::UnwindDegrees(-270.0);
	float64 Small64 = Math::UnwindDegrees(45.0);
	float32 Unwound32 = Math::UnwindDegrees(float32(270.0));
	float32 Negative32 = Math::UnwindDegrees(float32(-270.0));
	float32 Small32 = Math::UnwindDegrees(float32(45.0));
	return Math::IsNearlyEqual(Unwound64, -90.0) &&
		Math::IsNearlyEqual(Negative64, 90.0) &&
		Math::IsNearlyEqual(Small64, 45.0) &&
		Math::IsNearlyEqual(Unwound32, float32(-90.0)) &&
		Math::IsNearlyEqual(Negative32, float32(90.0)) &&
		Math::IsNearlyEqual(Small32, float32(45.0));
}
/** @end */
/**
 * @begin unwind-radians
 * @summary ClampAngle uses wrapped degree bounds.
 * @topic Unreal
 */
/**
 * @function ObserveUnwindRadiansNominal
 * @summary ClampAngle uses wrapped degree bounds.
 * @covers FMath.unwind-radians
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnwindRadiansNominal()
{
	float64 Unwound64 = Math::UnwindRadians(3.0 * PI);
	float64 Small64 = Math::UnwindRadians(HALF_PI);
	float32 ThreePi32 = float32(3.0 * PI);
	float32 HalfPi32 = float32(HALF_PI);
	float32 Unwound32 = Math::UnwindRadians(ThreePi32);
	float32 Small32 = Math::UnwindRadians(HalfPi32);
	return Unwound64 >= -PI && Unwound64 <= PI &&
		Math::IsNearlyEqual(Small64, HALF_PI) &&
		Unwound32 >= -float32(PI) && Unwound32 <= float32(PI) &&
		Math::IsNearlyEqual(Small32, HalfPi32, float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin lerp-stable
 * @summary are new values.
 * @topic Unreal
 */
/**
 * @function ObserveLerpStableNominal
 * @summary are new values.
 * @covers FMath.lerp-stable
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLerpStableNominal()
{
	float64 Start64 = Math::LerpStable(0.0, 10.0, 0.0);
	float64 Mid64 = Math::LerpStable(0.0, 10.0, 0.5);
	float64 End64 = Math::LerpStable(0.0, 10.0, 1.0);
	float64 Extra64 = Math::LerpStable(0.0, 10.0, 2.0);

	float32 A32 = 0.0;
	float32 B32 = 10.0;
	float32 Zero32 = 0.0;
	float32 Half32 = 0.5;
	float32 One32 = 1.0;
	float32 Two32 = 2.0;
	float32 Start32 = Math::LerpStable(A32, B32, Zero32);
	float32 Mid32 = Math::LerpStable(A32, B32, Half32);
	float32 End32 = Math::LerpStable(A32, B32, One32);
	float32 Extra32 = Math::LerpStable(A32, B32, Two32);
	return Start64 == 0.0 && Mid64 == 5.0 && End64 == 10.0 && Extra64 == 20.0 && Start32 == 0.0 && Mid32 == 5.0 && End32 == 10.0 && Extra32 == 20.0;
}
/** @end */
/**
 * @begin lerp
 * @summary are new values.
 * @topic Unreal
 */
/**
 * @function ObserveLerpNominal
 * @summary are new values.
 * @covers FMath.lerp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLerpNominal()
{
	float64 Start64 = Math::Lerp(0.0, 10.0, 0.0);
	float64 Mid64 = Math::Lerp(0.0, 10.0, 0.5);
	float64 End64 = Math::Lerp(0.0, 10.0, 1.0);
	float64 Extra64 = Math::Lerp(0.0, 10.0, 2.0);

	float32 A32 = 0.0;
	float32 B32 = 10.0;
	float32 Zero32 = 0.0;
	float32 Half32 = 0.5;
	float32 One32 = 1.0;
	float32 Start32 = Math::Lerp(A32, B32, Zero32);
	float32 Mid32 = Math::Lerp(A32, B32, Half32);
	float32 End32 = Math::Lerp(A32, B32, One32);

	FVector FromV(0.0, 0.0, 0.0);
	FVector ToV(10.0, 0.0, 0.0);
	FVector MidV = Math::Lerp(FromV, ToV, 0.5);
	FVector StartV = Math::Lerp(FromV, ToV, 0.0);

	FVector2D From2D(0.0, 0.0);
	FVector2D To2D(10.0, 10.0);
	FVector2D Mid2D = Math::Lerp(From2D, To2D, 0.5);

	FVector3f From3f(0.0, 0.0, 0.0);
	FVector3f To3f(10.0, 0.0, 0.0);
	FVector3f Mid3f = Math::Lerp(From3f, To3f, Half32);

	FVector2f From2f(0.0, 0.0);
	FVector2f To2f(10.0, 10.0);
	FVector2f Mid2f = Math::Lerp(From2f, To2f, Half32);

	FLinearColor MidColor = Math::Lerp(FLinearColor::White, FLinearColor::Black, Half32);
	bool bScalar = Start64 == 0.0 && Mid64 == 5.0 && End64 == 10.0 && Extra64 == 20.0 && Start32 == 0.0 && Mid32 == 5.0 && End32 == 10.0;
	bool bVector = MidV.X == 5.0 && StartV.X == 0.0 && Mid2D.X == 5.0 && Mid3f.X == 5.0 && Mid2f.X == 5.0;
	bool bColor = MidColor.R > 0.0 && MidColor.R < 1.0;
	return bScalar && bVector && bColor;
}
/** @end */
/**
 * @begin v-lerp
 * @summary are new values.
 * @topic Unreal
 */
/**
 * @function ObserveVLerpNominal
 * @summary are new values.
 * @covers FMath.v-lerp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVLerpNominal()
{
	FVector From(0.0, 0.0, 0.0);
	FVector To(10.0, 20.0, 30.0);
	FVector Alpha(0.0, 0.5, 1.0);
	FVector Mixed = Math::VLerp(From, To, Alpha);
	FVector ZeroAlpha = Math::VLerp(From, To, FVector(0.0, 0.0, 0.0));
	bool bPerAxis = Mixed.X == 0.0 && Mixed.Y == 10.0 && Mixed.Z == 30.0;
	bool bZeroStaysFrom = ZeroAlpha.X == 0.0 && ZeroAlpha.Y == 0.0 && ZeroAlpha.Z == 0.0;
	return bPerAxis && bZeroStaysFrom;
}
/** @end */
/**
 * @begin cubic-interp
 * @summary are new FQuat/FQuat4f values.
 * @topic Unreal
 */
/**
 * @function ObserveCubicInterpNominal
 * @summary are new FQuat/FQuat4f values.
 * @covers FMath.cubic-interp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCubicInterpNominal()
{
	float64 P0_64 = 0.0;
	float64 P1_64 = 1.0;
	float64 T0_64 = 0.0;
	float64 T1_64 = 0.0;
	float64 Start64 = Math::CubicInterp(P0_64, T0_64, P1_64, T1_64, 0.0);
	float64 Mid64 = Math::CubicInterp(P0_64, T0_64, P1_64, T1_64, 0.5);
	float64 End64 = Math::CubicInterp(P0_64, T0_64, P1_64, T1_64, 1.0);

	FVector VP0(0.0, 0.0, 0.0);
	FVector VP1(10.0, 0.0, 0.0);
	FVector VT;
	float64 Alpha64 = 0.5;
	FVector VMid64 = Math::CubicInterp(VP0, VT, VP1, VT, Alpha64);
	FVector VStart64 = Math::CubicInterp(VP0, VT, VP1, VT, 0.0);

	FQuat QP0 = FQuat::Identity;
	FQuat QP1 = FQuat(FRotator(0.0, 90.0, 0.0));
	FQuat QT = FQuat::Identity;
	FQuat QStart64 = Math::CubicInterp(QP0, QT, QP1, QT, 0.0);
	FQuat QEnd64 = Math::CubicInterp(QP0, QT, QP1, QT, 1.0);

	float32 P0_32 = 0.0;
	float32 P1_32 = 1.0;
	float32 T0_32 = 0.0;
	float32 T1_32 = 0.0;
	float32 Zero32 = 0.0;
	float32 Half32 = 0.5;
	float32 One32 = 1.0;
	float32 Start32 = Math::CubicInterp(P0_32, T0_32, P1_32, T1_32, Zero32);
	float32 Mid32 = Math::CubicInterp(P0_32, T0_32, P1_32, T1_32, Half32);
	float32 End32 = Math::CubicInterp(P0_32, T0_32, P1_32, T1_32, One32);

	FVector VMid32 = Math::CubicInterp(VP0, VT, VP1, VT, Half32);
	FQuat QStart32 = Math::CubicInterp(QP0, QT, QP1, QT, Zero32);

	FVector3f P0_3f(0.0, 0.0, 0.0);
	FVector3f P1_3f(10.0, 0.0, 0.0);
	FVector3f T3f;
	FVector3f Mid3f = Math::CubicInterp(P0_3f, T3f, P1_3f, T3f, Half32);

	FQuat4f Q4P0 = FQuat4f::Identity;
	FQuat4f Q4P1 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Q4T = FQuat4f::Identity;
	FQuat4f Q4Start = Math::CubicInterp(Q4P0, Q4T, Q4P1, Q4T, Zero32);
	FQuat4f Q4End = Math::CubicInterp(Q4P0, Q4T, Q4P1, Q4T, One32);

	bool bScalar = Start64 == 0.0 && Math::IsNearlyEqual(Mid64, 0.5) && End64 == 1.0 && Start32 == 0.0 && Math::IsNearlyEqual(Mid32, float32(0.5)) && End32 == 1.0;
	bool bVector = VStart64.X == 0.0 && Math::IsNearlyEqual(VMid64.X, 5.0) && Math::IsNearlyEqual(VMid32.X, 5.0) && Mid3f.X == 5.0;
	bool bQuat = QStart64.IsIdentity() && QEnd64.Equals(QP1, KINDA_SMALL_NUMBER) && QStart32.IsIdentity() && Q4Start.IsIdentity() && Q4End.Equals(Q4P1, float32(KINDA_SMALL_NUMBER));
	return bScalar && bVector && bQuat;
}
/** @end */
/**
 * @begin cubic-interp-derivative
 * @summary are new FQuat/FQuat4f values.
 * @topic Unreal
 */
/**
 * @function ObserveCubicInterpDerivativeNominal
 * @summary are new FQuat/FQuat4f values.
 * @covers FMath.cubic-interp-derivative
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCubicInterpDerivativeNominal()
{
	float64 P0_64 = 0.0;
	float64 P1_64 = 1.0;
	float64 T0_64 = 0.0;
	float64 T1_64 = 0.0;
	float64 DerivStart64 = Math::CubicInterpDerivative(P0_64, T0_64, P1_64, T1_64, 0.0);
	float64 DerivMid64 = Math::CubicInterpDerivative(P0_64, T0_64, P1_64, T1_64, 0.5);

	FVector VP0(0.0, 0.0, 0.0);
	FVector VP1(10.0, 0.0, 0.0);
	FVector VT;
	FVector DerivStartV = Math::CubicInterpDerivative(VP0, VT, VP1, VT, 0.0);
	FVector DerivMidV = Math::CubicInterpDerivative(VP0, VT, VP1, VT, 0.5);
	bool bScalar = Math::IsNearlyEqual(DerivStart64, 0.0, KINDA_SMALL_NUMBER) && Math::IsFinite(DerivMid64);
	bool bVector = DerivStartV.IsNearlyZero() && Math::IsFinite(DerivMidV.X);
	return bScalar && bVector;
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_06-cubic-interp-derivative
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveCubicInterpDerivativeNominal
 * @summary Call Math::.
 * @covers FMath.cubic-interp-derivative
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCubicInterpDerivativeNominal()
{
	FRotator RP0 = FRotator::ZeroRotator;
	FRotator RP1(0.0, 90.0, 0.0);
	FRotator RT = FRotator::ZeroRotator;
	FRotator DerivR64 = Math::CubicInterpDerivative(RP0, RT, RP1, RT, 0.0);
	FRotator DerivR64Mid = Math::CubicInterpDerivative(RP0, RT, RP1, RT, 0.5);

	float32 P0_32 = 0.0;
	float32 P1_32 = 1.0;
	float32 T0_32 = 0.0;
	float32 T1_32 = 0.0;
	float32 Zero32 = 0.0;
	float32 Half32 = 0.5;
	float32 DerivS32 = Math::CubicInterpDerivative(P0_32, T0_32, P1_32, T1_32, Zero32);
	float32 DerivM32 = Math::CubicInterpDerivative(P0_32, T0_32, P1_32, T1_32, Half32);

	FVector VP0(0.0, 0.0, 0.0);
	FVector VP1(10.0, 0.0, 0.0);
	FVector VT;
	FVector DerivV32 = Math::CubicInterpDerivative(VP0, VT, VP1, VT, Zero32);
	FRotator DerivR32 = Math::CubicInterpDerivative(RP0, RT, RP1, RT, Zero32);

	FVector3f P0_3f(0.0, 0.0, 0.0);
	FVector3f P1_3f(10.0, 0.0, 0.0);
	FVector3f T3f;
	FVector3f Deriv3f = Math::CubicInterpDerivative(P0_3f, T3f, P1_3f, T3f, Zero32);

	FRotator3f R3P0 = FRotator3f::ZeroRotator;
	FRotator3f R3P1(0.0, 90.0, 0.0);
	FRotator3f R3T = FRotator3f::ZeroRotator;
	FRotator3f DerivR3 = Math::CubicInterpDerivative(R3P0, R3T, R3P1, R3T, Zero32);

	bool bRot64 = Math::IsFinite(DerivR64.Yaw) && Math::IsFinite(DerivR64Mid.Yaw);
	bool bScalar32 = Math::IsNearlyEqual(DerivS32, Zero32, float32(KINDA_SMALL_NUMBER)) && Math::IsFinite(DerivM32);
	bool bRest = DerivV32.IsNearlyZero() && Math::IsFinite(DerivR32.Yaw) && Math::IsFinite(Deriv3f.X) && Math::IsFinite(DerivR3.Yaw);
	return bRot64 && bScalar32 && bRest;
}
/** @end */
/**
 * @begin v-interp-normal-rotation-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveVInterpNormalRotationToNominal
 * @summary Call Math::.
 * @covers FMath.v-interp-normal-rotation-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVInterpNormalRotationToNominal()
{
	FVector Current(1.0, 0.0, 0.0);
	FVector Target(0.0, 1.0, 0.0);
	FVector Rotated = Math::VInterpNormalRotationTo(Current, Target, 1.0, 90.0);
	FVector Unmoved = Math::VInterpNormalRotationTo(Current, Target, 0.0, 90.0);
	bool bReachedTarget = Rotated.Equals(Target, KINDA_SMALL_NUMBER);
	bool bZeroDeltaStays = Unmoved.Equals(Current, KINDA_SMALL_NUMBER);
	return bReachedTarget && bZeroDeltaStays;
}
/** @end */
/**
 * @begin v-interp-constant-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveVInterpConstantToNominal
 * @summary Call Math::.
 * @covers FMath.v-interp-constant-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVInterpConstantToNominal()
{
	FVector Current(0.0, 0.0, 0.0);
	FVector Target(10.0, 0.0, 0.0);
	FVector Stepped = Math::VInterpConstantTo(Current, Target, 0.5, 4.0);
	FVector Snapped = Math::VInterpConstantTo(Current, Target, 0.5, 0.0);
	FVector Arrived = Math::VInterpConstantTo(Target, Target, 0.5, 4.0);
	bool bMovedTwo = Stepped.Equals(FVector(2.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
	bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	bool bAtTarget = Arrived.Equals(Target, KINDA_SMALL_NUMBER);
	return bMovedTwo && bSpeedZeroSnaps && bAtTarget;
}
/** @end */
/**
 * @begin v-interp-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveVInterpToNominal
 * @summary Call Math::.
 * @covers FMath.v-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVInterpToNominal()
{
	FVector Current(0.0, 0.0, 0.0);
	FVector Target(10.0, 0.0, 0.0);
	FVector Eased = Math::VInterpTo(Current, Target, 0.1, 1.0);
	FVector Snapped = Math::VInterpTo(Current, Target, 0.1, 0.0);
	bool bBetween = Eased.X > 0.0 && Eased.X < 10.0;
	bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	return bBetween && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin vector-2-d-interp-constant-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveVector2DInterpConstantToNominal
 * @summary Call Math::.
 * @covers FMath.vector-2-d-interp-constant-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVector2DInterpConstantToNominal()
{
	FVector2D Current(0.0, 0.0);
	FVector2D Target(10.0, 0.0);
	FVector2D Stepped = Math::Vector2DInterpConstantTo(Current, Target, 0.5, 4.0);
	FVector2D Snapped = Math::Vector2DInterpConstantTo(Current, Target, 0.5, 0.0);
	bool bMovedTwo = Math::IsNearlyEqual(Stepped.X, 2.0) && Math::IsNearlyEqual(Stepped.Y, 0.0);
	bool bSpeedZeroSnaps = Math::IsNearlyEqual(Snapped.X, 10.0);
	return bMovedTwo && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin vector-2-d-interp-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveVector2DInterpToNominal
 * @summary Call Math::.
 * @covers FMath.vector-2-d-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVector2DInterpToNominal()
{
	FVector2D Current(0.0, 0.0);
	FVector2D Target(10.0, 0.0);
	FVector2D Eased = Math::Vector2DInterpTo(Current, Target, 0.1, 1.0);
	FVector2D Snapped = Math::Vector2DInterpTo(Current, Target, 0.1, 0.0);
	bool bBetween = Eased.X > 0.0 && Eased.X < 10.0;
	bool bSpeedZeroSnaps = Math::IsNearlyEqual(Snapped.X, 10.0);
	return bBetween && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin r-interp-constant-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveRInterpConstantToNominal
 * @summary Call Math::.
 * @covers FMath.r-interp-constant-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRInterpConstantToNominal()
{
	FRotator Current = FRotator::ZeroRotator;
	FRotator Target(0.0, 90.0, 0.0);
	FRotator Stepped = Math::RInterpConstantTo(Current, Target, 0.5, 40.0);
	FRotator Snapped = Math::RInterpConstantTo(Current, Target, 0.5, 0.0);
	bool bMovedToward = Stepped.Yaw > 0.0 && Stepped.Yaw <= 90.0;
	bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	return bMovedToward && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin r-interp-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveRInterpToNominal
 * @summary Call Math::.
 * @covers FMath.r-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRInterpToNominal()
{
	FRotator Current = FRotator::ZeroRotator;
	FRotator Target(0.0, 90.0, 0.0);
	FRotator Eased = Math::RInterpTo(Current, Target, 0.1, 1.0);
	FRotator Snapped = Math::RInterpTo(Current, Target, 0.1, 0.0);
	bool bMovedToward = Eased.Yaw > 0.0 && Eased.Yaw < 90.0;
	bool bSpeedZeroSnaps = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	return bMovedToward && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin rotator-from-axis-and-angle
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveRotatorFromAxisAndAngleNominal
 * @summary Call Math::.
 * @covers FMath.rotator-from-axis-and-angle
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotatorFromAxisAndAngleNominal()
{
	FVector Axis(0.0, 0.0, 1.0);
	FRotator Yaw90 = Math::RotatorFromAxisAndAngle(Axis, 90.0);
	FRotator Zero = Math::RotatorFromAxisAndAngle(Axis, 0.0);
	bool bYawNear90 = Math::IsNearlyEqual(Math::Abs(Yaw90.Yaw), 90.0, KINDA_SMALL_NUMBER);
	bool bZeroAngle = Zero.Equals(FRotator::ZeroRotator, KINDA_SMALL_NUMBER);
	return bYawNear90 && bZeroAngle;
}
/** @end */
/**
 * @begin random-point-in-bounding-box
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveRandomPointInBoundingBoxNominal
 * @summary Call Math::.
 * @covers FMath.random-point-in-bounding-box
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRandomPointInBoundingBoxNominal()
{
	FVector Center(0.0, 0.0, 0.0);
	FVector HalfSize(1.0, 1.0, 1.0);
	FVector Sample = Math::RandomPointInBoundingBox(Center, HalfSize);
	FVector SampleAgain = Math::RandomPointInBoundingBox(Center, HalfSize);
	bool bInside = Sample.X >= -1.0 && Sample.X <= 1.0 && Sample.Y >= -1.0 && Sample.Y <= 1.0 && Sample.Z >= -1.0 && Sample.Z <= 1.0;
	bool bAgainInside = SampleAgain.X >= -1.0 && SampleAgain.X <= 1.0 && SampleAgain.Y >= -1.0 && SampleAgain.Y <= 1.0 && SampleAgain.Z >= -1.0 && SampleAgain.Z <= 1.0;
	return bInside && bAgainInside;
}
/** @end */
/**
 * @begin random-rotator
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveRandomRotatorNominal
 * @summary Call Math::.
 * @covers FMath.random-rotator
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRandomRotatorNominal()
{
	FRotator WithRoll = Math::RandomRotator(true);
	FRotator WithoutRoll = Math::RandomRotator(false);
	bool bWithRollFinite = Math::IsFinite(WithRoll.Pitch) && Math::IsFinite(WithRoll.Yaw) && Math::IsFinite(WithRoll.Roll);
	bool bRollHeldZero = Math::IsNearlyEqual(WithoutRoll.Roll, 0.0);
	return bWithRollFinite && bRollHeldZero;
}
/** @end */
/**
 * @begin q-interp-constant-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveQInterpConstantToNominal
 * @summary Call Math::.
 * @covers FMath.q-interp-constant-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveQInterpConstantToNominal()
{
	FQuat Current = FQuat::Identity;
	FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
	FQuat Stepped = Math::QInterpConstantTo(Current, Target, 0.5, 40.0);
	FQuat Snapped = Math::QInterpConstantTo(Current, Target, 0.5, 0.0);
	FQuat4f Current4 = FQuat4f::Identity;
	FQuat4f Target4 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Stepped4 = Math::QInterpConstantTo(Current4, Target4, 0.5, 40.0);
	FQuat4f Snapped4 = Math::QInterpConstantTo(Current4, Target4, 0.5, 0.0);
	bool bMoved = !Stepped.Equals(Current, KINDA_SMALL_NUMBER);
	bool bSnapped = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	bool bMoved4 = !Stepped4.Equals(Current4, float32(KINDA_SMALL_NUMBER));
	bool bSnapped4 = Snapped4.Equals(Target4, float32(KINDA_SMALL_NUMBER));
	return bMoved && bSnapped && bMoved4 && bSnapped4;
}
/** @end */
/**
 * @begin q-interp-to
 * @summary Call Math::.
 * @topic Unreal
 */
/**
 * @function ObserveQInterpToNominal
 * @summary Call Math::.
 * @covers FMath.q-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveQInterpToNominal()
{
	FQuat Current = FQuat::Identity;
	FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
	FQuat Eased = Math::QInterpTo(Current, Target, 0.1, 1.0);
	FQuat Snapped = Math::QInterpTo(Current, Target, 0.1, 0.0);
	FQuat4f Current4 = FQuat4f::Identity;
	FQuat4f Target4 = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
	FQuat4f Eased4 = Math::QInterpTo(Current4, Target4, 0.1, 1.0);
	FQuat4f Snapped4 = Math::QInterpTo(Current4, Target4, 0.1, 0.0);
	bool bMoved = !Eased.Equals(Current, KINDA_SMALL_NUMBER);
	bool bSnapped = Snapped.Equals(Target, KINDA_SMALL_NUMBER);
	bool bMoved4 = !Eased4.Equals(Current4, float32(KINDA_SMALL_NUMBER));
	bool bSnapped4 = Snapped4.Equals(Target4, float32(KINDA_SMALL_NUMBER));
	return bMoved && bSnapped && bMoved4 && bSnapped4;
}
/** @end */
/**
 * @begin f-interp-constant-to
 * @summary to Target.
 * @topic Unreal
 */
/**
 * @function ObserveFInterpConstantToNominal
 * @summary to Target.
 * @covers FMath.f-interp-constant-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// to Target. Nearby sphere intersects; far sphere does not.

 Ray hits (0,0,0).
// Boundary/ownership: RadiusSquared is the squared radius. Call Math::.
bool ObserveFInterpConstantToNominal()
{
	float32 Current32 = 0.0;
	float32 Target32 = 10.0;
	float32 Dt32 = 0.5;
	float32 Speed32 = 4.0;
	float32 ZeroSpeed32 = 0.0;
	float32 Stepped32 = Math::FInterpConstantTo(Current32, Target32, Dt32, Speed32);
	float32 Snapped32 = Math::FInterpConstantTo(Current32, Target32, Dt32, ZeroSpeed32);
	float64 Current64 = 0.0;
	float64 Target64 = 10.0;
	float64 Dt64 = 0.5;
	float64 Speed64 = 4.0;
	float64 ZeroSpeed64 = 0.0;
	float64 Stepped64 = Math::FInterpConstantTo(Current64, Target64, Dt64, Speed64);
	float64 Snapped64 = Math::FInterpConstantTo(Current64, Target64, Dt64, ZeroSpeed64);
	return Math::IsNearlyEqual(Stepped32, float32(2.0)) && Math::IsNearlyEqual(Snapped32, float32(10.0)) && Math::IsNearlyEqual(Stepped64, 2.0) && Math::IsNearlyEqual(Snapped64, 10.0);
}
/** @end */
/**
 * @begin f-interp-to
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @topic Unreal
 */
/**
 * @function ObserveFInterpToNominal
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @covers FMath.f-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// to Target. Nearby sphere intersects; far sphere does not.

bool ObserveFInterpToNominal()
{
	float32 Current32 = 0.0;
	float32 Target32 = 10.0;
	float32 Dt32 = 0.1;
	float32 Speed32 = 1.0;
	float32 ZeroSpeed32 = 0.0;
	float32 Eased32 = Math::FInterpTo(Current32, Target32, Dt32, Speed32);
	float32 Snapped32 = Math::FInterpTo(Current32, Target32, Dt32, ZeroSpeed32);
	float64 Current64 = 0.0;
	float64 Target64 = 10.0;
	float64 Dt64 = 0.1;
	float64 Speed64 = 1.0;
	float64 ZeroSpeed64 = 0.0;
	float64 Eased64 = Math::FInterpTo(Current64, Target64, Dt64, Speed64);
	float64 Snapped64 = Math::FInterpTo(Current64, Target64, Dt64, ZeroSpeed64);
	bool bBetween32 = Eased32 > 0.0 && Eased32 < 10.0;
	bool bBetween64 = Eased64 > 0.0 && Eased64 < 10.0;
	return bBetween32 && Math::IsNearlyEqual(Snapped32, float32(10.0)) && bBetween64 && Math::IsNearlyEqual(Snapped64, 10.0);
}
/** @end */
/**
 * @begin c-interp-to
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @topic Unreal
 */
/**
 * @function ObserveCInterpToNominal
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @covers FMath.c-interp-to
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// to Target. Nearby sphere intersects; far sphere does not.

bool ObserveCInterpToNominal()
{
	FLinearColor Current = FLinearColor::White;
	FLinearColor Target = FLinearColor::Black;
	float32 Dt = 0.1;
	float32 Speed = 1.0;
	float32 ZeroSpeed = 0.0;
	FLinearColor Eased = Math::CInterpTo(Current, Target, Dt, Speed);
	FLinearColor Snapped = Math::CInterpTo(Current, Target, Dt, ZeroSpeed);
	bool bMoved = Eased.R < 1.0 && Eased.R > 0.0;
	bool bSpeedZeroSnaps = Snapped.Equals(Target);
	return bMoved && bSpeedZeroSnaps;
}
/** @end */
/**
 * @begin sphere-aabb-intersection
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @topic Unreal
 */
/**
 * @function ObserveSphereAABBIntersectionNominal
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @covers FMath.sphere-aabb-intersection
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// to Target. Nearby sphere intersects; far sphere does not.

bool ObserveSphereAABBIntersectionNominal()
{
	FBox NearBox(FVector(-0.5, -0.5, -0.5), FVector(0.5, 0.5, 0.5));
	FBox FarBox(FVector(10.0, 10.0, 10.0), FVector(11.0, 11.0, 11.0));
	bool bCenterHits = Math::SphereAABBIntersection(FVector(0.0, 0.0, 0.0), 1.0, NearBox);
	bool bCenterMisses = Math::SphereAABBIntersection(FVector(0.0, 0.0, 0.0), 1.0, FarBox);
	FSphere NearSphere(FVector(0.0, 0.0, 0.0), 1.0);
	bool bSphereHits = Math::SphereAABBIntersection(NearSphere, NearBox);
	bool bSphereMisses = Math::SphereAABBIntersection(NearSphere, FarBox);

	FBox3f NearBox3(FVector3f(-0.5, -0.5, -0.5), FVector3f(0.5, 0.5, 0.5));
	FBox3f FarBox3(FVector3f(10.0, 10.0, 10.0), FVector3f(11.0, 11.0, 11.0));
	float32 RadiusSq32 = 1.0;
	bool bCenterHits3 = Math::SphereAABBIntersection(FVector3f(0.0, 0.0, 0.0), RadiusSq32, NearBox3);
	bool bCenterMisses3 = Math::SphereAABBIntersection(FVector3f(0.0, 0.0, 0.0), RadiusSq32, FarBox3);
	FSphere3f NearSphere3(FVector3f(0.0, 0.0, 0.0), 1.0);
	bool bSphereHits3 = Math::SphereAABBIntersection(NearSphere3, NearBox3);
	bool bSphereMisses3 = Math::SphereAABBIntersection(NearSphere3, FarBox3);
	return bCenterHits && !bCenterMisses && bSphereHits && !bSphereMisses && bCenterHits3 && !bCenterMisses3 && bSphereHits3 && !bSphereMisses3;
}
/** @end */
/**
 * @begin ray-plane-intersection
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @topic Unreal
 */
/**
 * @function ObserveRayPlaneIntersectionNominal
 * @summary Boundary/ownership: RadiusSquared is the squared radius.
 * @covers FMath.ray-plane-intersection
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// to Target. Nearby sphere intersects; far sphere does not.

bool ObserveRayPlaneIntersectionNominal()
{
	FPlane Plane(FVector(0.0, 0.0, 0.0), FVector(0.0, 0.0, 1.0));
	FVector Hit = Math::RayPlaneIntersection(FVector(0.0, 0.0, 1.0), FVector(0.0, 0.0, -1.0), Plane);
	FVector Parallel = Math::RayPlaneIntersection(FVector(0.0, 0.0, 1.0), FVector(1.0, 0.0, 0.0), Plane);
	bool bHitOrigin = Hit.Equals(FVector(0.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
	bool bParallelFinite = Math::IsFinite(Parallel.X);
	return bHitOrigin && bParallelFinite;
}
/** @end */
/**
 * @begin line-plane-intersection
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveLinePlaneIntersectionNominal
 * @summary Observe the container API.
 * @covers FMath.line-plane-intersection
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Line (0,0,1)-(0,0,-1) vs Z=0 plane; segment along +X through a
// unit sphere; box [-1,1] with StartToEnd (4,0,0); 45-degree cone radius 10;
// 1.9 and -1.9.
// Expected observations: Plane hit is (0,0,0). The X-axis segment hits the
// unit sphere and the box. A miss along (0,1,0) from (2,2,2) is false. Cone
// sphere radius is positive. TruncToInt(1.9) is 1 and TruncToInt(-1.9) is -1.
// Boundary/ownership: StartToEnd is precomputed End-Start. ConeDirection is
// expected to be normalized. Call Math::.
bool ObserveLinePlaneIntersectionNominal()
{
	FVector Point1(0.0, 0.0, 1.0);
	FVector Point2(0.0, 0.0, -1.0);
	FVector Origin(0.0, 0.0, 0.0);
	FVector Normal(0.0, 0.0, 1.0);
	FVector HitFromNormal = Math::LinePlaneIntersection(Point1, Point2, Origin, Normal);
	FPlane Plane(Origin, Normal);
	FVector HitFromPlane = Math::LinePlaneIntersection(Point1, Point2, Plane);
	FVector3f P1_3f(0.0, 0.0, 1.0);
	FVector3f P2_3f(0.0, 0.0, -1.0);
	FVector3f Origin3f(0.0, 0.0, 0.0);
	FVector3f Normal3f(0.0, 0.0, 1.0);
	FVector3f Hit3f = Math::LinePlaneIntersection(P1_3f, P2_3f, Origin3f, Normal3f);
	return HitFromNormal.Equals(Origin, KINDA_SMALL_NUMBER) && HitFromPlane.Equals(Origin, KINDA_SMALL_NUMBER) && Math::IsNearlyEqual(Hit3f.Z, float32(0.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin line-sphere-intersection
 * @summary expected to be normalized.
 * @topic Unreal
 */
/**
 * @function ObserveLineSphereIntersectionNominal
 * @summary expected to be normalized.
 * @covers FMath.line-sphere-intersection
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLineSphereIntersectionNominal()
{
	float32 Length3f = 4.0;
	float32 Radius3f = 1.0;
	float32 MissLength3f = 1.0;
	bool bHit3f = Math::LineSphereIntersection(FVector3f(-2.0, 0.0, 0.0), FVector3f(1.0, 0.0, 0.0), Length3f, FVector3f(0.0, 0.0, 0.0), Radius3f);
	bool bMiss3f = Math::LineSphereIntersection(FVector3f(2.0, 2.0, 2.0), FVector3f(0.0, 1.0, 0.0), MissLength3f, FVector3f(0.0, 0.0, 0.0), Radius3f);
	bool bHit64 = Math::LineSphereIntersection(FVector(-2.0, 0.0, 0.0), FVector(1.0, 0.0, 0.0), 4.0, FVector(0.0, 0.0, 0.0), 1.0);
	bool bMiss64 = Math::LineSphereIntersection(FVector(2.0, 2.0, 2.0), FVector(0.0, 1.0, 0.0), 1.0, FVector(0.0, 0.0, 0.0), 1.0);
	return bHit3f && !bMiss3f && bHit64 && !bMiss64;
}
/** @end */
/**
 * @begin line-box-intersection
 * @summary expected to be normalized.
 * @topic Unreal
 */
/**
 * @function ObserveLineBoxIntersectionNominal
 * @summary expected to be normalized.
 * @covers FMath.line-box-intersection
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLineBoxIntersectionNominal()
{
	FBox Box(FVector(-1.0, -1.0, -1.0), FVector(1.0, 1.0, 1.0));
	FVector Start(-2.0, 0.0, 0.0);
	FVector End(2.0, 0.0, 0.0);
	FVector StartToEnd = End - Start;
	bool bHits = Math::LineBoxIntersection(Box, Start, End, StartToEnd);
	FVector MissStart(2.0, 2.0, 2.0);
	FVector MissEnd(3.0, 2.0, 2.0);
	FVector MissDelta = MissEnd - MissStart;
	bool bMisses = Math::LineBoxIntersection(Box, MissStart, MissEnd, MissDelta);
	return bHits && !bMisses;
}
/** @end */
/**
 * @begin compute-bounding-sphere-for-cone
 * @summary expected to be normalized.
 * @topic Unreal
 */
/**
 * @function ObserveComputeBoundingSphereForConeNominal
 * @summary expected to be normalized.
 * @covers FMath.compute-bounding-sphere-for-cone
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveComputeBoundingSphereForConeNominal()
{
	FVector ConeOrigin(0.0, 0.0, 0.0);
	FVector ConeDirection(1.0, 0.0, 0.0);
	float64 Half = HALF_PI * 0.5;
	FSphere Bound = Math::ComputeBoundingSphereForCone(ConeOrigin, ConeDirection, 10.0, Math::Cos(Half), Math::Sin(Half));
	FVector3f Origin3f(0.0, 0.0, 0.0);
	FVector3f Dir3f(1.0, 0.0, 0.0);
	float32 Half32 = float32(Half);
	float32 Radius32 = 10.0;
	FSphere3f Bound3 = Math::ComputeBoundingSphereForCone(Origin3f, Dir3f, Radius32, Math::Cos(Half32), Math::Sin(Half32));
	return Bound.W > 0.0 && Bound3.W > 0.0;
}
/** @end */
/**
 * @begin trunc-to-int
 * @summary expected to be normalized.
 * @topic Unreal
 */
/**
 * @function ObserveTruncToIntNominal
 * @summary expected to be normalized.
 * @covers FMath.trunc-to-int
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTruncToIntNominal()
{
	int32 Pos64 = Math::TruncToInt(1.9);
	int32 Neg64 = Math::TruncToInt(-1.9);
	float32 Pos32 = 1.9;
	float32 Neg32 = -1.9;
	int32 PosI32 = Math::TruncToInt(Pos32);
	int32 NegI32 = Math::TruncToInt(Neg32);
	return Pos64 == 1 && Neg64 == -1 && PosI32 == 1 && NegI32 == -1;
}
/** @end */
/**
 * @begin trunc-to-float
 * @summary is 2.
 * @topic Unreal
 */
/**
 * @function ObserveTruncToFloatNominal
 * @summary is 2.
 * @covers FMath.trunc-to-float
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

 and FloorToInt(-1.1) is -2. Zero stays 0.
// Boundary/ownership: Trunc preserves sign and drops the fraction. Floor
// rounds down. Call Math::. DefaultSafe; no fixture.
bool ObserveTruncToFloatNominal()
{
	float64 Pos64 = Math::TruncToFloat(1.9);
	float64 Neg64 = Math::TruncToFloat(-1.9);
	float64 Zero64 = Math::TruncToFloat(0.0);
	float32 Pos32In = 1.9;
	float32 Neg32In = -1.9;
	float32 Zero32In = 0.0;
	float32 Pos32 = Math::TruncToFloat(Pos32In);
	float32 Neg32 = Math::TruncToFloat(Neg32In);
	float32 Zero32 = Math::TruncToFloat(Zero32In);
	return Pos64 == 1.0 && Neg64 == -1.0 && Zero64 == 0.0 && Pos32 == 1.0 && Neg32 == -1.0 && Zero32 == 0.0;
}
/** @end */
/**
 * @begin trunc-to-double
 * @summary rounds down.
 * @topic Unreal
 */
/**
 * @function ObserveTruncToDoubleNominal
 * @summary rounds down.
 * @covers FMath.trunc-to-double
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

bool ObserveTruncToDoubleNominal()
{
	float64 Pos = Math::TruncToDouble(1.9);
	float64 Neg = Math::TruncToDouble(-1.9);
	float64 Zero = Math::TruncToDouble(0.0);
	return Pos == 1.0 && Neg == -1.0 && Zero == 0.0;
}
/** @end */
/**
 * @begin round-to-int
 * @summary rounds down.
 * @topic Unreal
 */
/**
 * @function ObserveRoundToIntNominal
 * @summary rounds down.
 * @covers FMath.round-to-int
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

bool ObserveRoundToIntNominal()
{
	int32 Pos64 = Math::RoundToInt(1.5);
	int32 Neg64 = Math::RoundToInt(-1.1);
	int32 Zero64 = Math::RoundToInt(0.0);
	float32 Pos32 = 1.5;
	float32 Neg32 = -1.1;
	int32 PosI32 = Math::RoundToInt(Pos32);
	int32 NegI32 = Math::RoundToInt(Neg32);
	return Pos64 == 2 && Neg64 == -1 && Zero64 == 0 && PosI32 == 2 && NegI32 == -1;
}
/** @end */
/**
 * @begin round-to-float
 * @summary rounds down.
 * @topic Unreal
 */
/**
 * @function ObserveRoundToFloatNominal
 * @summary rounds down.
 * @covers FMath.round-to-float
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

bool ObserveRoundToFloatNominal()
{
	float64 Pos64 = Math::RoundToFloat(1.5);
	float64 Neg64 = Math::RoundToFloat(-1.1);
	float32 Pos32In = 1.5;
	float32 Neg32In = -1.1;
	float32 Pos32 = Math::RoundToFloat(Pos32In);
	float32 Neg32 = Math::RoundToFloat(Neg32In);
	return Pos64 == 2.0 && Neg64 == -1.0 && Pos32 == 2.0 && Neg32 == -1.0;
}
/** @end */
/**
 * @begin round-to-double
 * @summary rounds down.
 * @topic Unreal
 */
/**
 * @function ObserveRoundToDoubleNominal
 * @summary rounds down.
 * @covers FMath.round-to-double
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

bool ObserveRoundToDoubleNominal()
{
	float64 Pos = Math::RoundToDouble(1.5);
	float64 Neg = Math::RoundToDouble(-1.1);
	float64 Zero = Math::RoundToDouble(0.0);
	return Pos == 2.0 && Neg == -1.0 && Zero == 0.0;
}
/** @end */
/**
 * @begin floor-to-int
 * @summary rounds down.
 * @topic Unreal
 */
/**
 * @function ObserveFloorToIntNominal
 * @summary rounds down.
 * @covers FMath.floor-to-int
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// is 2. FloorToInt(1.9) is 1

bool ObserveFloorToIntNominal()
{
	int32 Pos64 = Math::FloorToInt(1.9);
	int32 Neg64 = Math::FloorToInt(-1.1);
	int32 Zero64 = Math::FloorToInt(0.0);
	float32 Pos32 = 1.9;
	float32 Neg32 = -1.1;
	int32 PosI32 = Math::FloorToInt(Pos32);
	int32 NegI32 = Math::FloorToInt(Neg32);
	return Pos64 == 1 && Neg64 == -2 && Zero64 == 0 && PosI32 == 1 && NegI32 == -2;
}
/** @end */
/**
 * @begin floor-to-float
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveFloorToFloatNominal
 * @summary Expected
 * @covers FMath.floor-to-float
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: Floor(1.9) is 1 and Floor(-1.1) is -2. Ceil(1.1)
// is 2 and Ceil(-1.1) is -1. RoundFromZero(1.5) is 2 and RoundFromZero(-1.5)
// is -2.
// Boundary/ownership: Floor rounds down. Ceil rounds up. RoundFromZero
// pushes halfway cases away from zero. Call Math::.
bool ObserveFloorToFloatNominal()
{
	float64 Pos64 = Math::FloorToFloat(1.9);
	float64 Neg64 = Math::FloorToFloat(-1.1);
	float32 Pos32In = 1.9;
	float32 Neg32In = -1.1;
	float32 Pos32 = Math::FloorToFloat(Pos32In);
	float32 Neg32 = Math::FloorToFloat(Neg32In);
	return Pos64 == 1.0 && Neg64 == -2.0 && Pos32 == 1.0 && Neg32 == -2.0;
}
/** @end */
/**
 * @begin floor-to-double
 * @summary pushes halfway cases away from zero.
 * @topic Unreal
 */
/**
 * @function ObserveFloorToDoubleNominal
 * @summary pushes halfway cases away from zero.
 * @covers FMath.floor-to-double
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFloorToDoubleNominal()
{
	float64 Pos = Math::FloorToDouble(1.9);
	float64 Neg = Math::FloorToDouble(-1.1);
	float64 Zero = Math::FloorToDouble(0.0);
	return Pos == 1.0 && Neg == -2.0 && Zero == 0.0;
}
/** @end */
/**
 * @begin ceil-to-int
 * @summary pushes halfway cases away from zero.
 * @topic Unreal
 */
/**
 * @function ObserveCeilToIntNominal
 * @summary pushes halfway cases away from zero.
 * @covers FMath.ceil-to-int
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveCeilToIntNominal()
{
	int32 Pos64 = Math::CeilToInt(1.1);
	int32 Neg64 = Math::CeilToInt(-1.1);
	int32 Zero64 = Math::CeilToInt(0.0);
	float32 Pos32 = 1.1;
	float32 Neg32 = -1.1;
	int32 PosI32 = Math::CeilToInt(Pos32);
	int32 NegI32 = Math::CeilToInt(Neg32);
	return Pos64 == 2 && Neg64 == -1 && Zero64 == 0 && PosI32 == 2 && NegI32 == -1;
}
/** @end */
/**
 * @begin ceil-to-float
 * @summary pushes halfway cases away from zero.
 * @topic Unreal
 */
/**
 * @function ObserveCeilToFloatNominal
 * @summary pushes halfway cases away from zero.
 * @covers FMath.ceil-to-float
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveCeilToFloatNominal()
{
	float64 Pos64 = Math::CeilToFloat(1.1);
	float64 Neg64 = Math::CeilToFloat(-1.1);
	float32 Pos32In = 1.1;
	float32 Neg32In = -1.1;
	float32 Pos32 = Math::CeilToFloat(Pos32In);
	float32 Neg32 = Math::CeilToFloat(Neg32In);
	return Pos64 == 2.0 && Neg64 == -1.0 && Pos32 == 2.0 && Neg32 == -1.0;
}
/** @end */
/**
 * @begin ceil-to-double
 * @summary pushes halfway cases away from zero.
 * @topic Unreal
 */
/**
 * @function ObserveCeilToDoubleNominal
 * @summary pushes halfway cases away from zero.
 * @covers FMath.ceil-to-double
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveCeilToDoubleNominal()
{
	float64 Pos = Math::CeilToDouble(1.1);
	float64 Neg = Math::CeilToDouble(-1.1);
	float64 Zero = Math::CeilToDouble(0.0);
	return Pos == 2.0 && Neg == -1.0 && Zero == 0.0;
}
/** @end */
/**
 * @begin round-from-zero
 * @summary pushes halfway cases away from zero.
 * @topic Unreal
 */
/**
 * @function ObserveRoundFromZeroNominal
 * @summary pushes halfway cases away from zero.
 * @covers FMath.round-from-zero
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveRoundFromZeroNominal()
{
	float64 Pos64 = Math::RoundFromZero(1.5);
	float64 Neg64 = Math::RoundFromZero(-1.5);
	float64 Zero64 = Math::RoundFromZero(0.0);
	float32 Pos32In = 1.5;
	float32 Neg32In = -1.5;
	float32 Zero32In = 0.0;
	float32 Pos32 = Math::RoundFromZero(Pos32In);
	float32 Neg32 = Math::RoundFromZero(Neg32In);
	float32 Zero32 = Math::RoundFromZero(Zero32In);
	return Pos64 == 2.0 && Neg64 == -2.0 && Zero64 == 0.0 && Pos32 == 2.0 && Neg32 == -2.0 && Zero32 == 0.0;
}
/** @end */
/**
 * @begin inv-sqrt
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveInvSqrtNominal
 * @summary Expected
 * @covers FMath.inv-sqrt
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: InvSqrt(4) is 0.5. Fractional(1.25) is 0.25 and
// Fractional(-1.25) is -0.25. Frac(-1.25) is nonnegative. Exp(0) is 1.
// Exp2(3) is 8.
// Boundary/ownership: Fractional keeps the sign after truncating toward zero.
// Frac is the nonnegative remainder after flooring. Call Math::.
bool ObserveInvSqrtNominal()
{
	float64 Inv64 = Math::InvSqrt(4.0);
	float64 InvOne64 = Math::InvSqrt(1.0);
	float32 Four32 = 4.0;
	float32 One32 = 1.0;
	float32 Inv32 = Math::InvSqrt(Four32);
	float32 InvOne32 = Math::InvSqrt(One32);
	return Math::IsNearlyEqual(Inv64, 0.5) && Math::IsNearlyEqual(InvOne64, 1.0) && Math::IsNearlyEqual(Inv32, float32(0.5), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(InvOne32, float32(1.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin inv-sqrt-est
 * @summary Frac is the nonnegative remainder after flooring.
 * @topic Unreal
 */
/**
 * @function ObserveInvSqrtEstNominal
 * @summary Frac is the nonnegative remainder after flooring.
 * @covers FMath.inv-sqrt-est
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveInvSqrtEstNominal()
{
	float64 Est64 = Math::InvSqrtEst(4.0);
	float64 EstOne64 = Math::InvSqrtEst(1.0);
	float32 Four32 = 4.0;
	float32 One32 = 1.0;
	float32 Est32 = Math::InvSqrtEst(Four32);
	float32 EstOne32 = Math::InvSqrtEst(One32);
	return Math::IsNearlyEqual(Est64, 0.5, 0.05) && Math::IsNearlyEqual(EstOne64, 1.0, 0.05) && Math::IsNearlyEqual(Est32, float32(0.5), float32(0.05)) && Math::IsNearlyEqual(EstOne32, float32(1.0), float32(0.05));
}
/** @end */
/**
 * @begin fractional
 * @summary Frac is the nonnegative remainder after flooring.
 * @topic Unreal
 */
/**
 * @function ObserveFractionalNominal
 * @summary Frac is the nonnegative remainder after flooring.
 * @covers FMath.fractional
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFractionalNominal()
{
	float64 Pos64 = Math::Fractional(1.25);
	float64 Neg64 = Math::Fractional(-1.25);
	float64 Whole64 = Math::Fractional(2.0);
	float32 Pos32In = 1.25;
	float32 Neg32In = -1.25;
	float32 Pos32 = Math::Fractional(Pos32In);
	float32 Neg32 = Math::Fractional(Neg32In);
	return Math::IsNearlyEqual(Pos64, 0.25) && Math::IsNearlyEqual(Neg64, -0.25) && Math::IsNearlyEqual(Whole64, 0.0) && Math::IsNearlyEqual(Pos32, float32(0.25)) && Math::IsNearlyEqual(Neg32, float32(-0.25));
}
/** @end */
/**
 * @begin frac
 * @summary Frac is the nonnegative remainder after flooring.
 * @topic Unreal
 */
/**
 * @function ObserveFracNominal
 * @summary Frac is the nonnegative remainder after flooring.
 * @covers FMath.frac
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFracNominal()
{
	float64 Pos64 = Math::Frac(1.25);
	float64 Neg64 = Math::Frac(-1.25);
	float64 Whole64 = Math::Frac(2.0);
	float32 Pos32In = 1.25;
	float32 Neg32In = -1.25;
	float32 Pos32 = Math::Frac(Pos32In);
	float32 Neg32 = Math::Frac(Neg32In);
	bool bFrac64 = Math::IsNearlyEqual(Pos64, 0.25) && Neg64 >= 0.0 && Neg64 < 1.0 && Math::IsNearlyEqual(Whole64, 0.0);
	bool bFrac32 = Math::IsNearlyEqual(Pos32, float32(0.25)) && Neg32 >= 0.0 && Neg32 < 1.0;
	return bFrac64 && bFrac32;
}
/** @end */
/**
 * @begin exp
 * @summary Frac is the nonnegative remainder after flooring.
 * @topic Unreal
 */
/**
 * @function ObserveExpNominal
 * @summary Frac is the nonnegative remainder after flooring.
 * @covers FMath.exp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveExpNominal()
{
	float64 ExpZero = Math::Exp(0.0);
	float64 ExpOne = Math::Exp(1.0);
	return Math::IsNearlyEqual(ExpZero, 1.0) && Math::IsNearlyEqual(ExpOne, EULERS_NUMBER, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin exp-2
 * @summary Frac is the nonnegative remainder after flooring.
 * @topic Unreal
 */
/**
 * @function ObserveExp2Nominal
 * @summary Frac is the nonnegative remainder after flooring.
 * @covers FMath.exp-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveExp2Nominal()
{
	float64 Exp2Zero = Math::Exp2(0.0);
	float64 Exp2Three = Math::Exp2(3.0);
	return Math::IsNearlyEqual(Exp2Zero, 1.0) && Math::IsNearlyEqual(Exp2Three, 8.0);
}
/** @end */
/**
 * @begin loge
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveLogeNominal
 * @summary Observe the container API.
 * @covers FMath.loge
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Loge(1) and Loge(EULERS_NUMBER); Log2(8); LogX(10, 100); Fmod(5,2)
// and Fmod(-5,2); Sin/Cos of 0 and HALF_PI; Acos(1) and Acos(0); Tan(0);
// Atan(0).
// Expected observations: Loge(1) is 0. Log2(8) is 3. LogX(10,100) is 2.
// Fmod(5,2) is 1. Sin(0) is 0 and Cos(0) is 1. Acos(1) is 0. Tan(0) and
// Atan(0) are 0.
// Boundary/ownership: Log Value is positive. Fmod Y is a nonzero divisor.
// Angles are radians. Call Math::.
bool ObserveLogeNominal()
{
	float64 LogOne = Math::Loge(1.0);
	float64 LogE = Math::Loge(EULERS_NUMBER);
	return Math::IsNearlyEqual(LogOne, 0.0) && Math::IsNearlyEqual(LogE, 1.0, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin log-2
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveLog2Nominal
 * @summary Angles are radians.
 * @covers FMath.log-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLog2Nominal()
{
	float64 LogTwo = Math::Log2(2.0);
	float64 LogEight = Math::Log2(8.0);
	return Math::IsNearlyEqual(LogTwo, 1.0) && Math::IsNearlyEqual(LogEight, 3.0);
}
/** @end */
/**
 * @begin log-x
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveLogXNominal
 * @summary Angles are radians.
 * @covers FMath.log-x
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogXNominal()
{
	float64 LogTenHundred = Math::LogX(10.0, 100.0);
	float64 LogTwoEight = Math::LogX(2.0, 8.0);
	return Math::IsNearlyEqual(LogTenHundred, 2.0) && Math::IsNearlyEqual(LogTwoEight, 3.0);
}
/** @end */
/**
 * @begin fmod
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveFmodNominal
 * @summary Angles are radians.
 * @covers FMath.fmod
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFmodNominal()
{
	float64 Pos = Math::Fmod(5.0, 2.0);
	float64 Neg = Math::Fmod(-5.0, 2.0);
	float64 Whole = Math::Fmod(6.0, 2.0);
	return Math::IsNearlyEqual(Pos, 1.0) && Math::IsNearlyEqual(Neg, -1.0) && Math::IsNearlyEqual(Whole, 0.0);
}
/** @end */
/**
 * @begin sin
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveSinNominal
 * @summary Angles are radians.
 * @covers FMath.sin
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSinNominal()
{
	float64 SinZero = Math::Sin(0.0);
	float64 SinHalfPi = Math::Sin(HALF_PI);
	return Math::IsNearlyEqual(SinZero, 0.0) && Math::IsNearlyEqual(SinHalfPi, 1.0);
}
/** @end */
/**
 * @begin sinh
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveSinhNominal
 * @summary Angles are radians.
 * @covers FMath.sinh
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSinhNominal()
{
	float64 SinhZero = Math::Sinh(0.0);
	float64 SinhOne = Math::Sinh(1.0);
	return Math::IsNearlyEqual(SinhZero, 0.0) && SinhOne > 0.0;
}
/** @end */
/**
 * @begin cos
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveCosNominal
 * @summary Angles are radians.
 * @covers FMath.cos
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCosNominal()
{
	float64 CosZero = Math::Cos(0.0);
	float64 CosPi = Math::Cos(PI);
	return Math::IsNearlyEqual(CosZero, 1.0) && Math::IsNearlyEqual(CosPi, -1.0);
}
/** @end */
/**
 * @begin acos
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveAcosNominal
 * @summary Angles are radians.
 * @covers FMath.acos
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAcosNominal()
{
	float64 AcosOne = Math::Acos(1.0);
	float64 AcosZero = Math::Acos(0.0);
	return Math::IsNearlyEqual(AcosOne, 0.0) && Math::IsNearlyEqual(AcosZero, HALF_PI);
}
/** @end */
/**
 * @begin tan
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveTanNominal
 * @summary Angles are radians.
 * @covers FMath.tan
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTanNominal()
{
	float64 TanZero = Math::Tan(0.0);
	float64 TanQuarter = Math::Tan(PI / 4.0);
	return Math::IsNearlyEqual(TanZero, 0.0) && Math::IsNearlyEqual(TanQuarter, 1.0, KINDA_SMALL_NUMBER);
}
/** @end */
/**
 * @begin atan
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveAtanNominal
 * @summary Angles are radians.
 * @covers FMath.atan
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAtanNominal()
{
	float64 AtanZero = Math::Atan(0.0);
	float64 AtanOne = Math::Atan(1.0);
	return Math::IsNearlyEqual(AtanZero, 0.0) && Math::IsNearlyEqual(AtanOne, PI / 4.0);
}
/** @end */
/**
 * @begin atan-2
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAtan2Nominal
 * @summary Observe the container API.
 * @covers FMath.atan-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Atan2(1,0) and Atan2(0,1); Sqrt(4); Pow(2,3); float32 Exp(0)/Exp2(3);
// Loge(1); Log2(8); LogX(10,100); Fmod(5,2); Sin(0) and Sin(HALF_PI).
// Expected observations: Atan2(1,0) is HALF_PI. Sqrt(4) is 2. Pow(2,3) is 8.
// Float32 Exp(0) is 1 and Exp2(3) is 8. Log and Fmod match the float64
// counterparts. Sin(HALF_PI) is 1.
// Boundary/ownership: Atan2 is quadrant-aware. Log Value is positive. Fmod Y
// is a nonzero divisor. Call Math::.
bool ObserveAtan2Nominal()
{
	float64 Atan2Y = Math::Atan2(1.0, 0.0);
	float64 Atan2X = Math::Atan2(0.0, 1.0);
	return Math::IsNearlyEqual(Atan2Y, HALF_PI) && Math::IsNearlyEqual(Atan2X, 0.0);
}
/** @end */
/**
 * @begin sqrt
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveSqrtNominal
 * @summary is a nonzero divisor.
 * @covers FMath.sqrt
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSqrtNominal()
{
	float64 SqrtFour = Math::Sqrt(4.0);
	float64 SqrtZero = Math::Sqrt(0.0);
	return Math::IsNearlyEqual(SqrtFour, 2.0) && Math::IsNearlyEqual(SqrtZero, 0.0);
}
/** @end */
/**
 * @begin pow
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObservePowNominal
 * @summary is a nonzero divisor.
 * @covers FMath.pow
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePowNominal()
{
	float64 Eight = Math::Pow(2.0, 3.0);
	float64 One = Math::Pow(5.0, 0.0);
	return Math::IsNearlyEqual(Eight, 8.0) && Math::IsNearlyEqual(One, 1.0);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-exp
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveExpNominal
 * @summary is a nonzero divisor.
 * @covers FMath.exp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveExpNominal()
{
	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 ExpZero = Math::Exp(Zero32);
	float32 ExpOne = Math::Exp(One32);
	return Math::IsNearlyEqual(ExpZero, float32(1.0)) && Math::IsNearlyEqual(ExpOne, float32(EULERS_NUMBER), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-exp-2
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveExp2Nominal
 * @summary is a nonzero divisor.
 * @covers FMath.exp-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveExp2Nominal()
{
	float32 Zero32 = 0.0;
	float32 Three32 = 3.0;
	float32 Exp2Zero = Math::Exp2(Zero32);
	float32 Exp2Three = Math::Exp2(Three32);
	return Math::IsNearlyEqual(Exp2Zero, float32(1.0)) && Math::IsNearlyEqual(Exp2Three, float32(8.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-loge
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveLogeNominal
 * @summary is a nonzero divisor.
 * @covers FMath.loge
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogeNominal()
{
	float32 One32 = 1.0;
	float32 E32 = float32(EULERS_NUMBER);
	float32 LogOne = Math::Loge(One32);
	float32 LogE = Math::Loge(E32);
	return Math::IsNearlyEqual(LogOne, float32(0.0)) && Math::IsNearlyEqual(LogE, float32(1.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-log-2
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveLog2Nominal
 * @summary is a nonzero divisor.
 * @covers FMath.log-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLog2Nominal()
{
	float32 Two32 = 2.0;
	float32 Eight32 = 8.0;
	float32 LogTwo = Math::Log2(Two32);
	float32 LogEight = Math::Log2(Eight32);
	return Math::IsNearlyEqual(LogTwo, float32(1.0)) && Math::IsNearlyEqual(LogEight, float32(3.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-log-x
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveLogXNominal
 * @summary is a nonzero divisor.
 * @covers FMath.log-x
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogXNominal()
{
	float32 Ten32 = 10.0;
	float32 Hundred32 = 100.0;
	float32 Two32 = 2.0;
	float32 Eight32 = 8.0;
	float32 LogTenHundred = Math::LogX(Ten32, Hundred32);
	float32 LogTwoEight = Math::LogX(Two32, Eight32);
	return Math::IsNearlyEqual(LogTenHundred, float32(2.0)) && Math::IsNearlyEqual(LogTwoEight, float32(3.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-fmod
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveFmodNominal
 * @summary is a nonzero divisor.
 * @covers FMath.fmod
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFmodNominal()
{
	float32 Five32 = 5.0;
	float32 Two32 = 2.0;
	float32 NegFive32 = -5.0;
	float32 Pos = Math::Fmod(Five32, Two32);
	float32 Neg = Math::Fmod(NegFive32, Two32);
	return Math::IsNearlyEqual(Pos, float32(1.0)) && Math::IsNearlyEqual(Neg, float32(-1.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_14-sin
 * @summary is a nonzero divisor.
 * @topic Unreal
 */
/**
 * @function ObserveSinNominal
 * @summary is a nonzero divisor.
 * @covers FMath.sin
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSinNominal()
{
	float32 Zero32 = 0.0;
	float32 HalfPi32 = float32(HALF_PI);
	float32 SinZero = Math::Sin(Zero32);
	float32 SinHalfPi = Math::Sin(HalfPi32);
	return Math::IsNearlyEqual(SinZero, float32(0.0)) && Math::IsNearlyEqual(SinHalfPi, float32(1.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-sinh
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSinhNominal
 * @summary Observe the container API.
 * @covers FMath.sinh
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Sinh(0); Cos(0)/Cos(PI); Acos(1)/Acos(0); Tan(0); Atan(1);
// Atan2(1,0); Sqrt(4); Pow(2,3); Rand and FRand samples.
// Expected observations: Float32 trig matches the float64 identities. Rand
// is nonnegative. FRand is in [0,1].
// Boundary/ownership: Random APIs are observed by range, not exact values.
// Angles are radians. Call Math::.
bool ObserveSinhNominal()
{
	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 SinhZero = Math::Sinh(Zero32);
	float32 SinhOne = Math::Sinh(One32);
	return Math::IsNearlyEqual(SinhZero, float32(0.0)) && SinhOne > 0.0;
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-cos
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveCosNominal
 * @summary Angles are radians.
 * @covers FMath.cos
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCosNominal()
{
	float32 Zero32 = 0.0;
	float32 Pi32 = float32(PI);
	float32 CosZero = Math::Cos(Zero32);
	float32 CosPi = Math::Cos(Pi32);
	return Math::IsNearlyEqual(CosZero, float32(1.0)) && Math::IsNearlyEqual(CosPi, float32(-1.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-acos
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveAcosNominal
 * @summary Angles are radians.
 * @covers FMath.acos
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAcosNominal()
{
	float32 One32 = 1.0;
	float32 Zero32 = 0.0;
	float32 AcosOne = Math::Acos(One32);
	float32 AcosZero = Math::Acos(Zero32);
	return Math::IsNearlyEqual(AcosOne, float32(0.0)) && Math::IsNearlyEqual(AcosZero, float32(HALF_PI), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-tan
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveTanNominal
 * @summary Angles are radians.
 * @covers FMath.tan
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTanNominal()
{
	float32 Zero32 = 0.0;
	float32 Quarter32 = float32(PI / 4.0);
	float32 TanZero = Math::Tan(Zero32);
	float32 TanQuarter = Math::Tan(Quarter32);
	return Math::IsNearlyEqual(TanZero, float32(0.0)) && Math::IsNearlyEqual(TanQuarter, float32(1.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-atan
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveAtanNominal
 * @summary Angles are radians.
 * @covers FMath.atan
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAtanNominal()
{
	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 AtanZero = Math::Atan(Zero32);
	float32 AtanOne = Math::Atan(One32);
	return Math::IsNearlyEqual(AtanZero, float32(0.0)) && Math::IsNearlyEqual(AtanOne, float32(PI / 4.0), float32(KINDA_SMALL_NUMBER));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-atan-2
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveAtan2Nominal
 * @summary Angles are radians.
 * @covers FMath.atan-2
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAtan2Nominal()
{
	float32 One32 = 1.0;
	float32 Zero32 = 0.0;
	float32 Atan2Y = Math::Atan2(One32, Zero32);
	float32 Atan2X = Math::Atan2(Zero32, One32);
	return Math::IsNearlyEqual(Atan2Y, float32(HALF_PI), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(Atan2X, float32(0.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-sqrt
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveSqrtNominal
 * @summary Angles are radians.
 * @covers FMath.sqrt
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSqrtNominal()
{
	float32 Four32 = 4.0;
	float32 Zero32 = 0.0;
	float32 SqrtFour = Math::Sqrt(Four32);
	float32 SqrtZero = Math::Sqrt(Zero32);
	return Math::IsNearlyEqual(SqrtFour, float32(2.0)) && Math::IsNearlyEqual(SqrtZero, float32(0.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_15-pow
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObservePowNominal
 * @summary Angles are radians.
 * @covers FMath.pow
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePowNominal()
{
	float32 Two32 = 2.0;
	float32 Three32 = 3.0;
	float32 Five32 = 5.0;
	float32 Zero32 = 0.0;
	float32 Eight = Math::Pow(Two32, Three32);
	float32 One = Math::Pow(Five32, Zero32);
	return Math::IsNearlyEqual(Eight, float32(8.0)) && Math::IsNearlyEqual(One, float32(1.0));
}
/** @end */
/**
 * @begin rand
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveRandNominal
 * @summary Angles are radians.
 * @covers FMath.rand
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRandNominal()
{
	int32 First = Math::Rand();
	int32 Second = Math::Rand();
	return First >= 0 && Second >= 0;
}
/** @end */
/**
 * @begin f-rand
 * @summary Angles are radians.
 * @topic Unreal
 */
/**
 * @function ObserveFRandNominal
 * @summary Angles are radians.
 * @covers FMath.f-rand
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFRandNominal()
{
	float32 First = Math::FRand();
	float32 Second = Math::FRand();
	return First >= 0.0 && First <= 1.0 && Second >= 0.0 && Second <= 1.0;
}
/** @end */
/**
 * @begin abs
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAbsNominal
 * @summary Observe the container API.
 * @covers FMath.abs
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 and Square(0) is 0.
// Boundary/ownership: Sign(0) is 0. uint32 Square is unsigned. Call Math::.
bool ObserveAbsNominal()
{
	float64 AbsPos64 = Math::Abs(3.0);
	float64 AbsNeg64 = Math::Abs(-3.0);
	float64 AbsZero64 = Math::Abs(0.0);
	float32 Pos32 = 3.0;
	float32 Neg32 = -3.0;
	float32 Zero32 = 0.0;
	float32 AbsPos32 = Math::Abs(Pos32);
	float32 AbsNeg32 = Math::Abs(Neg32);
	float32 AbsZero32 = Math::Abs(Zero32);
	int32 AbsPosI = Math::Abs(int32(3));
	int32 AbsNegI = Math::Abs(int32(-3));
	int32 AbsZeroI = Math::Abs(int32(0));
	return AbsPos64 == 3.0 && AbsNeg64 == 3.0 && AbsZero64 == 0.0 && AbsPos32 == 3.0 && AbsNeg32 == 3.0 && AbsZero32 == 0.0 && AbsPosI == 3 && AbsNegI == 3 && AbsZeroI == 0;
}
/** @end */
/**
 * @begin sign
 * @summary Boundary/ownership: Sign(0) is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSignNominal
 * @summary Boundary/ownership: Sign(0) is 0.
 * @covers FMath.sign
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSignNominal()
{
	float64 SignPos64 = Math::Sign(3.0);
	float64 SignNeg64 = Math::Sign(-3.0);
	float64 SignZero64 = Math::Sign(0.0);
	float32 Pos32 = 3.0;
	float32 Neg32 = -3.0;
	float32 Zero32 = 0.0;
	float32 SignPos32 = Math::Sign(Pos32);
	float32 SignNeg32 = Math::Sign(Neg32);
	float32 SignZero32 = Math::Sign(Zero32);
	int32 SignPosI = Math::Sign(int32(3));
	int32 SignNegI = Math::Sign(int32(-3));
	int32 SignZeroI = Math::Sign(int32(0));
	return SignPos64 == 1.0 && SignNeg64 == -1.0 && SignZero64 == 0.0 && SignPos32 == 1.0 && SignNeg32 == -1.0 && SignZero32 == 0.0 && SignPosI == 1 && SignNegI == -1 && SignZeroI == 0;
}
/** @end */
/**
 * @begin square
 * @summary Boundary/ownership: Sign(0) is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSquareNominal
 * @summary Boundary/ownership: Sign(0) is 0.
 * @covers FMath.square
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSquareNominal()
{
	float64 Sq64 = Math::Square(3.0);
	float64 SqZero64 = Math::Square(0.0);
	float32 Three32 = 3.0;
	float32 Zero32 = 0.0;
	float32 Sq32 = Math::Square(Three32);
	float32 SqZero32 = Math::Square(Zero32);
	int32 SqI = Math::Square(int32(3));
	int32 SqNegI = Math::Square(int32(-3));
	uint32 SqU = Math::Square(uint32(3));
	return Sq64 == 9.0 && SqZero64 == 0.0 && Sq32 == 9.0 && SqZero32 == 0.0 && SqI == 9 && SqNegI == 9 && SqU == 9;
}
/** @end */
/**
 * @begin perlin-noise-1-d
 * @summary Inputs: Noise at
 * @topic Unreal
 */
/**
 * @function ObservePerlinNoise1DNominal
 * @summary Inputs: Noise at
 * @covers FMath.perlin-noise-1-d
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

 0 and (1,2)/(1,2,3); GridSnap 5 onto 2 and 5 onto 0;
// segments (0,0)-(2,0) vs (1,-1)-(1,1); springs from 0 toward 10 / Identity
// toward 90 yaw with omitted and explicit mass; EaseIn 0-to-10 at 0/0.5/1
// with Exp 2.
// Expected observations: Perlin samples are finite. GridSnap(5,2) is 6 and
// Grid 0 leaves Location. Crossing segments intersect at (1,0,0). Springs
// move toward the target and mutate SpringState. EaseIn(0.5,2) is 2.5.
// Boundary/ownership: SpringState is an inout writeback. Mass defaults to 1.
// out_IntersectionPoint is written on success. Call Math::.
bool ObservePerlinNoise1DNominal()
{
	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 SampleZero = Math::PerlinNoise1D(Zero32);
	float32 SampleOne = Math::PerlinNoise1D(One32);
	return Math::IsFinite(SampleZero) && Math::IsFinite(SampleOne);
}
/** @end */
/**
 * @begin perlin-noise-2-d
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObservePerlinNoise2DNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.perlin-noise-2-d
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObservePerlinNoise2DNominal()
{
	FVector2D Origin(0.0, 0.0);
	FVector2D Offset(1.0, 2.0);
	float32 SampleOrigin = Math::PerlinNoise2D(Origin);
	float32 SampleOffset = Math::PerlinNoise2D(Offset);
	return Math::IsFinite(SampleOrigin) && Math::IsFinite(SampleOffset);
}
/** @end */
/**
 * @begin perlin-noise-3-d
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObservePerlinNoise3DNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.perlin-noise-3-d
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObservePerlinNoise3DNominal()
{
	FVector Origin(0.0, 0.0, 0.0);
	FVector Offset(1.0, 2.0, 3.0);
	float32 SampleOrigin = Math::PerlinNoise3D(Origin);
	float32 SampleOffset = Math::PerlinNoise3D(Offset);
	return Math::IsFinite(SampleOrigin) && Math::IsFinite(SampleOffset);
}
/** @end */
/**
 * @begin grid-snap
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveGridSnapNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.grid-snap
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveGridSnapNominal()
{
	float64 Snap64 = Math::GridSnap(5.0, 2.0);
	float64 Unchanged64 = Math::GridSnap(5.0, 0.0);
	float32 Loc32 = 5.0;
	float32 Grid32 = 2.0;
	float32 Zero32 = 0.0;
	float32 Snap32 = Math::GridSnap(Loc32, Grid32);
	float32 Unchanged32 = Math::GridSnap(Loc32, Zero32);
	return Snap64 == 6.0 && Unchanged64 == 5.0 && Snap32 == 6.0 && Unchanged32 == 5.0;
}
/** @end */
/**
 * @begin segment-intersection-2-d
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveSegmentIntersection2DNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.segment-intersection-2-d
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveSegmentIntersection2DNominal()
{
	FVector Hit;
	bool bCrosses = Math::SegmentIntersection2D(
		FVector(0.0, 0.0, 0.0),
		FVector(2.0, 0.0, 0.0),
		FVector(1.0, -1.0, 0.0),
		FVector(1.0, 1.0, 0.0),
		Hit);
	FVector Miss;
	bool bMisses = Math::SegmentIntersection2D(
		FVector(0.0, 0.0, 0.0),
		FVector(1.0, 0.0, 0.0),
		FVector(0.0, 2.0, 0.0),
		FVector(1.0, 2.0, 0.0),
		Miss);
	bool bHitPoint = Hit.Equals(FVector(1.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
	return bCrosses && bHitPoint && !bMisses;
}
/** @end */
/**
 * @begin float-spring-interp
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveFloatSpringInterpNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.float-spring-interp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveFloatSpringInterpNominal()
{
	FFloatSpringState SpringState;
	float32 Current = 0.0;
	float32 Target = 10.0;
	float32 Stiffness = 100.0;
	float32 Damping = 1.0;
	float32 DeltaTime = 0.016;
	float32 Mass = 1.0;
	float32 TargetVelocityAmount = 1.0;
	float32 Stepped = Math::FloatSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
	float32 SteppedAgain = Math::FloatSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
	bool bMovedToward = Stepped > 0.0 && Stepped < 10.0;
	bool bSecondStepFinite = Math::IsFinite(SteppedAgain);
	return bMovedToward && bSecondStepFinite;
}
/** @end */
/**
 * @begin vector-spring-interp
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveVectorSpringInterpNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.vector-spring-interp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveVectorSpringInterpNominal()
{
	FVectorSpringState SpringState;
	FVector Current(0.0, 0.0, 0.0);
	FVector Target(10.0, 0.0, 0.0);
	float32 Stiffness = 100.0;
	float32 Damping = 1.0;
	float32 DeltaTime = 0.016;
	float32 Mass = 1.0;
	float32 TargetVelocityAmount = 1.0;
	FVector Stepped = Math::VectorSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
	FVector SteppedAgain = Math::VectorSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
	bool bMovedToward = Stepped.X > 0.0 && Stepped.X < 10.0;
	bool bSecondStepFinite = Math::IsFinite(SteppedAgain.X);
	return bMovedToward && bSecondStepFinite;
}
/** @end */
/**
 * @begin quaternion-spring-interp
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveQuaternionSpringInterpNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.quaternion-spring-interp
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveQuaternionSpringInterpNominal()
{
	FQuaternionSpringState SpringState;
	FQuat Current = FQuat::Identity;
	FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
	float32 Stiffness = 100.0;
	float32 Damping = 1.0;
	float32 DeltaTime = 0.016;
	float32 Mass = 1.0;
	float32 TargetVelocityAmount = 1.0;
	FQuat Stepped = Math::QuaternionSpringInterp(Current, Target, SpringState, Stiffness, Damping, DeltaTime);
	FQuat SteppedAgain = Math::QuaternionSpringInterp(Stepped, Target, SpringState, Stiffness, Damping, DeltaTime, Mass, TargetVelocityAmount);
	bool bMoved = !Stepped.Equals(Current, KINDA_SMALL_NUMBER);
	bool bSecondStepNormalized = SteppedAgain.IsNormalized();
	return bMoved && bSecondStepNormalized;
}
/** @end */
/**
 * @begin ease-in
 * @summary out_IntersectionPoint is written on success.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInNominal
 * @summary out_IntersectionPoint is written on success.
 * @covers FMath.ease-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Noise at

bool ObserveEaseInNominal()
{
	float64 Start = Math::EaseIn(0.0, 10.0, 0.0, 2.0);
	float64 Mid = Math::EaseIn(0.0, 10.0, 0.5, 2.0);
	float64 End = Math::EaseIn(0.0, 10.0, 1.0, 2.0);
	return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 2.5) && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin ease-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveEaseOutNominal
 * @summary scalars.
 * @covers FMath.ease-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseOutNominal()
{
	float64 Start = Math::EaseOut(0.0, 10.0, 0.0, 2.0);
	float64 Mid = Math::EaseOut(0.0, 10.0, 0.5, 2.0);
	float64 End = Math::EaseOut(0.0, 10.0, 1.0, 2.0);
	return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 7.5) && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin ease-in-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInOutNominal
 * @summary scalars.
 * @covers FMath.ease-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseInOutNominal()
{
	float64 Start = Math::EaseInOut(0.0, 10.0, 0.0, 2.0);
	float64 Mid = Math::EaseInOut(0.0, 10.0, 0.5, 2.0);
	float64 End = Math::EaseInOut(0.0, 10.0, 1.0, 2.0);
	return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0) && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin sinusoidal-in
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInNominal
 * @summary scalars.
 * @covers FMath.sinusoidal-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInNominal()
{
	float64 Start = Math::SinusoidalIn(0.0, 10.0, 0.0);
	float64 Mid = Math::SinusoidalIn(0.0, 10.0, 0.5);
	float64 End = Math::SinusoidalIn(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin sinusoidal-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalOutNominal
 * @summary scalars.
 * @covers FMath.sinusoidal-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalOutNominal()
{
	float64 Start = Math::SinusoidalOut(0.0, 10.0, 0.0);
	float64 Mid = Math::SinusoidalOut(0.0, 10.0, 0.5);
	float64 End = Math::SinusoidalOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin sinusoidal-in-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInOutNominal
 * @summary scalars.
 * @covers FMath.sinusoidal-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInOutNominal()
{
	float64 Start = Math::SinusoidalInOut(0.0, 10.0, 0.0);
	float64 Mid = Math::SinusoidalInOut(0.0, 10.0, 0.5);
	float64 End = Math::SinusoidalInOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0, KINDA_SMALL_NUMBER) && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin expo-in
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInNominal
 * @summary scalars.
 * @covers FMath.expo-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoInNominal()
{
	float64 Start = Math::ExpoIn(0.0, 10.0, 0.0);
	float64 Mid = Math::ExpoIn(0.0, 10.0, 0.5);
	float64 End = Math::ExpoIn(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin expo-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveExpoOutNominal
 * @summary scalars.
 * @covers FMath.expo-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoOutNominal()
{
	float64 Start = Math::ExpoOut(0.0, 10.0, 0.0);
	float64 Mid = Math::ExpoOut(0.0, 10.0, 0.5);
	float64 End = Math::ExpoOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin expo-in-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInOutNominal
 * @summary scalars.
 * @covers FMath.expo-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoInOutNominal()
{
	float64 Start = Math::ExpoInOut(0.0, 10.0, 0.0);
	float64 Mid = Math::ExpoInOut(0.0, 10.0, 0.5);
	float64 End = Math::ExpoInOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin circular-in
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInNominal
 * @summary scalars.
 * @covers FMath.circular-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularInNominal()
{
	float64 Start = Math::CircularIn(0.0, 10.0, 0.0);
	float64 Mid = Math::CircularIn(0.0, 10.0, 0.5);
	float64 End = Math::CircularIn(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin circular-out
 * @summary scalars.
 * @topic Unreal
 */
/**
 * @function ObserveCircularOutNominal
 * @summary scalars.
 * @covers FMath.circular-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularOutNominal()
{
	float64 Start = Math::CircularOut(0.0, 10.0, 0.0);
	float64 Mid = Math::CircularOut(0.0, 10.0, 0.5);
	float64 End = Math::CircularOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin circular-in-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.circular-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularInOutNominal()
{
	float64 Start = Math::CircularInOut(0.0, 10.0, 0.0);
	float64 Mid = Math::CircularInOut(0.0, 10.0, 0.5);
	float64 End = Math::CircularInOut(0.0, 10.0, 1.0);
	return Math::IsNearlyEqual(Start, 0.0) && Math::IsNearlyEqual(Mid, 5.0, KINDA_SMALL_NUMBER) && Math::IsNearlyEqual(End, 10.0);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-ease-in
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.ease-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseInNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	float32 Start = Math::EaseIn(A, B, Zero, Exp);
	float32 Mid = Math::EaseIn(A, B, Half, Exp);
	float32 End = Math::EaseIn(A, B, One, Exp);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(2.5)) && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-ease-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveEaseOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.ease-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	float32 Start = Math::EaseOut(A, B, Zero, Exp);
	float32 Mid = Math::EaseOut(A, B, Half, Exp);
	float32 End = Math::EaseOut(A, B, One, Exp);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(7.5)) && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-ease-in-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.ease-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseInOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	float32 Start = Math::EaseInOut(A, B, Zero, Exp);
	float32 Mid = Math::EaseInOut(A, B, Half, Exp);
	float32 End = Math::EaseInOut(A, B, One, Exp);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0)) && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-sinusoidal-in
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.sinusoidal-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::SinusoidalIn(A, B, Zero);
	float32 Mid = Math::SinusoidalIn(A, B, Half);
	float32 End = Math::SinusoidalIn(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-sinusoidal-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.sinusoidal-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::SinusoidalOut(A, B, Zero);
	float32 Mid = Math::SinusoidalOut(A, B, Half);
	float32 End = Math::SinusoidalOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-sinusoidal-in-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.sinusoidal-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::SinusoidalInOut(A, B, Zero);
	float32 Mid = Math::SinusoidalInOut(A, B, Half);
	float32 End = Math::SinusoidalInOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-expo-in
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.expo-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoInNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::ExpoIn(A, B, Zero);
	float32 Mid = Math::ExpoIn(A, B, Half);
	float32 End = Math::ExpoIn(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-expo-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveExpoOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.expo-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::ExpoOut(A, B, Zero);
	float32 Mid = Math::ExpoOut(A, B, Half);
	float32 End = Math::ExpoOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_19-expo-in-out
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInOutNominal
 * @summary Boundary/ownership: Overloads are selected by float32 locals.
 * @covers FMath.expo-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoInOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::ExpoInOut(A, B, Zero);
	float32 Mid = Math::ExpoInOut(A, B, Half);
	float32 End = Math::ExpoInOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-circular-in
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInNominal
 * @summary values.
 * @covers FMath.circular-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularInNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::CircularIn(A, B, Zero);
	float32 Mid = Math::CircularIn(A, B, Half);
	float32 End = Math::CircularIn(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-circular-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveCircularOutNominal
 * @summary values.
 * @covers FMath.circular-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::CircularOut(A, B, Zero);
	float32 Mid = Math::CircularOut(A, B, Half);
	float32 End = Math::CircularOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Mid > 0.0 && Mid < 10.0 && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-circular-in-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInOutNominal
 * @summary values.
 * @covers FMath.circular-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCircularInOutNominal()
{
	float32 A = 0.0;
	float32 B = 10.0;
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Start = Math::CircularInOut(A, B, Zero);
	float32 Mid = Math::CircularInOut(A, B, Half);
	float32 End = Math::CircularInOut(A, B, One);
	return Math::IsNearlyEqual(Start, float32(0.0)) && Math::IsNearlyEqual(Mid, float32(5.0), float32(KINDA_SMALL_NUMBER)) && Math::IsNearlyEqual(End, float32(10.0));
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-ease-in
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInNominal
 * @summary values.
 * @covers FMath.ease-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseInNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	FVector Start = Math::EaseIn(A, B, Zero, Exp);
	FVector Mid = Math::EaseIn(A, B, Half, Exp);
	FVector End = Math::EaseIn(A, B, One, Exp);
	return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 2.5) && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-ease-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveEaseOutNominal
 * @summary values.
 * @covers FMath.ease-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	FVector Start = Math::EaseOut(A, B, Zero, Exp);
	FVector Mid = Math::EaseOut(A, B, Half, Exp);
	FVector End = Math::EaseOut(A, B, One, Exp);
	return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 7.5) && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-ease-in-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveEaseInOutNominal
 * @summary values.
 * @covers FMath.ease-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEaseInOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	float32 Exp = 2.0;
	FVector Start = Math::EaseInOut(A, B, Zero, Exp);
	FVector Mid = Math::EaseInOut(A, B, Half, Exp);
	FVector End = Math::EaseInOut(A, B, One, Exp);
	return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0) && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-sinusoidal-in
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInNominal
 * @summary values.
 * @covers FMath.sinusoidal-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::SinusoidalIn(A, B, Zero);
	FVector Mid = Math::SinusoidalIn(A, B, Half);
	FVector End = Math::SinusoidalIn(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-sinusoidal-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalOutNominal
 * @summary values.
 * @covers FMath.sinusoidal-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::SinusoidalOut(A, B, Zero);
	FVector Mid = Math::SinusoidalOut(A, B, Half);
	FVector End = Math::SinusoidalOut(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-sinusoidal-in-out
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveSinusoidalInOutNominal
 * @summary values.
 * @covers FMath.sinusoidal-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSinusoidalInOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::SinusoidalInOut(A, B, Zero);
	FVector Mid = Math::SinusoidalInOut(A, B, Half);
	FVector End = Math::SinusoidalInOut(A, B, One);
	return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0, KINDA_SMALL_NUMBER) && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_20-expo-in
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInNominal
 * @summary values.
 * @covers FMath.expo-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExpoInNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::ExpoIn(A, B, Zero);
	FVector Mid = Math::ExpoIn(A, B, Half);
	FVector End = Math::ExpoIn(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_21-expo-out
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveExpoOutNominal
 * @summary Observe the container API.
 * @covers FMath.expo-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: FVector (0,0,0) to (10,0,0) at alpha 0/0.5/1; NormalizeToRange
// 5 and 15 over [0,10]; IntegerDivisionTrunc 7/3, -7/3, and unsigned 10/3;
// DivideBy 0 as the diagnostic companion.
// Expected observations: Vector endpoints match A and B. NormalizeToRange(5)
// is 0.5 and 15 is unclamped 1.5. 7/3 truncates to 2; -7/3 truncates toward
// zero to -2.
// Boundary/ownership: DivideBy must be nonzero; zero throws. Overflow of
// MIN integer is also rejected. Call Math::, never FMath::.
bool ObserveExpoOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::ExpoOut(A, B, Zero);
	FVector Mid = Math::ExpoOut(A, B, Half);
	FVector End = Math::ExpoOut(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_21-expo-in-out
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveExpoInOutNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.expo-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveExpoInOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::ExpoInOut(A, B, Zero);
	FVector Mid = Math::ExpoInOut(A, B, Half);
	FVector End = Math::ExpoInOut(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_21-circular-in
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.circular-in
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCircularInNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::CircularIn(A, B, Zero);
	FVector Mid = Math::CircularIn(A, B, Half);
	FVector End = Math::CircularIn(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_21-circular-out
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveCircularOutNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.circular-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCircularOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::CircularOut(A, B, Zero);
	FVector Mid = Math::CircularOut(A, B, Half);
	FVector End = Math::CircularOut(A, B, One);
	return Start.Equals(A) && Mid.X > 0.0 && Mid.X < 10.0 && End.Equals(B);
}
/** @end */
/**
 * @begin FMath-NamespaceAndGlobalFunctions_21-circular-in-out
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveCircularInOutNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.circular-in-out
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCircularInOutNominal()
{
	FVector A(0.0, 0.0, 0.0);
	FVector B(10.0, 0.0, 0.0);
	float32 Zero = 0.0;
	float32 Half = 0.5;
	float32 One = 1.0;
	FVector Start = Math::CircularInOut(A, B, Zero);
	FVector Mid = Math::CircularInOut(A, B, Half);
	FVector End = Math::CircularInOut(A, B, One);
	return Start.Equals(A) && Math::IsNearlyEqual(Mid.X, 5.0, KINDA_SMALL_NUMBER) && End.Equals(B);
}
/** @end */
/**
 * @begin normalize-to-range
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeToRangeNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.normalize-to-range
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveNormalizeToRangeNominal()
{
	float64 Mid = Math::NormalizeToRange(5.0, 0.0, 10.0);
	float64 Low = Math::NormalizeToRange(0.0, 0.0, 10.0);
	float64 High = Math::NormalizeToRange(15.0, 0.0, 10.0);
	float64 Degenerate = Math::NormalizeToRange(5.0, 3.0, 3.0);
	return Math::IsNearlyEqual(Mid, 0.5) && Math::IsNearlyEqual(Low, 0.0) && Math::IsNearlyEqual(High, 1.5) && Math::IsFinite(Degenerate);
}
/** @end */
/**
 * @begin integer-division-trunc
 * @summary MIN integer is also rejected.
 * @topic Unreal
 */
/**
 * @function ObserveIntegerDivisionTruncNominal
 * @summary MIN integer is also rejected.
 * @covers FMath.integer-division-trunc
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIntegerDivisionTruncNominal()
{
	int32 Pos32 = Math::IntegerDivisionTrunc(7, 3);
	int32 Neg32 = Math::IntegerDivisionTrunc(-7, 3);
	int32 Exact32 = Math::IntegerDivisionTrunc(9, 3);
	int64 Pos64 = Math::IntegerDivisionTrunc(int64(7), int64(3));
	int64 Neg64 = Math::IntegerDivisionTrunc(int64(-7), int64(3));
	uint32 PosU32 = Math::IntegerDivisionTrunc(uint32(10), uint32(3));
	uint64 PosU64 = Math::IntegerDivisionTrunc(uint64(10), uint64(3));
	return Pos32 == 2 && Neg32 == -2 && Exact32 == 3 && Pos64 == 2 && Neg64 == int64(-2) && PosU32 == 3 && PosU64 == uint64(3);
}
/** @end */
/**
 * @begin get-reflection-vector
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetReflectionVectorNominal
 * @summary Observe the container API.
 * @covers FMath.get-reflection-vector
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Direction (1,0,0) with unit normal (-1,0,0); 1 vs 1 and 1 vs 2;
// 0 and SMALL_NUMBER/2; 8/7/0/1; 0-to-90 degrees and 0-to-HALF_PI radians;
// a zero SurfaceNormal as the diagnostic companion.
// Expected observations: Reflection X is -1. Equal pairs are true; 1 vs 2 is
// false. Zero is nearly zero; 1 is not. 8 and 1 are powers of two; 7 and 0
// are not. 0-to-90 delta is 90 degrees.
// Boundary/ownership: Call Math::, never FMath::. ErrorTolerance defaults to
// SMALL_NUMBER. Zero SurfaceNormal is a degenerate reflection.
bool ObserveGetReflectionVectorNominal()
{
	FVector Direction(1.0, 0.0, 0.0);
	FVector SurfaceNormal(-1.0, 0.0, 0.0);
	FVector Reflected = Math::GetReflectionVector(Direction, SurfaceNormal);
	return Reflected.X == -1.0 && Reflected.Y == 0.0 && Reflected.Z == 0.0;
}
/** @end */
/**
 * @begin is-nearly-equal
 * @summary SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyEqualNominal
 * @summary SMALL_NUMBER.
 * @covers FMath.is-nearly-equal
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsNearlyEqualNominal()
{
	float64 Left64 = 1.0;
	float64 Right64 = 1.0;
	bool bEqual64Default = Math::IsNearlyEqual(Left64, Right64);
	bool bEqual64Explicit = Math::IsNearlyEqual(Left64, Right64, SMALL_NUMBER);
	bool bUnequal64 = Math::IsNearlyEqual(Left64, 2.0);
	float64 Near64 = 1.0 + SMALL_NUMBER * 0.5;
	bool bTolerant64 = Math::IsNearlyEqual(Left64, Near64);

	float32 Left32 = 1.0;
	float32 Right32 = 1.0;
	float32 Two32 = 2.0;
	float32 Tolerance32 = float32(SMALL_NUMBER);
	bool bEqual32Default = Math::IsNearlyEqual(Left32, Right32);
	bool bEqual32Explicit = Math::IsNearlyEqual(Left32, Right32, Tolerance32);
	bool bUnequal32 = Math::IsNearlyEqual(Left32, Two32);
	return bEqual64Default && bEqual64Explicit && !bUnequal64 && bTolerant64 && bEqual32Default && bEqual32Explicit && !bUnequal32;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary SMALL_NUMBER.
 * @covers FMath.is-nearly-zero
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsNearlyZeroNominal()
{
	float64 Zero64 = 0.0;
	bool bZero64Default = Math::IsNearlyZero(Zero64);
	bool bZero64Explicit = Math::IsNearlyZero(Zero64, SMALL_NUMBER);
	bool bOne64 = Math::IsNearlyZero(1.0);
	float64 Tiny64 = SMALL_NUMBER * 0.5;
	bool bTiny64 = Math::IsNearlyZero(Tiny64);

	float32 Zero32 = 0.0;
	float32 One32 = 1.0;
	float32 Tolerance32 = float32(SMALL_NUMBER);
	bool bZero32Default = Math::IsNearlyZero(Zero32);
	bool bZero32Explicit = Math::IsNearlyZero(Zero32, Tolerance32);
	bool bOne32 = Math::IsNearlyZero(One32);
	return bZero64Default && bZero64Explicit && !bOne64 && bTiny64 && bZero32Default && bZero32Explicit && !bOne32;
}
/** @end */
/**
 * @begin is-power-of-two
 * @summary SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveIsPowerOfTwoNominal
 * @summary SMALL_NUMBER.
 * @covers FMath.is-power-of-two
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsPowerOfTwoNominal()
{
	bool bEight = Math::IsPowerOfTwo(8);
	bool bSeven = Math::IsPowerOfTwo(7);
	bool bZero = Math::IsPowerOfTwo(0);
	bool bOne = Math::IsPowerOfTwo(1);
	bool bNegative = Math::IsPowerOfTwo(-8);
	return bEight && !bSeven && !bZero && bOne && !bNegative;
}
/** @end */
/**
 * @begin find-delta-angle-degrees
 * @summary SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveFindDeltaAngleDegreesNominal
 * @summary SMALL_NUMBER.
 * @covers FMath.find-delta-angle-degrees
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFindDeltaAngleDegreesNominal()
{
	float64 Delta90_64 = Math::FindDeltaAngleDegrees(0.0, 90.0);
	float64 DeltaWrap64 = Math::FindDeltaAngleDegrees(10.0, 350.0);
	bool bDegrees64 = Math::IsNearlyEqual(Delta90_64, 90.0) && Math::IsNearlyEqual(DeltaWrap64, -20.0);

	float32 Start32 = 0.0;
	float32 Target32 = 90.0;
	float32 Delta90_32 = Math::FindDeltaAngleDegrees(Start32, Target32);
	float32 WrapStart32 = 10.0;
	float32 WrapTarget32 = 350.0;
	float32 DeltaWrap32 = Math::FindDeltaAngleDegrees(WrapStart32, WrapTarget32);
	bool bDegrees32 = Math::IsNearlyEqual(Delta90_32, float32(90.0)) && Math::IsNearlyEqual(DeltaWrap32, float32(-20.0));
	return bDegrees64 && bDegrees32;
}
/** @end */
/**
 * @begin find-delta-angle-radians
 * @summary SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveFindDeltaAngleRadiansNominal
 * @summary SMALL_NUMBER.
 * @covers FMath.find-delta-angle-radians
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFindDeltaAngleRadiansNominal()
{
	float64 DeltaHalfPi64 = Math::FindDeltaAngleRadians(0.0, HALF_PI);
	bool bRadians64 = Math::IsNearlyEqual(DeltaHalfPi64, HALF_PI);

	float32 Zero32 = 0.0;
	float32 HalfPi32 = float32(HALF_PI);
	float32 DeltaHalfPi32 = Math::FindDeltaAngleRadians(Zero32, HalfPi32);
	bool bRadians32 = Math::IsNearlyEqual(DeltaHalfPi32, HalfPi32);
	return bRadians64 && bRadians32;
}
/** @end */
/**
 * @begin is-within
 * @summary IsWithinInclusive Max is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveIsWithinNominal
 * @summary IsWithinInclusive Max is inclusive.
 * @covers FMath.is-within
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsWithinNominal()
{
	float64 Min64 = 0.0;
	float64 Max64 = 10.0;
	bool bInside64 = Math::IsWithin(5.0, Min64, Max64);
	bool bLower64 = Math::IsWithin(0.0, Min64, Max64);
	bool bUpper64 = Math::IsWithin(10.0, Min64, Max64);
	bool bBelow64 = Math::IsWithin(-1.0, Min64, Max64);

	float32 Min32 = 0.0;
	float32 Max32 = 10.0;
	float32 Five32 = 5.0;
	float32 Ten32 = 10.0;
	float32 Zero32 = 0.0;
	bool bInside32 = Math::IsWithin(Five32, Min32, Max32);
	bool bUpper32 = Math::IsWithin(Ten32, Min32, Max32);
	bool bLower32 = Math::IsWithin(Zero32, Min32, Max32);

	int32 MinI = 0;
	int32 MaxI = 10;
	bool bInsideI = Math::IsWithin(5, MinI, MaxI);
	bool bUpperI = Math::IsWithin(10, MinI, MaxI);
	bool bLowerI = Math::IsWithin(0, MinI, MaxI);
	return bInside64 && bLower64 && !bUpper64 && !bBelow64 && bInside32 && !bUpper32 && bLower32 && bInsideI && !bUpperI && bLowerI;
}
/** @end */
/**
 * @begin is-within-inclusive
 * @summary IsWithinInclusive Max is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveIsWithinInclusiveNominal
 * @summary IsWithinInclusive Max is inclusive.
 * @covers FMath.is-within-inclusive
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsWithinInclusiveNominal()
{
	float64 Min64 = 0.0;
	float64 Max64 = 10.0;
	bool bInside64 = Math::IsWithinInclusive(5.0, Min64, Max64);
	bool bLower64 = Math::IsWithinInclusive(0.0, Min64, Max64);
	bool bUpper64 = Math::IsWithinInclusive(10.0, Min64, Max64);
	bool bBelow64 = Math::IsWithinInclusive(-1.0, Min64, Max64);

	float32 Min32 = 0.0;
	float32 Max32 = 10.0;
	float32 Five32 = 5.0;
	float32 Ten32 = 10.0;
	float32 Zero32 = 0.0;
	bool bInside32 = Math::IsWithinInclusive(Five32, Min32, Max32);
	bool bUpper32 = Math::IsWithinInclusive(Ten32, Min32, Max32);
	bool bLower32 = Math::IsWithinInclusive(Zero32, Min32, Max32);

	int32 MinI = 0;
	int32 MaxI = 10;
	bool bInsideI = Math::IsWithinInclusive(5, MinI, MaxI);
	bool bUpperI = Math::IsWithinInclusive(10, MinI, MaxI);
	bool bLowerI = Math::IsWithinInclusive(0, MinI, MaxI);
	return bInside64 && bLower64 && bUpper64 && !bBelow64 && bInside32 && bUpper32 && bLower32 && bInsideI && bUpperI && bLowerI;
}
/** @end */
/**
 * @begin is-na-n
 * @summary IsWithinInclusive Max is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveIsNaNNominal
 * @summary IsWithinInclusive Max is inclusive.
 * @covers FMath.is-na-n
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNaNNominal()
{
	float64 Nan64 = 0.0 / 0.0;
	float64 One64 = 1.0;
	float64 Inf64 = 1.0 / 0.0;
	bool bNan64 = Math::IsNaN(Nan64);
	bool bOne64 = Math::IsNaN(One64);
	bool bInf64 = Math::IsNaN(Inf64);

	float32 Zero32 = 0.0;
	float32 Nan32 = Zero32 / Zero32;
	float32 One32 = 1.0;
	float32 Inf32 = One32 / Zero32;
	bool bNan32 = Math::IsNaN(Nan32);
	bool bOne32 = Math::IsNaN(One32);
	bool bInf32 = Math::IsNaN(Inf32);
	return bNan64 && !bOne64 && !bInf64 && bNan32 && !bOne32 && !bInf32;
}
/** @end */
/**
 * @begin is-finite
 * @summary IsWithinInclusive Max is inclusive.
 * @topic Unreal
 */
/**
 * @function ObserveIsFiniteNominal
 * @summary IsWithinInclusive Max is inclusive.
 * @covers FMath.is-finite
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsFiniteNominal()
{
	float64 Nan64 = 0.0 / 0.0;
	float64 One64 = 1.0;
	float64 Inf64 = 1.0 / 0.0;
	bool bNan64 = Math::IsFinite(Nan64);
	bool bOne64 = Math::IsFinite(One64);
	bool bInf64 = Math::IsFinite(Inf64);

	float32 Zero32 = 0.0;
	float32 Nan32 = Zero32 / Zero32;
	float32 One32 = 1.0;
	float32 Inf32 = One32 / Zero32;
	bool bNan32 = Math::IsFinite(Nan32);
	bool bOne32 = Math::IsFinite(One32);
	bool bInf32 = Math::IsFinite(Inf32);
	return !bNan64 && bOne64 && !bInf64 && !bNan32 && bOne32 && !bInf32;
}
/** @end */
/**
 * @begin min
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveMinNominal
 * @summary values.
 * @covers FMath.min
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinNominal()
{
	float64 Min64 = Math::Min(3.0, -1.0);
	float64 Equal64 = Math::Min(4.0, 4.0);
	float32 Three32 = 3.0;
	float32 Neg32 = -1.0;
	float32 Min32 = Math::Min(Three32, Neg32);
	int32 MinI = Math::Min(int32(3), int32(-1));
	uint32 MinU = Math::Min(uint32(3), uint32(1));
	return Min64 == -1.0 && Equal64 == 4.0 && Min32 == -1.0 && MinI == -1 && MinU == 1;
}
/** @end */
/**
 * @begin max-3
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveMax3Nominal
 * @summary values.
 * @covers FMath.max-3
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMax3Nominal()
{
	float64 Max3_64 = Math::Max3(1.0, 5.0, 3.0);
	float64 Max3First64 = Math::Max3(9.0, 1.0, 2.0);
	float32 A32 = 1.0;
	float32 B32 = 5.0;
	float32 C32 = 3.0;
	float32 Max3_32 = Math::Max3(A32, B32, C32);
	return Max3_64 == 5.0 && Max3First64 == 9.0 && Max3_32 == 5.0;
}
/** @end */
/**
 * @begin max
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveMaxNominal
 * @summary values.
 * @covers FMath.max
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMaxNominal()
{
	float64 Max64 = Math::Max(3.0, -1.0);
	float64 Equal64 = Math::Max(4.0, 4.0);
	float32 Three32 = 3.0;
	float32 Neg32 = -1.0;
	float32 Max32 = Math::Max(Three32, Neg32);
	int32 MaxI = Math::Max(int32(3), int32(-1));
	uint32 MaxU = Math::Max(uint32(3), uint32(1));
	return Max64 == 3.0 && Equal64 == 4.0 && Max32 == 3.0 && MaxI == 3 && MaxU == 3;
}
/** @end */
/**
 * @begin get-mapped-range-value-clamped
 * @summary FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveGetMappedRangeValueClampedNominal
 * @summary FMath::.
 * @covers FMath.get-mapped-range-value-clamped
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMappedRangeValueClampedNominal()
{
	FVector2D Input64(0.0, 10.0);
	FVector2D Output64(0.0, 100.0);
	float64 Mid64 = Math::GetMappedRangeValueClamped(Input64, Output64, 5.0);
	float64 High64 = Math::GetMappedRangeValueClamped(Input64, Output64, 15.0);
	float64 Low64 = Math::GetMappedRangeValueClamped(Input64, Output64, -5.0);

	FVector2f Input32(0.0, 10.0);
	FVector2f Output32(0.0, 100.0);
	float32 Five32 = 5.0;
	float32 Fifteen32 = 15.0;
	float32 Mid32 = Math::GetMappedRangeValueClamped(Input32, Output32, Five32);
	float32 High32 = Math::GetMappedRangeValueClamped(Input32, Output32, Fifteen32);
	return Mid64 == 50.0 && High64 == 100.0 && Low64 == 0.0 && Mid32 == 50.0 && High32 == 100.0;
}
/** @end */
/**
 * @begin get-mapped-range-value-unclamped
 * @summary FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveGetMappedRangeValueUnclampedNominal
 * @summary FMath::.
 * @covers FMath.get-mapped-range-value-unclamped
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMappedRangeValueUnclampedNominal()
{
	FVector2D Input64(0.0, 10.0);
	FVector2D Output64(0.0, 100.0);
	float64 Mid64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, 5.0);
	float64 High64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, 15.0);
	float64 Low64 = Math::GetMappedRangeValueUnclamped(Input64, Output64, -5.0);

	FVector2f Input32(0.0, 10.0);
	FVector2f Output32(0.0, 100.0);
	float32 Five32 = 5.0;
	float32 Fifteen32 = 15.0;
	float32 Mid32 = Math::GetMappedRangeValueUnclamped(Input32, Output32, Five32);
	float32 High32 = Math::GetMappedRangeValueUnclamped(Input32, Output32, Fifteen32);
	return Mid64 == 50.0 && High64 == 150.0 && Low64 == -50.0 && Mid32 == 50.0 && High32 == 150.0;
}
/** @end */
/**
 * @begin is-point-in-box
 * @summary FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveIsPointInBoxNominal
 * @summary FMath::.
 * @covers FMath.is-point-in-box
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsPointInBoxNominal()
{
	FVector Origin;
	FVector Extent(1.0, 1.0, 1.0);
	bool bInside = Math::IsPointInBox(FVector(0.0, 0.0, 0.0), Origin, Extent);
	bool bOnFace = Math::IsPointInBox(FVector(1.0, 0.0, 0.0), Origin, Extent);
	bool bOutside = Math::IsPointInBox(FVector(2.0, 0.0, 0.0), Origin, Extent);
	return bInside && bOnFace && !bOutside;
}
/** @end */
/**
 * @begin is-point-in-box-with-transform
 * @summary FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveIsPointInBoxWithTransformNominal
 * @summary FMath::.
 * @covers FMath.is-point-in-box-with-transform
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsPointInBoxWithTransformNominal()
{
	FTransform BoxWorldTransform = FTransform::Identity;
	FVector BoxExtent(1.0, 1.0, 1.0);
	bool bInside = Math::IsPointInBoxWithTransform(FVector(0.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
	bool bOnFace = Math::IsPointInBoxWithTransform(FVector(1.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
	bool bOutside = Math::IsPointInBoxWithTransform(FVector(2.0, 0.0, 0.0), BoxWorldTransform, BoxExtent);
	return bInside && bOnFace && !bOutside;
}
/** @end */
/**
 * @begin find-nearest-points-on-line-segments
 * @summary FMath::.
 * @topic Unreal
 */
/**
 * @function ObserveFindNearestPointsOnLineSegmentsNominal
 * @summary FMath::.
 * @covers FMath.find-nearest-points-on-line-segments
 * @inputs FMath values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFindNearestPointsOnLineSegmentsNominal()
{
	FVector Segment1Point;
	FVector Segment2Point;
	Math::FindNearestPointsOnLineSegments(
		FVector(0.0, 0.0, 0.0),
		FVector(10.0, 0.0, 0.0),
		FVector(5.0, 5.0, 0.0),
		FVector(5.0, 10.0, 0.0),
		Segment1Point,
		Segment2Point);
	bool bSegment1 = Segment1Point.Equals(FVector(5.0, 0.0, 0.0), 0.001);
	bool bSegment2 = Segment2Point.Equals(FVector(5.0, 5.0, 0.0), 0.001);
	return bSegment1 && bSegment2;
}
/** @end */
