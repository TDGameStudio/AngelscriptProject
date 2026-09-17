/**
 * @version v1
 * @summary An anonymous struct declaration. C++ originally expected it to fail, but the live C++ wraps this in #if 0 because structural validation is absent: the anonymous struct compiles. Since it has no type name, the observers.
 * @topic Language
 */
/**
 * @version root
 * @summary An anonymous struct declaration. C++ originally expected it to fail, but the live C++ wraps this in #if 0 because structural validation is absent: the anonymous struct compiles. Since it has no type name, the observers.
 * @topic Baseline
 */
/**
 * The anonymous struct declaration itself.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared but unnamed struct type
 */
struct
{
	int X;
}

namespace SyntaxTest
{
	/**
	 * Observe the member type's empty default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a zero-initialized int
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int AnonymousMemberTypeEmptyDefault()
	{
		int X = 0;
		return X;
	}

	/**
	 * Observe the member type's write boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int assigned 1
	 * @Return 1
	 * @Boundary written value
	 */
	UFUNCTION()
	int AnonymousMemberTypeWriteBoundary()
	{
		int X = 1;
		return X;
	}
}
/** @end */
