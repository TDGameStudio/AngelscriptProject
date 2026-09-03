/**
 * Assigning a value of the wrong element type onto TOptional<int> is
 * rejected. The implicit value constructor and opAssign both require the
 * element type, so there is no implicit conversion from FString to int.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.WrongElementType
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalAssignWrongElementType
 * @Kind CompileReject
 * @Covers TOptional.opAssign
 * @Inputs TOptional<int> Opt; Opt = "hello"
 * @Return does not compile
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional<int> Opt;
		Opt = "hello";
	}
}
