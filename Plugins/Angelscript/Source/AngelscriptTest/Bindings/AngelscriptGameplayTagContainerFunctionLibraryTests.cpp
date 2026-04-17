#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "GameplayTagsManager.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace GameplayTagContainerFunctionLibraryTest
{
	static constexpr ANSICHAR RemoveTagMissModuleName[] = "ASGameplayTagContainerRemoveTagMiss";

	struct FRemoveTagMissReference
	{
		int32 RemoveMissing = 0;
		int32 NumAfterMissing = 0;
		int32 HasPresentAfterMissing = 0;
		int32 RemoveEmpty = 0;
		int32 NumAfterEmpty = 0;
		int32 HasPresentAfterEmpty = 0;
		int32 RemovePresent = 0;
		int32 NumAfterPresent = 0;
		int32 HasPresentAfterPresent = 0;
	};

	int32 BoolToScriptInt(const bool bValue)
	{
		return bValue ? 1 : 0;
	}

	bool FindPresentAndMissingTags(FGameplayTag& OutPresentTag, FGameplayTag& OutMissingTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> TagArray;
		AllTags.GetGameplayTagArray(TagArray);

		for (const FGameplayTag& CandidatePresentTag : TagArray)
		{
			if (!CandidatePresentTag.IsValid())
			{
				continue;
			}

			for (const FGameplayTag& CandidateMissingTag : TagArray)
			{
				if (!CandidateMissingTag.IsValid() || CandidateMissingTag == CandidatePresentTag)
				{
					continue;
				}

				if (CandidatePresentTag.MatchesTag(CandidateMissingTag) || CandidateMissingTag.MatchesTag(CandidatePresentTag))
				{
					continue;
				}

				OutPresentTag = CandidatePresentTag;
				OutMissingTag = CandidateMissingTag;
				return true;
			}
		}

		return false;
	}

	FRemoveTagMissReference CaptureReference(const FGameplayTag& PresentTag, const FGameplayTag& MissingTag)
	{
		FGameplayTagContainer Container;
		Container.AddTag(PresentTag);

		FRemoveTagMissReference Reference;
		Reference.RemoveMissing = BoolToScriptInt(Container.RemoveTag(MissingTag));
		Reference.NumAfterMissing = Container.Num();
		Reference.HasPresentAfterMissing = BoolToScriptInt(Container.HasTagExact(PresentTag));

		Reference.RemoveEmpty = BoolToScriptInt(Container.RemoveTag(FGameplayTag::EmptyTag));
		Reference.NumAfterEmpty = Container.Num();
		Reference.HasPresentAfterEmpty = BoolToScriptInt(Container.HasTagExact(PresentTag));

		Reference.RemovePresent = BoolToScriptInt(Container.RemoveTag(PresentTag));
		Reference.NumAfterPresent = Container.Num();
		Reference.HasPresentAfterPresent = BoolToScriptInt(Container.HasTagExact(PresentTag));
		return Reference;
	}

	FString BuildRemoveTagMissScript(
		const FString& PresentTagName,
		const FString& MissingTagName,
		const FRemoveTagMissReference& Reference,
		const bool bIntentionallyExpectWrongMissingResult)
	{
		FStringFormatOrderedArguments Arguments;
		Arguments.Add(PresentTagName);
		Arguments.Add(MissingTagName);
		Arguments.Add(bIntentionallyExpectWrongMissingResult ? 1 : Reference.RemoveMissing);
		Arguments.Add(Reference.NumAfterMissing);
		Arguments.Add(Reference.HasPresentAfterMissing);
		Arguments.Add(Reference.RemoveEmpty);
		Arguments.Add(Reference.NumAfterEmpty);
		Arguments.Add(Reference.HasPresentAfterEmpty);
		Arguments.Add(Reference.RemovePresent);
		Arguments.Add(Reference.NumAfterPresent);
		Arguments.Add(Reference.HasPresentAfterPresent);

		return FString::Format(TEXT(R"(
int Entry()
{
	FGameplayTag PresentTag = FGameplayTag::RequestGameplayTag(FName("{0}"), true);
	FGameplayTag MissingTag = FGameplayTag::RequestGameplayTag(FName("{1}"), true);
	if (!PresentTag.IsValid())
		return 10;
	if (!MissingTag.IsValid())
		return 20;
	if (PresentTag == MissingTag)
		return 30;

	FGameplayTagContainer Container;
	Container.AddTag(PresentTag);

	if ((Container.RemoveTag(MissingTag) ? 1 : 0) != {2})
		return 40;
	if (Container.Num() != {3})
		return 50;
	if ((Container.HasTagExact(PresentTag) ? 1 : 0) != {4})
		return 60;

	if ((Container.RemoveTag(FGameplayTag::EmptyTag) ? 1 : 0) != {5})
		return 70;
	if (Container.Num() != {6})
		return 80;
	if ((Container.HasTagExact(PresentTag) ? 1 : 0) != {7})
		return 90;

	if ((Container.RemoveTag(PresentTag) ? 1 : 0) != {8})
		return 100;
	if (Container.Num() != {9})
		return 110;
	if ((Container.HasTagExact(PresentTag) ? 1 : 0) != {10})
		return 120;
	if (!Container.IsEmpty())
		return 130;

	return 1;
}
)"), Arguments);
	}
}

using namespace GameplayTagContainerFunctionLibraryTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGameplayTagContainerRemoveTagMissTest,
	"Angelscript.TestModule.FunctionLibraries.GameplayTagContainerRemoveTagMiss",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGameplayTagContainerRemoveTagMissTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FGameplayTag PresentTag;
	FGameplayTag MissingTag;
	if (!TestTrue(
		TEXT("GameplayTagContainer remove-tag miss test requires two unrelated registered gameplay tags"),
		GameplayTagContainerFunctionLibraryTest::FindPresentAndMissingTags(PresentTag, MissingTag)))
	{
		return false;
	}

	const GameplayTagContainerFunctionLibraryTest::FRemoveTagMissReference Reference =
		GameplayTagContainerFunctionLibraryTest::CaptureReference(PresentTag, MissingTag);
	const FString Script = GameplayTagContainerFunctionLibraryTest::BuildRemoveTagMissScript(
		PresentTag.ToString().ReplaceCharWithEscapedChar(),
		MissingTag.ToString().ReplaceCharWithEscapedChar(),
		Reference,
		false);

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(ANSI_TO_TCHAR(GameplayTagContainerFunctionLibraryTest::RemoveTagMissModuleName));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		GameplayTagContainerFunctionLibraryTest::RemoveTagMissModuleName,
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
		TEXT("GameplayTagContainer.RemoveTag should preserve miss and empty-tag behavior exactly"),
		Result,
		1);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
