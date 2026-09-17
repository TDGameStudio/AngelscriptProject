/**
 * @version v1
 * @summary Observe line/plane, line/sphere, and line/box intersection plus cone bounding spheres and TruncToInt.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe line/plane, line/sphere, and line/box intersection plus cone bounding spheres and TruncToInt.
 * @topic Baseline
 */
// Math::LineBoxIntersection; Math::ComputeBoundingSphereForCone;
// Math::TruncToInt.
// Inputs: Line (0,0,1)-(0,0,-1) vs Z=0 plane; segment along +X through a
// unit sphere; box [-1,1] with StartToEnd (4,0,0); 45-degree cone radius 10;
// 1.9 and -1.9.
// Expected observations: Plane hit is (0,0,0). The X-axis segment hits the
// unit sphere and the box. A miss along (0,1,0) from (2,2,2) is false. Cone
// sphere radius is positive. TruncToInt(1.9) is 1 and TruncToInt(-1.9) is -1.
// Boundary/ownership: StartToEnd is precomputed End-Start. ConeDirection is
// expected to be normalized. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_09
{
	bool Observe_LinePlaneIntersection_Nominal()
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

	bool Observe_LineSphereIntersection_Nominal()
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

	bool Observe_LineBoxIntersection_Nominal()
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

	bool Observe_ComputeBoundingSphereForCone_Nominal()
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

	bool Observe_TruncToInt_Nominal()
	{
		int32 Pos64 = Math::TruncToInt(1.9);
		int32 Neg64 = Math::TruncToInt(-1.9);
		float32 Pos32 = 1.9;
		float32 Neg32 = -1.9;
		int32 PosI32 = Math::TruncToInt(Pos32);
		int32 NegI32 = Math::TruncToInt(Neg32);
		return Pos64 == 1 && Neg64 == -1 && PosI32 == 1 && NegI32 == -1;
	}
}
/** @end */
