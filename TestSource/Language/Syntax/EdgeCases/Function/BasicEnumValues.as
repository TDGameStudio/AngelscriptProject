/**
 * A basic enum whose enumerators are implicitly numbered from zero. The
 * observers read each enumerator's underlying value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.BasicEnumValues
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.BasicEnumValues
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 1 AssertCompiles.
 * @Provenance sha256=e1dba63617c30eb6b1864ec019a84662297a5bb9ba7f3c2342737a12822ef2f5; lines 337-339.
 * @Provenance Oracle: Value1 is 0, Value2 is 1, Value3 is 2.
 * @Provenance Extra: empty/default first enumerator is 0; Value3 is the last-index boundary.
 * @Provenance DefaultSafe. Source owns locals.
 */

enum EEnumBasic
{
	Value1,
	Value2,
	Value3
}

namespace SyntaxTest
{
	/**
	 * Observe the implicit value of the first enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumBasic::Value1
	 * @Return 0
	 * @Boundary default first value
	 */
	UFUNCTION()
	int BasicEnumFirstValueDefaultsToZero()
	{
		return int(EEnumBasic::Value1);
	}

	/**
	 * Observe the implicit value of the second enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumBasic::Value2
	 * @Return 1
	 */
	UFUNCTION()
	int BasicEnumSecondValue()
	{
		return int(EEnumBasic::Value2);
	}

	/**
	 * Observe the implicit value of the last enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumBasic::Value3
	 * @Return 2
	 * @Boundary last index
	 */
	UFUNCTION()
	int BasicEnumLastValueBoundary()
	{
		return int(EEnumBasic::Value3);
	}
}
