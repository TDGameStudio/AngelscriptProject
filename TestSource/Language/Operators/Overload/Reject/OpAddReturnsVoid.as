/**
 * opAdd must return the combined value, so declaring it void is rejected. This
 * file is the illegal program itself; do not give it a return type, since the
 * void return is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpAddReturnsVoid
 * @Harness CompileReject
 * @Tag Language.Operators.OpAddReturnsVoid
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opAdd with a void return
 * @Return does not compile; diagnostic "opAdd returning void should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOAddVoid lines 310-317;
 * @Provenance sha256=ccc60c65ff957b82613f71bed6f53157dae5a1aaa4addd342fb94f021c8c33b7.
 * @Provenance Expected diagnostic: opAdd returning void should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FVecAddVoid
{
	int X = 0;

	/**
	 * Returns nothing where a binary operator owes a result.
	 */
	void opAdd(const FVecAddVoid&in Other) const
	{
	}
}
