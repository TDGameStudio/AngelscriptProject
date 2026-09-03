/**
 * Three overloads of a void function distinguished by parameter type and count.
 * The observers confirm each overload accepts its call shape and that pass-by-value
 * arguments are unchanged afterwards.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.VoidOverloadSet
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.VoidOverloadSet
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 4 AssertCompiles.
 * @Provenance sha256=374de961c9bf9c82a9dd25591747faac09ea456a596ca53b9c526e1c830297ba; lines 650-654.
 * @Provenance Oracle: int/float/two-arg overloads accept the call and leave pass-by-value args unchanged.
 * @Provenance Extra: zero args stay 0. DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * The int overload of Foo.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an int argument
	 * @Return nothing
	 * @Param X the ignored argument
	 */
	void Foo(int X)
	{
	}

	/**
	 * The float overload of Foo.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a float argument
	 * @Return nothing
	 * @Param X the ignored argument
	 */
	void Foo(float X)
	{
	}

	/**
	 * The two-int overload of Foo.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two int arguments
	 * @Return nothing
	 * @Param X the first ignored argument
	 * @Param Y the second ignored argument
	 */
	void Foo(int X, int Y)
	{
	}

	/**
	 * Observe that the int overload leaves its argument unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an eleven-valued int local
	 * @Return 11
	 */
	UFUNCTION()
	int VoidOverloadIntUnchanged()
	{
		int X = 11;
		Foo(X);
		return X;
	}

	/**
	 * Observe that the float overload leaves its argument unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a 1.5-valued float local
	 * @Return 1, the truncated unchanged value
	 */
	UFUNCTION()
	int VoidOverloadFloatUnchanged()
	{
		float X = 1.5f;
		Foo(X);
		return int(X);
	}

	/**
	 * Observe that the two-int overload leaves its arguments unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two zero-valued int locals
	 * @Return 0
	 * @Boundary zero arguments
	 */
	UFUNCTION()
	int VoidOverloadTwoArgZeros()
	{
		int X = 0;
		int Y = 0;
		Foo(X, Y);
		return X + Y;
	}
}
