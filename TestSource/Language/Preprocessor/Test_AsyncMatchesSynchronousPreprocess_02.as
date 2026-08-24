// Theme: Language.Preprocessor. WorldStory: consumer imports async-load provider.
// C++: AngelscriptPreprocessorAsyncTests.cpp::AsyncMatchesSynchronousPreprocess
// Consumer.as; lines 329-340; both sync and async preprocess succeed.
// sha256=c0549203ce33558f6c7cf1aceac04b8d1fc8814aee85c1c21092db5d56d923e8.
// Oracle: UseProvider() == 21; StoredValue default is ProviderMultiplier (3).
// Extra: default StoredValue is 3; UseProvider does not mutate StoredValue.
// FixtureIsolated. Keep UPROPERTY name StoredValue.

import Tests.Preprocessor.AsyncLoad.Provider;

class AAsyncLoadMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int StoredValue = ProviderMultiplier;
}

int UseProvider()
{
	return ProvideValue() * ProviderMultiplier;
}

bool Observe_UseProvider_Nominal()
{
	return UseProvider() == 21;
}

bool Observe_StoredValue_Default(AAsyncLoadMacroActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AsyncMatchesSynchronousPreprocess_02 setup: required Actor is null");
	}
	return Actor.StoredValue == 3;
}

bool Observe_StoredValue_IndependentOfUseProvider(AAsyncLoadMacroActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AsyncMatchesSynchronousPreprocess_02 setup: required Actor is null");
	}
	int Product = UseProvider();
	return Product == 21 && Actor.StoredValue == 3;
}
