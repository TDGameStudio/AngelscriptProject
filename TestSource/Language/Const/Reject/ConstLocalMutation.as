/**
 * Assigning to a const local is rejected: a const binding cannot be written
 * through, even from the scope that declared it. This file is the illegal
 * program itself; do not drop the const to make it compile.
 *
 * @Theme Language.Const
 * @Subject Const.LocalMutation
 * @Harness CompileReject
 * @Tag Language.Const.ConstLocalMutation
 * @Kind CompileReject
 * @Covers Const.Immutability
 * @Inputs Declare const int Value = 1, then assign Value = 2
 * @Return does not compile; diagnostic "cannot assign to a const local"
 * @Provenance C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
 * @Provenance sha256=0f7f163de22f2128aa06ec0502a91ceae5ab3dd299dea15b9bc9e1a9c3435f80; lines 231-237.
 * @Provenance Oracle: compile fails — modifying a const local (Value = 2).
 */

void Test()
{
	const int Value = 1;
	Value = 2;
}
