/**
 * An empty void function. The observers confirm the call completes and that
 * neither a first nor repeated call touches the caller's locals.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EmptyVoidFunction
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EmptyVoidFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 1 AssertCompiles.
 * @Provenance sha256=e7d8a630f999398380cd257c2aa6418ec4794cd74da97cabe24d0b970f8080fe; lines 632-634.
 * @Provenance Oracle: Foo() completes; it does not write the caller local.
 * @Provenance Extra: empty body leaves 0; repeat calls leave a non-zero local unchanged.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * A function whose body is empty.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo()
	{
	}

	/**
	 * Observe that the empty body leaves the caller's local untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a zero-valued local and one call
	 * @Return 0
	 */
	UFUNCTION()
	int EmptyVoidFunctionLeavesZero()
	{
		int Result = 0;
		Foo();
		return Result;
	}

	/**
	 * Observe that repeated calls leave a non-zero local unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a seven-valued local and two calls
	 * @Return 7
	 * @Boundary repeat calls
	 */
	UFUNCTION()
	int EmptyVoidFunctionRepeatLeavesLocal()
	{
		int Result = 7;
		Foo();
		Foo();
		return Result;
	}
}
