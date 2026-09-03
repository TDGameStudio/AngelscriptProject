/**
 * The same name may be declared in separate sibling blocks. The first block's
 * X and the second block's X do not collide, and an outer local stays at its
 * default. Empty sibling blocks leave that outer default unchanged.
 *
 * @Theme Feature.Access
 * @Subject Access.SeparateBlocksIndependent
 * @Harness Function
 * @Tag Feature.Access.SeparateBlocksIndependent
 * @Namespace AccessTest
 * @Provenance Theme: Feature.Access. Positive: the same name may be declared in separate blocks.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Scope_Positive block 2 AssertCompiles.
 * @Provenance Oracle: first block X==1 and second block X==2 do not collide; outer stays 0.
 * @Provenance Extra: empty sibling blocks leave the outer default unchanged.
 * @Provenance DefaultSafe.
 */

namespace AccessTest
{
	/**
	 * Two sibling blocks each declaring their own X.
	 *
	 * @Covers Access.Scope
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		{
			int X = 1;
		}
		{
			int X = 2;
		}
	}

	/**
	 * Observe that sibling blocks keep independent locals of the same name.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs an outer of 0, then X==1 in the first block and X==2 in the second
	 * @Return 0, the outer value after both blocks
	 */
	UFUNCTION()
	int SeparateBlocksIndependent()
	{
		int Outer = 0;
		{
			int X = 1;
			if (X != 1)
			{
				return -1;
			}
		}
		{
			int X = 2;
			if (X != 2)
			{
				return -2;
			}
		}
		return Outer;
	}

	/**
	 * Observe that empty sibling blocks leave the outer value untouched.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs an outer X of 9 and two empty sibling blocks
	 * @Return 9
	 * @Boundary empty sibling blocks
	 */
	UFUNCTION()
	int EmptySiblingBlocksDefault()
	{
		int X = 9;
		{
		}
		{
		}
		return X;
	}
}
