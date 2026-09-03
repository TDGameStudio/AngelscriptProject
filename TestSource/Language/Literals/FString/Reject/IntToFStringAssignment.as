/**
 * Initialising an FString from an integer literal is rejected: numbers do not
 * convert to text implicitly. This file is the illegal program itself; do not
 * quote the literal or use a formatting call, since the implicit conversion is
 * the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.IntToFStringAssignment
 * @Harness CompileReject
 * @Tag Language.Literals.IntToFStringAssignment
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FString S = 42;
 * @Return does not compile; diagnostic "cannot convert int to FString"
 */

void Test()
{
	FString S = 42;
}
