// Theme: Language.Syntax.EdgeCases. Positive FPlane construction and intersection helpers.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FPlaneOperations
// sha256=797339421b3ea5d373ce8e6a2506c4cd66db1209e95ae2733c7cd9580ab38c8b; lines 1403-1467.
// Oracle: TestPlaneDot()==10; TestEquals/TestRayPlaneIntersection/TestSegmentPlaneIntersection true;
// TestConstruction Z~1 W~10; TestGetNormal (0,0,1); TestGetOrigin (0,0,10).
// Extra: origin-plane TestConstructionFromVector; TestEquals is the identity/copy vector.
// DefaultSafe. Source owns locals. Math::Abs for plane-distance compare.

FPlane TestConstruction()
{
	FVector normal = FVector(0, 0, 1);
	FVector location = FVector(0, 0, 10);
	return FPlane(location, normal);
}

FPlane TestConstructionFromPoints()
{
	FVector a = FVector(0, 0, 0);
	FVector b = FVector(1, 0, 0);
	FVector c = FVector(0, 1, 0);
	return FPlane(a, b, c);
}

FPlane TestConstructionFromVector()
{
	return FPlane(FVector::ZeroVector, FVector(0, 0, 1));
}

float TestPlaneDot()
{
	FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
	FVector point = FVector(0, 0, 10);
	return plane.PlaneDot(point);
}

FVector TestGetNormal()
{
	FPlane plane = FPlane(FVector(0, 0, 10), FVector(0, 0, 2));
	return plane.GetNormal();
}

FVector TestGetOrigin()
{
	FPlane plane = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));
	return plane.GetOrigin();
}

bool TestEquals()
{
	// FPlane has no AS-facing opEquals/Equals; compare via the supported
	// normal + plane-distance surface instead.
	FPlane a = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));
	FPlane b = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));
	return a.GetNormal().Equals(b.GetNormal(), 0.001)
		&& Math::Abs(a.PlaneDot(FVector::ZeroVector) - b.PlaneDot(FVector::ZeroVector)) < 0.001;
}

bool TestRayPlaneIntersection()
{
	FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
	FVector intersection = plane.RayPlaneIntersection(FVector(0, 0, -5), FVector(0, 0, 1));
	return intersection.Equals(FVector::ZeroVector, 0.001);
}

bool TestSegmentPlaneIntersection()
{
	FPlane plane = FPlane(FVector::ZeroVector, FVector(0, 0, 1));
	FVector intersection;
	bool hit = plane.SegmentPlaneIntersection(FVector(0, 0, -5), FVector(0, 0, 5), intersection);
	return hit && intersection.Equals(FVector::ZeroVector, 0.001);
}

bool Observe_FPlaneOperations_Nominal()
{
	FPlane Built = TestConstruction();
	FPlane FromPoints = TestConstructionFromPoints();
	return Built.Z > 0.9
		&& Math::Abs(Built.W - 10.0) < 0.1
		&& (FromPoints.Z > 0.9 || FromPoints.Z < -0.9)
		&& TestConstructionFromVector().Z > 0.9
		&& TestPlaneDot() == 10.0f
		&& TestGetNormal().Equals(FVector(0, 0, 1), 0.001)
		&& TestGetOrigin().Equals(FVector(0, 0, 10), 0.001)
		&& TestEquals()
		&& TestRayPlaneIntersection()
		&& TestSegmentPlaneIntersection();
}

bool Observe_FPlaneOperations_OriginEmpty()
{
	FPlane OriginPlane = TestConstructionFromVector();
	return OriginPlane.GetOrigin().Equals(FVector::ZeroVector, 0.001) && Math::Abs(OriginPlane.PlaneDot(FVector::ZeroVector)) < 0.001;
}
