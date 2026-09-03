/**
 * A BlueprintCallable UFUNCTION may not collide with a native AActor method.
 * SetActorHiddenInGame is already specified on AActor. This file is the
 * illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.NativeCallableCollision
 * @Harness CompileReject
 * @Tag Definitions.UFunction.NativeCallableCollision
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs UFUNCTION(BlueprintCallable) void SetActorHiddenInGame(bool bNewHidden)
 * @Return does not compile; diagnostic "BlueprintCallable method SetActorHiddenInGame in class ACoverageUFunctionNativeCollisionActor already specified in superclass AActor."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: BlueprintCallable collides with native AActor method.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case native callable collision.
 * @Provenance Expected compile failure: "BlueprintCallable method SetActorHiddenInGame in class ACoverageUFunctionNativeCollisionActor already specified in superclass AActor."
 */

UCLASS()
class ACoverageUFunctionNativeCollisionActor : AActor
{
	/**
	 * Illegal BlueprintCallable that collides with a native AActor method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs bool bNewHidden
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintCallable)
	void SetActorHiddenInGame(bool bNewHidden)
	{
	}
}
