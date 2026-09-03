/**
 * FRotator construction and add as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FRotator.Construction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.RotatorConstructionAndAdd
 * @Provenance TestSource/Math/FRotator/Function/RotatorConstruction.as
 * @Provenance TestSource/Math/FRotator/Function/RotatorArithmeticOperators.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class URotatorConstructionAndAddScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultThreeParamAndZeroConstant()
	{
		AssertEquals(FRotator::ZeroRotator, FRotator());
		AssertEquals(FRotator(10, 20, 30), FRotator(10, 20, 30));
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddTwoRotators()
	{
		AssertEquals(
			FRotator(15, 30, 45),
			FRotator(10, 20, 30) + FRotator(5, 10, 15));
	}
}
