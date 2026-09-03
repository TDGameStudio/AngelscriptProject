/**
 * Nested scope name shadowing: an inner local of the same name does not
 * overwrite the outer after the block ends. An empty inner block is a no-op
 * and leaves the outer value untouched.
 *
 * @Theme Feature.Access
 * @Subject Access.OuterUnchangedAfterInnerShadow
 * @Harness Function
 * @Tag Feature.Access.OuterUnchangedAfterInnerShadow
 * @Namespace AccessTest
 * @Provenance Theme: Feature.Access. Positive nested scope / name shadowing.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Positive block 1 AssertCompiles.
 * @Provenance Oracle: inner shadow does not overwrite outer after the block.
 * @Provenance Extra: empty inner block is a no-op; outer remains 1.
 * @Provenance DefaultSafe.
 */

namespace AccessTest
{
	/**
	 * An inner local shadows the outer name for the duration of the block.
	 *
	 * @Covers Access.Scope
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int X = 1;
		{
			int X = 2;
		}
	}

	/**
	 * Observe that the inner shadow does not overwrite the outer after the block.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs an outer X of 1 and an inner X of 2
	 * @Return 1, the outer value after the block
	 */
	UFUNCTION()
	int OuterUnchangedAfterInnerShadow()
	{
		int X = 1;
		{
			int X = 2;
			if (X != 2)
			{
				return 0;
			}
		}
		return X;
	}

	/**
	 * Observe that an empty inner block leaves the outer value untouched.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs an outer X of 7 and an empty inner block
	 * @Return 7
	 * @Boundary empty inner block
	 */
	UFUNCTION()
	int EmptyInnerScopeDefault()
	{
		int X = 7;
		{
		}
		return X;
	}
}
