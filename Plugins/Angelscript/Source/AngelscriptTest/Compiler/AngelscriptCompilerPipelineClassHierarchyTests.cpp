#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineClassHierarchyTest
{
	static const FString BaseRelativeScriptPath(TEXT("Tests/Compiler/ClassHierarchy/Base.as"));
	static const FString ChildRelativeScriptPath(TEXT("Tests/Compiler/ClassHierarchy/Child.as"));
	static const FName BaseModuleName(TEXT("Tests.Compiler.ClassHierarchy.Base"));
	static const FName ChildModuleName(TEXT("Tests.Compiler.ClassHierarchy.Child"));
	static const FName BaseClassName(TEXT("UHierarchyBase"));
	static const FName ChildClassName(TEXT("UHierarchyChild"));
	static const FName DerivedFunctionName(TEXT("GetDerivedValue"));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerPipelineClassHierarchyFixtures"));
	}

	FString WriteFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	FAngelscriptModuleDesc* FindModuleByName(
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

	TArray<FString> CollectDiagnosticMessages(
		FAngelscriptEngine& Engine,
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
}

using namespace CompilerPipelineClassHierarchyTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerScriptSuperclassRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.ScriptSuperclassRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerScriptSuperclassRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString BaseAbsoluteScriptPath = CompilerPipelineClassHierarchyTest::WriteFixture(
		CompilerPipelineClassHierarchyTest::BaseRelativeScriptPath,
		TEXT(
			"UCLASS()\n"
			"class UHierarchyBase : UObject\n"
			"{\n"
			"    UFUNCTION()\n"
			"    int GetBaseValue()\n"
			"    {\n"
			"        return 7;\n"
			"    }\n"
			"}\n"));
	const FString ChildAbsoluteScriptPath = CompilerPipelineClassHierarchyTest::WriteFixture(
		CompilerPipelineClassHierarchyTest::ChildRelativeScriptPath,
		TEXT(
			"UCLASS()\n"
			"class UHierarchyChild : UHierarchyBase\n"
			"{\n"
			"    UFUNCTION()\n"
			"    int GetDerivedValue()\n"
			"    {\n"
			"        return GetBaseValue();\n"
			"    }\n"
			"}\n"));

	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*BaseAbsoluteScriptPath, false, true);
		IFileManager::Get().Delete(*ChildAbsoluteScriptPath, false, true);
		Engine.DiscardModule(*CompilerPipelineClassHierarchyTest::BaseModuleName.ToString());
		Engine.DiscardModule(*CompilerPipelineClassHierarchyTest::ChildModuleName.ToString());
	};

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineClassHierarchyTest::BaseRelativeScriptPath, BaseAbsoluteScriptPath);
	Preprocessor.AddFile(CompilerPipelineClassHierarchyTest::ChildRelativeScriptPath, ChildAbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	TArray<TSharedRef<FAngelscriptModuleDesc>> ModulesToCompile = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const FString PreprocessDiagnostics = FString::Join(
		CompilerPipelineClassHierarchyTest::CollectDiagnosticMessages(
			Engine,
			{BaseAbsoluteScriptPath, ChildAbsoluteScriptPath},
			PreprocessErrorCount),
		TEXT("\n"));

	bPassed &= TestTrue(
		TEXT("Script superclass round-trip should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should keep preprocessing diagnostics empty"),
		PreprocessErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Script superclass round-trip should not accumulate preprocessing messages"),
		PreprocessDiagnostics.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should emit two module descriptors"),
		ModulesToCompile.Num(),
		2);
	if (!bPreprocessSucceeded || ModulesToCompile.Num() != 2)
	{
		return false;
	}

	FAngelscriptModuleDesc* BaseModuleDesc = CompilerPipelineClassHierarchyTest::FindModuleByName(
		ModulesToCompile,
		CompilerPipelineClassHierarchyTest::BaseModuleName.ToString());
	FAngelscriptModuleDesc* ChildModuleDesc = CompilerPipelineClassHierarchyTest::FindModuleByName(
		ModulesToCompile,
		CompilerPipelineClassHierarchyTest::ChildModuleName.ToString());
	if (!TestNotNull(TEXT("Script superclass round-trip should emit the base module descriptor"), BaseModuleDesc)
		|| !TestNotNull(TEXT("Script superclass round-trip should emit the child module descriptor"), ChildModuleDesc))
	{
		return false;
	}

	TSharedPtr<FAngelscriptClassDesc> ChildClassDesc = ChildModuleDesc->GetClass(CompilerPipelineClassHierarchyTest::ChildClassName.ToString());
	if (!TestNotNull(TEXT("Script superclass round-trip should preserve the child class descriptor after preprocessing"), ChildClassDesc.Get()))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should keep the child descriptor super class text stable"),
		ChildClassDesc->SuperClass,
		CompilerPipelineClassHierarchyTest::BaseClassName.ToString());

	Engine.ResetDiagnostics();

	TArray<TSharedRef<FAngelscriptModuleDesc>> CompiledModules;
	const ECompileResult CompileResult = Engine.CompileModules(
		ECompileType::FullReload,
		ModulesToCompile,
		CompiledModules);

	int32 CompileErrorCount = 0;
	const FString CompileDiagnostics = FString::Join(
		CompilerPipelineClassHierarchyTest::CollectDiagnosticMessages(
			Engine,
			{BaseAbsoluteScriptPath, ChildAbsoluteScriptPath},
			CompileErrorCount),
		TEXT("\n"));

	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should compile as FullyHandled"),
		CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should keep compile diagnostics empty"),
		CompileErrorCount,
		0);
	bPassed &= TestTrue(
		TEXT("Script superclass round-trip should not accumulate compile messages"),
		CompileDiagnostics.IsEmpty());
	bPassed &= TestEqual(
		TEXT("Script superclass round-trip should materialize exactly two compiled modules"),
		CompiledModules.Num(),
		2);
	if (CompileResult != ECompileResult::FullyHandled || CompiledModules.Num() != 2)
	{
		return false;
	}

	UClass* GeneratedBaseClass = FindGeneratedClass(&Engine, CompilerPipelineClassHierarchyTest::BaseClassName);
	UClass* GeneratedChildClass = FindGeneratedClass(&Engine, CompilerPipelineClassHierarchyTest::ChildClassName);
	if (!TestNotNull(TEXT("Script superclass round-trip should generate the base class"), GeneratedBaseClass)
		|| !TestNotNull(TEXT("Script superclass round-trip should generate the child class"), GeneratedChildClass))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Script superclass round-trip should keep the generated child super chain pointing at the generated base"),
		GeneratedChildClass->GetSuperClass() == GeneratedBaseClass);

	UFunction* DerivedFunction = FindGeneratedFunction(GeneratedChildClass, CompilerPipelineClassHierarchyTest::DerivedFunctionName);
	if (!TestNotNull(TEXT("Script superclass round-trip should expose GetDerivedValue on the generated child class"), DerivedFunction))
	{
		return false;
	}

	UObject* RuntimeObject = GeneratedChildClass->GetDefaultObject();
	if (!TestNotNull(TEXT("Script superclass round-trip should materialize the child default object"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, DerivedFunction, Result);
	bPassed &= TestTrue(
		TEXT("Script superclass round-trip should execute the generated child method"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Script superclass round-trip should let the child method call through to the scripted base implementation"),
			Result,
			7);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
