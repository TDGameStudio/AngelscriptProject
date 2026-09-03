/**
 * The GameplayTags namespace globals. C++ printf-injects the sanitized
 * identifier, so TestSource takes the tag and parent names as runner parameters
 * because identifiers cannot be parameterized directly.
 *
 * @Theme Optional.GameplayTags
 * @Subject GameplayTags.NamespaceGlobals
 * @Harness Function
 * @Tag Optional.GameplayTags.GameplayTagNamespaceGlobals
 * @Namespace GameplayTagsTest
 * @Provenance Theme: Optional.GameplayTags. WorldStory GameplayTags:: namespace globals.
 * @Provenance C++ printf-injects GameplayTags::SanitizedIdentifier; TestSource uses TagName
 * @Provenance and ParentName runner parameters because identifiers cannot be parameterized.
 * @Provenance C++: AngelscriptGameplayTagBindingsTests.cpp::GameplayTagNamespaceGlobals
 * @Provenance ExpectGlobalInt each GPTagNS_* == 1. Extra: empty default tag is invalid.
 * @Provenance FixtureIsolated.
 */

namespace GameplayTagsTest
{
	/**
	 * Checks that a namespace tag resolves as valid.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered tag name
	 * @Return 1 when the tag is valid
	 * @Param TagName the tag to request
	 */
	int NamespaceTagValid(FName TagName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return NamespaceTag.IsValid() ? 1 : 0;
	}

	/**
	 * Checks that a namespace tag equals a freshly requested one.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered tag name
	 * @Return 1 when both resolve equal
	 * @Param TagName the tag to request twice
	 */
	int NamespaceTagEqualsRequested(FName TagName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return (NamespaceTag == RequestedTag) ? 1 : 0;
	}

	/**
	 * Checks that a namespace tag's name matches a requested one.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered tag name
	 * @Return 1 when both names match
	 * @Param TagName the tag to request twice
	 */
	int NamespaceTagNameMatches(FName TagName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return (NamespaceTag.GetTagName() == RequestedTag.GetTagName()) ? 1 : 0;
	}

	/**
	 * Checks that a namespace tag stringifies like a requested one.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered tag name
	 * @Return 1 when both strings match
	 * @Param TagName the tag to request twice
	 */
	int NamespaceTagToStringMatches(FName TagName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(TagName, true);
		return (NamespaceTag.ToString() == RequestedTag.ToString()) ? 1 : 0;
	}

	/**
	 * Checks that the namespace parent tag resolves as valid.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered parent tag name
	 * @Return 1 when the parent tag is valid
	 * @Param ParentName the parent tag to request
	 */
	int ParentTagValid(FName ParentName)
	{
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return NamespaceParentTag.IsValid() ? 1 : 0;
	}

	/**
	 * Checks that the namespace parent equals a freshly requested one.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a registered parent tag name
	 * @Return 1 when both resolve equal
	 * @Param ParentName the parent tag to request twice
	 */
	int ParentTagEqualsRequested(FName ParentName)
	{
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		FGameplayTag RequestedParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return (NamespaceParentTag == RequestedParentTag) ? 1 : 0;
	}

	/**
	 * Checks that the namespace tag's direct parent is the parent tag.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a child and its parent
	 * @Return 1 when the direct parent matches
	 * @Param TagName the child tag
	 * @Param ParentName the parent tag
	 */
	int DirectParentMatches(FName TagName, FName ParentName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return (NamespaceTag.RequestDirectParent() == NamespaceParentTag) ? 1 : 0;
	}

	/**
	 * Checks that the parent chain contains the parent tag.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a child and its parent
	 * @Return 1 when the chain holds the parent
	 * @Param TagName the child tag
	 * @Param ParentName the parent tag
	 */
	int ParentChainContainsParent(FName TagName, FName ParentName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		FGameplayTagContainer ParentChain = NamespaceTag.GetGameplayTagParents();
		return ParentChain.HasTagExact(NamespaceParentTag) ? 1 : 0;
	}

	/**
	 * Checks that the namespace tag matches its parent.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesTag reports true
	 * @Param TagName the child tag
	 * @Param ParentName the parent tag
	 */
	int MatchesParent(FName TagName, FName ParentName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return NamespaceTag.MatchesTag(NamespaceParentTag) ? 1 : 0;
	}

	/**
	 * Checks that the namespace tag does not exactly match its parent.
	 *
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a child and its parent
	 * @Return 1 when MatchesTagExact reports false
	 * @Param TagName the child tag
	 * @Param ParentName the parent tag
	 */
	int NotMatchesExactParent(FName TagName, FName ParentName)
	{
		FGameplayTag NamespaceTag = FGameplayTag::RequestGameplayTag(TagName, true);
		FGameplayTag NamespaceParentTag = FGameplayTag::RequestGameplayTag(ParentName, true);
		return NamespaceTag.MatchesTagExact(NamespaceParentTag) ? 0 : 1;
	}

	/**
	 * Observe every namespace-global vector.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a child and its parent
	 * @Return true when all ten report 1
	 * @Param TagName the child tag
	 * @Param ParentName the parent tag
	 */
	UFUNCTION()
	bool NamespaceGlobalsNominal(FName TagName, FName ParentName)
	{
		if (TagName.IsNone())
		{
			throw("TS-OPT-0006 setup: required TagName is None");
		}
		if (ParentName.IsNone())
		{
			throw("TS-OPT-0006 setup: required ParentName is None");
		}

		if (NamespaceTagValid(TagName) != 1)
		{
			return false;
		}

		if (NamespaceTagEqualsRequested(TagName) != 1)
		{
			return false;
		}

		if (NamespaceTagNameMatches(TagName) != 1)
		{
			return false;
		}

		if (NamespaceTagToStringMatches(TagName) != 1)
		{
			return false;
		}

		if (ParentTagValid(ParentName) != 1)
		{
			return false;
		}

		if (ParentTagEqualsRequested(ParentName) != 1)
		{
			return false;
		}

		if (DirectParentMatches(TagName, ParentName) != 1)
		{
			return false;
		}

		if (ParentChainContainsParent(TagName, ParentName) != 1)
		{
			return false;
		}

		if (MatchesParent(TagName, ParentName) != 1)
		{
			return false;
		}

		return NotMatchesExactParent(TagName, ParentName) == 1;
	}

	/**
	 * Observe that a default namespace tag is invalid.
	 *
	 * @Kind Observe
	 * @Covers GameplayTags.NamespaceGlobals
	 * @Inputs a default-constructed tag
	 * @Return 1 when the tag is invalid
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int NamespaceEmptyTagInvalid()
	{
		FGameplayTag EmptyDefault;
		return EmptyDefault.IsValid() ? 0 : 1;
	}
}
