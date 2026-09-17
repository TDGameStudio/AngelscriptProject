/**
 * @version v1
 * @summary FBox construction and query helpers: the min/max constructor, BuildAABB, inside tests, center/extent/size/volume, expansion, the plus operator, and the intersection and boundary variants. Each helper isolates one query.
 * @topic Language
 */
/**
 * @version root
 * @summary FBox construction and query helpers: the min/max constructor, BuildAABB, inside tests, center/extent/size/volume, expansion, the plus operator, and the intersection and boundary variants. Each helper isolates one query.
 * @topic Baseline
 */
namespace SyntaxTest
{
	/**
	 * Builds a box through the min/max constructor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the corners (0,0,0) and (100,100,100)
	 * @Return the constructed box
	 */
	FBox BoxConstruction()
	{
		FVector min = FVector(0, 0, 0);
		FVector max = FVector(100, 100, 100);
		return FBox(min, max);
	}

	/**
	 * Builds the same box through BuildAABB.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a center and a half-extent of 50
	 * @Return the constructed box
	 */
	FBox BoxBuildAABB()
	{
		return FBox::BuildAABB(FVector(50, 50, 50), FVector(50, 50, 50));
	}

	/**
	 * Queries whether the box's center lies inside it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box and its center
	 * @Return true
	 */
	bool BoxIsInside()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		FVector point = FVector(50, 50, 50);
		return box.IsInside(point);
	}

	/**
	 * Queries whether a far point lies outside the box.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box and the point (200,200,200)
	 * @Return false
	 */
	bool BoxIsInsideOutside()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		FVector point = FVector(200, 200, 200);
		return box.IsInside(point);
	}

	/**
	 * Reads the box's center.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box
	 * @Return (50,50,50)
	 */
	FVector BoxGetCenter()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		return box.GetCenter();
	}

	/**
	 * Reads the box's extent.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box
	 * @Return (50,50,50)
	 */
	FVector BoxGetExtent()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		return box.GetExtent();
	}

	/**
	 * Reads the box's size.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box
	 * @Return (100,100,100)
	 */
	FVector BoxGetSize()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		return box.Max - box.Min;
	}

	/**
	 * Reads the box's volume.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 10-cube box
	 * @Return 1000
	 */
	float BoxGetVolume()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
		return box.GetVolume();
	}

	/**
	 * Expands the box by a scalar.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box and a 10-unit expansion
	 * @Return the expanded box
	 */
	FBox BoxExpandBy()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		return box.ExpandBy(10.0);
	}

	/**
	 * Grows the box to include a far point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box and the point (200,200,200)
	 * @Return the grown box
	 */
	FBox BoxPlusOperator()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));
		FVector point = FVector(200, 200, 200);
		return box + point;
	}

	/**
	 * Verifies validity through the supported volume and extent surface.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 100-cube box
	 * @Return true when the volume is positive and the max matches
	 */
	bool BoxIsValid()
	{
		// FBox::IsValid (uint8 member) is not exposed on the AS binding surface;
		// verify validity through the supported volume/extent surface instead.
		FBox box = FBox(FVector(0, 0, 0), FVector(100, 100, 100));

		if (box.GetVolume() <= 0.0)
		{
			return false;
		}

		return box.Max.Equals(FVector(100, 100, 100), 0.001);
	}

	/**
	 * Queries intersection and overlap between two boxes.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a 10-cube box and a 15-cube box offset by 5
	 * @Return true when all intersection and overlap facts hold
	 */
	bool BoxIntersectAndOverlap()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
		FBox other = FBox(FVector(5, 5, 5), FVector(20, 20, 20));
		FBox overlap = box.Overlap(other);

		if (!box.Intersect(other))
		{
			return false;
		}

		if (!box.IntersectXY(other))
		{
			return false;
		}

		if (!overlap.Min.Equals(FVector(5, 5, 5), 0.001))
		{
			return false;
		}

		return overlap.Max.Equals(FVector(10, 10, 10), 0.001);
	}

	/**
	 * Queries the inside, inside-or-on and XY variants.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a 10-cube box, an inner box, and boundary and outside points
	 * @Return true when all variant results hold
	 */
	bool BoxInsideAndBoundaryVariants()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
		FBox inner = FBox(FVector(2, 2, 2), FVector(8, 8, 8));
		FVector boundary = FVector(10, 5, 5);
		FVector outsideZ = FVector(5, 5, 20);

		if (!box.IsInside(inner))
		{
			return false;
		}

		if (box.IsInside(boundary))
		{
			return false;
		}

		if (!box.IsInsideOrOn(boundary))
		{
			return false;
		}

		if (!box.IsInsideXY(outsideZ))
		{
			return false;
		}

		return box.IsInsideOrOnXY(FVector(10, 5, 20));
	}

	/**
	 * Reads center and extents through the out-parameter helper.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the box spanning (-2,-4,-6) to (6,8,10)
	 * @Return true when the center and extents match
	 */
	bool BoxGetCenterAndExtentsOutParams()
	{
		FBox box = FBox(FVector(-2, -4, -6), FVector(6, 8, 10));
		FVector center;
		FVector extents;
		box.GetCenterAndExtents(center, extents);

		if (!center.Equals(FVector(2, 2, 2), 0.001))
		{
			return false;
		}

		return extents.Equals(FVector(4, 6, 8), 0.001);
	}

	/**
	 * Exercises expansion by vector, shifting, moving and closest point.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the 10-cube box with several transforms
	 * @Return true when all transformed boxes match
	 */
	bool BoxClosestShiftMoveAndVectorExpand()
	{
		FBox box = FBox(FVector(0, 0, 0), FVector(10, 10, 10));
		FBox expanded = box.ExpandBy(FVector(1, 2, 3));
		FBox shifted = box.ShiftBy(FVector(5, 0, 0));
		FBox moved = box.MoveTo(FVector(100, 100, 100));
		FVector closest = box.GetClosestPointTo(FVector(20, 5, -5));

		if (!expanded.Min.Equals(FVector(-1, -2, -3), 0.001))
		{
			return false;
		}

		if (!expanded.Max.Equals(FVector(11, 12, 13), 0.001))
		{
			return false;
		}

		if (!shifted.Min.Equals(FVector(5, 0, 0), 0.001))
		{
			return false;
		}

		if (!shifted.Max.Equals(FVector(15, 10, 10), 0.001))
		{
			return false;
		}

		if (!moved.GetCenter().Equals(FVector(100, 100, 100), 0.001))
		{
			return false;
		}

		return closest.Equals(FVector(10, 5, 0), 0.001);
	}

	/**
	 * Observe that every box helper produces its expected result.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all box helpers
	 * @Return true when every outcome matches
	 */
	UFUNCTION()
	bool FBoxOperationsNominal()
	{
		FBox Built = BoxConstruction();
		FBox Aabb = BoxBuildAABB();
		FBox Expanded = BoxExpandBy();

		if (!Built.Min.Equals(FVector(0, 0, 0), 0.001))
		{
			return false;
		}

		if (!Built.Max.Equals(FVector(100, 100, 100), 0.001))
		{
			return false;
		}

		if (!Aabb.Min.Equals(FVector(0, 0, 0), 0.001))
		{
			return false;
		}

		if (!Aabb.Max.Equals(FVector(100, 100, 100), 0.001))
		{
			return false;
		}

		if (!BoxIsInside())
		{
			return false;
		}

		if (BoxIsInsideOutside())
		{
			return false;
		}

		if (!BoxGetCenter().Equals(FVector(50, 50, 50), 0.001))
		{
			return false;
		}

		if (!BoxGetExtent().Equals(FVector(50, 50, 50), 0.001))
		{
			return false;
		}

		if (!BoxGetSize().Equals(FVector(100, 100, 100), 0.001))
		{
			return false;
		}

		if (BoxGetVolume() != 1000.0f)
		{
			return false;
		}

		if (!(Expanded.Max - Expanded.Min).Equals(FVector(120, 120, 120), 0.001))
		{
			return false;
		}

		if (!BoxPlusOperator().Max.Equals(FVector(200, 200, 200), 0.001))
		{
			return false;
		}

		if (!BoxIsValid())
		{
			return false;
		}

		if (!BoxIntersectAndOverlap())
		{
			return false;
		}

		if (!BoxInsideAndBoundaryVariants())
		{
			return false;
		}

		if (!BoxGetCenterAndExtentsOutParams())
		{
			return false;
		}

		return BoxClosestShiftMoveAndVectorExpand();
	}

	/**
	 * Observe that a default-constructed box has no volume.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed FBox
	 * @Return true when the volume is not positive
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FBoxOperationsDefaultEmpty()
	{
		FBox Empty;
		return Empty.GetVolume() <= 0.0;
	}
}
/** @end */
