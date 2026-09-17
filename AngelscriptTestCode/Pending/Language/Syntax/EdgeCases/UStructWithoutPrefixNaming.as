/**
 * @version v1
 * @summary A USTRUCT declared without the F prefix. C++ originally expected the naming convention to be enforced, but the live C++ wraps this in #if 0: the struct compiles, so the CSV NegativeDiagnostic is not a compile-fail.
 * @topic Language
 */
/**
 * @version root
 * @summary A USTRUCT declared without the F prefix. C++ originally expected the naming convention to be enforced, but the live C++ wraps this in #if 0: the struct compiles, so the CSV NegativeDiagnostic is not a compile-fail.
 * @topic Baseline
 */
USTRUCT()
struct MyStruct
{
	/**
	 * The struct's single property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; a plain UPROPERTY named X
	 */
	UPROPERTY()
	int X;
}

namespace SyntaxTest
{
	/**
	 * Observe the property's default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed MyStruct
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int MyStructDefaultX()
	{
		MyStruct S;
		return S.X;
	}

	/**
	 * Observe the property's write boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a MyStruct whose X was set to 5
	 * @Return 5
	 * @Boundary written value
	 */
	UFUNCTION()
	int MyStructWriteBoundary()
	{
		MyStruct S;
		S.X = 5;
		return S.X;
	}

	/**
	 * Observe that a copy's write leaves the original untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copied MyStruct whose copy was zeroed
	 * @Return 3
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int MyStructCopyIndependentX()
	{
		MyStruct A;
		A.X = 3;
		MyStruct B = A;
		B.X = 0;
		return A.X;
	}
}
/** @end */
