// Theme: Feature.PropertyAccess. Positive: call FetchScore, not a synthetic GetScore.
// C++: BlueprintGetterRemainsCallableWithoutSyntheticAlias
// CheckGetterAccess oracle Result==7.
// Extra: default Score==7; Score written to 0 returns 10 from the Score!=7 guard.
// DefaultSafe. Keep #if EDITOR.

#if EDITOR
UCLASS()
class AAutoAccessorGetterScriptActor : AAngelscriptPropertyAccessorCarrier
{
	UFUNCTION()
	int32 CheckGetterAccess()
	{
		if (Score != 7)
		{
			return 10;
		}

		return FetchScore();
	}
}

int Observe_GetterAccess_Nominal(AAutoAccessorGetterScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintGetterRemainsCallableWithoutSyntheticAlias setup: required Actor is null");
	}
	return Actor.CheckGetterAccess();
}

int Observe_GetterAccess_DefaultScore(AAutoAccessorGetterScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintGetterRemainsCallableWithoutSyntheticAlias setup: required Actor is null");
	}
	return Actor.Score;
}

int Observe_GetterAccess_WrongScoreBoundary(AAutoAccessorGetterScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintGetterRemainsCallableWithoutSyntheticAlias setup: required Actor is null");
	}
	Actor.Score = 0;
	return Actor.CheckGetterAccess();
}
#endif
