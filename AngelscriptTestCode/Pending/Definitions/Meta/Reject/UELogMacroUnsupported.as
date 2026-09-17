/**
 * @version v1
 * @summary Native UE_LOG is not an AngelScript API, so this program is rejected. C++ compiles it as the module ASCoverageLogging_UELogMacroUnsupported and expects fragments naming LogTemp, Verbose and TEXT.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Native UE_LOG is not an AngelScript API, so this program is rejected. C++ compiles it as the module ASCoverageLogging_UELogMacroUnsupported and expects fragments naming LogTemp, Verbose and TEXT.
 * @topic Negative
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
/** @end */
