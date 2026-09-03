/**
 * Assigning a string literal to an FString stores the literal's text. The
 * assignment copies by value, so a default FString is empty and mutating the
 * source afterwards leaves the copy at the original literal.
 *
 * @Theme Language.Literals
 * @Subject Literals.StringLiteralAssignment
 * @Harness Function
 * @Tag Language.Literals.StringLiteralAssignment
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 1 AssertCompiles.
 * @Provenance sha256=f0a5aaca3d715b9e04209b7411bc665a56434e7652e4ae70a7032bdebce360aa; lines 50-52.
 * @Provenance Oracle: Test() assigns "Hello World"; Observe compares that literal.
 * @Provenance Extra: default FString is empty; assignment copies, later source mutation does not alias.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that a literal assignment reads back the literal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString S = "Hello World"
	 * @Return true when S equals "Hello World"
	 */
	UFUNCTION()
	bool LiteralAssignmentNominal()
	{
		FString S = "Hello World";
		return S == "Hello World";
	}

	/**
	 * Observe the default empty boundary of an unassigned FString.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A default-constructed FString
	 * @Return true when its length is 0
	 * @Boundary default empty string
	 */
	UFUNCTION()
	bool LiteralEmptyDefault()
	{
		FString Empty;
		return Empty.Len() == 0;
	}

	/**
	 * Observe that assignment copies by value rather than by alias.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of a literal, then the source changed
	 * @Return true when the copy keeps the original literal
	 */
	UFUNCTION()
	bool LiteralCopyIndependence()
	{
		FString S = "Hello World";
		FString Copy = S;
		S = "changed";
		return Copy == "Hello World";
	}
}
