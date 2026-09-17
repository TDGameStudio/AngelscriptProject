/**
 * @version v1
 * @summary Isolated compile-fail: a synthetic GetScore alias is not generated for the BlueprintGetter. C++ compiles this as BlueprintGetterSyntheticAliasDoesNotCompile and expects bCompiled==false with a diagnostic mentioning.
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: a synthetic GetScore alias is not generated for the BlueprintGetter. C++ compiles this as BlueprintGetterSyntheticAliasDoesNotCompile and expects bCompiled==false with a diagnostic mentioning.
 * @topic Negative
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
/** @end */
