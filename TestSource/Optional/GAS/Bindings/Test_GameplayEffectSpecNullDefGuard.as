// Theme: Optional.GAS. C++ compiles then expects a runtime script exception.
// CSV NegativeDiagnostic is a heuristic; empty TSubclassOf is the null vector.
// Diagnostic: "GameplayEffect was null."
// C++: AngelscriptGASValueBindingsTests.cpp::GameplayEffectSpecNullDefGuard
// Extra: empty effect class is already the null CDO. FixtureIsolated.

void TriggerNullEffectSpec()
{
	TSubclassOf<UGameplayEffect> EmptyEffectClass;
	UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
	FGameplayEffectContextHandle Context;
	FGameplayEffectSpec Spec(NullEffect, Context, 1.0f);
}

int Observe_TriggerNullEffectSpec_EmptyClassIsNull()
{
	TSubclassOf<UGameplayEffect> EmptyEffectClass;
	UGameplayEffect NullEffect = EmptyEffectClass.GetDefaultObject();
	return (NullEffect == null) ? 1 : 0;
}

int Observe_TriggerNullEffectSpec_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}
