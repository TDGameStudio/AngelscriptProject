#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorMacroShapeTests_Private
{
	FString GetPreprocessorMacroShapeFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorMacroShapeFixtures"));
	}

	FString WritePreprocessorMacroShapeFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorMacroShapeFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<const FAngelscriptPreprocessor::FMacro*> GatherMacros(const FAngelscriptPreprocessor& Preprocessor)
	{
		TArray<const FAngelscriptPreprocessor::FMacro*> Macros;
		for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
		{
			for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
			{
				for (const FAngelscriptPreprocessor::FMacro& Macro : Chunk.Macros)
				{
					Macros.Add(&Macro);
				}
			}
		}

		return Macros;
	}

	const FAngelscriptPreprocessor::FMacro* FindMacroByTypeAndName(
		const TArray<const FAngelscriptPreprocessor::FMacro*>& Macros,
		const FAngelscriptPreprocessor::EMacroType Type,
		const FString& Name)
	{
		for (const FAngelscriptPreprocessor::FMacro* Macro : Macros)
		{
			if (Macro != nullptr && Macro->Type == Type && Macro->Name == Name)
			{
				return Macro;
			}
		}

		return nullptr;
	}

	const FAngelscriptPreprocessor::FMacro* FindMacroByTypeAndSubjectIndex(
		const TArray<const FAngelscriptPreprocessor::FMacro*>& Macros,
		const FAngelscriptPreprocessor::EMacroType Type,
		const int32 SubjectIndex)
	{
		for (const FAngelscriptPreprocessor::FMacro* Macro : Macros)
		{
			if (Macro != nullptr && Macro->Type == Type && Macro->SubjectIndex == SubjectIndex)
			{
				return Macro;
			}
		}

		return nullptr;
	}

	const FAngelscriptPreprocessor::FChunk* FindChunkContainingMacro(
		const FAngelscriptPreprocessor& Preprocessor,
		const FAngelscriptPreprocessor::FMacro& TargetMacro)
	{
		for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
		{
			for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
			{
				for (const FAngelscriptPreprocessor::FMacro& Macro : Chunk.Macros)
				{
					if (&Macro == &TargetMacro)
					{
						return &Chunk;
					}
				}
			}
		}

		return nullptr;
	}

	int32 FindLineNumberContaining(const FString& Source, const FString& Needle)
	{
		const int32 MatchIndex = Source.Find(Needle, ESearchCase::CaseSensitive);
		if (MatchIndex == INDEX_NONE)
		{
			return INDEX_NONE;
		}

		int32 LineNumber = 1;
		for (int32 Index = 0; Index < MatchIndex; ++Index)
		{
			if (Source[Index] == '\n')
			{
				++LineNumber;
			}
		}

		return LineNumber;
	}

	int32 CountDiagnostics(const FAngelscriptEngine::FDiagnostics* Diagnostics)
	{
		return Diagnostics != nullptr ? Diagnostics->Diagnostics.Num() : 0;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorMacroShapeTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorClassEnumMetaShapesTest,
	"Angelscript.TestModule.Preprocessor.Macros.ClassEnumMetaShapes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorClassEnumMetaShapesTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	const FString ScriptSource =
		TEXT("UCLASS(Abstract, BlueprintType)\n")
		TEXT("class UMacroCarrier : UObject\n")
		TEXT("{\n")
		TEXT("}\n")
		TEXT("\n")
		TEXT("UENUM(BlueprintType)\n")
		TEXT("enum class EMacroState : uint8\n")
		TEXT("{\n")
		TEXT("    // Alpha Friendly\n")
		TEXT("    Alpha,\n")
		TEXT("    Beta UMETA(DisplayName=\"Beta Friendly\"),\n")
		TEXT("};\n");

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/MacroShapes/ClassEnumMetaShapes.as");
	const FString AbsoluteScriptPath = WritePreprocessorMacroShapeFixture(RelativeScriptPath, ScriptSource);
	const int32 ExpectedClassLine = FindLineNumberContaining(ScriptSource, TEXT("UCLASS("));
	const int32 ExpectedEnumLine = FindLineNumberContaining(ScriptSource, TEXT("UENUM("));
	const int32 ExpectedAlphaValueLine = FindLineNumberContaining(ScriptSource, TEXT("Alpha,"));
	const int32 ExpectedBetaMetaLine = FindLineNumberContaining(ScriptSource, TEXT("UMETA(DisplayName=\"Beta Friendly\")"));

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	const TArray<const FAngelscriptPreprocessor::FMacro*> Macros = GatherMacros(Preprocessor);
	const FAngelscriptPreprocessor::FMacro* ClassMacro =
		FindMacroByTypeAndName(Macros, FAngelscriptPreprocessor::EMacroType::Class, TEXT("UMacroCarrier"));
	const FAngelscriptPreprocessor::FMacro* EnumMacro =
		FindMacroByTypeAndName(Macros, FAngelscriptPreprocessor::EMacroType::Enum, TEXT("EMacroState"));
	const FAngelscriptPreprocessor::FMacro* EnumValueMacro =
		FindMacroByTypeAndSubjectIndex(Macros, FAngelscriptPreprocessor::EMacroType::EnumValue, 0);
	const FAngelscriptPreprocessor::FMacro* EnumMetaMacro =
		FindMacroByTypeAndSubjectIndex(Macros, FAngelscriptPreprocessor::EMacroType::EnumMeta, 1);

	bPassed &= TestTrue(
		TEXT("Class/enum/meta macro shape fixture should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Class/enum/meta macro shape fixture should not emit diagnostics"),
		CountDiagnostics(Diagnostics),
		0);
	bPassed &= TestEqual(
		TEXT("Class/enum/meta macro shape fixture should emit exactly four macro records"),
		Macros.Num(),
		4);
	bPassed &= TestNotNull(
		TEXT("Macro set should include a named UCLASS record for UMacroCarrier"),
		ClassMacro);
	bPassed &= TestNotNull(
		TEXT("Macro set should include a named UENUM record for EMacroState"),
		EnumMacro);
	bPassed &= TestNotNull(
		TEXT("Macro set should include an EnumValue record for subject index 0"),
		EnumValueMacro);
	bPassed &= TestNotNull(
		TEXT("Macro set should include an EnumMeta record for subject index 1"),
		EnumMetaMacro);

	if (ClassMacro != nullptr)
	{
		const FAngelscriptPreprocessor::FChunk* ClassChunk = FindChunkContainingMacro(Preprocessor, *ClassMacro);
		bPassed &= TestEqual(
			TEXT("UCLASS record should keep the original class specifier list"),
			ClassMacro->Arguments,
			FString(TEXT("Abstract, BlueprintType")));
		bPassed &= TestEqual(
			TEXT("UCLASS record should keep a stable source line number"),
			ClassMacro->FileLineNumber,
			ExpectedClassLine);
		bPassed &= TestNotNull(
			TEXT("UCLASS record should stay attached to a class chunk"),
			ClassChunk);
		if (ClassChunk != nullptr)
		{
			bPassed &= TestEqual(
				TEXT("UCLASS record should belong to a class chunk"),
				static_cast<int32>(ClassChunk->Type),
				static_cast<int32>(FAngelscriptPreprocessor::EChunkType::Class));
			bPassed &= TestNotNull(
				TEXT("UCLASS chunk should keep the resolved class descriptor"),
				ClassChunk->ClassDesc.Get());
			if (ClassChunk->ClassDesc.IsValid())
			{
				bPassed &= TestEqual(
					TEXT("UCLASS chunk should resolve the same class name as the macro"),
					ClassChunk->ClassDesc->ClassName,
					FString(TEXT("UMacroCarrier")));
			}
		}
	}

	if (EnumMacro != nullptr)
	{
		const FAngelscriptPreprocessor::FChunk* EnumChunk = FindChunkContainingMacro(Preprocessor, *EnumMacro);
		bPassed &= TestEqual(
			TEXT("UENUM record should keep the original enum specifier list"),
			EnumMacro->Arguments,
			FString(TEXT("BlueprintType")));
		bPassed &= TestEqual(
			TEXT("UENUM record should keep a stable source line number"),
			EnumMacro->FileLineNumber,
			ExpectedEnumLine);
		bPassed &= TestNotNull(
			TEXT("UENUM record should stay attached to an enum chunk"),
			EnumChunk);
		if (EnumChunk != nullptr)
		{
			bPassed &= TestEqual(
				TEXT("UENUM record should belong to an enum chunk"),
				static_cast<int32>(EnumChunk->Type),
				static_cast<int32>(FAngelscriptPreprocessor::EChunkType::Enum));
		}
	}

	if (EnumValueMacro != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("EnumValue record should preserve the preceding comment text"),
			EnumValueMacro->Comment.Contains(TEXT("Alpha Friendly")));
		bPassed &= TestEqual(
			TEXT("EnumValue record should pin its subject index to the first enum entry"),
			EnumValueMacro->SubjectIndex,
			0);
		bPassed &= TestEqual(
			TEXT("EnumValue record should keep a stable source line number"),
			EnumValueMacro->FileLineNumber,
			ExpectedAlphaValueLine);
	}

	if (EnumMetaMacro != nullptr)
	{
		bPassed &= TestTrue(
			TEXT("EnumMeta record should preserve the DisplayName payload"),
			EnumMetaMacro->Arguments.Contains(TEXT("DisplayName=\"Beta Friendly\"")));
		bPassed &= TestEqual(
			TEXT("EnumMeta record should pin its subject index to the second enum entry"),
			EnumMetaMacro->SubjectIndex,
			1);
		bPassed &= TestEqual(
			TEXT("EnumMeta record should keep a stable source line number"),
			EnumMetaMacro->FileLineNumber,
			ExpectedBetaMetaLine);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
