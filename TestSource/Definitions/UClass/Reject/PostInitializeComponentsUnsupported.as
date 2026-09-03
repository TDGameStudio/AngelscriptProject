/**
 * BlueprintOverride of PostInitializeComponents on AActor is rejected. That
 * method does not exist in the script-visible Actor superclass.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PostInitializeComponentsUnsupported
 * @Harness CompileReject
 * @Tag Definitions.UClass.PostInitializeComponentsUnsupported
 * @Kind CompileReject
 * @Covers UClass.BlueprintOverride
 * @Inputs UFUNCTION(BlueprintOverride) void PostInitializeComponents()
 * @Return does not compile; diagnostic "BlueprintOverride method PostInitializeComponents does not exist in superclass Actor"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: PostInitializeComponents BlueprintOverride.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorComponentInitialization CompileAndExpectFailure.
 * @Provenance Expected diagnostic: BlueprintOverride method PostInitializeComponents does not exist in superclass Actor.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class APostInitializeComponentsUnsupportedActor : AActor
{
	/**
	 * Illegal BlueprintOverride of PostInitializeComponents.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs PostInitializeComponents override on AActor
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void PostInitializeComponents()
	{
	}
}
