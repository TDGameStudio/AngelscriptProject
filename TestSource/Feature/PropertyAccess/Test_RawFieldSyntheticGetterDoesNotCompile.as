// Theme: Feature.PropertyAccess. Isolated compile-fail: synthetic GetField on a raw field.
// CSV Positive. C++ RawFieldSyntheticGetterDoesNotCompile: bCompiled==false,
// compile error mentioning GetField.
// Isolate this failing program. Keep #if EDITOR.

#if EDITOR
UCLASS()
class AAutoAccessorRawFieldScriptActorFailure : AAngelscriptPropertyAccessorCarrier
{
	UFUNCTION()
	int32 CheckSyntheticGetter()
	{
		return GetField();
	}
}
#endif
