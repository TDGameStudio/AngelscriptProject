/**
 * An enum with no enumerators. C++ originally expected this to be rejected, but
 * the live C++ wraps it in #if 0 because structural validation is absent: the
 * enum compiles. The observers confirm the default conversion is zero and that
 * two defaulted values compare equal.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EmptyEnumDeclaration
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EmptyEnumDeclaration
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 5 is #if 0
 * @Provenance (structural-validation-absent); enum EEnumEmpty { } compiles.
 * @Provenance CSV NegativeDiagnostic is not a compile-fail.
 * @Provenance sha256=eda456f841820e8f86c9ce143562d17e7435846d267bb4ed4505d2e1281750b5; lines 410-412.
 * @Provenance Oracle: EEnumEmpty is a usable type; default conversion is 0.
 * @Provenance Extra: empty default 0; two default values compare equal.
 * @Provenance DefaultSafe value oracle.
 */

enum EEnumEmpty
{
}

namespace SyntaxTest
{
	/**
	 * Observe the default conversion of an empty enum.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed EEnumEmpty
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int EmptyEnumDefaultsToZero()
	{
		EEnumEmpty Value;
		return int(Value);
	}

	/**
	 * Observe that two defaulted values compare equal.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two default-constructed EEnumEmpty values
	 * @Return 1 when they are equal, otherwise 0
	 * @Boundary default comparison
	 */
	UFUNCTION()
	int EmptyEnumTwoDefaultsMatch()
	{
		EEnumEmpty First;
		EEnumEmpty Second;
		if (First == Second)
		{
			return 1;
		}
		return 0;
	}
}
