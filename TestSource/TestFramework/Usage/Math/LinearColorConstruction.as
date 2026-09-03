/**
 * FLinearColor constructors and named constants as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FLinearColor.Construction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.LinearColorConstruction
 * @Provenance TestSource/Math/FLinearColor/Function/LinearColorConstruction.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class ULinearColorConstructionScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultIsBlackOpaque()
	{
		FLinearColor DefaultColor = FLinearColor();
		AssertEquals(0.0, DefaultColor.R);
		AssertEquals(0.0, DefaultColor.G);
		AssertEquals(0.0, DefaultColor.B);
		AssertEquals(1.0, DefaultColor.A);
	}

	UFUNCTION(meta=(AngelscriptTest))
	void FourParamAndWhite()
	{
		FLinearColor Four = FLinearColor(0.5, 0.6, 0.7, 0.8);
		AssertEquals(0.5, Four.R);
		AssertEquals(0.6, Four.G);
		AssertEquals(0.7, Four.B);
		AssertEquals(0.8, Four.A);
		AssertEquals(1.0, FLinearColor::White.R);
		AssertEquals(1.0, FLinearColor::White.G);
		AssertEquals(1.0, FLinearColor::White.B);
		AssertEquals(1.0, FLinearColor::White.A);
	}
}
