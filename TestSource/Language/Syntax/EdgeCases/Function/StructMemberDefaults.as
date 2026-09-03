/**
 * A struct whose members carry initializers: an int set to 42 and a string set to
 * "Default". The observers confirm the defaults, the empty-string boundary, and
 * copy independence.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructMemberDefaults
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.StructMemberDefaults
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 4 AssertCompiles.
 * @Provenance sha256=588d61b5c2fce1cec0b488de062c1e7a1fac96a53379b7efd0962edbe898ad50; lines 244-250.
 * @Provenance Oracle: X is 42; Name is "Default".
 * @Provenance Extra: empty Name is Len 0; copy then rename leaves the original Name.
 * @Provenance DefaultSafe. Source owns locals.
 */

/**
 * The struct under test with two initialized members.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared struct with initialized members
 */
struct FStructDefaults
{
	int X = 42;
	FString Name = "Default";
}

namespace SyntaxTest
{
	/**
	 * Observe the int member's initializer.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 42
	 * @Boundary default value
	 */
	UFUNCTION()
	int StructDefaultsDefaultX()
	{
		FStructDefaults S;
		return S.X;
	}

	/**
	 * Observe the string member's initializer.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return "Default"
	 * @Boundary default value
	 */
	UFUNCTION()
	FString StructDefaultsDefaultName()
	{
		FStructDefaults S;
		return S.Name;
	}

	/**
	 * Observe the empty-string boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a struct whose Name was cleared
	 * @Return 0
	 * @Boundary empty string
	 */
	UFUNCTION()
	int StructDefaultsEmptyNameLen()
	{
		FStructDefaults S;
		S.Name = "";
		return S.Name.Len();
	}

	/**
	 * Observe that renaming a copy leaves the original untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied struct whose copy was renamed
	 * @Return "Default"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	FString StructDefaultsCopyIndependentName()
	{
		FStructDefaults A;
		FStructDefaults B = A;
		B.Name = "Other";
		return A.Name;
	}
}
