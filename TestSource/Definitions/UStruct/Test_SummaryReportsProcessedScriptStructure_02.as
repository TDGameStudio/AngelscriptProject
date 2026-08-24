// Theme: Definitions.UStruct. Positive preprocessor summary consumer fixture.
// C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryReportsProcessedScriptStructure block 2
// import Tests.Preprocessor.Summary.Shared; ConsumerValue is the second counted UPROPERTY.
// Extra: ConsumerValue default 0; assigned boundary.
// Isolation=none. DefaultSafe.

import Tests.Preprocessor.Summary.Shared;

UCLASS()
class USummaryConsumer : UObject
{
	UPROPERTY()
	int ConsumerValue;
}

int Observe_SummaryConsumer_DefaultZero(USummaryConsumer Consumer)
{
	if (Consumer is null)
	{
		throw("Test_SummaryReportsProcessedScriptStructure_02 setup: required Consumer is null");
	}
	return Consumer.ConsumerValue;
}

int Observe_SummaryConsumer_AssignedBoundary(USummaryConsumer Consumer)
{
	if (Consumer is null)
	{
		throw("Test_SummaryReportsProcessedScriptStructure_02 setup: required Consumer is null");
	}
	Consumer.ConsumerValue = 11;
	return Consumer.ConsumerValue;
}
