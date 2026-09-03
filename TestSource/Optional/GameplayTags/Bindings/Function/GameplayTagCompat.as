/**
 * GameplayTag compatibility: requesting a valid tag by name, and the empty-tag
 * vectors that are false-or-null rather than compile failures. The runner
 * supplies a valid tag name because the registry is fixture-isolated.
 *
 * @Theme Optional.GameplayTags
 * @Subject GameplayTags.Compat
 * @Harness Function
 * @Tag Optional.GameplayTags.GameplayTagCompat
 * @Namespace GameplayTagsTest
 * @Provenance Theme: Optional.GameplayTags. C++ functions return 1 on success. CSV
 * @Provenance NegativeDiagnostic is a heuristic; empty-tag cases are false/null vectors,
 * @Provenance not compile failures. Runner supplies a valid tag name for RequestGameplayTag.
 * @Provenance Extra: empty default is the false vector (already in GPTag_Empty*).
 * @Provenance FixtureIsolated (tag registry).
 */

namespace GameplayTagsTest
{
	/**
	 * Requests a tag by name and reports whether it resolved.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs a registered tag name
	 * @Return 1 when the tag is valid, otherwise 0
	 * @Param TagName the tag to request
	 */
	int RequestValidTag(FName TagName)
	{
		FGameplayTag GlobalTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return GlobalTag.IsValid() ? 1 : 0;
	}

	/**
	 * Checks that a default-constructed tag is not valid.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs none
	 * @Return 1 when the default tag is invalid
	 */
	int EmptyTagNotValid()
	{
		FGameplayTag EmptyDefault;
		return EmptyDefault.IsValid() ? 0 : 1;
	}

	/**
	 * Checks that a default tag equals the empty tag singleton.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs none
	 * @Return 1 when the two are equal
	 */
	int EmptyTagEqualsEmptyTag()
	{
		FGameplayTag EmptyDefault;
		return (EmptyDefault == FGameplayTag::EmptyTag) ? 1 : 0;
	}

	/**
	 * Checks that a default tag's name is NAME_None.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs none
	 * @Return 1 when the name is none
	 */
	int EmptyTagNameIsNone()
	{
		FGameplayTag EmptyDefault;
		return EmptyDefault.GetTagName().IsNone() ? 1 : 0;
	}

	/**
	 * Checks that a default tag stringifies like the empty tag.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs none
	 * @Return 1 when both strings match
	 */
	int EmptyTagToStringMatchesEmptyTag()
	{
		FGameplayTag EmptyDefault;
		return (EmptyDefault.ToString() == FGameplayTag::EmptyTag.ToString()) ? 1 : 0;
	}

	/**
	 * Checks that requesting NAME_None yields the empty tag.
	 *
	 * @Covers GameplayTags.Compat
	 * @Inputs none
	 * @Return 1 when the request falls back to the empty tag
	 */
	int RequestNoneYieldsEmptyTag()
	{
		FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
		return (RequestedInvalid == FGameplayTag::EmptyTag) ? 1 : 0;
	}

	/**
	 * Observe every compat vector including the runner-supplied tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.Compat
	 * @Inputs a valid tag name plus all empty-tag vectors
	 * @Return true when all six report 1
	 * @Param TagName the registered tag to request
	 */
	UFUNCTION()
	bool GameplayTagCompatNominal(FName TagName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0001 setup: required TagName is None");
		}

		if (RequestValidTag(TagName) != 1)
		{
			return false;
		}

		if (EmptyTagNotValid() != 1)
		{
			return false;
		}

		if (EmptyTagEqualsEmptyTag() != 1)
		{
			return false;
		}

		if (EmptyTagNameIsNone() != 1)
		{
			return false;
		}

		if (EmptyTagToStringMatchesEmptyTag() != 1)
		{
			return false;
		}

		return RequestNoneYieldsEmptyTag() == 1;
	}

	/**
	 * Observe the empty-tag vectors without needing a registered tag.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.Compat
	 * @Inputs all empty-tag vectors
	 * @Return true when all five report 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	bool GameplayTagCompatEmpty()
	{
		if (EmptyTagNotValid() != 1)
		{
			return false;
		}

		if (EmptyTagEqualsEmptyTag() != 1)
		{
			return false;
		}

		if (EmptyTagNameIsNone() != 1)
		{
			return false;
		}

		if (EmptyTagToStringMatchesEmptyTag() != 1)
		{
			return false;
		}

		return RequestNoneYieldsEmptyTag() == 1;
	}
}
