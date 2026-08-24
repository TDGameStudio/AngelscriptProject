// Theme: Definitions.UProperty. Positive: script UAnimNotify subclass registers UPROPERTY defaults.
// C++: class is child of UAnimNotify; EffectTag CDO n"Default"; EffectStrength FDoubleProperty.
// Extra: empty tag NAME_None is independent of Default; strength 0 is the empty boundary.
// DefaultSafe.

UCLASS()
class UFunctionalAnimNotify_ScriptEffect : UAnimNotify
{
	UPROPERTY(EditAnywhere)
	FName EffectTag = n"Default";

	UPROPERTY(EditAnywhere)
	float EffectStrength = 1.0;
}

bool Observe_AnimNotify_EmptyTagIndependent()
{
	FName EffectTag = n"Default";
	FName EmptyTag = NAME_None;
	return EffectTag != EmptyTag;
}

float Observe_AnimNotify_EmptyStrengthBoundary()
{
	return 0.0;
}
