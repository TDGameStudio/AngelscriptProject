#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportDedupTests_Private
{
	FString GetPreprocessorImportDedupFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorImportDedupFixtures"));
	}

	FString WritePreprocessorImportDedupFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorImportDedupFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectImportDedupDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const TArray<FString>& AbsoluteFilenames,
		int32& OutErrorCount)
	{
		TArray<FString> Messages;
		OutErrorCount = 0;

		for (const FString& AbsoluteFilename : AbsoluteFilenames)
		{
			const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
			if (Diagnostics == nullptr)
			{
				continue;
			}

			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				Messages.Add(Diagnostic.Message);
				if (Diagnostic.bIsError)
				{
					++OutErrorCount;
				}
			}
		}

		return Messages;
	}

	const FAngelscriptModuleDesc* FindImportDedupModuleByName(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ModuleName)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			if (Module->ModuleName == ModuleName)
			{
				return &Module.Get();
			}
		}

		return nullptr;
	}

	FString JoinModuleCodeSections(const FAngelscriptModuleDesc& Module)
	{
		FString JoinedCode;

		for (const FAngelscriptModuleDesc::FCodeSection& CodeSection : Module.Code)
		{
			if (!JoinedCode.IsEmpty())
			{
				JoinedCode += TEXT("\n");
			}

			JoinedCode += CodeSection.Code;
		}

		return JoinedCode;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportDedupTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorDuplicateImportDedupTest,
	"Angelscript.TestModule.Preprocessor.Import.DuplicateStatementsDeduplicateDependency",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorDuplicateImportDedupTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/ImportDedup/Shared.as");
	const FString SharedAbsolutePath = WritePreprocessorImportDedupFixture(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 17;\n")
		TEXT("}\n"));

	const FString ConsumerRelativePath = TEXT("Tests/Preprocessor/ImportDedup/Consumer.as");
	const FString ConsumerAbsolutePath = WritePreprocessorImportDedupFixture(
		ConsumerRelativePath,
		TEXT("import Tests.Preprocessor.ImportDedup.Shared;\n")
		TEXT("import Tests.Preprocessor.ImportDedup.Shared;\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(ConsumerRelativePath, ConsumerAbsolutePath);
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FString ModuleOrder = FString::JoinBy(
		Modules,
		TEXT(" -> "),
		[](const TSharedRef<FAngelscriptModuleDesc>& Module)
		{
			return Module->ModuleName;
		});

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectImportDedupDiagnosticMessages(
		Engine,
		{SharedAbsolutePath, ConsumerAbsolutePath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Duplicate manual imports should still preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Duplicate manual imports should still emit exactly two modules"),
		Modules.Num(),
		2);
	bPassed &= TestEqual(
		TEXT("Duplicate manual imports should not emit preprocessing errors"),
		ErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Duplicate manual imports should keep preprocessing diagnostics empty"),
		DiagnosticSummary.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Duplicate manual imports should still preserve provider-first module ordering"),
		ModuleOrder,
		FString(TEXT("Tests.Preprocessor.ImportDedup.Shared -> Tests.Preprocessor.ImportDedup.Consumer")));

	const FAngelscriptModuleDesc* SharedModule = FindImportDedupModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportDedup.Shared"));
	const FAngelscriptModuleDesc* ConsumerModule = FindImportDedupModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportDedup.Consumer"));

	bPassed &= TestNotNull(
		TEXT("Duplicate manual imports should emit the provider module"),
		SharedModule);
	bPassed &= TestNotNull(
		TEXT("Duplicate manual imports should emit the consumer module"),
		ConsumerModule);

	if (SharedModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Provider module should still report zero imported dependencies"),
			SharedModule->ImportedModules.Num(),
			0);
	}

	if (ConsumerModule != nullptr)
	{
		const FString ProcessedCode = JoinModuleCodeSections(*ConsumerModule);

		bPassed &= TestEqual(
			TEXT("Consumer module should deduplicate repeated imported dependency metadata"),
			ConsumerModule->ImportedModules.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("Consumer module should retain the provider name after deduplication"),
			ConsumerModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.ImportDedup.Shared")));
		bPassed &= TestFalse(
			TEXT("Consumer module should strip all duplicate raw import statements from processed code"),
			ProcessedCode.Contains(TEXT("import Tests.Preprocessor.ImportDedup.Shared;")));
	}

	if (bPassed)
	{
		TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
		AngelscriptTestSupport::FScopedAutomaticImportsOverride AutomaticImportsOverride(Engine.GetScriptEngine());
		const ECompileResult CompileResult = Engine.CompileModules(ECompileType::SoftReloadOnly, Modules, CompiledModules);

		bPassed &= TestTrue(
			TEXT("Deduplicated import modules should compile successfully after preprocessing"),
			CompileResult == ECompileResult::FullyHandled || CompileResult == ECompileResult::PartiallyHandled);
		bPassed &= TestEqual(
			TEXT("Deduplicated import compile should produce two compiled modules"),
			CompiledModules.Num(),
			2);

		if (ConsumerModule != nullptr && TestNotNull(
			TEXT("Compiled consumer module should materialize a script module for execution"),
			ConsumerModule->ScriptModule))
		{
			asIScriptFunction* EntryFunction = AngelscriptTestSupport::GetFunctionByDecl(
				*this,
				*ConsumerModule->ScriptModule,
				TEXT("int Entry()"));

			int32 Result = 0;
			if (EntryFunction != nullptr)
			{
				bPassed &= AngelscriptTestSupport::ExecuteIntFunction(*this, Engine, *EntryFunction, Result);
				bPassed &= TestEqual(
					TEXT("Deduplicated import module should still execute through the provider dependency"),
					Result,
					17);
			}
			else
			{
				bPassed = false;
			}
		}
		else
		{
			bPassed = false;
		}
	}

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
