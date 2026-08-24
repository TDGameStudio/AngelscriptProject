// Theme: Language.Syntax.EdgeCases. WorldStory CDO Tags.Add.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultTagsAddExecutedOnCDO
// sha256=b736bedfe717142c3c34df6171f2072a0601ef188a29fc8194f08dd0ffa55bbc; lines 354-373.
// Oracle: VerifyTags returns 42 (Alpha+Beta present, Num>=2). Extra: clearing
// Tags returns 1 (Alpha missing). FixtureIsolated.

UCLASS()
class ADefaultTagsActor : AActor
{
	default Tags.Add(n"Alpha");
	default Tags.Add(n"Beta");

	UFUNCTION()
	int VerifyTags()
	{
		if (!Tags.Contains(n"Alpha"))
		{
			return 1;
		}
		if (!Tags.Contains(n"Beta"))
		{
			return 2;
		}
		if (Tags.Num() < 2)
		{
			return 3;
		}
		return 42;
	}
}

bool Observe_DefaultTags_Nominal(ADefaultTagsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultTagsAddExecutedOnCDO setup: required Actor is null");
	}
	return Actor.VerifyTags() == 42;
}

bool Observe_DefaultTags_ClearedBoundary(ADefaultTagsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultTagsAddExecutedOnCDO setup: required Actor is null");
	}
	Actor.Tags.Empty();
	return Actor.VerifyTags() == 1;
}
