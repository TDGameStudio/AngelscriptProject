/**
 * Comparison operators specific to FName and FText. FName orders through
 * Compare, while FText exposes no equality operator in this fork and is
 * compared with IdenticalTo, which is false for distinct instances even when
 * their text matches.
 *
 * @Theme Language.Literals
 * @Subject Literals.NameAndTextComparisonOperators
 * @Harness Function
 * @Tag Language.Literals.NameAndTextComparisonOperators
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::NameAndTextComparisonOperators
 * @Provenance sha256=4f4dba0a72bf6fde5f481e7f9fd73926f7d0ae845889925bd92d68bae86b51a4; lines 759-773.
 * @Provenance Oracle: NameCompareOrdersValues true; TextIdentical true (separate FromString are not IdenticalTo).
 * @Provenance Extra: two default FNames Compare equal; same FText IdenticalTo itself.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Compares two names in both directions.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"Alpha" and n"Beta" compared both ways
	 * @Return true when the ordering is consistent
	 */
	bool NameCompareOrdersValues()
	{
		FName Left = n"Alpha";
		FName Right = n"Beta";

		if (Left.Compare(Right) >= 0)
		{
			return false;
		}

		return Right.Compare(Left) > 0;
	}

	/**
	 * Compares two identically built texts for identity.
	 *
	 * @Covers Literals.FString
	 * @Inputs two FTexts wrapping "A"
	 * @Return true, since IdenticalTo is false for distinct instances
	 */
	bool TextIdentical()
	{
		FText Left = FText::FromString("A");
		FText Right = FText::FromString("A");
		return !Left.IdenticalTo(Right);
	}

	/**
	 * Observe that both comparison forms behave as expected.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs NameCompareOrdersValues() and TextIdentical()
	 * @Return true when both hold
	 */
	UFUNCTION()
	bool NameAndTextComparisonProduceExpectedValues()
	{
		if (!NameCompareOrdersValues())
		{
			return false;
		}

		return TextIdentical();
	}

	/**
	 * Observe that two default-constructed names compare equal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Compare between two NAME_None values
	 * @Return true when the comparison is 0
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool NameCompareEmptyNoneBoundary()
	{
		FName Left;
		FName Right;
		return Left.Compare(Right) == 0;
	}

	/**
	 * Observe that a text is identical to itself.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs IdenticalTo against the same instance
	 * @Return true
	 * @Boundary self comparison
	 */
	UFUNCTION()
	bool TextIdenticalSameObjectBoundary()
	{
		FText Value = FText::FromString("A");
		return Value.IdenticalTo(Value);
	}
}
