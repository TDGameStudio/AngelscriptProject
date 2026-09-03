/**
 * Preprocessor summary consumer fixture. C++ counts the import of the shared
 * module and ConsumerValue as the second UPROPERTY.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.SummaryConsumerFixture
 * @Harness UClass
 * @Tag Definitions.UStruct.SummaryConsumerFixture
 * @Provenance Theme: Definitions.UStruct. Positive preprocessor summary consumer fixture.
 * @Provenance C++: AngelscriptPreprocessorSummaryTests.cpp::SummaryReportsProcessedScriptStructure block 2
 * @Provenance import Tests.Preprocessor.Summary.Shared; ConsumerValue is the second counted UPROPERTY.
 * @Provenance Extra: ConsumerValue default 0; assigned boundary.
 * @Provenance Isolation=none. DefaultSafe.
 */

/**
 * Import the shared summary provider counted by the preprocessor summary.
 *
 * @Covers UStruct.SummaryConsumerFixture
 * @Inputs Tests.Preprocessor.Summary.Shared
 * @Return the imported module
 */
import Tests.Preprocessor.Summary.Shared;

UCLASS()
class USummaryConsumer : UObject
{
	UPROPERTY()
	int ConsumerValue;

	/**
	 * Observe the default ConsumerValue.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummaryConsumerFixture
	 * @Inputs this consumer
	 * @Return 0
	 * @Boundary default zero
	 */
	UFUNCTION()
	int SummaryConsumerDefaultZero()
	{
		return ConsumerValue;
	}

	/**
	 * Observe the assigned ConsumerValue boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.SummaryConsumerFixture
	 * @Inputs ConsumerValue set to 11
	 * @Return 11
	 * @Boundary assigned value
	 */
	UFUNCTION()
	int SummaryConsumerAssignedBoundary()
	{
		ConsumerValue = 11;
		return ConsumerValue;
	}
}
