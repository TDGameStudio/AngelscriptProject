/**
 * An object handle is classified against nullptr with both the equal and
 * not-equal operators. Exactly one of the two comparisons holds for any given
 * handle, so the pair partitions handles into null and non-null.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrComparison
 * @Harness Function
 * @Tag Language.Casting.NullptrComparison
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

namespace CastingTest
{
	/**
	 * Observe the classification: a null handle reports 0 and a live handle
	 * reports 1, with -1 reserved for a handle that matches neither.
	 *
	 * @Kind Observe
	 * @Covers Casting.Nullptr
	 * @Param A Source actor handle, runner-owned when non-null
	 * @Inputs Compare A against nullptr with both operators
	 * @Return 0 when A is null, 1 when A is non-null
	 */
	UFUNCTION()
	int NullCompareClassifiesHandle(AActor A)
	{
		if (A == nullptr)
		{
			return 0;
		}
		if (A != nullptr)
		{
			return 1;
		}
		return -1;
	}
}
