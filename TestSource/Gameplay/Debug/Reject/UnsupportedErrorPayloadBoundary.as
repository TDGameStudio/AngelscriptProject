/**
 * A nested container used as an error payload, which must stay a deterministic
 * compile-failure boundary. C++ compiles this as the module
 * ASCoverageErrorHandling_UnsupportedErrorPayloadBoundary and expects the diagnostic to
 * report the nesting.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.UnsupportedErrorPayloadBoundary
 * @Harness CompileReject
 * @Tag Gameplay.Debug.UnsupportedErrorPayloadBoundary
 * @Provenance Theme: Gameplay.Debug. Isolated compile-fail: nested containers as error payload.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeCompileBoundaries
 * @Provenance Expected diagnostic: Containers cannot be nested in other containers.
 * @Provenance DiagnosticOnly. Do not flatten Details.
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
