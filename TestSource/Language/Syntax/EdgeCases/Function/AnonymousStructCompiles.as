/**
 * An anonymous struct declaration. C++ originally expected it to fail, but the
 * live C++ wraps this in #if 0 because structural validation is absent: the
 * anonymous struct compiles. Since it has no type name, the observers exercise
 * the member's int type instead.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.AnonymousStructCompiles
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.AnonymousStructCompiles
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Negative block 1 is #if 0
 * @Provenance (structural-validation-absent); anonymous struct { int X; } compiles.
 * @Provenance CSV NegativeDiagnostic is not a compile-fail.
 * @Provenance sha256=11dcab82c6f96ea7431886e2e9c87565273bb066ec3829a1318999575c8eef6b; lines 277-279.
 * @Provenance Oracle: the unnamed struct compiles. It has no type name to construct.
 * @Provenance Extra: member type int empty default is 0; boundary write is 1.
 * @Provenance DefaultSafe value oracle.
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
