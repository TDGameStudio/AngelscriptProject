/**
 * Mutating a member from a const method is rejected: a const method promises
 * not to change the object it is called on. This file is the illegal program
 * itself; do not drop the const to make it compile.
 *
 * @Theme Language.Const
 * @Subject Const.MethodMemberMutation
 * @Harness CompileReject
 * @Tag Language.Const.ConstMethodMemberMutation
 * @Kind CompileReject
 * @Covers Const.Immutability
 * @Inputs A class with int Value and a method marked const that assigns Value = 2
 * @Return does not compile; diagnostic "cannot modify a member from a const method"
 * @Provenance C++: AngelscriptCoverageConstTests.cpp::ConstViolationNegativeCompile
 * @Provenance sha256=6d38acd5f6855d5867e23f4ff3ae382c5c9aa076bb1cc88ada2a70bfb427f0f7; lines 258-268.
 * @Provenance Oracle: compile fails — mutating a member from a const method.
 */

class ConstMutationProbe
{
	int Value = 0;

/** */
	void Mutate() const
	{
		Value = 2;
	}
}
