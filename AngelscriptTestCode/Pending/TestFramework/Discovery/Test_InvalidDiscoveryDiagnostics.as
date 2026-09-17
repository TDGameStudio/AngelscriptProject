/**
 * @version v1
 * @summary TestFramework Discovery Test_InvalidDiscoveryDiagnostics
 * @topic TestFramework
 */
/**
 * @version root
 * @summary TestFramework Discovery Test_InvalidDiscoveryDiagnostics
 * @topic Baseline
 */
// Framework contract: invalid suite bases, non-void or parameterized marked
// methods, and malformed/duplicate flag metadata are diagnosed and omitted.
// One valid control leaf remains so the oracle can distinguish omission from
// empty discovery.
// Payload: the valid control uses a unique true-check message. Invalid
// bodies are present only so their declarations occupy documented lines.
// Expected observations: every invalid declaration produces a source-located
// diagnostic and is absent from the snapshot; the control descriptor remains.
// C++ oracle required: diagnostic count/text/line, omitted identities, and
// that the control leaf is the only published descriptor from this file.

UCLASS()
class UTestSourceInvalidDiscoveryWrongBase : UObject
{
	UFUNCTION(meta=(AngelscriptTest))
	void MarkedMethodOnWrongBaseIsOmitted()
	{
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceInvalidDiscoverySignatureSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	int VerifyNonVoidMarkedMethodIsOmitted()
	{
		return 1;
	}

	UFUNCTION(meta=(AngelscriptTest))
	void VerifyParameterizedMarkedMethodIsOmitted(int UnusedValue)
	{
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EditorContext;EngineFilter"))
class UTestSourceInvalidDiscoveryDuplicateFlagsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyDuplicateFlagMetadataIsOmitted()
	{
		Fail("TS-FW-DISCOVERY-003 duplicate-flag leaf must not execute");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;None;EngineFilter"))
class UTestSourceInvalidDiscoveryUnsupportedTokenSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyUnsupportedFlagTokenIsOmitted()
	{
		Fail("TS-FW-DISCOVERY-003 unsupported-token leaf must not execute");
	}
}

UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UTestSourceInvalidDiscoveryDiagnosticsSuite : UAngelscriptTestSuite
{
	UFUNCTION(meta=(AngelscriptTest))
	void VerifyInvalidDiscoveryDiagnostics()
	{
		AssertTrue(true, "TS-FW-DISCOVERY-003 valid control leaf payload");
	}
}
/** @end */
