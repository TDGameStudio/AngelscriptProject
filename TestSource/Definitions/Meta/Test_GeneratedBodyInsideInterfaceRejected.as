// Theme: Definitions.Meta. Isolated compile-fail: GENERATED_BODY is not valid inside a script interface.
// C++: GeneratedBodyInsideInterfaceRejected CompileAndExpectFailure.
// Expected diagnostic: "Virtual property syntax has been removed".
// Isolate this failing program; do not drop GENERATED_BODY().
// DiagnosticOnly.

interface ICoverageMacrosUnsupportedGeneratedBodyInterface
{
	GENERATED_BODY()
}
