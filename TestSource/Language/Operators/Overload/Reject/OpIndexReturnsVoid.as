/**
 * opIndex must yield the indexed element, so declaring it void is rejected.
 * This file is the illegal program itself; do not give it a return type, since
 * the void return is the point.
 *
 * @Theme Language.Operators
 * @Subject Operators.OpIndexReturnsVoid
 * @Harness CompileReject
 * @Tag Language.Operators.OpIndexReturnsVoid
 * @Kind CompileReject
 * @Covers Operators.Overload
 * @Inputs A struct declaring opIndex with a void return
 * @Return does not compile; diagnostic "opIndex returning void should fail"
 * @Provenance C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOIndexBadReturn; lines 336-343;
 * @Provenance sha256=9b58ce1729c5ed6060a3d244bb27644c7f32d600a32ae7ec16dfadb618f33585.
 * @Provenance Expected diagnostic: opIndex returning void should fail.
 * @Provenance C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

struct FContainerBadRet
{
	TArray<int> Data;

	/**
	 * Returns nothing where an index operator owes the element.
	 */
	void opIndex(int Index) const
	{
	}
}
