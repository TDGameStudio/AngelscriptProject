/**
 * GENERATED_BODY is a UHT spelling and is not valid inside a script interface, so
 * this program is rejected. Isolate the failing construct; do not drop
 * GENERATED_BODY().
 *
 * @Theme Definitions.Meta
 * @Subject Meta.GeneratedBodyInsideInterfaceRejected
 * @Harness CompileReject
 * @Tag Definitions.Meta.GeneratedBodyInsideInterfaceRejected
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: GENERATED_BODY is not valid inside a script interface.
 * @Provenance C++: GeneratedBodyInsideInterfaceRejected CompileAndExpectFailure.
 * @Provenance Expected diagnostic: "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program; do not drop GENERATED_BODY().
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: GENERATED_BODY is not legal on a script interface.
 *
 * @Kind CompileReject
 * @Covers Meta.GeneratedBodyInsideInterfaceRejected
 * @Inputs GENERATED_BODY() inside an interface
 * @Return does not compile; "Virtual property syntax has been removed"
 */
interface ICoverageMacrosUnsupportedGeneratedBodyInterface
{
	/**
	 * The isolated failing construct: GENERATED_BODY is UHT-only.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.GeneratedBodyInsideInterfaceRejected
	 * @Inputs none
	 * @Return does not compile
	 */
	GENERATED_BODY()
}
