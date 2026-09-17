/**
 * @version v1
 * @summary FQuat default, Identity, and IsIdentity as Suite usage.
 * @topic TestFramework
 */
/**
 * @version root
 * @summary FQuat default, Identity, and IsIdentity as Suite usage.
 * @topic Baseline
 */
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UQuatIdentityScriptTests : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void DefaultMatchesIdentity()
	{
		AssertEquals(FQuat::Identity, FQuat());
		AssertEquals(FQuat(0, 0, 0, 1), FQuat::Identity);
		AssertTrue(FQuat::Identity.IsNormalized());
		AssertTrue(FQuat::Identity.IsIdentity());
	}
}
/** @end */
