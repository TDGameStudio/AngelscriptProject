/**
 * A UENUM declared without the E prefix. C++ originally expected the naming
 * convention to be enforced, but the live C++ wraps this in #if 0: the enum
 * compiles, so the CSV NegativeDiagnostic is not a compile-fail. The observers
 * read the enumerator's value directly and through a stored local.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UEnumWithoutPrefixNaming
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.UEnumWithoutPrefixNaming
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Negative block 4 is #if 0
 * @Provenance (naming-convention-unenforced); UENUM MyEnum compiles.
 * @Provenance CSV NegativeDiagnostic is not a compile-fail.
 * @Provenance sha256=63c0f233b26d169c7c1bd0a67ba2981d087daacd9347d002ff044ab8495a0ca2; lines 400-403.
 * @Provenance Oracle: MyEnum::Value1 is 0.
 * @Provenance Extra: default first enumerator is 0; a stored Value1 still converts to 0.
 * @Provenance DefaultSafe value oracle.
 */

UENUM()
enum MyEnum
{
	Value1
}

namespace SyntaxTest
{
	/**
	 * Observe the value of the unprefixed enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs MyEnum::Value1
	 * @Return 0
	 * @Boundary default first value
	 */
	UFUNCTION()
	int UnprefixedEnumFirstValueIsZero()
	{
		return int(MyEnum::Value1);
	}

	/**
	 * Observe the value held by a local of the unprefixed enum type.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local initialised to MyEnum::Value1
	 * @Return 0
	 */
	UFUNCTION()
	int UnprefixedEnumStoredValue()
	{
		MyEnum E = MyEnum::Value1;
		return int(E);
	}

	/**
	 * Observe that a stored default is not a non-zero value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local initialised to MyEnum::Value1
	 * @Return the value when non-zero, otherwise 0
	 * @Boundary non-zero check
	 */
	UFUNCTION()
	int UnprefixedEnumNonZeroBoundary()
	{
		MyEnum E = MyEnum::Value1;
		if (int(E) != 0)
		{
			return int(E);
		}
		return 0;
	}
}
