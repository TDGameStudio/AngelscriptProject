/**
 * @version v1
 * @summary A nested container used as an error payload, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_UnsupportedErrorPayloadBoundary and expects the diagnostic to.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A nested container used as an error payload, which must stay a deterministic compile-failure boundary. C++ compiles this as the module ASCoverageErrorHandling_UnsupportedErrorPayloadBoundary and expects the diagnostic to.
 * @topic Negative
 */
/**
 * The isolated failing program: a TArray of TMap cannot be declared.
 *
 * @Kind CompileReject
 * @Covers Debug.UnsupportedErrorPayloadBoundary
 * @Inputs none
 * @Return does not compile; "Containers cannot be nested in other containers"
 */
class FCoverageErrorPayload
{
	TArray<TMap<int, FString>> Details;
}
/** @end */
