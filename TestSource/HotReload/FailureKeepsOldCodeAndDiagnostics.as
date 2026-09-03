/**
 * Failed soft reload must keep last-good code. Root GetValue returns 5;
 * broken-type does not compile; live result stays 5.
 *
 * @Theme HotReload
 * @Subject HotReload.FunctionBody
 * @Harness SourceHistory
 * @Tag HotReload.FunctionBody.FailureKeepsOldCodeAndDiagnostics
 * @Module HotReloadFailureKeepsOldCode.as
 * @Identity UHotReloadFailureKeepsOldCode
 * @Provenance C++: AngelscriptHotReloadFunctionTests.cpp::FailureKeepsOldCodeAndDiagnostics
 */

UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 5;
	}
}


/*
@version root
@compile Initial
@expect compile-ok

@version broken-type
@parent root
@compile SoftReloadOnly
@expect compile-fail "MissingType"
@retain UClass, GetValue
@oracle execute UHotReloadFailureKeepsOldCode.GetValue == 5
@change
UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
@end
*/
