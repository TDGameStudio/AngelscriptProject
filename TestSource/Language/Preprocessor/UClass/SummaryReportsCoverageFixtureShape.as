/**
 * A coverage fixture whose shape exercises one of each counted construct: one
 * enum, one UCLASS, one UFUNCTION and one UPROPERTY, so the preprocessor
 * summary reports one of each. The observers confirm the accessor round-trips
 * the property and that the two enum members are distinct.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.SummaryReportsCoverageFixtureShape
 * @Harness UClass
 * @Tag Language.Preprocessor.SummaryReportsCoverageFixtureShape
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::SummaryReportsCoverageFixtureShape
 * @Provenance lines 335-355;
 * @Provenance sha256=f34f43a90ead84079d3270a1b67ec10bcfd0a6649ebdd78913d3667254278520.
 * @Provenance Oracle: GetValue() returns Value. Default Value is 0. Assigned Value writes back.
 * @Provenance Extra: Idle vs Active are distinct enum members; default Value is empty/zero.
 * @Provenance DefaultSafe. Keep UPROPERTY name Value.
 */

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

	/**
	 * Reads back the property value.
	 *
	 * @Covers Preprocessor.Summary
	 * @Inputs the carrier's Value
	 * @Return the stored value
	 */
	UFUNCTION()
	int GetValue()
	{
		return Value;
	}

	/**
	 * Observe the default state of the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs a freshly constructed carrier
	 * @Return true when GetValue reports 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool CoverageFixtureValueDefaultsToZero()
	{
		return GetValue() == 0;
	}

	/**
	 * Observe that an assignment writes back through the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs Value assigned to 1, then the enum members compared
	 * @Return true when the accessor reports 1 and the members differ
	 * @Boundary assigned value
	 */
	UFUNCTION()
	bool CoverageFixtureValueWritesBack()
	{
		Value = 1;

		if (GetValue() != 1)
		{
			return false;
		}

		return ECoveragePreprocessorState::Idle != ECoveragePreprocessorState::Active;
	}
}
