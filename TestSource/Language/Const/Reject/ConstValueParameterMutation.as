/**
 * Assigning to a const value parameter is rejected: the parameter is const
 * for the whole body, so it cannot be used as a scratch variable. This file
 * is the illegal program itself; do not drop the const to make it compile.
 *
 * @Theme Language.Const
 * @Subject Const.ValueParameterMutation
 * @Harness CompileReject
 * @Tag Language.Const.ConstValueParameterMutation
 * @Kind CompileReject
 * @Covers Const.Immutability
 * @Inputs Declare void Test(const int Value), then assign Value = 2
 * @Return does not compile; diagnostic "cannot assign to a const parameter"
 * @Provenance C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
 * @Provenance sha256=7463a6b1118813055ad5949ca8524d13cdd4cc314eaa3c09662a3357219a265b; lines 245-250.
 * @Provenance Oracle: compile fails — modifying a const value parameter (Value = 2).
 */

void Test(const int Value)
{
	Value = 2;
}
