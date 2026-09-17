/**
 * @version v1
 * @summary FTransform Identity, GetLocation, and TransformPosition as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary FTransform Identity, GetLocation, and TransformPosition as Suite usage.
 * @topic Baseline
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
/** @end */
