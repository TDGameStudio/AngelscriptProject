/**
 * A function with two defaulted parameters, one of which is unused. The observers
 * confirm the defaults apply when omitted and that explicit values override them.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultParameterFunction
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.DefaultParameterFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 3 AssertCompiles.
 * @Provenance sha256=e94e86f47db5d0113e6fe8b3649442dbb8c29947c572e9efe92977008a8370b8; lines 644-646.
 * @Provenance Oracle: Foo() returns default X=5. Extra: Foo(0) == 0; Foo(9, 0.0f) == 9.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Returns the first parameter, both of which carry defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an optional int defaulting to 5 and an unused optional float
	 * @Return the value of X
	 * @Param X the returned optional parameter
	 * @Param Y an unused optional parameter
	 */
	int Foo(int X = 5, float Y = 1.0f)
	{
		return X;
	}

	/**
	 * Observe that both defaults apply when omitted.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo()
	 * @Return 5
	 */
	UFUNCTION()
	int DefaultParameterUsesDefaultX()
	{
		return Foo();
	}

	/**
	 * Observe that an explicit zero overrides the default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo(0)
	 * @Return 0
	 * @Boundary zero override
	 */
	UFUNCTION()
	int DefaultParameterZeroBoundary()
	{
		return Foo(0);
	}

	/**
	 * Observe that both arguments can be supplied explicitly.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo(9, 0.0f)
	 * @Return 9
	 * @Boundary explicit both
	 */
	UFUNCTION()
	int DefaultParameterExplicitBoth()
	{
		return Foo(9, 0.0f);
	}
}
