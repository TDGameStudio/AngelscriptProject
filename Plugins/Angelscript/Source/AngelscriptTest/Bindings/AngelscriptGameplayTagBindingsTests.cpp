#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Binds/Bind_FGameplayTag.h"
#include "Core/AngelscriptEngine.h"
#include "GameplayTagsManager.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

static bool FindGameplayTagHierarchyFixture(
	FGameplayTag& OutChildTag,
	FGameplayTag& OutParentTag,
	FGameplayTag& OutUnrelatedTag)
{
	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

	TArray<FGameplayTag> TagArray;
	AllTags.GetGameplayTagArray(TagArray);

	for (const FGameplayTag& CandidateChildTag : TagArray)
	{
		const FGameplayTag CandidateParentTag = CandidateChildTag.RequestDirectParent();
		if (!CandidateParentTag.IsValid())
		{
			continue;
		}

		for (const FGameplayTag& CandidateUnrelatedTag : TagArray)
		{
			if (!CandidateUnrelatedTag.IsValid())
			{
				continue;
			}

			if (CandidateUnrelatedTag == CandidateChildTag || CandidateUnrelatedTag == CandidateParentTag)
			{
				continue;
			}

			if (CandidateChildTag.MatchesTag(CandidateUnrelatedTag) || CandidateUnrelatedTag.MatchesTag(CandidateChildTag))
			{
				continue;
			}

			if (CandidateParentTag.MatchesTag(CandidateUnrelatedTag) || CandidateUnrelatedTag.MatchesTag(CandidateParentTag))
			{
				continue;
			}

			OutChildTag = CandidateChildTag;
			OutParentTag = CandidateParentTag;
			OutUnrelatedTag = CandidateUnrelatedTag;
			return true;
		}
	}

	return false;
}

struct FGameplayTagNamespaceGlobalFixture
{
	FGameplayTag Tag;
	FString SanitizedTagIdentifier;
	FGameplayTag ParentTag;
	FString SanitizedParentIdentifier;
};

static FString SanitizeGameplayTagIdentifier(const FString& TagName)
{
	FString SanitizedIdentifier = TagName;
	for (TCHAR& Character : SanitizedIdentifier)
	{
		if (!FAngelscriptEngine::IsValidIdentifierCharacter(Character))
		{
			Character = TEXT('_');
		}
	}

	return SanitizedIdentifier;
}

static bool IsValidScriptIdentifier(const FString& Identifier)
{
	if (Identifier.IsEmpty())
	{
		return false;
	}

	if (!(FChar::IsAlpha(Identifier[0]) || Identifier[0] == TEXT('_')))
	{
		return false;
	}

	for (int32 Index = 1; Index < Identifier.Len(); ++Index)
	{
		if (!FAngelscriptEngine::IsValidIdentifierCharacter(Identifier[Index]))
		{
			return false;
		}
	}

	return true;
}

static bool HasGameplayTagNamespaceGlobal(FAngelscriptEngine& Engine, const FString& Identifier)
{
	asIScriptEngine* ScriptEngine = Engine.GetScriptEngine();
	if (ScriptEngine == nullptr)
	{
		return false;
	}

	const asUINT GlobalPropertyCount = ScriptEngine->GetGlobalPropertyCount();
	for (asUINT GlobalPropertyIndex = 0; GlobalPropertyIndex < GlobalPropertyCount; ++GlobalPropertyIndex)
	{
		const char* Name = nullptr;
		const char* NamespaceName = nullptr;
		if (ScriptEngine->GetGlobalPropertyByIndex(GlobalPropertyIndex, &Name, &NamespaceName) < 0)
		{
			continue;
		}

		if (Name != nullptr
			&& NamespaceName != nullptr
			&& FCStringAnsi::Strcmp(Name, TCHAR_TO_ANSI(*Identifier)) == 0
			&& FCStringAnsi::Strcmp(NamespaceName, "GameplayTags") == 0)
		{
			return true;
		}
	}

	return false;
}

enum EGameplayTagEmptyContractBit : int32
{
	NonEmptyHasAllEmptyBit = 0,
	NonEmptyHasAllExactEmptyBit,
	NonEmptyHasAnyEmptyBit,
	NonEmptyHasAnyExactEmptyBit,
	EmptyHasAllEmptyBit,
	EmptyHasAllExactEmptyBit,
	EmptyHasAnyEmptyBit,
	EmptyHasAnyExactEmptyBit,
	EmptyHasAllNonEmptyBit,
	EmptyHasAllExactNonEmptyBit,
	EmptyHasAnyNonEmptyBit,
	EmptyHasAnyExactNonEmptyBit,
	NonEmptyHasTagEmptyTagBit,
	NonEmptyHasTagExactEmptyTagBit,
};

static int32 BuildGameplayTagContainerEmptyContractMask(const FGameplayTag& ValidTag)
{
	FGameplayTagContainer NonEmptyContainer;
	NonEmptyContainer.AddTag(ValidTag);

	FGameplayTagContainer EmptyContainer;
	FGameplayTag EmptyTag;

	int32 ResultMask = 0;
	auto SetBitIfTrue = [&ResultMask](const EGameplayTagEmptyContractBit Bit, const bool bValue)
	{
		if (bValue)
		{
			ResultMask |= (1 << static_cast<int32>(Bit));
		}
	};

	SetBitIfTrue(NonEmptyHasAllEmptyBit, NonEmptyContainer.HasAll(EmptyContainer));
	SetBitIfTrue(NonEmptyHasAllExactEmptyBit, NonEmptyContainer.HasAllExact(EmptyContainer));
	SetBitIfTrue(NonEmptyHasAnyEmptyBit, NonEmptyContainer.HasAny(EmptyContainer));
	SetBitIfTrue(NonEmptyHasAnyExactEmptyBit, NonEmptyContainer.HasAnyExact(EmptyContainer));
	SetBitIfTrue(EmptyHasAllEmptyBit, EmptyContainer.HasAll(EmptyContainer));
	SetBitIfTrue(EmptyHasAllExactEmptyBit, EmptyContainer.HasAllExact(EmptyContainer));
	SetBitIfTrue(EmptyHasAnyEmptyBit, EmptyContainer.HasAny(EmptyContainer));
	SetBitIfTrue(EmptyHasAnyExactEmptyBit, EmptyContainer.HasAnyExact(EmptyContainer));
	SetBitIfTrue(EmptyHasAllNonEmptyBit, EmptyContainer.HasAll(NonEmptyContainer));
	SetBitIfTrue(EmptyHasAllExactNonEmptyBit, EmptyContainer.HasAllExact(NonEmptyContainer));
	SetBitIfTrue(EmptyHasAnyNonEmptyBit, EmptyContainer.HasAny(NonEmptyContainer));
	SetBitIfTrue(EmptyHasAnyExactNonEmptyBit, EmptyContainer.HasAnyExact(NonEmptyContainer));
	SetBitIfTrue(NonEmptyHasTagEmptyTagBit, NonEmptyContainer.HasTag(EmptyTag));
	SetBitIfTrue(NonEmptyHasTagExactEmptyTagBit, NonEmptyContainer.HasTagExact(EmptyTag));
	return ResultMask;
}

static bool FindGameplayTagNamespaceGlobalFixture(FAngelscriptEngine& Engine, FGameplayTagNamespaceGlobalFixture& OutFixture)
{
	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

	TArray<FGameplayTag> TagArray;
	AllTags.GetGameplayTagArray(TagArray);

	TMap<FString, int32> IdentifierCounts;
	for (const FGameplayTag& Tag : TagArray)
	{
		const FString Identifier = SanitizeGameplayTagIdentifier(Tag.ToString());
		IdentifierCounts.FindOrAdd(Identifier) += 1;
	}

	for (const FGameplayTag& CandidateTag : TagArray)
	{
		const FGameplayTag CandidateParentTag = CandidateTag.RequestDirectParent();
		if (!CandidateParentTag.IsValid())
		{
			continue;
		}

		const FString TagIdentifier = SanitizeGameplayTagIdentifier(CandidateTag.ToString());
		const FString ParentIdentifier = SanitizeGameplayTagIdentifier(CandidateParentTag.ToString());
		if (!IsValidScriptIdentifier(TagIdentifier) || !IsValidScriptIdentifier(ParentIdentifier))
		{
			continue;
		}

		// Only require uniqueness for the tag itself: the parent tag is auto-registered
		// by Bind_AddNewGameplayTags alongside its children (see Bind_FGameplayTag.cpp),
		// so it does not need its own GameplayTagList entry in config/*.ini.
		if (IdentifierCounts.FindRef(TagIdentifier) != 1)
		{
			continue;
		}

		if (!HasGameplayTagNamespaceGlobal(Engine, TagIdentifier) || !HasGameplayTagNamespaceGlobal(Engine, ParentIdentifier))
		{
			continue;
		}

		OutFixture.Tag = CandidateTag;
		OutFixture.SanitizedTagIdentifier = TagIdentifier;
		OutFixture.ParentTag = CandidateParentTag;
		OutFixture.SanitizedParentIdentifier = ParentIdentifier;
		return true;
	}

	return false;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagContainerBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagContainerCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagContainerEmptyContractsTest,
	"Angelscript.TestModule.Bindings.GameplayTagContainerEmptyContracts",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagQueryBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagQueryCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagExactQueryBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagExactQueryCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagNamespaceGlobalsTest,
	"Angelscript.TestModule.Bindings.GameplayTagNamespaceGlobals",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagHierarchySemanticsTest,
	"Angelscript.TestModule.FunctionLibraries.GameplayTagHierarchySemantics",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagContainerHierarchyAndFiltersTest,
	"Angelscript.TestModule.FunctionLibraries.GameplayTagContainerHierarchyAndFilters",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGameplayTagBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
	if (!TestTrue(TEXT("GameplayTagsManager should have at least one registered tag"), AllTags.Num() > 0))
	{
		return false;
	}

	FString GameplayTagIdentifier = AllTags.First().ToString();
	for (TCHAR& Character : GameplayTagIdentifier)
	{
		if (!(FChar::IsAlnum(Character) || Character == TEXT('_')))
		{
			Character = TEXT('_');
		}
	}

	const FString EscapedTagName = AllTags.First().ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag GlobalTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!GlobalTag.IsValid())
		return 5;

	FGameplayTag EmptyDefault;
	if (EmptyDefault.IsValid())
		return 10;
	if (!(EmptyDefault == FGameplayTag::EmptyTag))
		return 20;
	if (!EmptyDefault.GetTagName().IsNone())
		return 30;
	if (!(EmptyDefault.ToString() == FGameplayTag::EmptyTag.ToString()))
		return 40;

	FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
	if (RequestedInvalid.IsValid())
		return 50;
	if (!(RequestedInvalid == FGameplayTag::EmptyTag))
		return 60;

	return 1;
}
)"), *EscapedTagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagCompat", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTag compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptGameplayTagContainerBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
	if (!TestTrue(TEXT("GameplayTagsManager should have at least one registered tag"), AllTags.Num() > 0))
	{
		return false;
	}

	const FString TagName = AllTags.First().ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTagContainer EmptyDefault;
	if (!EmptyDefault.IsEmpty())
		return 10;
	if (!(EmptyDefault == FGameplayTagContainer::EmptyContainer))
		return 20;

	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!ValidTag.IsValid())
		return 25;

	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	if (!Tags.IsValid())
		return 30;
	if (Tags.Num() != 1)
		return 40;
	if (!Tags.HasTag(ValidTag))
		return 50;
	if (!Tags.HasTagExact(ValidTag))
		return 60;
	if (!(Tags.First() == ValidTag))
		return 70;

	FGameplayTagContainer Others;
	Others.AddTag(ValidTag);
	if (!Tags.HasAny(Others))
		return 80;
	if (!Tags.HasAnyExact(Others))
		return 85;
	if (!Tags.HasAll(Others))
		return 90;
	if (!Tags.HasAllExact(Others))
		return 95;

	FGameplayTagContainer Combined;
	Combined.AppendTags(Tags);
	if (!Combined.HasTag(ValidTag))
		return 100;

	if (!Combined.RemoveTag(ValidTag))
		return 110;
	if (!Combined.IsEmpty())
		return 120;

	Combined.AppendTags(Tags);
	Combined.Reset();
	if (!Combined.IsEmpty())
		return 130;

	return 1;
}
)"), *TagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagContainerCompat", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTagContainer compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptGameplayTagContainerEmptyContractsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
	if (!TestTrue(TEXT("GameplayTagContainer empty-contract test requires at least one registered gameplay tag"), AllTags.Num() > 0))
	{
		return false;
	}

	const FGameplayTag ValidTag = AllTags.First();
	if (!TestTrue(TEXT("GameplayTagContainer empty-contract test should resolve a valid gameplay tag fixture"), ValidTag.IsValid()))
	{
		return false;
	}

	const int32 NativeMask = BuildGameplayTagContainerEmptyContractMask(ValidTag);
	const int32 ExpectedMask =
		(1 << NonEmptyHasAllEmptyBit) |
		(1 << NonEmptyHasAllExactEmptyBit) |
		(1 << EmptyHasAllEmptyBit) |
		(1 << EmptyHasAllExactEmptyBit);
	if (!TestEqual(
			TEXT("GameplayTagContainer empty-contract test should match the UE native empty-container semantics reference"),
			NativeMask,
			ExpectedMask))
	{
		return false;
	}

	const FString TagName = ValidTag.ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!ValidTag.IsValid())
		return -1;

	FGameplayTagContainer NonEmptyContainer;
	NonEmptyContainer.AddTag(ValidTag);

	FGameplayTagContainer EmptyContainer;
	FGameplayTag EmptyTag;

	int ResultMask = 0;
	if (NonEmptyContainer.HasAll(EmptyContainer))
		ResultMask |= (1 << 0);
	if (NonEmptyContainer.HasAllExact(EmptyContainer))
		ResultMask |= (1 << 1);
	if (NonEmptyContainer.HasAny(EmptyContainer))
		ResultMask |= (1 << 2);
	if (NonEmptyContainer.HasAnyExact(EmptyContainer))
		ResultMask |= (1 << 3);
	if (EmptyContainer.HasAll(EmptyContainer))
		ResultMask |= (1 << 4);
	if (EmptyContainer.HasAllExact(EmptyContainer))
		ResultMask |= (1 << 5);
	if (EmptyContainer.HasAny(EmptyContainer))
		ResultMask |= (1 << 6);
	if (EmptyContainer.HasAnyExact(EmptyContainer))
		ResultMask |= (1 << 7);
	if (EmptyContainer.HasAll(NonEmptyContainer))
		ResultMask |= (1 << 8);
	if (EmptyContainer.HasAllExact(NonEmptyContainer))
		ResultMask |= (1 << 9);
	if (EmptyContainer.HasAny(NonEmptyContainer))
		ResultMask |= (1 << 10);
	if (EmptyContainer.HasAnyExact(NonEmptyContainer))
		ResultMask |= (1 << 11);
	if (NonEmptyContainer.HasTag(EmptyTag))
		ResultMask |= (1 << 12);
	if (NonEmptyContainer.HasTagExact(EmptyTag))
		ResultMask |= (1 << 13);

	return ResultMask;
}
)"), *TagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagContainerEmptyContracts", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 ScriptMask = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, ScriptMask))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTagContainer empty contracts should match the UE native semantics"), ScriptMask, NativeMask);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptGameplayTagQueryBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
	if (!TestTrue(TEXT("GameplayTagsManager should have at least one registered tag"), AllTags.Num() > 0))
	{
		return false;
	}

	const FString TagName = AllTags.First().ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!ValidTag.IsValid())
		return 10;

	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);

	FGameplayTagQuery EmptyDefault;
	if (!EmptyDefault.IsEmpty())
		return 20;
	if (!(EmptyDefault == FGameplayTagQuery::EmptyQuery))
		return 30;

	FGameplayTagQuery MatchAny = FGameplayTagQuery::MakeQuery_MatchAnyTags(Tags);
	if (MatchAny.IsEmpty())
		return 40;

	FGameplayTagQuery MatchAll = FGameplayTagQuery::MakeQuery_MatchAllTags(Tags);
	if (MatchAll.IsEmpty())
		return 50;

	FGameplayTagQuery MatchNone = FGameplayTagQuery::MakeQuery_MatchNoTags(Tags);
	if (MatchNone.IsEmpty())
		return 60;

	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	if (MatchTag.IsEmpty())
		return 70;

	if (MatchAny == MatchAll)
		return 80;

	FGameplayTagQuery Copy = MatchAny;
	if (!(Copy == MatchAny))
		return 90;

	FGameplayTagQuery MatchAnyExact = FGameplayTagQuery::MakeQuery_ExactMatchAnyTags(Tags);
	if (MatchAnyExact.IsEmpty())
		return 100;

	FGameplayTagQuery MatchAllExact = FGameplayTagQuery::MakeQuery_ExactMatchAllTags(Tags);
	if (MatchAllExact.IsEmpty())
		return 110;

	if (!Tags.MatchesQuery(MatchAny))
		return 120;
	if (!Tags.MatchesQuery(MatchAll))
		return 130;
	if (!Tags.MatchesQuery(MatchAnyExact))
		return 140;
	if (!Tags.MatchesQuery(MatchAllExact))
		return 150;
	if (Tags.MatchesQuery(MatchNone))
		return 160;

	return 1;
}
)"), *TagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagQueryCompat", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTagQuery compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptGameplayTagExactQueryBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTagContainer AllTags;
	UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
	if (!TestTrue(TEXT("GameplayTags exact-query compat test requires at least one registered gameplay tag"), AllTags.Num() > 0))
	{
		return false;
	}

	const FString TagName = AllTags.First().ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!ValidTag.IsValid())
		return 10;
	if (!(ValidTag.GetTagName() == FName("%s")))
		return 20;
	if (!(ValidTag.ToString() == "%s"))
		return 30;

	FGameplayTagQuery MatchTag = FGameplayTagQuery::MakeQuery_MatchTag(ValidTag);
	if (MatchTag.IsEmpty())
		return 40;

	FGameplayTagContainer Tags;
	Tags.AddTag(ValidTag);
	if (!Tags.MatchesQuery(MatchTag))
		return 50;

	FGameplayTagContainer EmptyTags;
	if (EmptyTags.MatchesQuery(MatchTag))
		return 60;

	FGameplayTag RequestedInvalid = FGameplayTag::RequestGameplayTag(NAME_None, false);
	if (!(RequestedInvalid == FGameplayTag::EmptyTag))
		return 70;

	return 1;
}
)"), *TagName, *TagName, *TagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagExactQueryCompat", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTag exact/query compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptGameplayTagNamespaceGlobalsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	AngelscriptReloadGameplayTags();
	// The shared clone test engine misses the initial Bind_AddNewGameplayTags pass
	// (AngelscriptGameplayTagsLookup short-circuits subsequent calls), so replay
	// RegisterGlobalProperty for every cached tag onto the currently scoped engine.
	AngelscriptRebindGameplayTagsToCurrentEngine();

	FGameplayTagNamespaceGlobalFixture Fixture;
	if (!TestTrue(
		TEXT("GameplayTag namespace-global test requires a child gameplay tag with a valid direct parent, unique sanitized identifiers, and bound GameplayTags globals"),
		FindGameplayTagNamespaceGlobalFixture(Engine, Fixture)))
	{
		return false;
	}

	const FString TagName = Fixture.Tag.ToString().ReplaceCharWithEscapedChar();
	const FString ParentTagName = Fixture.ParentTag.ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag NamespaceTag = GameplayTags::%s;
	FGameplayTag RequestedTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!NamespaceTag.IsValid())
		return 10;
	if (!RequestedTag.IsValid())
		return 20;
	if (!(NamespaceTag == RequestedTag))
		return 30;
	if (!(NamespaceTag.GetTagName() == RequestedTag.GetTagName()))
		return 40;
	if (!(NamespaceTag.ToString() == RequestedTag.ToString()))
		return 50;

	FGameplayTag NamespaceParentTag = GameplayTags::%s;
	FGameplayTag RequestedParentTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	if (!NamespaceParentTag.IsValid())
		return 60;
	if (!RequestedParentTag.IsValid())
		return 70;
	if (!(NamespaceParentTag == RequestedParentTag))
		return 80;
	if (!(NamespaceParentTag.GetTagName() == RequestedParentTag.GetTagName()))
		return 90;
	if (!(NamespaceTag.RequestDirectParent() == NamespaceParentTag))
		return 100;

	FGameplayTagContainer ParentChain = NamespaceTag.GetGameplayTagParents();
	if (!ParentChain.HasTagExact(NamespaceParentTag))
		return 110;
	if (!NamespaceTag.MatchesTag(NamespaceParentTag))
		return 120;
	if (NamespaceTag.MatchesTagExact(NamespaceParentTag))
		return 130;

	return 1;
}
)"),
		*Fixture.SanitizedTagIdentifier,
		*TagName,
		*Fixture.SanitizedParentIdentifier,
		*ParentTagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagNamespaceGlobals", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTag namespace globals should match RequestGameplayTag and expose the direct parent global"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptGameplayTagHierarchySemanticsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTag ChildTag;
	FGameplayTag ParentTag;
	FGameplayTag UnrelatedTag;
	if (!TestTrue(
		TEXT("GameplayTags hierarchy semantics test requires child/parent/unrelated gameplay tag fixture"),
		FindGameplayTagHierarchyFixture(ChildTag, ParentTag, UnrelatedTag)))
	{
		return false;
	}

	const FString ChildTagName = ChildTag.ToString().ReplaceCharWithEscapedChar();
	const FString ParentTagName = ParentTag.ToString().ReplaceCharWithEscapedChar();
	const FString UnrelatedTagName = UnrelatedTag.ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);

	if (!ChildTag.IsValid() || !ParentTag.IsValid() || !UnrelatedTag.IsValid())
		return 10;

	if (!ChildTag.MatchesTag(ParentTag))
		return 20;
	if (ChildTag.MatchesTagExact(ParentTag))
		return 30;
	if (ChildTag.MatchesTagDepth(ParentTag) < 1)
		return 40;

	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	if (!ChildTag.MatchesAny(ParentContainer))
		return 50;
	if (ChildTag.MatchesAnyExact(ParentContainer))
		return 60;

	FGameplayTag DirectParent = ChildTag.RequestDirectParent();
	if (!(DirectParent == ParentTag))
		return 70;

	FGameplayTagContainer SingleTagContainer = ChildTag.GetSingleTagContainer();
	if (SingleTagContainer.Num() != 1)
		return 80;
	if (!SingleTagContainer.HasTagExact(ChildTag))
		return 90;
	if (SingleTagContainer.HasTagExact(ParentTag))
		return 100;

	FGameplayTagContainer ParentChain = ChildTag.GetGameplayTagParents();
	if (!ParentChain.HasTagExact(ChildTag))
		return 110;
	if (!ParentChain.HasTagExact(ParentTag))
		return 120;

	FGameplayTagContainer UnrelatedContainer;
	UnrelatedContainer.AddTag(UnrelatedTag);
	if (ChildTag.MatchesTag(UnrelatedTag))
		return 130;
	if (ChildTag.MatchesTagExact(UnrelatedTag))
		return 140;
	if (ChildTag.MatchesTagDepth(UnrelatedTag) != 0)
		return 150;
	if (ChildTag.MatchesAny(UnrelatedContainer))
		return 160;
	if (ChildTag.MatchesAnyExact(UnrelatedContainer))
		return 170;
	if (ParentChain.HasTagExact(UnrelatedTag))
		return 180;

	return 1;
}
)"), *ChildTagName, *ParentTagName, *UnrelatedTagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagHierarchySemantics", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTag hierarchy helper semantics should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptGameplayTagContainerHierarchyAndFiltersTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE

	FGameplayTag ChildTag;
	FGameplayTag ParentTag;
	FGameplayTag UnrelatedTag;
	if (!TestTrue(
		TEXT("GameplayTagContainer hierarchy/filter test requires child/parent/unrelated gameplay tag fixture"),
		FindGameplayTagHierarchyFixture(ChildTag, ParentTag, UnrelatedTag)))
	{
		return false;
	}

	const FString ChildTagName = ChildTag.ToString().ReplaceCharWithEscapedChar();
	const FString ParentTagName = ParentTag.ToString().ReplaceCharWithEscapedChar();
	const FString UnrelatedTagName = UnrelatedTag.ToString().ReplaceCharWithEscapedChar();
	const FString Script = FString::Printf(TEXT(R"(
int Entry()
{
	FGameplayTag ChildTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	FGameplayTag ParentTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);
	FGameplayTag UnrelatedTag = FGameplayTag::RequestGameplayTag(FName("%s"), true);

	if (!ChildTag.IsValid() || !ParentTag.IsValid() || !UnrelatedTag.IsValid())
		return 10;

	FGameplayTagContainer ContainerA;
	ContainerA.AddTag(ChildTag);
	ContainerA.AddTagFast(UnrelatedTag);
	if (!ContainerA.HasTagExact(UnrelatedTag))
		return 20;

	FGameplayTagContainer ParentContainer;
	ParentContainer.AddTag(ParentTag);
	ParentContainer.AddTagFast(UnrelatedTag);

	FGameplayTagContainer Filtered = ContainerA.Filter(ParentContainer);
	if (!Filtered.HasTagExact(ChildTag))
		return 30;
	if (!Filtered.HasTagExact(UnrelatedTag))
		return 40;
	if (Filtered.Num() != 2)
		return 50;

	FGameplayTagContainer FilteredExact = ContainerA.FilterExact(ParentContainer);
	if (FilteredExact.HasTagExact(ChildTag))
		return 60;
	if (!FilteredExact.HasTagExact(UnrelatedTag))
		return 70;
	if (FilteredExact.Num() != 1)
		return 80;

	FGameplayTagContainer LeafContainer = ParentContainer;
	if (!LeafContainer.AddLeafTag(ChildTag))
		return 90;
	if (!LeafContainer.HasTagExact(ChildTag))
		return 100;
	if (LeafContainer.HasTagExact(ParentTag))
		return 110;
	if (!LeafContainer.HasTag(ParentTag))
		return 120;
	if (LeafContainer.Num() != 2)
		return 130;

	FGameplayTagContainer LeafFilteredExact = ContainerA.FilterExact(LeafContainer);
	if (!LeafFilteredExact.HasTagExact(ChildTag))
		return 140;
	if (!LeafFilteredExact.HasTagExact(UnrelatedTag))
		return 150;
	if (LeafFilteredExact.Num() != 2)
		return 160;

	FGameplayTagContainer ExpandedParents = ContainerA.GetGameplayTagParents();
	if (!ExpandedParents.HasTagExact(ChildTag))
		return 170;
	if (!ExpandedParents.HasTagExact(ParentTag))
		return 180;
	if (!ExpandedParents.HasTagExact(UnrelatedTag))
		return 190;

	FGameplayTagContainer RemoveContainer;
	RemoveContainer.AddTag(ChildTag);
	ContainerA.RemoveTags(RemoveContainer);
	if (ContainerA.HasTagExact(ChildTag))
		return 200;
	if (!ContainerA.HasTagExact(UnrelatedTag))
		return 210;
	if (ContainerA.Num() != 1)
		return 220;

	return 1;
}
)"), *ChildTagName, *ParentTagName, *UnrelatedTagName);

	asIScriptModule* Module = BuildModule(*this, Engine, "ASGameplayTagContainerHierarchyAndFilters", Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("GameplayTagContainer hierarchy/filter helpers should behave as expected"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

#endif
