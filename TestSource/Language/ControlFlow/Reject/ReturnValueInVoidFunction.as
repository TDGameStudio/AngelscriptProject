/**
 * Returning a value from a void function is rejected: a void function has
 * nothing to return. This file is the illegal program itself; do not change
 * the declared type or drop the value, since the mismatch is the point.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ReturnValueInVoidFunction
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ReturnValueInVoidFunction
 * @Kind CompileReject
 * @Covers ControlFlow.Return
 * @Inputs void Test() { return 5; }
 * @Return does not compile; diagnostic "return value in a void function"
 * @Provenance C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
 * @Provenance sha256=a560b3f756658b96a351ca1862a7ceda4c3a9d6c28f2a3d2e949d69b2ea64e80; lines 560-562.
 * @Provenance Oracle: compile fails — return value in a void function.
 * @Provenance CSV SourceShape is Positive; C++ AssertFailsToCompile is the TrailingOracle.
 */

/** */
void Test()
{
	return 5;
}
