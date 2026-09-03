/**
 * opEquals must return bool, so declaring it with an int return is rejected.
 * This file is the illegal program itself; do not change the return type, since
 * the wrong return type is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpEqualsNonBoolReturn
 * @Harness CompileReject
 * @Tag Language.Operators.OpEqualsNonBoolReturn
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opEquals with an int return
 * @Return does not compile; diagnostic "opEquals with non-bool return should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOEqualsWrongReturn; lines 243-250;
 * @Provenance sha256=288cbce18325cff21e40de475e21b0996b59a7c072bf9ecf8cdd61978f4b44d7.
 * @Provenance Expected diagnostic: opEquals with non-bool return should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FVecEqWrongRet
{
	int X = 0;

	/**
	 * Returns an int where opEquals owes a bool.
	 */
	int opEquals(const FVecEqWrongRet&in Other) const
	{
		return 0;
	}
}
