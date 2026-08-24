// Theme: Feature.PropertyAccess. Isolated compile-fail: synthetic GetScore alias.
// CSV Positive. C++ BlueprintGetterSyntheticAliasDoesNotCompile: bCompiled==false,
// compile error mentioning GetScore.
// Isolate this failing program. Keep #if EDITOR.

#if EDITOR
UCLASS()
class AAutoAccessorGetterScriptActorFailure : AAngelscriptPropertyAccessorCarrier
{
	UFUNCTION()
	int32 CheckSyntheticGetterAlias()
	{
		return GetScore();
	}
}
#endif
