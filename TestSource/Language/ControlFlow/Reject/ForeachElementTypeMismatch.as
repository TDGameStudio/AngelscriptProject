/**
 * A range-for whose loop variable type does not match the container's element
 * type is rejected. This file is the illegal program itself.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachElementTypeMismatch
 * @Harness CompileReject
 * @Tag Language.ControlFlow.ForeachElementTypeMismatch
 * @Kind CompileReject
 * @Covers ControlFlow.Foreach
 * @Inputs for (FString Val : Arr) where Arr is a TArray<int>
 * @Return does not compile; diagnostic "cannot convert the element to the loop variable type"
 */

/** */
void Test()
{
	TArray<int> Arr;
	for (FString Val : Arr)
	{
	}
}
