#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace ASClassMetadataTests
{
	struct FDeveloperOnlyModuleCase
	{
		FName ModuleName;
		FString Filename;
		FName GeneratedClassName;
		bool bExpectedDeveloperOnly = false;
	};

	UASClass* CompileMetadataCase(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FDeveloperOnlyModuleCase& TestCase)
	{
		const FString ScriptSource = FString::Printf(
			TEXT(R"AS(
UCLASS()
class %s : AActor
{
}
)AS"),
			*TestCase.GeneratedClassName.ToString());

		if (!Test.TestTrue(
			*FString::Printf(TEXT("ASClass metadata case '%s' should compile"), *TestCase.ModuleName.ToString()),
			CompileAnnotatedModuleFromMemory(&Engine, TestCase.ModuleName, TestCase.Filename, ScriptSource)))
		{
			return nullptr;
		}

		UASClass* GeneratedClass = Cast<UASClass>(FindGeneratedClass(&Engine, TestCase.GeneratedClassName));
		Test.TestNotNull(
			*FString::Printf(TEXT("ASClass metadata case '%s' should generate '%s'"), *TestCase.ModuleName.ToString(), *TestCase.GeneratedClassName.ToString()),
			GeneratedClass);
		return GeneratedClass;
	}
}

using namespace ASClassMetadataTests;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassIsDeveloperOnlyRecognizesNestedEditorModuleNamesTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.IsDeveloperOnlyRecognizesNestedEditorModuleNames",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassIsFunctionImplementedInScriptTurnsFalseAfterDiscardTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.IsFunctionImplementedInScriptTurnsFalseAfterDiscard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-behavior): IsFunctionImplementedInScript returns true after DiscardModule+GC on UE 5.7; investigate UFunction lifecycle change

bool FAngelscriptASClassIsDeveloperOnlyRecognizesNestedEditorModuleNamesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	const TArray<ASClassMetadataTests::FDeveloperOnlyModuleCase> Cases =
	{
		{
			FName(TEXT("Game.Tools.Editor.Visualizers")),
			TEXT("Game/Tools/Editor/Visualizers.as"),
			FName(TEXT("ANestedEditorVisualizerActor")),
			true
		},
		{
			FName(TEXT("Editor.Visualizers")),
			TEXT("Editor/Visualizers.as"),
			FName(TEXT("APrefixedEditorVisualizerActor")),
			true
		},
		{
			FName(TEXT("Game.Tools.Runtime.Visualizers")),
			TEXT("Game/Tools/Runtime/Visualizers.as"),
			FName(TEXT("ARuntimeVisualizerActor")),
			false
		}
	};

	ON_SCOPE_EXIT
	{
		for (const ASClassMetadataTests::FDeveloperOnlyModuleCase& TestCase : Cases)
		{
			Engine.DiscardModule(*TestCase.ModuleName.ToString());
		}
		ResetSharedCloneEngine(Engine);
	};

	for (const ASClassMetadataTests::FDeveloperOnlyModuleCase& TestCase : Cases)
	{
		UASClass* GeneratedClass = ASClassMetadataTests::CompileMetadataCase(*this, Engine, TestCase);
		if (GeneratedClass == nullptr)
		{
			return false;
		}

		TestEqual(
			*FString::Printf(
				TEXT("ASClass metadata case '%s' should report the expected developer-only state"),
				*TestCase.ModuleName.ToString()),
			GeneratedClass->IsDeveloperOnly(),
			TestCase.bExpectedDeveloperOnly);
	}

	ASTEST_END_SHARE_FRESH
	return true;
}

bool FAngelscriptASClassIsFunctionImplementedInScriptTurnsFalseAfterDiscardTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	static const FName ModuleName(TEXT("Game.Tools.Runtime.DiscardMetadata"));
	static const FName GeneratedClassName(TEXT("UMetadataDiscardCarrier"));
	bool bModuleDiscarded = false;
	ON_SCOPE_EXIT
	{
		if (!bModuleDiscarded)
		{
			Engine.DiscardModule(*ModuleName.ToString());
		}
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UMetadataDiscardCarrier : UObject
{
	UFUNCTION()
	int ComputeValue()
	{
		return 7;
	}
}
)AS");

	if (!TestTrue(
			TEXT("ASClass discard metadata case should compile"),
			CompileAnnotatedModuleFromMemory(
				&Engine,
				ModuleName,
				TEXT("Game/Tools/Runtime/DiscardMetadata.as"),
				ScriptSource)))
	{
		return false;
	}

	UASClass* GeneratedClass = Cast<UASClass>(FindGeneratedClass(&Engine, GeneratedClassName));
	if (!TestNotNull(TEXT("ASClass discard metadata case should generate the script class"), GeneratedClass))
	{
		return false;
	}

	UASFunction* GeneratedFunction = Cast<UASFunction>(FindGeneratedFunction(GeneratedClass, TEXT("ComputeValue")));
	if (!TestNotNull(TEXT("ASClass discard metadata case should resolve the generated script function"), GeneratedFunction))
	{
		return false;
	}

	const bool bImplementedBeforeDiscard = GeneratedClass->IsFunctionImplementedInScript(TEXT("ComputeValue"));
	const FString SourcePathBeforeDiscard = GeneratedFunction->GetSourceFilePath();
	const int32 SourceLineBeforeDiscard = GeneratedFunction->GetSourceLineNumber();

	Engine.DiscardModule(*ModuleName.ToString());
	bModuleDiscarded = true;

	// UE 5.7: post-Discard cleanup of UASClass' IsFunctionImplementedInScript
	// book-keeping + source-file metadata is driven by GC finalization rather
	// than by the DiscardModule call itself. Force one pass so the asserts
	// below observe the fully-cleaned state.
	CollectGarbage(RF_NoFlags, true);

	const bool bImplementedAfterDiscard = GeneratedClass->IsFunctionImplementedInScript(TEXT("ComputeValue"));
	const FString SourcePathAfterDiscard = GeneratedFunction->GetSourceFilePath();
	const int32 SourceLineAfterDiscard = GeneratedFunction->GetSourceLineNumber();

	TestTrue(TEXT("ASClass should report the function implemented before discard"), bImplementedBeforeDiscard);
	TestFalse(TEXT("ASClass should stop reporting the function implemented after discard"), bImplementedAfterDiscard);
	TestFalse(TEXT("Generated script function should expose a non-empty source path before discard"), SourcePathBeforeDiscard.IsEmpty());
	TestTrue(TEXT("Generated script function should expose a positive source line before discard"), SourceLineBeforeDiscard > 0);
	TestTrue(
		TEXT("Generated script function should clear its source metadata after discard"),
		SourcePathAfterDiscard.IsEmpty() || SourceLineAfterDiscard == -1);

	bPassed =
		bImplementedBeforeDiscard
		&& !bImplementedAfterDiscard
		&& !SourcePathBeforeDiscard.IsEmpty()
		&& SourceLineBeforeDiscard > 0
		&& (SourcePathAfterDiscard.IsEmpty() || SourceLineAfterDiscard == -1);

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
