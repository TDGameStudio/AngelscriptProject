/**
 * A reference parameter that writes a constant back to the caller. The observers
 * confirm the write from zero and from a negative start, and that an untouched
 * sibling local keeps its value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ReferenceWriteParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ReferenceWriteParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Function_Positive block 5 AssertCompiles.
 * @Provenance sha256=7b2032d0df047f100e99da183d448e4bf35d37c72143b1a2093d423ba6e25e02; lines 658-660.
 * @Provenance Oracle: Foo(Out) sets Out to 42. Extra: start 0 and start -1 both become 42;
 * @Provenance a second local stays 7. DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Writes 42 through an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's local receives 42
	 * @Param Out the out parameter
	 */
	void Foo(int&out Out)
	{
		Out = 42;
	}

	/**
	 * Observe the write from a zero start.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a zero-valued local written through the reference
	 * @Return 42
	 */
	UFUNCTION()
	int ReferenceWriteNominalFromZero()
	{
		int Out = 0;
		Foo(Out);
		return Out;
	}

	/**
	 * Observe that the write overwrites a negative start.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a -1 local written through the reference
	 * @Return 42
	 * @Boundary negative start
	 */
	UFUNCTION()
	int ReferenceWriteOverwriteBoundary()
	{
		int Out = -1;
		Foo(Out);
		return Out;
	}

	/**
	 * Observe that a sibling local is untouched by the write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs one local written and one left alone
	 * @Return true when the written local is 42 and the sibling is 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReferenceWriteCopyIndependence()
	{
		int Written = 0;
		int Untouched = 7;
		Foo(Written);

		if (Written != 42)
		{
			return false;
		}

		return Untouched == 7;
	}
}
