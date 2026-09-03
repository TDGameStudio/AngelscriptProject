/**
 * Comparing an FString against an integer is rejected: the two sides have no
 * common comparison. This file is the illegal program itself; do not convert
 * either side, since the unsupported comparison is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.FStringComparedToInt
 * @Harness CompileReject
 * @Tag Language.Literals.FStringComparedToInt
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs S == 5 where S is an FString
 * @Return does not compile; diagnostic "cannot compare FString with int"
 */

/** */
void Test()
{
	FString S = "5";
	bool B = (S == 5);
}
