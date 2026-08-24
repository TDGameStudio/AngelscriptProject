// Theme: Definitions.UStruct. Positive preprocessor summary shared fixture.
// C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryReportsProcessedScriptStructure block 1
// Summary: 2 files, 2 modules, 1 import, 2 classes, 1 function, 2 properties, 1 enum, 1 delegate.
// Oracle: GetAmount()==3.0. Extra: SharedValue default 0; Idle vs Active distinct.
// DefaultSafe.

UENUM()
enum ESummaryState
{
	Idle,
	Active
}

delegate float FSummaryDelegate();

UCLASS()
class USummaryShared : UObject
{
	UFUNCTION()
	float GetAmount()
	{
		return 3.0;
	}

	UPROPERTY()
	int SharedValue;
}

float Observe_SummaryShared_GetAmountNominal(USummaryShared Shared)
{
	if (Shared is null)
	{
		throw("Test_SummaryReportsProcessedScriptStructure_01 setup: required Shared is null");
	}
	return Shared.GetAmount();
}

int Observe_SummaryShared_DefaultZero(USummaryShared Shared)
{
	if (Shared is null)
	{
		throw("Test_SummaryReportsProcessedScriptStructure_01 setup: required Shared is null");
	}
	return Shared.SharedValue;
}

bool Observe_SummaryState_IdleActiveBoundary()
{
	return ESummaryState::Idle != ESummaryState::Active;
}
