/**
 * Exact query compatibility: tag name and string round-trips, matching a
 * container against a MatchTag query, and the empty vectors that must not match.
 * The runner supplies a valid tag name.
 *
 * @Theme Optional.GameplayTags
 * @Subject GameplayTags.ExactQueryCompat
 * @Harness Function
 * @Tag Optional.GameplayTags.GameplayTagExactQueryCompat
 * @Namespace GameplayTagsTest
 * @Provenance Theme: Optional.GameplayTags. C++ functions return 1. CSV NegativeDiagnostic is
 * @Provenance a heuristic; C++ ExpectGlobalInt value oracles after compile.
 * @Provenance C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagExactQueryCompat
 * @Provenance Runner supplies TagName. Extra: empty container does not match MatchTag;
 * @Provenance RequestGameplayTag(None) equals EmptyTag.
 * @Provenance FixtureIsolated.
 */

namespace GameplayTagsTest
{
	/**
	 * Checks that a requested tag reports back its own name.
	 *
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the round trip matches
	 * @Param TagName the tag to request
	 */
	int TagNameRoundTrip(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return (ValidTag.GetTagName() == TagName) ? 1 : 0;
	}

	/**
	 * Checks that a tag stringifies to its own name.
	 *
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the strings match
	 * @Param TagName the tag to request
	 */
	int TagToStringRoundTrip(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return (ValidTag.ToString() == TagName.ToString()) ? 1 : 0;
	}

	/**
	 * Checks that a populated container matches a MatchTag query.
	 *
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query matches
	 * @Param TagName the tag to add and query
	 */
	int MatchTagQuery(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		return Tags.MatchesQuery(MatchTag) ? 1 : 0;
	}

	/**
	 * Checks that an empty container does not match a MatchTag query.
	 *
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query does not match
	 * @Param TagName the tag the query is built from
	 */
	int EmptyNotMatchQuery(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
		FGameplayTagContainer EmptyTags;
		return EmptyTags.MatchesQuery(MatchTag) ? 0 : 1;
	}

	/**
	 * Checks that requesting NAME_None yields the empty tag.
	 *
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs none
	 * @Return 1 when the result equals the empty tag
	 */
	int RequestNoneEqualsEmpty()
	{
		FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
		return (RequestedInvalid == FGameplayTag::EmptyTag) ? 1 : 0;
	}

	/**
	 * Observe every exact-query vector.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs a valid tag name plus the empty vectors
	 * @Return true when all five report 1
	 * @Param TagName the registered tag to use
	 */
	UFUNCTION()
	bool ExactQueryNominal(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0005 setup: required TagName is None");
		}

		if (TagNameRoundTrip(TagName) != 1)
		{
			return false;
		}

		if (TagToStringRoundTrip(TagName) != 1)
		{
			return false;
		}

		if (MatchTagQuery(TagName) != 1)
		{
			return false;
		}

		if (EmptyNotMatchQuery(TagName) != 1)
		{
			return false;
		}

		return RequestNoneEqualsEmpty() == 1;
	}

	/**
	 * Observe the empty-request vector without needing a registered tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.ExactQueryCompat
	 * @Inputs the NAME_None request
	 * @Return true when it yields the empty tag
	 * @Boundary empty request
	 */
	UFUNCTION()
	bool ExactQueryEmpty()
	{
		return RequestNoneEqualsEmpty() == 1;
	}
}
