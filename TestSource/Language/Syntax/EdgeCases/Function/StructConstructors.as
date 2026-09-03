/**
 * A struct with two constructors: a default one zeroing the member and a
 * parameterized one storing its argument.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StructConstructors
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.StructConstructors
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 5 AssertCompiles.
 * @Provenance sha256=a7c2f9d42ee32a2bd3c0c864420bcaeb39a26b5e547d49161914c831bed91e4d; lines 254-261.
 * @Provenance Oracle: FStructCtor() sets X to 0; FStructCtor(InX) stores InX.
 * @Provenance Extra: empty ctor is 0; InX=7 boundary; copy then write leaves original X.
 * @Provenance DefaultSafe. Source owns locals.
 */

/**
 * The struct with its two constructors.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared struct with default and parameterized construction
 */
struct FStructCtor
{
	int X;

	/**
	 * The default constructor zeroing the member.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return a new FStructCtor with X set to 0
	 */
	FStructCtor()
	{
		X = 0;
	}

	/**
	 * The parameterized constructor storing its argument.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the initial X value
	 * @Return a new FStructCtor with X set to InX
	 * @Param InX the value to store
	 */
	FStructCtor(int InX)
	{
		X = InX;
	}
}

namespace SyntaxTest
{
	/**
	 * Observe the default constructor's zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed struct
	 * @Return 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	int StructCtorDefaultZero()
	{
		FStructCtor S;
		return S.X;
	}

	/**
	 * Observe the parameterized constructor's boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a struct constructed with 7
	 * @Return 7
	 * @Boundary argument value
	 */
	UFUNCTION()
	int StructCtorInXBoundary()
	{
		FStructCtor S(7);
		return S.X;
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
	int StructCtorCopyIndependentX()
	{
		FStructCtor A(1);
		FStructCtor B = A;
		B.X = 2;
		return A.X;
	}
}
