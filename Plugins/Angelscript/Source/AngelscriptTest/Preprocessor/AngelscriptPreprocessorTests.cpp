#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "Preprocessor/AngelscriptPreprocessor.h"
#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorTests_Private
{
	FAngelscriptEngine* GetEngineForPreprocessorTests(FAutomationTestBase* Test)
	{
		if (FAngelscriptEngine* ProductionEngine = AngelscriptTestSupport::TryGetRunningProductionEngine())
		{
			return ProductionEngine;
		}

		return &AngelscriptTestSupport::GetOrCreateSharedCloneEngine();
	}

	FString GetPreprocessorFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorFixtures"));
	}

	FString WriteFixtureFile(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	const FAngelscriptModuleDesc* FindModuleByName(
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
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorBasicParseTest,
	"Angelscript.TestModule.Preprocessor.BasicParse",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorBasicParseTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* Engine = GetEngineForPreprocessorTests(this);
	if (!TestNotNull(TEXT("Preprocessor basic parse test should have an initialized engine"), Engine))
	{
		return false;
	}

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/BasicModule.as");
	const FString AbsoluteScriptPath = WriteFixtureFile(
		RelativeScriptPath,
		TEXT("int ReturnSeven()\n")
		TEXT("{\n")
		TEXT("    return 7;\n")
		TEXT("}\n"));

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	if (!TestTrue(TEXT("Preprocessor should succeed for a minimal script module"), Preprocessor.Preprocess()))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	if (!TestEqual(TEXT("Basic parse should yield exactly one module"), Modules.Num(), 1))
	{
		return false;
	}

	const FAngelscriptModuleDesc& Module = Modules[0].Get();
	TestEqual(TEXT("Basic parse should normalize the module name from the relative filename"), Module.ModuleName, FString(TEXT("Tests.Preprocessor.BasicModule")));
	if (!TestEqual(TEXT("Basic parse should emit a single code section"), Module.Code.Num(), 1))
	{
		return false;
	}

	TestTrue(TEXT("Processed code should still contain the function body"), Module.Code[0].Code.Contains(TEXT("ReturnSeven")));
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorMacroDetectionTest,
	"Angelscript.TestModule.Preprocessor.MacroDetection",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorMacroDetectionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* Engine = GetEngineForPreprocessorTests(this);
	if (!TestNotNull(TEXT("Preprocessor macro test should have an initialized engine"), Engine))
	{
		return false;
	}

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/MacroActor.as");
	const FString AbsoluteScriptPath = WriteFixtureFile(
		RelativeScriptPath,
		TEXT("class AMacroActor : AActor\n")
		TEXT("{\n")
		TEXT("    UPROPERTY(EditAnywhere, BlueprintReadWrite)\n")
		TEXT("    UStaticMesh Mesh;\n\n")
		TEXT("    UFUNCTION(BlueprintOverride)\n")
		TEXT("    void BeginPlay()\n")
		TEXT("    {\n")
		TEXT("    }\n")
		TEXT("}\n"));

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	if (!TestTrue(TEXT("Preprocessor should succeed for a script containing property/function macros"), Preprocessor.Preprocess()))
	{
		return false;
	}

	const TArray<const FAngelscriptPreprocessor::FMacro*> Macros = GatherMacros(Preprocessor);
	const bool bHasPropertyMacro = Macros.ContainsByPredicate([](const FAngelscriptPreprocessor::FMacro* Macro)
	{
		return Macro->Type == FAngelscriptPreprocessor::EMacroType::Property && Macro->Name == TEXT("Mesh");
	});
	const bool bHasFunctionMacro = Macros.ContainsByPredicate([](const FAngelscriptPreprocessor::FMacro* Macro)
	{
		return Macro->Type == FAngelscriptPreprocessor::EMacroType::Function && Macro->Name == TEXT("BeginPlay");
	});

	TestTrue(TEXT("Preprocessor should record the UPROPERTY macro for Mesh"), bHasPropertyMacro);
	TestTrue(TEXT("Preprocessor should record the UFUNCTION macro for BeginPlay"), bHasFunctionMacro);
	return bHasPropertyMacro && bHasFunctionMacro;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorImportTest,
	"Angelscript.TestModule.Preprocessor.ImportParsing",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorImportTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine* Engine = GetEngineForPreprocessorTests(this);
	if (!TestNotNull(TEXT("Preprocessor import test should have an initialized engine"), Engine))
	{
		return false;
	}

	const FString SharedRelativePath = TEXT("Tests/Preprocessor/Shared.as");
	const FString SharedAbsolutePath = WriteFixtureFile(
		SharedRelativePath,
		TEXT("int SharedValue()\n")
		TEXT("{\n")
		TEXT("    return 11;\n")
		TEXT("}\n"));

	const FString ImportingRelativePath = TEXT("Tests/Preprocessor/UsesImport.as");
	const FString ImportingAbsolutePath = WriteFixtureFile(
		ImportingRelativePath,
		TEXT("import Tests.Preprocessor.Shared;\n")
		TEXT("int UseShared()\n")
		TEXT("{\n")
		TEXT("    return SharedValue();\n")
		TEXT("}\n"));

	FAngelscriptPreprocessor Preprocessor;
	TGuardValue<bool> AutomaticImportGuard(Engine->bUseAutomaticImportMethod, false);
	Preprocessor.AddFile(SharedRelativePath, SharedAbsolutePath);
	Preprocessor.AddFile(ImportingRelativePath, ImportingAbsolutePath);

	if (!TestTrue(TEXT("Preprocessor should succeed when resolving a manual import"), Preprocessor.Preprocess()))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	if (!TestEqual(TEXT("Import parse should keep both modules available for compilation"), Modules.Num(), 2))
	{
		return false;
	}

	const FAngelscriptModuleDesc* ImportingModule = FindModuleByName(Modules, TEXT("Tests.Preprocessor.UsesImport"));
	if (!TestNotNull(TEXT("Import parse should produce the importing module"), ImportingModule))
	{
		return false;
	}

	const bool bTracksImport = ImportingModule->ImportedModules.Contains(TEXT("Tests.Preprocessor.Shared"));
	TestTrue(TEXT("Import parse should record the imported module name"), bTracksImport);
	TestFalse(TEXT("The import statement should be removed from the processed code"), ImportingModule->Code[0].Code.Contains(TEXT("import Tests.Preprocessor.Shared;")));
	return bTracksImport;
}

#endif
