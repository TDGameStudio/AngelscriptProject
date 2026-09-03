/**
 * opCmp must return int, so declaring it with a float return is rejected. This
 * file is the illegal program itself; do not change the return type, since the
 * wrong return type is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpCmpNonIntReturn
 * @Harness CompileReject
 * @Tag Language.Operators.OpCmpNonIntReturn
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opCmp with a float return
 * @Return does not compile; diagnostic "opCmp with non-int return should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOCmpWrongReturn; lines 257-264;
 * @Provenance sha256=a2af84b572dbcbc945cc4b75137ff5f71badc4a75fe2ce33530b2d19e821ea21.
 * @Provenance Expected diagnostic: opCmp with non-int return should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FValCmpWrongRet
{
	int Value = 0;

	/**
	 * Returns a float where opCmp owes an int.
	 */
	float opCmp(const FValCmpWrongRet&in Other) const
	{
		return 0.0f;
	}
}
