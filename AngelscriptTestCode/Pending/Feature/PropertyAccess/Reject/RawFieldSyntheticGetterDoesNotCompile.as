/**
 * @version v1
 * @summary Isolated compile-fail: a synthetic GetField alias is not generated for a raw field. C++ compiles this as RawFieldSyntheticGetterDoesNotCompile and expects bCompiled==false with a diagnostic mentioning GetField.
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: a synthetic GetField alias is not generated for a raw field. C++ compiles this as RawFieldSyntheticGetterDoesNotCompile and expects bCompiled==false with a diagnostic mentioning GetField.
 * @topic Negative
 */
#if EDITOR
UCLASS()
class AAutoAccessorRawFieldScriptActorFailure : AAngelscriptPropertyAccessorCarrier
{
	/**
	 * The isolated failing program: GetField is not a generated alias for Field.
	 *
	 * @Kind CompileReject
	 * @Covers PropertyAccess.RawFieldSyntheticGetterDoesNotCompile
	 * @Inputs none
	 * @Return does not compile; diagnostic mentioning GetField
	 */
	UFUNCTION()
	int32 CheckSyntheticGetter()
	{
		return GetField();
	}
}
#endif
/** @end */
