/**
 * An f-string that interpolates an int and a float in the same literal. The
 * float formatting is locale-dependent in width, so the observers assert only
 * the integer prefix rather than the full rendered text.
 *
 * @Theme Language.Literals
 * @Subject Literals.FStringInterpolatesMultipleTypes
 * @Harness Function
 * @Tag Language.Literals.FStringInterpolatesMultipleTypes
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 7 AssertCompiles.
 * @Provenance sha256=b52c4e5ed6623ddc07a2696fd52955c5458efad242e2f52e69e10b117fb52ca4; lines 102-104.
 * @Provenance Oracle: f"{1} and {2.5f}" starts with "1 and ".
 * @Provenance Extra: A = 0, B = 0.0f interpolates zeros; mutating A/B after interpolation does not rewrite S.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that both an int and a float interpolate into one literal.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A = 1 and B = 2.5f interpolated as f"{A} and {B}"
	 * @Return true when the result starts with "1 and "
	 */
	UFUNCTION()
	bool FStringMultipleNominal()
	{
		int A = 1;
		float B = 2.5f;
		FString S = f"{A} and {B}";
		return S.StartsWith("1 and ");
	}

	/**
	 * Observe the zero boundary for both interpolated values.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A = 0 and B = 0.0f interpolated as f"{A} and {B}"
	 * @Return true when the result starts with "0 and "
	 * @Boundary zero values
	 */
	UFUNCTION()
	bool FStringMultipleZeroBoundary()
	{
		int A = 0;
		float B = 0.0f;
		FString S = f"{A} and {B}";
		return S.StartsWith("0 and ");
	}

	/**
	 * Observe that mutating both sources does not rewrite the string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A = 1 and B = 2.5f interpolated, then both set to 0
	 * @Return true when the string keeps the "1 and " prefix
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FStringMultipleCopyIndependence()
	{
		int A = 1;
		float B = 2.5f;
		FString S = f"{A} and {B}";
		A = 0;
		B = 0.0f;
		return S.StartsWith("1 and ");
	}
}
