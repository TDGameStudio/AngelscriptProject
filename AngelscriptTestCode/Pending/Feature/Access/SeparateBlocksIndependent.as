/**
 * @version v1
 * @summary The same name may be declared in separate sibling blocks. The first block's X and the second block's X do not collide, and an outer local stays at its default. Empty sibling blocks leave that outer default unchanged.
 * @topic Feature
 */
/**
 * @version root
 * @summary The same name may be declared in separate sibling blocks. The first block's X and the second block's X do not collide, and an outer local stays at its default. Empty sibling blocks leave that outer default unchanged.
 * @topic Baseline
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
/** @end */
