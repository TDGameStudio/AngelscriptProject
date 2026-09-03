/**
 * FTransform Identity, GetLocation, and TransformPosition as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FTransform.GeometricConstruction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.TransformLocation
 * @Provenance TestSource/Math/FTransform/Function/FTransformConstruction.as
 * @Provenance TestSource/Math/FTransform/Function/TransformPositionAndVector.as
 */

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTransformLocationScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void IdentityAndTranslatedPoint()
	{
		AssertTrue(FTransform().Equals(FTransform::Identity));
		FTransform Translated = FTransform(FVector(100, 0, 0));
		AssertEquals(FVector(100, 0, 0), Translated.GetLocation());
		AssertEquals(FVector(110, 0, 0), Translated.TransformPosition(FVector(10, 0, 0)));
	}
}
