/**
 * Isolated compile-fail: a synthetic GetScore alias is not generated for the
 * BlueprintGetter. C++ compiles this as BlueprintGetterSyntheticAliasDoesNotCompile
 * and expects bCompiled==false with a diagnostic mentioning GetScore.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.BlueprintGetterSyntheticAliasDoesNotCompile
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.BlueprintGetterSyntheticAliasDoesNotCompile
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: synthetic GetScore alias.
 * @Provenance CSV Positive. C++ BlueprintGetterSyntheticAliasDoesNotCompile: bCompiled==false,
 * @Provenance compile error mentioning GetScore.
 * @Provenance Isolate this failing program. Keep #if EDITOR.
 */

#if EDITOR
UCLASS()
class AAutoAccessorGetterScriptActorFailure : AAngelscriptPropertyAccessorCarrier
{
	/**
	 * The isolated failing program: GetScore is not a generated alias for FetchScore.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.BlueprintGetterSyntheticAliasDoesNotCompile
	 * @Inputs none
	 * @Return does not compile; diagnostic mentioning GetScore
	 */
	UFUNCTION()
	int32 CheckSyntheticGetterAlias()
	{
		return GetScore();
	}
}
#endif
