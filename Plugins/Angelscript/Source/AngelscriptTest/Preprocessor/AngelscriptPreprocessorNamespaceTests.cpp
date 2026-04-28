#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace PreprocessorNamespaceTest
{
	static const TCHAR* InvalidNamespaceMessage = TEXT("Invalid namespace declaration, expected '{' after namespace name.");

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorNamespaceFixtures"));
	}

	FString WriteFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	int32 CountErrorDiagnostics(const FAngelscriptEngine::FDiagnostics* Diagnostics)
	{
		if (Diagnostics == nullptr)
		{
			return 0;
		}

		int32 ErrorCount = 0;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			if (Diagnostic.bIsError)
			{
				++ErrorCount;
			}
		}

		return ErrorCount;
	}

	bool ContainsCompilableCode(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module->Code)
			{
				if (!Section.Code.IsEmpty())
				{
					return true;
				}
			}
		}

		return false;
	}

	const FAngelscriptPreprocessor::FChunk* FindFirstChunkOfType(
		const FAngelscriptPreprocessor& Preprocessor,
		const FAngelscriptPreprocessor::EChunkType ChunkType)
	{
		for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
		{
			for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
			{
				if (Chunk.Type == ChunkType)
				{
					return &Chunk;
				}
			}
		}

		return nullptr;
	}

	const FAngelscriptPreprocessor::FChunk* FindChunkContainingText(
		const FAngelscriptPreprocessor& Preprocessor,
		const FString& Needle)
	{
		for (const FAngelscriptPreprocessor::FFile& File : Preprocessor.Files)
		{
			for (const FAngelscriptPreprocessor::FChunk& Chunk : File.ChunkedCode)
			{
				if (Chunk.Content.Contains(Needle))
				{
					return &Chunk;
				}
			}
		}

		return nullptr;
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorInvalidNamespaceDeclarationReportsSyntaxTest,
	"Angelscript.TestModule.Preprocessor.Namespace.InvalidDeclarationReportsSyntax",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorInvalidNamespaceDeclarationReportsSyntaxTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedErrorPlain(PreprocessorNamespaceTest::InvalidNamespaceMessage, EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
	ASTEST_BEGIN_MODULE_CLEAN

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	const FString ScriptSource = TEXT(
		"namespace Gameplay\n"
		"UCLASS()\n"
		"class UBrokenNamespaceCarrier : UObject\n"
		"{\n"
		"}\n"
		"\n"
		"int Entry()\n"
		"{\n"
		"    return 7;\n"
		"}\n");

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Namespace/InvalidDeclarationReportsSyntax.as");
	const FString AbsoluteScriptPath = PreprocessorNamespaceTest::WriteFixture(RelativeScriptPath, ScriptSource);
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	const FAngelscriptPreprocessor::FChunk* ClassChunk =
		PreprocessorNamespaceTest::FindFirstChunkOfType(Preprocessor, FAngelscriptPreprocessor::EChunkType::Class);
	const FAngelscriptPreprocessor::FChunk* EntryChunk =
		PreprocessorNamespaceTest::FindChunkContainingText(Preprocessor, TEXT("int Entry()"));

	bPassed &= TestFalse(
		TEXT("Invalid namespace declaration should fail during preprocessing"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Invalid namespace declaration should keep exactly one module descriptor for inspection"),
		Modules.Num(),
		1);
	bPassed &= TestNotNull(
		TEXT("Invalid namespace declaration should emit diagnostics for the failing file"),
		Diagnostics);
	bPassed &= TestNotNull(
		TEXT("Invalid namespace declaration should still parse the class chunk before fail-closed cleanup"),
		ClassChunk);
	bPassed &= TestNotNull(
		TEXT("Invalid namespace declaration should still keep the trailing Entry chunk available for inspection"),
		EntryChunk);

	if (Diagnostics != nullptr && Diagnostics->Diagnostics.Num() > 0)
	{
		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		bPassed &= TestEqual(
			TEXT("Invalid namespace declaration should emit exactly one error diagnostic"),
			PreprocessorNamespaceTest::CountErrorDiagnostics(Diagnostics),
			1);
		bPassed &= TestEqual(
			TEXT("Invalid namespace declaration should report the expected namespace syntax error text"),
			FirstDiagnostic.Message,
			FString(PreprocessorNamespaceTest::InvalidNamespaceMessage));
		bPassed &= TestEqual(
			TEXT("Invalid namespace declaration should pin the diagnostic row to the namespace line"),
			FirstDiagnostic.Row,
			1);
		bPassed &= TestEqual(
			TEXT("Invalid namespace declaration should keep the diagnostic column at the namespace start"),
			FirstDiagnostic.Column,
			1);
	}

	if (ClassChunk != nullptr)
	{
		bPassed &= TestFalse(
			TEXT("Invalid namespace declaration should not leak Gameplay into the class chunk namespace"),
			ClassChunk->Namespace.IsSet());
	}

	if (EntryChunk != nullptr)
	{
		bPassed &= TestFalse(
			TEXT("Invalid namespace declaration should not leak Gameplay into the trailing global chunk namespace"),
			EntryChunk->Namespace.IsSet());
	}

	if (Modules.Num() == 1)
	{
		FAngelscriptModuleDesc& Module = Modules[0].Get();
		bPassed &= TestEqual(
			TEXT("Invalid namespace declaration should not emit any processed code sections"),
			Module.Code.Num(),
			0);
		bPassed &= TestNull(
			TEXT("Invalid namespace declaration should not surface a compilable class descriptor"),
			Module.GetClass(TEXT("UBrokenNamespaceCarrier")).Get());
	}

	bPassed &= TestFalse(
		TEXT("Invalid namespace declaration should not leave behind compilable code after preprocessing fails"),
		PreprocessorNamespaceTest::ContainsCompilableCode(Modules));

	ASTEST_END_MODULE_CLEAN
	return bPassed;
}

#endif
