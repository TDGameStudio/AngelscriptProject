// Theme: Definitions.UFunction. WorldStory AdvancedDisplay/DefaultToSelf/HidePin/AutoCreateRefTerm.
// C++: AngelscriptCoverageUFunctionTests.cpp::UFunctionParameterMetadata
// Oracle: ConfigureAdvanced generates with those metadata keys; body is a no-op.
// Extra: empty call with null Target and empty label; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageUFunctionParameterActor : AActor
{
	UFUNCTION(BlueprintCallable, Category="Coverage|Parameters", meta=(
		AdvancedDisplay="OptionalValue,OptionalLabel",
		DefaultToSelf="Target",
		HidePin="Target",
		AutoCreateRefTerm="OptionalLabel"))
	void ConfigureAdvanced(UObject Target, int RequiredValue, int OptionalValue, const FString&in OptionalLabel)
	{
	}
}

int Observe_ParameterMeta_EmptyCall(ACoverageUFunctionParameterActor Actor)
{
	Actor.ConfigureAdvanced(nullptr, 0, 0, "");
	return 0;
}

bool Observe_ParameterMeta_NullDefault()
{
	ACoverageUFunctionParameterActor Actor = nullptr;
	return Actor == nullptr;
}

int Observe_ParameterMeta_RepeatCall(ACoverageUFunctionParameterActor Actor)
{
	Actor.ConfigureAdvanced(nullptr, 1, 2, "x");
	Actor.ConfigureAdvanced(Actor, 3, 4, "yz");
	return 1;
}
