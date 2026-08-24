// Theme: Gameplay.Assets. C++ compiles both receiver classes then exercises
// valid vs missing callback names. CSV NegativeDiagnostic is the C++ guard path,
// not a compile-fail of these declarations.
// C++: AngelscriptAssetManagerFunctionLibraryTests.cpp::NullAndInvalidCallbackGuards
// Oracle: CallbackCount stays 0 until OnScanComplete; DifferentFunction is not
// the scan callback. Extra: default CallbackCount is 0. FixtureIsolated.

UCLASS()
class UAssetManagerValidScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	UFUNCTION()
	void OnScanComplete()
	{
		CallbackCount += 1;
	}
}

UCLASS()
class UAssetManagerMissingScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	UFUNCTION()
	void DifferentFunction()
	{
		CallbackCount += 1;
	}
}

bool Observe_ValidScan_DefaultZero(UAssetManagerValidScanReceiver Receiver)
{
	if (Receiver is null)
	{
		throw("Test_NullAndInvalidCallbackGuards setup: required Receiver is null");
	}
	return Receiver.CallbackCount == 0;
}

bool Observe_ValidScan_OnScanCompleteIncrements(UAssetManagerValidScanReceiver Receiver)
{
	if (Receiver is null)
	{
		throw("Test_NullAndInvalidCallbackGuards setup: required Receiver is null");
	}
	Receiver.OnScanComplete();
	return Receiver.CallbackCount == 1;
}

bool Observe_MissingScan_DefaultZero(UAssetManagerMissingScanReceiver Receiver)
{
	if (Receiver is null)
	{
		throw("Test_NullAndInvalidCallbackGuards setup: required Receiver is null");
	}
	return Receiver.CallbackCount == 0;
}

bool Observe_MissingScan_DifferentFunctionDirectCall(UAssetManagerMissingScanReceiver Receiver)
{
	if (Receiver is null)
	{
		throw("Test_NullAndInvalidCallbackGuards setup: required Receiver is null");
	}
	Receiver.DifferentFunction();
	return Receiver.CallbackCount == 1;
}
