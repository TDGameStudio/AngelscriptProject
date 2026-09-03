/**
 * `default` statements that call Tags.Add on the CDO. The verifier returns
 * distinct codes so a failure names which tag is missing.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultTagsAddExecutedOnCDO
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.DefaultTagsAddExecutedOnCDO
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultTagsAddExecutedOnCDO
 * @Provenance sha256=b736bedfe717142c3c34df6171f2072a0601ef188a29fc8194f08dd0ffa55bbc; lines 354-373.
 * @Provenance Oracle: VerifyTags returns 42 (Alpha+Beta present, Num>=2). Extra: clearing
 * @Provenance Tags returns 1 (Alpha missing). FixtureIsolated.
 */

UCLASS()
class ADefaultTagsActor : AActor
{
	default Tags.Add(n"Alpha");
	default Tags.Add(n"Beta");

	/**
	 * Verifies that both default tags were added.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the actor's Tags array
	 * @Return 42 when both tags are present, otherwise 1, 2 or 3
	 */
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

	/**
	 * Observe that both default tags were applied to the CDO.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when verification returns 42
	 */
	UFUNCTION()
	bool DefaultTagsVerifyPasses()
	{
		return VerifyTags() == 42;
	}

	/**
	 * Observe the boundary where the tags have been cleared.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Tags emptied
	 * @Return true when verification returns 1
	 * @Boundary cleared tags
	 */
	UFUNCTION()
	bool DefaultTagsClearedFailsVerification()
	{
		Tags.Empty();
		return VerifyTags() == 1;
	}
}
