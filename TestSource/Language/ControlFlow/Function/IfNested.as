/**
 * Nested if statements: an inner if inside either arm of an outer one, so the
 * four combinations of two conditions each reach their own result. Deeper
 * nesting works the same way, with each level narrowing further, and the
 * final else catches whatever falls past every test.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.IfNested
 * @Harness Function
 * @Tag Language.ControlFlow.IfNested
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageConditionalTests.cpp::IfNested
 * @Provenance sha256=1f3d81dd5ec4090ba36d4603a7eb27087911198c4ee137d5e2bb8bff6a39a0cf; lines 175-218.
 * @Provenance Oracle: NestedIf(1, 1) 1; DeepNested(25) 3.
 * @Provenance Extra: remaining NestedIf quadrants; DeepNested 0/1/2 bands.
 */

namespace ControlFlowTest
{
	/**
	 * Observe a two-level nest: each of the four sign combinations of X and Y
	 * reaches its own result.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param X Classified against zero by the outer test
	 * @Param Y Classified against zero by the inner test
	 * @Inputs if (X > 0) { if (Y > 0) ... else ... } else { if (Y > 0) ... else ... }
	 * @Return 1 for +/+, 2 for +/-, 3 for -/+, 4 for -/-
	 */
	UFUNCTION()
	int NestedIfSelectsQuadrant(int X, int Y)
	{
		if (X > 0)
		{
			if (Y > 0)
			{
				return 1;
			}
			else
			{
				return 2;
			}
		}
		else
		{
			if (Y > 0)
			{
				return 3;
			}
			else
			{
				return 4;
			}
		}
	}

	/**
	 * Observe a three-level nest that narrows a value into bands, with a
	 * trailing return catching everything past the last test.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Param Value Classified into bands by successive tests
	 * @Inputs Tests against 0, then 10, then 20
	 * @Return 0 up to zero, 1 up to ten, 2 up to twenty, 3 above twenty
	 */
	UFUNCTION()
	int DeepNestedSelectsBand(int Value)
	{
		if (Value > 0)
		{
			if (Value > 10)
			{
				if (Value > 20)
				{
					return 3;
				}
				return 2;
			}
			return 1;
		}
		return 0;
	}

	/**
	 * Observe the zero default: both inputs at zero fall to the last arm of
	 * each nest.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs Both functions evaluated at zero
	 * @Return true when the quadrant is 4 and the band is 0
	 * @Boundary zero input
	 */
	UFUNCTION()
	bool NestedIfZeroFallsToLastArm()
	{
		if (NestedIfSelectsQuadrant(0, 0) != 4)
		{
			return false;
		}
		return DeepNestedSelectsBand(0) == 0;
	}

	/**
	 * Observe the remaining quadrants of the two-level nest.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs The three quadrant combinations other than +/+
	 * @Return true when they yield 2, 3, and 4 respectively
	 */
	UFUNCTION()
	bool NestedIfReachesOtherQuadrants()
	{
		if (NestedIfSelectsQuadrant(1, -1) != 2)
		{
			return false;
		}
		if (NestedIfSelectsQuadrant(-1, 1) != 3)
		{
			return false;
		}
		return NestedIfSelectsQuadrant(-1, -1) == 4;
	}

	/**
	 * Observe the band boundaries of the three-level nest, including the
	 * exact threshold where the deepest test does not yet hold.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.If
	 * @Inputs Values 5, 15, and 20
	 * @Return true when they yield 1, 2, and 2 respectively
	 * @Boundary band thresholds
	 */
	UFUNCTION()
	bool DeepNestedRespectsBandThresholds()
	{
		if (DeepNestedSelectsBand(5) != 1)
		{
			return false;
		}
		if (DeepNestedSelectsBand(15) != 2)
		{
			return false;
		}
		return DeepNestedSelectsBand(20) == 2;
	}
}
