/**
 * @version v1
 * @summary Observe Math cubic Hermite interpolation and the first derivative overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Math cubic Hermite interpolation and the first derivative overloads.
 * @topic Baseline
 */
// FQuat, FVector3f, and FQuat4f endpoints; float64 and float32 alpha.
// Expected observations: Alpha 0 returns Point0. Alpha 1 returns Point1.
// Zero-tangent midpoint is the average. Derivative at alpha 0 with zero
// tangents is 0.
// Boundary/ownership: Alpha outside [0,1] extrapolates. Quaternion results
// are new FQuat/FQuat4f values. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_05
{
	bool Observe_CubicInterp_Nominal()
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

	bool Observe_CubicInterpDerivative_Nominal()
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
}
/** @end */
