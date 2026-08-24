// Framework contract: CreateTestWorld(true) installs GameInstance subsystem
// context. A second creation fails without replacing or leaking the first
// World. Terminal cleanup releases it when the leaf does not destroy it.
// Payload: one GameInstance World plus an immediate duplicate create is
// enough; no explicit DestroyTestWorld is used.
// Expected observations: GameInstance is non-null after the first create;
// the second create fails; no World remains for the next fresh leaf.
// C++ oracle required: duplicate-create diagnostic, first World identity
// preserved until cleanup, and automatic release.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceGameInstanceWorldCleanupSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyGameInstanceWorldCleanup()
	{
		FAngelscriptTest::CreateTestWorld(true);
		UWorld FirstWorld = FAngelscriptTest::GetTestWorld();
		AssertNotNull(FirstWorld, "TS-FW-WORLD-003 missing GameInstance World");
		AssertNotNull(
			FirstWorld.GetGameInstance(),
			"TS-FW-WORLD-003 missing GameInstance");
		AssertSame(FirstWorld, GetWorld(), "TS-FW-WORLD-003 suite World mismatch");
		FAngelscriptTest::CreateTestWorld(true);
		Fail("TS-FW-WORLD-003 duplicate create did not fail");
	}
}
