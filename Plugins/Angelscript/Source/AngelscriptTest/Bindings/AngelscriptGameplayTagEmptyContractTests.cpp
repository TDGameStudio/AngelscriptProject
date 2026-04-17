#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "GameplayTagsManager.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptGameplayTagEmptyContractTests_Private
{
	struct FGameplayTagEmptyReference
	{
		int32 MatchesTag = 0;
		int32 MatchesTagExact = 0;
		int32 MatchesTagDepth = 0;
		int32 MatchesAny = 0;
		int32 MatchesAnyExact = 0;
		int32 SingleIsEmpty = 0;
		int32 SingleNum = 0;
		int32 SingleHasEmpty = 0;
		int32 SingleEqualsEmptyContainer = 0;
		int32 ParentIsValid = 0;
		int32 ParentEqualsEmpty = 0;
		int32 ParentsIsEmpty = 0;
		int32 ParentsNum = 0;
		int32 ParentsHasEmpty = 0;
		int32 ParentsHasValid = 0;
		int32 ParentsEqualsEmptyContainer = 0;
	};

	static constexpr ANSICHAR GameplayTagEmptyContractsModuleName[] = "ASGameplayTagEmptyContracts";

	int32 BoolToScriptInt(const bool bValue)
	{
		return bValue ? 1 : 0;
	}

	bool FindValidGameplayTag(FGameplayTag& OutValidTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);
		if (AllTags.Num() == 0)
		{
			return false;
		}

		OutValidTag = AllTags.First();
		return OutValidTag.IsValid();
	}

	FGameplayTagEmptyReference CaptureEmptyTagReference(const FGameplayTag& ValidTag)
	{
		FGameplayTagContainer ValidContainer;
		ValidContainer.AddTag(ValidTag);

		const FGameplayTag EmptyTag;
		const FGameplayTagContainer SingleContainer = EmptyTag.GetSingleTagContainer();
		const FGameplayTag DirectParent = EmptyTag.RequestDirectParent();
		const FGameplayTagContainer ParentChain = EmptyTag.GetGameplayTagParents();

		FGameplayTagEmptyReference Reference;
		Reference.MatchesTag = BoolToScriptInt(EmptyTag.MatchesTag(ValidTag));
		Reference.MatchesTagExact = BoolToScriptInt(EmptyTag.MatchesTagExact(ValidTag));
		Reference.MatchesTagDepth = EmptyTag.MatchesTagDepth(ValidTag);
		Reference.MatchesAny = BoolToScriptInt(EmptyTag.MatchesAny(ValidContainer));
		Reference.MatchesAnyExact = BoolToScriptInt(EmptyTag.MatchesAnyExact(ValidContainer));
		Reference.SingleIsEmpty = BoolToScriptInt(SingleContainer.IsEmpty());
		Reference.SingleNum = SingleContainer.Num();
		Reference.SingleHasEmpty = BoolToScriptInt(SingleContainer.HasTagExact(FGameplayTag::EmptyTag));
		Reference.SingleEqualsEmptyContainer = BoolToScriptInt(SingleContainer == FGameplayTagContainer::EmptyContainer);
		Reference.ParentIsValid = BoolToScriptInt(DirectParent.IsValid());
		Reference.ParentEqualsEmpty = BoolToScriptInt(DirectParent == FGameplayTag::EmptyTag);
		Reference.ParentsIsEmpty = BoolToScriptInt(ParentChain.IsEmpty());
		Reference.ParentsNum = ParentChain.Num();
		Reference.ParentsHasEmpty = BoolToScriptInt(ParentChain.HasTagExact(FGameplayTag::EmptyTag));
		Reference.ParentsHasValid = BoolToScriptInt(ParentChain.HasTagExact(ValidTag));
		Reference.ParentsEqualsEmptyContainer = BoolToScriptInt(ParentChain == FGameplayTagContainer::EmptyContainer);
		return Reference;
	}

	FString BuildGameplayTagEmptyContractsScript(const FString& ValidTagName, const FGameplayTagEmptyReference& Reference)
	{
		FStringFormatOrderedArguments Arguments;
		Arguments.Add(ValidTagName);
		Arguments.Add(Reference.MatchesTag);
		Arguments.Add(Reference.MatchesTagExact);
		Arguments.Add(Reference.MatchesTagDepth);
		Arguments.Add(Reference.MatchesAny);
		Arguments.Add(Reference.MatchesAnyExact);
		Arguments.Add(Reference.SingleIsEmpty);
		Arguments.Add(Reference.SingleNum);
		Arguments.Add(Reference.SingleHasEmpty);
		Arguments.Add(Reference.SingleEqualsEmptyContainer);
		Arguments.Add(Reference.ParentIsValid);
		Arguments.Add(Reference.ParentEqualsEmpty);
		Arguments.Add(Reference.ParentsIsEmpty);
		Arguments.Add(Reference.ParentsNum);
		Arguments.Add(Reference.ParentsHasEmpty);
		Arguments.Add(Reference.ParentsHasValid);
		Arguments.Add(Reference.ParentsEqualsEmptyContainer);

		return FString::Format(TEXT(R"(
int Entry()
{
	FGameplayTag EmptyTag;
	FGameplayTag ValidTag = FGameplayTag::RequestGameplayTag(FName("{0}"), true);
	if (!ValidTag.IsValid())
		return 10;

	FGameplayTagContainer ValidContainer;
	ValidContainer.AddTag(ValidTag);

	if (!ValidTag.MatchesTagExact(ValidTag))
		return 20;
	if (!ValidTag.MatchesAnyExact(ValidContainer))
		return 30;
	if (!ValidTag.GetSingleTagContainer().HasTagExact(ValidTag))
		return 40;

	if ((EmptyTag.MatchesTag(ValidTag) ? 1 : 0) != {1})
		return 50;
	if ((EmptyTag.MatchesTagExact(ValidTag) ? 1 : 0) != {2})
		return 60;
	if (EmptyTag.MatchesTagDepth(ValidTag) != {3})
		return 70;
	if ((EmptyTag.MatchesAny(ValidContainer) ? 1 : 0) != {4})
		return 80;
	if ((EmptyTag.MatchesAnyExact(ValidContainer) ? 1 : 0) != {5})
		return 90;

	FGameplayTagContainer SingleContainer = EmptyTag.GetSingleTagContainer();
	if ((SingleContainer.IsEmpty() ? 1 : 0) != {6})
		return 100;
	if (SingleContainer.Num() != {7})
		return 110;
	if ((SingleContainer.HasTagExact(FGameplayTag::EmptyTag) ? 1 : 0) != {8})
		return 120;
	if ((SingleContainer == FGameplayTagContainer::EmptyContainer ? 1 : 0) != {9})
		return 130;
	if (SingleContainer.HasTagExact(ValidTag))
		return 140;

	FGameplayTag DirectParent = EmptyTag.RequestDirectParent();
	if ((DirectParent.IsValid() ? 1 : 0) != {10})
		return 150;
	if ((DirectParent == FGameplayTag::EmptyTag ? 1 : 0) != {11})
		return 160;
	if (DirectParent == ValidTag)
		return 170;

	FGameplayTagContainer ParentChain = EmptyTag.GetGameplayTagParents();
	if ((ParentChain.IsEmpty() ? 1 : 0) != {12})
		return 180;
	if (ParentChain.Num() != {13})
		return 190;
	if ((ParentChain.HasTagExact(FGameplayTag::EmptyTag) ? 1 : 0) != {14})
		return 200;
	if ((ParentChain.HasTagExact(ValidTag) ? 1 : 0) != {15})
		return 210;
	if ((ParentChain == FGameplayTagContainer::EmptyContainer ? 1 : 0) != {16})
		return 220;

	return 1;
}
)"), Arguments);
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptGameplayTagEmptyContractTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagEmptyContractBindingsTest,
	"Angelscript.TestModule.Bindings.GameplayTagEmptyTagContracts",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGameplayTagEmptyContractBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag ValidTag;
	if (!TestTrue(
		TEXT("GameplayTag empty-contract test requires at least one registered gameplay tag"),
		FindValidGameplayTag(ValidTag)))
	{
		return false;
	}

	const FGameplayTagEmptyReference Reference = CaptureEmptyTagReference(ValidTag);
	const FString Script = BuildGameplayTagEmptyContractsScript(
		ValidTag.ToString().ReplaceCharWithEscapedChar(),
		Reference);

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASGameplayTagEmptyContracts"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		GameplayTagEmptyContractsModuleName,
		Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	bPassed = TestEqual(
		TEXT("GameplayTag empty-tag helpers should mirror native empty-tag contracts and stay fail-closed against a valid tag/container"),
		Result,
		1);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
