/**
 * @version v1
 * @summary A three-level chain of nested USTRUCTs carrying integers, so reflection must walk Root.Middle.Inner to reach the deepest properties.
 * @topic Language
 */
/**
 * @version root
 * @summary A three-level chain of nested USTRUCTs carrying integers, so reflection must walk Root.Middle.Inner to reach the deepest properties.
 * @topic Baseline
 */
/**
 * The innermost struct of the nested chain.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared inner struct with two widths
 */
USTRUCT()
struct FCoverageIntPropertyDeepInner
{
	UPROPERTY()
	int8 Int8Value = 7;

	UPROPERTY()
	uint64 UInt64Value = 999999999;
}

/**
 * The middle struct embedding the inner one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared middle struct embedding Inner
 */
USTRUCT()
struct FCoverageIntPropertyDeepMiddle
{
	UPROPERTY()
	FCoverageIntPropertyDeepInner Inner;

	UPROPERTY()
	int16 Int16Value = 777;
}

/**
 * The root struct embedding the middle one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared root struct embedding Middle
 */
USTRUCT()
struct FCoverageIntPropertyDeepRoot
{
	UPROPERTY()
	FCoverageIntPropertyDeepMiddle Middle;

	UPROPERTY()
	int IntValue = 12345;
}

UCLASS()
class ACoverageIntStructDeepPathsActor : AActor
{
	UPROPERTY()
	FCoverageIntPropertyDeepRoot Root;

	/**
	 * Observe that the deepest defaults are readable through the chain.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four nested defaults match
	 */
	UFUNCTION()
	bool IntStructDeepPathsNominal()
	{
		if (Root.Middle.Inner.Int8Value != 7)
		{
			return false;
		}

		if (Root.Middle.Inner.UInt64Value != 999999999)
		{
			return false;
		}

		if (Root.Middle.Int16Value != 777)
		{
			return false;
		}

		return Root.IntValue == 12345;
	}

	/**
	 * Observe that mutating a copied inner struct leaves the chain intact.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copy of the innermost struct
	 * @Return true when the original keeps 7 and the copy holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntStructDeepPathsCopyIndependence()
	{
		FCoverageIntPropertyDeepInner Copy = Root.Middle.Inner;
		Copy.Int8Value = 0;

		if (Root.Middle.Inner.Int8Value != 7)
		{
			return false;
		}

		return Copy.Int8Value == 0;
	}
}
/** @end */
