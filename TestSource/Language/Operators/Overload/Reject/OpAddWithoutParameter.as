/**
 * opAdd must take the right-hand operand, so declaring it with no parameter is
 * rejected. This file is the illegal program itself; do not add the parameter,
 * since the missing one is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpAddWithoutParameter
 * @Harness CompileReject
 * @Tag Language.Operators.OpAddWithoutParameter
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opAdd with an empty parameter list
 * @Return does not compile; diagnostic "opAdd without parameter should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOBadParams lines 296-303;
 * @Provenance sha256=9fc601346d79727e27c17b9655906019c61fdd2ce6d692f553f77e398e3f5954.
 * @Provenance Expected diagnostic: opAdd without parameter should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FVecBadParams
{
	int X = 0;

	/**
	 * Takes no operand, where a binary operator owes one.
	 */
	FVecBadParams opAdd() const
	{
		return FVecBadParams();
	}
}
