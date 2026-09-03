/**
 * Initialising an FString from nullptr is rejected: a string is a value type
 * and has no null state. This file is the illegal program itself; do not
 * substitute an empty string, since the nullptr is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.NullptrToFStringAssignment
 * @Harness CompileReject
 * @Tag Language.Literals.NullptrToFStringAssignment
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FString S = nullptr;
 * @Return does not compile; diagnostic "cannot convert nullptr to FString"
 */

void Test()
{
	FString S = nullptr;
}
