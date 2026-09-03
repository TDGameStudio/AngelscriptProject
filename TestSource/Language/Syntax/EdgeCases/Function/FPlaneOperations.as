/**
 * FPlane construction and intersection helpers: the location/normal constructor,
 * the three-point constructor, PlaneDot, normal and origin accessors, and the ray
 * and segment intersection queries.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FPlaneOperations
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FPlaneOperations
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::FPlaneOperations
 * @Provenance sha256=797339421b3ea5d373ce8e6a2506c4cd66db1209e95ae2733c7cd9580ab38c8b; lines 1403-1467.
 * @Provenance Oracle: TestPlaneDot()==10; TestEquals/TestRayPlaneIntersection/TestSegmentPlaneIntersection true;
 * @Provenance TestConstruction Z~1 W~10; TestGetNormal (0,0,1); TestGetOrigin (0,0,10).
 * @Provenance Extra: origin-plane TestConstructionFromVector; TestEquals is the identity/copy vector.
 * @Provenance DefaultSafe. Source owns locals. Math::Abs for plane-distance compare.
 */

namespace SyntaxTest
{
	/**
	 * Builds a plane from a location and a normal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the location (0,0,10) and the normal (0,0,1)
	 * @Return the constructed plane
	 */
	FPlane PlaneConstruction()
	{
		FVector normal = FVector(0, 0, 1);
		FVector location = FVector(0, 0, 10);
		return FPlane(location, normal);
	}

	/**
	 * Builds a plane through three points.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the origin and the unit X and Y points
	 * @Return the constructed plane
	 */
	FPlane PlaneConstructionFromPoints()
	{
		FVector a = FVector(0, 0, 0);
		FVector b = FVector(1, 0, 0);
		FVector c = FVector(0, 1, 0);
		return FPlane(a, b, c);
	}

	/**
	 * Builds a plane through the origin.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the zero vector and the normal (0,0,1)
	 * @Return the constructed plane
	 */
	FPlane PlaneConstructionFromVector()
	{
		return FPlane(FVector::ZeroVector, FVector(0, 0, 1));
	}

	/**
	 * Computes the signed distance of a point from a plane.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the Z-plane and the point (0,0,10)
	 * @Return 10
	 */
	float PlanePlaneDot()
	{
		FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
		FVector point = FVector(0, 0, 10);
		return plane.PlaneDot(point);
	}

	/**
	 * Reads the plane's normalized normal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a plane built with the unnormalized normal (0,0,2)
	 * @Return (0,0,1)
	 */
	FVector PlaneGetNormal()
	{
		FPlane plane = FPlane(FVector(0, 0, 10), FVector(0, 0, 2));
		return plane.GetNormal();
	}

	/**
	 * Reads the plane's origin.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a plane at (0,0,10)
	 * @Return (0,0,10)
	 */
	FVector PlaneGetOrigin()
	{
		FPlane plane = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));
		return plane.GetOrigin();
	}

	/**
	 * Compares two identically built planes through the supported surface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two planes built from the same inputs
	 * @Return true when their normals and distances match
	 */
	bool PlaneEquals()
	{
		// FPlane has no AS-facing opEquals/Equals; compare via the supported
		// normal + plane-distance surface instead.
		FPlane a = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));
		FPlane b = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));

		if (!a.GetNormal().Equals(b.GetNormal(), 0.001))
		{
			return false;
		}

		return Math::Abs(a.PlaneDot(FVector::ZeroVector) - b.PlaneDot(FVector::ZeroVector)) < 0.001;
	}

	/**
	 * Intersects a ray with a plane.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the Z-plane and a ray from below
	 * @Return true when the intersection is the origin
	 */
	bool PlaneRayPlaneIntersection()
	{
		FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
		FVector intersection = plane.RayPlaneIntersection(FVector(0, 0, -5), FVector(0, 0, 1));
		return intersection.Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Intersects a segment with a plane.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the Z-plane and a segment crossing it
	 * @Return true when the hit lands at the origin
	 */
	bool PlaneSegmentPlaneIntersection()
	{
		FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
		FVector intersection;
		bool hit = plane.SegmentPlaneIntersection(FVector(0, 0, -5), FVector(0, 0, 5), intersection);

		if (!hit)
		{
			return false;
		}

		return intersection.Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that every plane helper produces its expected result.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all plane helpers
	 * @Return true when every outcome matches
	 */
	UFUNCTION()
	bool FPlaneOperationsNominal()
	{
		FPlane Built = PlaneConstruction();
		FPlane FromPoints = PlaneConstructionFromPoints();

		if (Built.Z <= 0.9)
		{
			return false;
		}

		if (Math::Abs(Built.W - 10.0) >= 0.1)
		{
			return false;
		}

		if (!(FromPoints.Z > 0.9 || FromPoints.Z < -0.9))
		{
			return false;
		}

		if (PlaneConstructionFromVector().Z <= 0.9)
		{
			return false;
		}

		if (PlanePlaneDot() != 10.0f)
		{
			return false;
		}

		if (!PlaneGetNormal().Equals(FVector(0, 0, 1), 0.001))
		{
			return false;
		}

		if (!PlaneGetOrigin().Equals(FVector(0, 0, 10), 0.001))
		{
			return false;
		}

		if (!PlaneEquals())
		{
			return false;
		}

		if (!PlaneRayPlaneIntersection())
		{
			return false;
		}

		return PlaneSegmentPlaneIntersection();
	}

	/**
	 * Observe the origin plane's zero distance.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the plane through the origin
	 * @Return true when the origin reads zero and the dot is zero
	 * @Boundary origin plane
	 */
	UFUNCTION()
	bool FPlaneOperationsOriginEmpty()
	{
		FPlane OriginPlane = PlaneConstructionFromVector();

		if (!OriginPlane.GetOrigin().Equals(FVector::ZeroVector, 0.001))
		{
			return false;
		}

		return Math::Abs(OriginPlane.PlaneDot(FVector::ZeroVector)) < 0.001;
	}
}
