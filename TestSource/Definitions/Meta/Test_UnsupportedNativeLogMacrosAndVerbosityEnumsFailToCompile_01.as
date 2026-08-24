// Theme: Definitions.Meta. NegativeDiagnostic: native UE_LOG is not an AS API.
// C++: CompileAndExpectFailure for TryNativeUELogMacro.
// Expected diagnostic: native log macro / verbosity is rejected at compile.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void TryNativeUELogMacro()
{
	UE_LOG(LogTemp, Verbose, TEXT("Coverage verbose"));
}
