/**
 * A basic script struct with an int and a float member, both defaulting through
 * their type's zero values.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BasicScriptStruct
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BasicScriptStruct
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 1 AssertCompiles.
 * @Provenance sha256=20f262e2090840fd77ba98bde44e42856da835783d7c455035aca11045709505; lines 217-219.
 * @Provenance Oracle: FStructBasic default X is 0 and Y is 0.0f.
 * @Provenance Extra: empty defaults; copy assignment is independent after a write.
 * @Provenance DefaultSafe. Source owns locals.
 */

/**
 * The struct under test with its two members.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared struct with zero-defaulted members
 */
struct FStructBasic
{
	int X;
	float Y;
}

namespace SyntaxTest
{
	/**
	 * Observe the int member's default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int BasicStructDefaultX()
	{
		FStructBasic S;
		return S.X;
	}

	/**
	 * Observe the float member's default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0.0
	 * @Boundary default value
	 */
	UFUNCTION()
	float BasicStructDefaultY()
	{
		FStructBasic S;
		return S.Y;
	}

	/**
	 * Observe that a copy's write leaves the original untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied struct whose copy was written
	 * @Return 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int BasicStructCopyIndependentX()
	{
		FStructBasic A;
		A.X = 1;
		FStructBasic B = A;
		B.X = 2;
		return A.X;
	}
}
