// Theme: Feature.Attach. NegativeDiagnostic: AttachSocket without Attach.
// C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachSocketWithoutAttach.
// AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
// Expected diagnostic: "AttachSocket without Attach should fail".
// Isolate the failing program. DiagnosticOnly.

class ADefCompSocketNoAttachActor : AActor
{
	UPROPERTY(DefaultComponent, AttachSocket = "Socket1")
	USceneComponent Child;
}
