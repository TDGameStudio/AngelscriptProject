/**
 * @version v1
 * @summary The binary plus operator concatenates two FString values into a new string. The result copies its inputs, so mutating an operand afterwards leaves the concatenation unchanged, and an empty left operand simply yields the.
 * @topic Language
 */
/**
 * @version root
 * @summary The binary plus operator concatenates two FString values into a new string. The result copies its inputs, so mutating an operand afterwards leaves the concatenation unchanged, and an empty left operand simply yields the.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Observe that plus concatenates two strings.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "Hello" + " World"
	 * @Return true when the result is "Hello World"
	 */
	UFUNCTION()
	bool ConcatPlusNominal()
	{
		FString A = "Hello";
		FString B = " World";
		FString C = A + B;
		return C == "Hello World";
	}

	/**
	 * Observe the empty-left boundary of plus.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" + " World"
	 * @Return true when the result is " World"
	 * @Boundary empty left operand
	 */
	UFUNCTION()
	bool ConcatPlusEmptyLeft()
	{
		FString A = "";
		FString B = " World";
		return A + B == " World";
	}

	/**
	 * Observe that plus copies its operands rather than aliasing them.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A + B, then A changed
	 * @Return true when the concatenation keeps "Hello World"
	 */
	UFUNCTION()
	bool ConcatPlusCopyIndependence()
	{
		FString A = "Hello";
		FString B = " World";
		FString C = A + B;
		A = "changed";
		return C == "Hello World";
	}
}
/** @end */
