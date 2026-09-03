/**
 * An f-string that interpolates a single integer variable. The rewrite happens
 * at the point of initialization, so changing the variable afterwards does not
 * rewrite the already-built string.
 *
 * @Theme Language.Literals
 * @Subject Literals.FStringInterpolatesInt
 * @Harness Function
 * @Tag Language.Literals.FStringInterpolatesInt
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 5 AssertCompiles.
 * @Provenance sha256=465275f929bf1ee2a10e7e71430c7a97aaab242adde5bcbe42cf2a880a9b7cba; lines 88-90.
 * @Provenance Oracle: f"Value is {42}" == "Value is 42".
 * @Provenance Extra: X = 0 interpolates "Value is 0"; changing X after interpolation does not rewrite S.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that an integer interpolates into the f-string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 42 interpolated into f"Value is {X}"
	 * @Return true when the result is "Value is 42"
	 */
	UFUNCTION()
	bool FStringIntNominal()
	{
		int X = 42;
		FString S = f"Value is {X}";
		return S == "Value is 42";
	}

	/**
	 * Observe the zero boundary of integer interpolation.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 0 interpolated into f"Value is {X}"
	 * @Return true when the result is "Value is 0"
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool FStringIntZeroBoundary()
	{
		int X = 0;
		FString S = f"Value is {X}";
		return S == "Value is 0";
	}

	/**
	 * Observe that mutating the source variable does not rewrite the string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs X = 42 interpolated, then X set to 0
	 * @Return true when the string keeps "Value is 42"
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FStringIntCopyIndependence()
	{
		int X = 42;
		FString S = f"Value is {X}";
		X = 0;
		return S == "Value is 42";
	}
}
