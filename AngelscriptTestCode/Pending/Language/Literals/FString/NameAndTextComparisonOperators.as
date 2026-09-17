/**
 * @version v1
 * @summary Comparison operators specific to FName and FText. FName orders through Compare, while FText exposes no equality operator in this fork and is compared with IdenticalTo, which is false for distinct instances even when.
 * @topic Language
 */
/**
 * @version root
 * @summary Comparison operators specific to FName and FText. FName orders through Compare, while FText exposes no equality operator in this fork and is compared with IdenticalTo, which is false for distinct instances even when.
 * @topic Baseline
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
/** @end */
