/**
 * Four levels of nested blocks. A variable declared in the innermost block is
 * visible only while that nest is live, and empty nests leave the outer value
 * untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DeeplyNestedBlocks
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.DeeplyNestedBlocks
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 2 AssertCompiles.
 * @Provenance sha256=86b3086e265b9ee6550ef3f870299872ee236e30c6837e45e40b9866b7144d09; lines 235-237.
 * @Provenance Oracle: four nested blocks compile; innermost X is 1 while the nest is live.
 * @Provenance Extra: empty inner nests leave outer 0; assigning through the nest yields 1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Four nested blocks whose innermost declares a variable.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		{
			{
				{
					{
						int X = 1;
					}
				}
			}
		}
	}

	/**
	 * Observe the value of the innermost declaration.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs four nested blocks assigning to an outer variable
	 * @Return 1, the value assigned in the innermost block
	 */
	UFUNCTION()
	int DeepNestInnermostValue()
	{
		int Result = 0;
		{
			{
				{
					{
						int X = 1;
						Result = X;
					}
				}
			}
		}
		return Result;
	}

	/**
	 * Observe that empty nested blocks leave the outer value untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs four empty nested blocks
	 * @Return 0
	 * @Boundary empty blocks
	 */
	UFUNCTION()
	int DeepNestEmptyBlocksDefault()
	{
		int Result = 0;
		{
			{
				{
					{
					}
				}
			}
		}
		return Result;
	}

	/**
	 * Observe that the outer variable keeps the value assigned inside.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an outer variable assigned from the innermost block
	 * @Return 1
	 */
	UFUNCTION()
	int DeepNestOuterKeepsAssignedValue()
	{
		int Outer = 0;
		{
			{
				{
					{
						int X = 1;
						Outer = X;
					}
				}
			}
		}
		return Outer;
	}
}
