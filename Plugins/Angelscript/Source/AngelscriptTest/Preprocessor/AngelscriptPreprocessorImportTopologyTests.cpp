#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportTopologyTests_Private
{
	FString GetPreprocessorImportTopologyFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorImportTopologyFixtures"));
	}

	FString WritePreprocessorImportTopologyFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorImportTopologyFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectImportTopologyDiagnosticMessages(
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

	const FAngelscriptModuleDesc* FindImportTopologyModuleByName(
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
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorImportTopologyTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorTopologicalImportOrderTest,
	"Angelscript.TestModule.Preprocessor.Import.TopologicalOrderRespectsDependencyChain",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorTopologicalImportOrderTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString BaseRelativePath = TEXT("Tests/Preprocessor/ImportTopology/Base.as");
	const FString BaseAbsolutePath = WritePreprocessorImportTopologyFixture(
		BaseRelativePath,
		TEXT("int BaseValue()\n")
		TEXT("{\n")
		TEXT("    return 2;\n")
		TEXT("}\n"));

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/ImportTopology/Shared.as");
	const FString SharedAbsolutePath = WritePreprocessorImportTopologyFixture(
		SharedRelativePath,
		TEXT("import Tests.Preprocessor.ImportTopology.Base;\n")
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return BaseValue() + 3;\n")
		TEXT("}\n"));

	const FString ConsumerRelativePath = TEXT("Tests/Preprocessor/ImportTopology/Consumer.as");
	const FString ConsumerAbsolutePath = WritePreprocessorImportTopologyFixture(
		ConsumerRelativePath,
		TEXT("import Tests.Preprocessor.ImportTopology.Shared;\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return SharedValue() + 5;\n")
		TEXT("}\n"));

	TGuardValue<bool> AutomaticImportGuard(Engine.bUseAutomaticImportMethod, false);
	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(ConsumerRelativePath, ConsumerAbsolutePath);
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(BaseRelativePath, BaseAbsolutePath);

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
	const TArray<FString> DiagnosticMessages = CollectImportTopologyDiagnosticMessages(
		Engine,
		{BaseAbsolutePath, SharedAbsolutePath, ConsumerAbsolutePath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Provider-first topology test should preprocess successfully in manual import mode"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Provider-first topology test should emit exactly three module descriptors"),
		Modules.Num(),
		3);
	bPassed &= TestEqual(
		TEXT("Provider-first topology test should not emit preprocessing errors"),
		ErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Provider-first topology test should keep diagnostics empty"),
		DiagnosticSummary.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Provider-first topology test should order modules as Base -> Shared -> Consumer"),
		ModuleOrder,
		FString(TEXT("Tests.Preprocessor.ImportTopology.Base -> Tests.Preprocessor.ImportTopology.Shared -> Tests.Preprocessor.ImportTopology.Consumer")));

	const FAngelscriptModuleDesc* BaseModule = FindImportTopologyModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportTopology.Base"));
	const FAngelscriptModuleDesc* SharedModule = FindImportTopologyModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportTopology.Shared"));
	const FAngelscriptModuleDesc* ConsumerModule = FindImportTopologyModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.ImportTopology.Consumer"));

	bPassed &= TestNotNull(
		TEXT("Provider-first topology test should emit the base provider module"),
		BaseModule);
	bPassed &= TestNotNull(
		TEXT("Provider-first topology test should emit the shared provider module"),
		SharedModule);
	bPassed &= TestNotNull(
		TEXT("Provider-first topology test should emit the consumer module"),
		ConsumerModule);

	if (BaseModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Base provider should not record any imported modules"),
			BaseModule->ImportedModules.Num(),
			0);
	}

	if (SharedModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Shared provider should record exactly one imported module"),
			SharedModule->ImportedModules.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("Shared provider should record Base as its only dependency"),
			SharedModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.ImportTopology.Base")));
		bPassed &= TestTrue(
			TEXT("Shared provider should materialize at least one code section"),
			SharedModule->Code.Num() > 0);
		if (SharedModule->Code.Num() > 0)
		{
			bPassed &= TestFalse(
				TEXT("Shared provider should strip its raw import statement from processed code"),
				SharedModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.ImportTopology.Base;")));
		}
	}

	if (ConsumerModule != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Consumer should record exactly one imported module"),
			ConsumerModule->ImportedModules.Num(),
			1);
		bPassed &= TestTrue(
			TEXT("Consumer should record Shared as its only dependency"),
			ConsumerModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.ImportTopology.Shared")));
		bPassed &= TestTrue(
			TEXT("Consumer should materialize at least one code section"),
			ConsumerModule->Code.Num() > 0);
		if (ConsumerModule->Code.Num() > 0)
		{
			bPassed &= TestFalse(
				TEXT("Consumer should strip its raw import statement from processed code"),
				ConsumerModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.ImportTopology.Shared;")));
		}
	}

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
