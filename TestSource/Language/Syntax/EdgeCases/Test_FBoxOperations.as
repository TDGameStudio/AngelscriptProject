// Theme: Language.Syntax.EdgeCases. Positive FBox construction and query helpers.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FBoxOperations
// sha256=013c54a289ef76d873c88191ec8d73cfdc82b2e7245fbaf6443c17223539d693; lines 1186-1306.
// Oracle: TestConstruction/TestBuildAABB min (0,0,0) max (100,100,100); TestIsInside true;
// TestIsInsideOutside false; TestGetCenter/Extent (50,50,50); TestGetSize (100,100,100);
// TestGetVolume 1000; ExpandBy size 120; Plus max 200; remaining bool helpers true.
// Extra: default FBox volume is not the 10^3 box; TestIsInsideOutside is the false vector.
// DefaultSafe. Source owns locals.

FBox TestConstruction()
{
	FVector min = FVector(0, 0, 0);
	FVector max = FVector(100, 100, 100);
	return FBox(min, max);
}

FBox TestBuildAABB()
{
	return FBox::BuildAABB(FVector(50, 50, 50), FVector(50, 50, 50));
}

bool TestIsInside()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	FVector point = FVector(50, 50, 50);
	return box.IsInside(point);
}

bool TestIsInsideOutside()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	FVector point = FVector(200, 200, 200);
	return box.IsInside(point);
}

FVector TestGetCenter()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	return box.GetCenter();
}

FVector TestGetExtent()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	return box.GetExtent();
}

FVector TestGetSize()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	return box.Max - box.Min;
}

float TestGetVolume()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
	return box.GetVolume();
}

FBox TestExpandBy()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	return box.ExpandBy(10.0);
}

FBox TestPlusOperator()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	FVector point = FVector(200, 200, 200);
	return box + point;
}

bool TestIsValid()
{
	// FBox::IsValid (uint8 member) is not exposed on the AS binding surface;
	// verify validity through the supported volume/extent surface instead.
	FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
	return box.GetVolume() > 0.0 && box.Max.Equals(FVector(100, 100, 100), 0.001);
}

bool TestIntersectAndOverlap()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
	FBox other = FBox(FVector(5, 5, 5), FVector(20, 20, 20));
	FBox overlap = box.Overlap(other);
	return box.Intersect(other)
		&& box.IntersectXY(other)
		&& overlap.Min.Equals(FVector(5, 5, 5), 0.001)
		&& overlap.Max.Equals(FVector(10, 10, 10), 0.001);
}

bool TestInsideBoxAndBoundaryVariants()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
	FBox inner = FBox(FVector(2, 2, 2), FVector(8, 8, 8));
	FVector boundary = FVector(10, 5, 5);
	FVector outsideZ = FVector(5, 5, 20);
	return box.IsInside(inner)
		&& !box.IsInside(boundary)
		&& box.IsInsideOrOn(boundary)
		&& box.IsInsideXY(outsideZ)
		&& box.IsInsideOrOnXY(FVector(10, 5, 20));
}

bool TestGetCenterAndExtentsOutParams()
{
	FBox box = FBox(FVector(-2, -4, -6), FVector(6, 8, 10));
	FVector center;
	FVector extents;
	box.GetCenterAndExtents(center, extents);
	return center.Equals(FVector(2, 2, 2), 0.001)
		&& extents.Equals(FVector(4, 6, 8), 0.001);
}

bool TestClosestShiftMoveAndVectorExpand()
{
	FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
	FBox expanded = box.ExpandBy(FVector(1, 2, 3));
	FBox shifted = box.ShiftBy(FVector(5, 0, 0));
	FBox moved = box.MoveTo(FVector(100, 100, 100));
	FVector closest = box.GetClosestPointTo(FVector(20, 5, -5));
	return expanded.Min.Equals(FVector(-1, -2, -3), 0.001)
		&& expanded.Max.Equals(FVector(11, 12, 13), 0.001)
		&& shifted.Min.Equals(FVector(5, 0, 0), 0.001)
		&& shifted.Max.Equals(FVector(15, 10, 10), 0.001)
		&& moved.GetCenter().Equals(FVector(100, 100, 100), 0.001)
		&& closest.Equals(FVector(10, 5, 0), 0.001);
}

bool Observe_FBoxOperations_Nominal()
{
	FBox Built = TestConstruction();
	FBox Aabb = TestBuildAABB();
	FBox Expanded = TestExpandBy();
	return Built.Min.Equals(FVector(0, 0, 0), 0.001)
		&& Built.Max.Equals(FVector(100, 100, 100), 0.001)
		&& Aabb.Min.Equals(FVector(0, 0, 0), 0.001)
		&& Aabb.Max.Equals(FVector(100, 100, 100), 0.001)
		&& TestIsInside()
		&& !TestIsInsideOutside()
		&& TestGetCenter().Equals(FVector(50, 50, 50), 0.001)
		&& TestGetExtent().Equals(FVector(50, 50, 50), 0.001)
		&& TestGetSize().Equals(FVector(100, 100, 100), 0.001)
		&& TestGetVolume() == 1000.0f
		&& (Expanded.Max - Expanded.Min).Equals(FVector(120, 120, 120), 0.001)
		&& TestPlusOperator().Max.Equals(FVector(200, 200, 200), 0.001)
		&& TestIsValid()
		&& TestIntersectAndOverlap()
		&& TestInsideBoxAndBoundaryVariants()
		&& TestGetCenterAndExtentsOutParams()
		&& TestClosestShiftMoveAndVectorExpand();
}

bool Observe_FBoxOperations_DefaultEmpty()
{
	FBox Empty;
	return Empty.GetVolume() <= 0.0;
}
