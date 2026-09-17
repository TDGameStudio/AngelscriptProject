/**
 * @version v1
 * @summary FGameplayTagQuery factories and matching: the empty default, the any/all/none and tag factories, exact-match factories, copy equality, and container matching across every factory. The runner supplies a valid tag name.
 * @topic Optional
 */
/**
 * @version root
 * @summary FGameplayTagQuery factories and matching: the empty default, the any/all/none and tag factories, exact-match factories, copy equality, and container matching across every factory. The runner supplies a valid tag name.
 * @topic Baseline
 */
namespace GameplayTagsTest
{
	/**
	 * Checks that a default query is empty and equals the empty singleton.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs none
	 * @Return 1 when the query is empty and matches the singleton
	 */
	int EmptyDefault()
	{
		FGameplayTagQuery EmptyDefault;
		if (!EmptyDefault.IsEmpty())
		{
			return 0;
		}
		return (EmptyDefault == FGameplayTagQuery::EmptyQuery) ? 1 : 0;
	}

	/**
	 * Checks that the MatchAnyTags factory produces a non-empty query.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query is non-empty
	 * @Param TagName the tag the query is built from
	 */
	int MatchAnyNotEmpty(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
		return MatchAny.IsEmpty() ? 0 : 1;
	}

	/**
	 * Checks that the MatchAllTags factory produces a non-empty query.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query is non-empty
	 * @Param TagName the tag the query is built from
	 */
	int MatchAllNotEmpty(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
		return MatchAll.IsEmpty() ? 0 : 1;
	}

	/**
	 * Checks that the MatchNoTags factory produces a non-empty query.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query is non-empty
	 * @Param TagName the tag the query is built from
	 */
	int MatchNoneNotEmpty(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchNone = FGameplayTagQuery::MakeQuery_MatchNoTags(Tags);
		return MatchNone.IsEmpty() ? 0 : 1;
	}

	/**
	 * Checks that the MatchTag factory produces a non-empty query.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the query is non-empty
	 * @Param TagName the tag the query is built from
	 */
	int MatchTagNotEmpty(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
		return MatchTag.IsEmpty() ? 0 : 1;
	}

	/**
	 * Checks that the any and all factories produce different queries.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the two queries differ
	 * @Param TagName the tag the queries are built from
	 */
	int DifferentQueriesNotEqual(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
		FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
		return (MatchAny == MatchAll) ? 0 : 1;
	}

	/**
	 * Checks that copying a query preserves equality.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the copy equals the original
	 * @Param TagName the tag the query is built from
	 */
	int CopyEquality(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
		FGameplayTagQuery Copy = MatchAny;
		return (Copy == MatchAny) ? 1 : 0;
	}

	/**
	 * Checks that the exact-match factories produce non-empty queries.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when both exact queries are non-empty
	 * @Param TagName the tag the queries are built from
	 */
	int ExactMatchFactories(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAnyExact = FGameplayTagQuery::MakeQuery_ExactMatchAnyTags(Tags);
		FGameplayTagQuery MatchAllExact = FGameplayTagQuery::MakeQuery_ExactMatchAllTags(Tags);

		if (MatchAnyExact.IsEmpty())
		{
			return 0;
		}
		if (MatchAllExact.IsEmpty())
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Checks container matching across every factory, including the none case.
	 *
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a registered tag name
	 * @Return 1 when the four positive queries match and the none query does not
	 * @Param TagName the tag used throughout
	 */
	int MatchesQuery(FName TagName)
	{
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagContainer Tags;
		Tags.AddTag(ValidTag);
		FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
		FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
		FGameplayTagQuery MatchAnyExact = FGameplayTagQuery::MakeQuery_ExactMatchAnyTags(Tags);
		FGameplayTagQuery MatchAllExact = FGameplayTagQuery::MakeQuery_ExactMatchAllTags(Tags);
		FGameplayTagQuery MatchNone = FGameplayTagQuery::MakeQuery_MatchNoTags(Tags);

		if (!Tags.MatchesQuery(MatchAny))
		{
			return 0;
		}
		if (!Tags.MatchesQuery(MatchAll))
		{
			return 0;
		}
		if (!Tags.MatchesQuery(MatchAnyExact))
		{
			return 0;
		}
		if (!Tags.MatchesQuery(MatchAllExact))
		{
			return 0;
		}
		if (Tags.MatchesQuery(MatchNone))
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe every query-compat vector.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs a valid tag name
	 * @Return true when all nine report 1
	 * @Param TagName the registered tag to use
	 */
	UFUNCTION()
	bool QueryCompatNominal(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0004 setup: required TagName is None");
		}

		if (EmptyDefault() != 1)
		{
			return false;
		}

		if (MatchAnyNotEmpty(TagName) != 1)
		{
			return false;
		}

		if (MatchAllNotEmpty(TagName) != 1)
		{
			return false;
		}

		if (MatchNoneNotEmpty(TagName) != 1)
		{
			return false;
		}

		if (MatchTagNotEmpty(TagName) != 1)
		{
			return false;
		}

		if (DifferentQueriesNotEqual(TagName) != 1)
		{
			return false;
		}

		if (CopyEquality(TagName) != 1)
		{
			return false;
		}

		if (ExactMatchFactories(TagName) != 1)
		{
			return false;
		}

		return MatchesQuery(TagName) == 1;
	}

	/**
	 * Observe that an empty container does not match a MatchTag query.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.QueryCompat
	 * @Inputs an empty container queried against a MatchTag query
	 * @Return 1 when the query does not match
	 * @Boundary empty container
	 * @Param TagName the tag the query is built from
	 */
	UFUNCTION()
	int EmptyContainerDoesNotMatchTag(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0004 setup: required TagName is None");
		}
		FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
		FGameplayTagContainer EmptyTags;
		return EmptyTags.MatchesQuery(MatchTag) ? 0 : 1;
	}
}
/** @end */
