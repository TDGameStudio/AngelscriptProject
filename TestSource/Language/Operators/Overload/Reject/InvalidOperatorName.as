/**
 * An operator overload whose name is not a recognised operator is rejected.
 * This file is the illegal program itself; do not rename opInvalid to a real
 * operator, since the invalid name is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.InvalidOperatorName
 * @Harness CompileReject
 * @Tag Language.Operators.InvalidOperatorName
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opInvalid, which is not a known operator
 * @Return does not compile; diagnostic "invalid operator overload name should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOInvalid lines 226-236;
 * @Provenance sha256=6277dcaf72cae7822421d31bb3243b52c638a45cf2e38fd51bee2ebbb67fa148.
 * @Provenance Expected diagnostic: invalid operator overload name should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FVecInvalid
{
	int X = 0;

	/**
	 * Not a recognised operator name, which is what the case is about.
	 */
	FVecInvalid opInvalid(const FVecInvalid&in Other) const
	{
		return FVecInvalid();
	}
}
