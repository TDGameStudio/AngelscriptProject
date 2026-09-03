/**
 * FQuat default, Identity, and IsIdentity as Suite usage.
 *
 * @Theme TestFramework.Usage.Math
 * @Subject FQuat.Construction
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Math.QuatIdentity
 * @Provenance TestSource/Math/FQuat/Function/QuatConstruction.as
 * @Provenance TestSource/Math/FQuat/Function/QuatInverseAndNormalize.as
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
