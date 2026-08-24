// Theme: Language.Preprocessor. Positive: one enum, one UCLASS, one UFUNCTION,
// one UPROPERTY so the preprocessor summary counts each as 1.
// C++: AngelscriptCoveragePreprocessorTests.cpp::SummaryReportsCoverageFixtureShape
// lines 335-355;
// sha256=f34f43a90ead84079d3270a1b67ec10bcfd0a6649ebdd78913d3667254278520.
// Oracle: GetValue() returns Value. Default Value is 0. Assigned Value writes back.
// Extra: Idle vs Active are distinct enum members; default Value is empty/zero.
// DefaultSafe. Keep UPROPERTY name Value.

UENUM()
enum ECoveragePreprocessorState
{
	Idle,
	Active
}

UCLASS()
class UCoveragePreprocessorSummaryCarrier : UObject
{
	UPROPERTY()
	int Value;

	UFUNCTION()
	int GetValue()
	{
		return Value;
	}
}

bool Observe_GetValue_DefaultZero(UCoveragePreprocessorSummaryCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_SummaryReportsCoverageFixtureShape setup: required Carrier is null");
	}
	return Carrier.GetValue() == 0;
}

bool Observe_GetValue_AssignedBoundary(UCoveragePreprocessorSummaryCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_SummaryReportsCoverageFixtureShape setup: required Carrier is null");
	}
	Carrier.Value = 1;
	return Carrier.GetValue() == 1
		&& ECoveragePreprocessorState::Idle != ECoveragePreprocessorState::Active;
}
