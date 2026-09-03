/**
 * Native UE_LOG is not an AngelScript API, so this program is rejected. C++
 * compiles it as the module ASCoverageLogging_UELogMacroUnsupported and expects
 * fragments naming LogTemp, Verbose and TEXT.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.UELogMacroUnsupported
 * @Harness CompileReject
 * @Tag Definitions.Meta.UELogMacroUnsupported
 * @Provenance Theme: Definitions.Meta. NegativeDiagnostic: native UE_LOG is not an AS API.
 * @Provenance C++: CompileAndExpectFailure for TryNativeUELogMacro.
 * @Provenance Expected diagnostic: native log macro / verbosity is rejected at compile.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: UE_LOG has no script-facing signature.
 *
 * @Kind CompileReject
 * @Covers Meta.UELogMacroUnsupported
 * @Inputs none
 * @Return does not compile; native UE_LOG macro syntax is not AS-facing
 */
void TryNativeUELogMacro()
{
	UE_LOG(LogTemp, Verbose, TEXT("Coverage verbose"));
}
