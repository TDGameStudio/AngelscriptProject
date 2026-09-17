/**
 * @version v1
 * @summary Observe scalar and color interp-to, sphere/AABB intersection, and ray/plane intersection.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe scalar and color interp-to, sphere/AABB intersection, and ray/plane intersection.
 * @topic Baseline
 */
// Math::SphereAABBIntersection; Math::RayPlaneIntersection.
// Inputs: 0 toward 10 at dt 0.5 speed 4 and speed 0; White toward Black;
// sphere at origin radius 1 vs box [-0.5,0.5] and a far box; ray (0,0,1)
// along -Z into the XY plane.
// Expected observations: Constant interp of 2 units lands on 2. Speed 0 snaps
// to Target. Nearby sphere intersects; far sphere does not. Ray hits (0,0,0).
// Boundary/ownership: RadiusSquared is the squared radius. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_08
{
	bool Observe_FInterpConstantTo_Nominal()
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

	bool Observe_FInterpTo_Nominal()
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

	bool Observe_CInterpTo_Nominal()
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

	bool Observe_SphereAABBIntersection_Nominal()
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

	bool Observe_RayPlaneIntersection_Nominal()
	{
		FPlane Plane(FVector(0.0, 0.0, 0.0), FVector(0.0, 0.0, 1.0));
		FVector Hit = Math::RayPlaneIntersection(FVector(0.0, 0.0, 1.0), FVector(0.0, 0.0, -1.0), Plane);
		FVector Parallel = Math::RayPlaneIntersection(FVector(0.0, 0.0, 1.0), FVector(1.0, 0.0, 0.0), Plane);
		bool bHitOrigin = Hit.Equals(FVector(0.0, 0.0, 0.0), KINDA_SMALL_NUMBER);
		bool bParallelFinite = Math::IsFinite(Parallel.X);
		return bHitOrigin && bParallelFinite;
	}
}
/** @end */
