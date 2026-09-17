/**
 * @version v1
 * @summary TestFramework Discovery Test_RegistryGenerationRebuild
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Discovery Test_RegistryGenerationRebuild
 * @topic Baseline
 */
// Framework contract: each registry rebuild publishes one immutable
// generation. Generation numbers advance. An empty eligible rebuild must
// not mutate or leak a retained prior snapshot.
// Version pair: this stored source is generation A with body marker
// TS-FW-DISCOVERY-004-GEN-A. The future HotReload runner applies a later
// generation B that changes only the body marker, then an empty eligible
// generation with no published leaves.
// Payload: the current marker string is enough for the oracle to identify
// which stored body is loaded; arithmetic is incidental.
// Expected observations: generation A is uniquely identifiable; later
// rebuilds advance the number; empty discovery leaves generation A intact.
// C++ oracle required: generation monotonicity, snapshot immutability, and
// empty-generation emptiness. This file cannot observe those itself.

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceRegistryGenerationRebuildSuite : UAngelscriptTestSuite
{
	FString BodyMarker = "TS-FW-DISCOVERY-004-GEN-A";

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyRegistryGenerationRebuild()
	{
		AssertEquals(
			"TS-FW-DISCOVERY-004-GEN-A",
			BodyMarker,
			"TS-FW-DISCOVERY-004 generation A body marker");
	}
}

// Generation B replacement (not compiled here; applied by the HotReload
// runner onto the same logical module path):
// BodyMarker = "TS-FW-DISCOVERY-004-GEN-B";
// Empty eligible generation: no concrete marked suites remain, and the
// retained generation A snapshot must still contain this leaf.
/** @end */
