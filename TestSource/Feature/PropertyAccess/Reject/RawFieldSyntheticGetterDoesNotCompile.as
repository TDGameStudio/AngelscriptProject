/**
 * Isolated compile-fail: a synthetic GetField alias is not generated for a raw field.
 * C++ compiles this as RawFieldSyntheticGetterDoesNotCompile and expects bCompiled==false
 * with a diagnostic mentioning GetField.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.RawFieldSyntheticGetterDoesNotCompile
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.RawFieldSyntheticGetterDoesNotCompile
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: synthetic GetField on a raw field.
 * @Provenance CSV Positive. C++ RawFieldSyntheticGetterDoesNotCompile: bCompiled==false,
 * @Provenance compile error mentioning GetField.
 * @Provenance Isolate this failing program. Keep #if EDITOR.
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
