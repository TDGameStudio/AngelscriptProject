/**
 * The FLinearColor R, G, B and A components read and written as members. C++ executes
 * each entrypoint and checks the value it produces, so those names are part of the
 * contract and are kept verbatim. The observers cover the empty default and the
 * independence of a copy.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.MemberAccess
 * @Harness Function
 * @Tag Gameplay.FLinearColor.LinearColorMemberAccess
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive R/G/B/A getter and setter oracles.
 * @Provenance C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorMemberAccess
 * @Provenance Oracle: GetR 0.1; GetG 0.2; GetB 0.3; GetA 0.4;
 * @Provenance SetR (0.9,0.2,0.3,0.4); SetG (0.1,0.8,0.3,0.4); SetB (0.1,0.2,0.7,0.4); SetA (0.1,0.2,0.3,1.0).
 * @Provenance Extra: default empty (0,0,0,1); copy independence of SetR source. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Read the R component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return 0.1
	 */
	UFUNCTION()
	float GetR()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		return c.R;
	}

	/**
	 * Read the G component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return 0.2
	 */
	UFUNCTION()
	float GetG()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		return c.G;
	}

	/**
	 * Read the B component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return 0.3
	 */
	UFUNCTION()
	float GetB()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		return c.B;
	}

	/**
	 * Read the A component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return 0.4
	 */
	UFUNCTION()
	float GetA()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		return c.A;
	}

	/**
	 * Write the R component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return FLinearColor(0.9, 0.2, 0.3, 0.4)
	 */
	UFUNCTION()
	FLinearColor SetR()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		c.R = 0.9;
		return c;
	}

	/**
	 * Write the G component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return FLinearColor(0.1, 0.8, 0.3, 0.4)
	 */
	UFUNCTION()
	FLinearColor SetG()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		c.G = 0.8;
		return c;
	}

	/**
	 * Write the B component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return FLinearColor(0.1, 0.2, 0.7, 0.4)
	 */
	UFUNCTION()
	FLinearColor SetB()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		c.B = 0.7;
		return c;
	}

	/**
	 * Write the A component of a known color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return FLinearColor(0.1, 0.2, 0.3, 1.0)
	 */
	UFUNCTION()
	FLinearColor SetA()
	{
		FLinearColor c = FLinearColor(0.1, 0.2, 0.3, 0.4);
		c.A = 1.0;
		return c;
	}

	/**
	 * Observe that reading every component yields the expected values.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return true when R, G, B and A read 0.1, 0.2, 0.3 and 0.4
	 */
	UFUNCTION()
	bool GettersNominal()
	{
		if (GetR() != 0.1)
		{
			return false;
		}
		if (GetG() != 0.2)
		{
			return false;
		}
		if (GetB() != 0.3)
		{
			return false;
		}
		return GetA() == 0.4;
	}

	/**
	 * Observe that writing R is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals (0.9, 0.2, 0.3, 0.4)
	 */
	UFUNCTION()
	bool SetRNominal()
	{
		return SetR().Equals(FLinearColor(0.9, 0.2, 0.3, 0.4));
	}

	/**
	 * Observe that writing G is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals (0.1, 0.8, 0.3, 0.4)
	 */
	UFUNCTION()
	bool SetGNominal()
	{
		return SetG().Equals(FLinearColor(0.1, 0.8, 0.3, 0.4));
	}

	/**
	 * Observe that writing B is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals (0.1, 0.2, 0.7, 0.4)
	 */
	UFUNCTION()
	bool SetBNominal()
	{
		return SetB().Equals(FLinearColor(0.1, 0.2, 0.7, 0.4));
	}

	/**
	 * Observe that writing A is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals (0.1, 0.2, 0.3, 1.0)
	 */
	UFUNCTION()
	bool SetANominal()
	{
		return SetA().Equals(FLinearColor(0.1, 0.2, 0.3, 1.0));
	}

	/**
	 * Observe that a default color reads as black with alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs a default-constructed color
	 * @Return true when the members read (0, 0, 0, 1)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool MemberAccessDefaultEmpty()
	{
		FLinearColor Empty = FLinearColor();

		if (Empty.R != 0.0)
		{
			return false;
		}
		if (Empty.G != 0.0)
		{
			return false;
		}
		if (Empty.B != 0.0)
		{
			return false;
		}
		return Empty.A == 1.0;
	}

	/**
	 * Observe that mutating a copy leaves the source color untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.MemberAccess
	 * @Inputs a known color and a mutated copy of it
	 * @Return true when the source still reads (0.1, 0.2, 0.3, 0.4) and the copy reads 0.9
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetRCopyIndependence()
	{
		FLinearColor Source = FLinearColor(0.1, 0.2, 0.3, 0.4);
		FLinearColor Mutated = Source;
		Mutated.R = 0.9;

		if (!Source.Equals(FLinearColor(0.1, 0.2, 0.3, 0.4)))
		{
			return false;
		}
		return Mutated.R == 0.9;
	}
}
