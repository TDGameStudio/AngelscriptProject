#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Core/AngelscriptEngine.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"
#include "UObject/StructOnScope.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineGlobalUFunctionTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.GlobalUFunctionCreatesStaticsClass"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/GlobalUFunctionCreatesStaticsClass.as"));
	static const FName FunctionName(TEXT("GetGlobalValue"));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerGlobalUFunctionFixtures"));
	}

	FString WriteFixture(const FString& RelativePath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativePath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const FString& AbsoluteFilename,
		int32& OutErrorCount)
	{
		OutErrorCount = 0;

		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
		if (Diagnostics == nullptr)
		{
			return {};
		}

		TArray<FString> Messages;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			Messages.Add(Diagnostic.Message);
			if (Diagnostic.bIsError)
			{
				++OutErrorCount;
			}
		}

		return Messages;
	}

	FString MakeExpectedStaticsClassName(const FString& ModuleNameString)
	{
		FString Identifier;
		Identifier.Reserve(ModuleNameString.Len());
		for (const TCHAR Character : ModuleNameString)
		{
			if (FAngelscriptEngine::IsValidIdentifierCharacter(Character))
			{
				Identifier += Character;
			}
			else
			{
				Identifier += TEXT('_');
			}
		}

		return FString::Printf(TEXT("Module_%sStatics"), *Identifier);
	}

	TSharedPtr<FAngelscriptClassDesc> FindStaticsClassDesc(const TSharedRef<FAngelscriptModuleDesc>& ModuleDesc, int32& OutStaticsClassCount)
	{
		OutStaticsClassCount = 0;
		TSharedPtr<FAngelscriptClassDesc> FoundClass;
		for (const TSharedRef<FAngelscriptClassDesc>& ClassDesc : ModuleDesc->Classes)
		{
			if (ClassDesc->bIsStaticsClass)
			{
				++OutStaticsClassCount;
				FoundClass = ClassDesc;
			}
		}

		return FoundClass;
	}

	bool ExecuteGeneratedStaticIntFunction(
		FAutomationTestBase& Test,
		UClass* OwnerClass,
		UASFunction* Function,
		int32& OutResult)
	{
		FIntProperty* ReturnProperty = FindFProperty<FIntProperty>(Function, TEXT("ReturnValue"));
		if (!Test.TestNotNull(TEXT("Global UFUNCTION statics-class scenario should expose a ReturnValue property"), ReturnProperty))
		{
			return false;
		}

		FStructOnScope Params(Function);
		void* ParamsMemory = Params.GetStructMemory();
		if (!Test.TestNotNull(TEXT("Global UFUNCTION statics-class scenario should allocate a reflected parameter buffer"), ParamsMemory))
		{
			return false;
		}

		UObject* DefaultObject = OwnerClass != nullptr ? OwnerClass->GetDefaultObject() : nullptr;
		if (!Test.TestNotNull(TEXT("Global UFUNCTION statics-class scenario should expose a default object for the generated statics class"), DefaultObject))
		{
			return false;
		}

		if (Function->bIsWorldContextGenerated)
		{
			*(UObject**)((SIZE_T)ParamsMemory + Function->WorldContextOffsetInParms) = DefaultObject;
		}

		Function->RuntimeCallEvent(DefaultObject, ParamsMemory);
		OutResult = ReturnProperty->GetPropertyValue_InContainer(ParamsMemory);
		return true;
	}
}

using namespace CompilerPipelineGlobalUFunctionTest;

namespace CompilerPipelineGlobalUFunctionSanitizedModuleTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.GlobalUFunction-Foo+Bar"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/GlobalUFunction-Foo+Bar.as"));
	static const FName FunctionName(TEXT("GetSanitizedGlobalValue"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerGlobalUFunctionCreatesStaticsClassTest,
	"Angelscript.TestModule.Compiler.EndToEnd.GlobalUFunctionCreatesStaticsClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerGlobalUFunctionCreatesStaticsClassTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UFUNCTION(BlueprintCallable)
int GetGlobalValue()
{
	return 42;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineGlobalUFunctionTest::WriteFixture(
		CompilerPipelineGlobalUFunctionTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineGlobalUFunctionTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineGlobalUFunctionTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineGlobalUFunctionTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should keep preprocessing errors at zero"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	const FString ExpectedStaticsClassName = CompilerPipelineGlobalUFunctionTest::MakeExpectedStaticsClassName(ModuleDesc->ModuleName);
	int32 StaticsClassCount = 0;
	const TSharedPtr<FAngelscriptClassDesc> StaticsClassDesc = CompilerPipelineGlobalUFunctionTest::FindStaticsClassDesc(
		ModuleDesc,
		StaticsClassCount);
	if (!TestTrue(TEXT("Global UFUNCTION statics-class scenario should emit a statics class descriptor"), StaticsClassDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should emit exactly one statics class descriptor"),
		StaticsClassCount,
		1);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should normalize the generated statics class name from the module name"),
		StaticsClassDesc->ClassName,
		ExpectedStaticsClassName);

	const TSharedPtr<FAngelscriptFunctionDesc> FunctionDesc = StaticsClassDesc->GetMethod(
		CompilerPipelineGlobalUFunctionTest::FunctionName.ToString());
	if (!TestTrue(TEXT("Global UFUNCTION statics-class scenario should attach GetGlobalValue to the generated statics class descriptor"), FunctionDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should mark the generated descriptor method as static"),
		FunctionDesc->bIsStatic);
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should preserve BlueprintCallable on the generated descriptor method"),
		FunctionDesc->bBlueprintCallable);

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineGlobalUFunctionTest::ModuleName,
		CompilerPipelineGlobalUFunctionTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	const FName GeneratedStaticsClassName(*FString::Printf(TEXT("U%s"), *ExpectedStaticsClassName));
	UClass* GeneratedClass = FindGeneratedClass(&Engine, GeneratedStaticsClassName);
	if (!TestNotNull(TEXT("Global UFUNCTION statics-class scenario should materialize the generated statics class"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = FindGeneratedFunction(GeneratedClass, CompilerPipelineGlobalUFunctionTest::FunctionName);
	UASFunction* ScriptFunction = Cast<UASFunction>(GeneratedFunction);
	if (!TestNotNull(TEXT("Global UFUNCTION statics-class scenario should materialize the generated static function"), GeneratedFunction)
		|| !TestNotNull(TEXT("Global UFUNCTION statics-class scenario should expose the generated function as a UASFunction"), ScriptFunction))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should surface the reflected function as static"),
		GeneratedFunction->HasAnyFunctionFlags(FUNC_Static));
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should surface the reflected function as BlueprintCallable"),
		GeneratedFunction->HasAnyFunctionFlags(FUNC_BlueprintCallable));
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should synthesize a hidden world-context parameter for the reflected static function"),
		ScriptFunction->bIsWorldContextGenerated);
	bPassed &= TestEqual(
		TEXT("Global UFUNCTION statics-class scenario should append the hidden world-context parameter after the declared script arguments"),
		ScriptFunction->WorldContextIndex,
		ScriptFunction->Arguments.Num());
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should record a valid world-context offset for reflective execution"),
		ScriptFunction->WorldContextOffsetInParms >= 0);

	int32 RuntimeResult = 0;
	const bool bExecuted = CompilerPipelineGlobalUFunctionTest::ExecuteGeneratedStaticIntFunction(
		*this,
		GeneratedClass,
		ScriptFunction,
		RuntimeResult);
	bPassed &= TestTrue(
		TEXT("Global UFUNCTION statics-class scenario should execute the generated statics function through RuntimeCallEvent"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Global UFUNCTION statics-class scenario should return the original global function value through the generated statics class"),
			RuntimeResult,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerGlobalUFunctionSanitizesModuleNameForStaticsClassTest,
	"Angelscript.TestModule.Compiler.EndToEnd.GlobalUFunctionSanitizesModuleNameForStaticsClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerGlobalUFunctionSanitizesModuleNameForStaticsClassTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UFUNCTION(BlueprintCallable)
int GetSanitizedGlobalValue()
{
	return 77;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineGlobalUFunctionTest::WriteFixture(
		CompilerPipelineGlobalUFunctionSanitizedModuleTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineGlobalUFunctionSanitizedModuleTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineGlobalUFunctionSanitizedModuleTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineGlobalUFunctionTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should keep preprocessing errors at zero"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	const FString ExpectedStaticsClassName(TEXT("Module_Tests_Compiler_GlobalUFunction_Foo_BarStatics"));
	const FString ExpectedDisplayName(TEXT("GlobalUFunction-Foo+Bar"));
	int32 StaticsClassCount = 0;
	const TSharedPtr<FAngelscriptClassDesc> StaticsClassDesc = CompilerPipelineGlobalUFunctionTest::FindStaticsClassDesc(
		ModuleDesc,
		StaticsClassCount);
	if (!TestTrue(TEXT("Sanitized-module global UFUNCTION scenario should emit a statics class descriptor"), StaticsClassDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should preserve '-' in the raw module name before statics-class sanitization"),
		ModuleDesc->ModuleName.Contains(TEXT("-")));
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should preserve '+' in the raw module name before statics-class sanitization"),
		ModuleDesc->ModuleName.Contains(TEXT("+")));
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should emit exactly one statics class descriptor"),
		StaticsClassCount,
		1);
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should sanitize invalid module-name characters when generating the statics class name"),
		StaticsClassDesc->ClassName,
		ExpectedStaticsClassName);
	bPassed &= TestFalse(
		TEXT("Sanitized-module global UFUNCTION scenario should not leave '-' in the generated statics class name"),
		StaticsClassDesc->ClassName.Contains(TEXT("-")));
	bPassed &= TestFalse(
		TEXT("Sanitized-module global UFUNCTION scenario should not leave '+' in the generated statics class name"),
		StaticsClassDesc->ClassName.Contains(TEXT("+")));
	const FString* DisplayName = StaticsClassDesc->Meta.Find(FName(TEXT("DisplayName")));
	bPassed &= TestNotNull(
		TEXT("Sanitized-module global UFUNCTION scenario should set DisplayName metadata from the unsanitized base filename"),
		DisplayName);
	if (DisplayName != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Sanitized-module global UFUNCTION scenario should preserve the original base filename in DisplayName metadata"),
			*DisplayName,
			ExpectedDisplayName);
	}

	const TSharedPtr<FAngelscriptFunctionDesc> FunctionDesc = StaticsClassDesc->GetMethod(
		CompilerPipelineGlobalUFunctionSanitizedModuleTest::FunctionName.ToString());
	if (!TestTrue(TEXT("Sanitized-module global UFUNCTION scenario should attach GetSanitizedGlobalValue to the generated statics class descriptor"), FunctionDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should mark the generated descriptor method as static"),
		FunctionDesc->bIsStatic);
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should preserve BlueprintCallable on the generated descriptor method"),
		FunctionDesc->bBlueprintCallable);

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineGlobalUFunctionSanitizedModuleTest::ModuleName,
		CompilerPipelineGlobalUFunctionSanitizedModuleTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Sanitized-module global UFUNCTION scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	const FName GeneratedStaticsClassName(*FString::Printf(TEXT("U%s"), *ExpectedStaticsClassName));
	UClass* GeneratedClass = FindGeneratedClass(&Engine, GeneratedStaticsClassName);
	if (!TestNotNull(TEXT("Sanitized-module global UFUNCTION scenario should materialize the sanitized statics class"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = FindGeneratedFunction(GeneratedClass, CompilerPipelineGlobalUFunctionSanitizedModuleTest::FunctionName);
	UASFunction* ScriptFunction = Cast<UASFunction>(GeneratedFunction);
	if (!TestNotNull(TEXT("Sanitized-module global UFUNCTION scenario should materialize the generated static function"), GeneratedFunction)
		|| !TestNotNull(TEXT("Sanitized-module global UFUNCTION scenario should expose the generated function as a UASFunction"), ScriptFunction))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should surface the reflected function as static"),
		GeneratedFunction->HasAnyFunctionFlags(FUNC_Static));
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should surface the reflected function as BlueprintCallable"),
		GeneratedFunction->HasAnyFunctionFlags(FUNC_BlueprintCallable));

	int32 RuntimeResult = 0;
	const bool bExecuted = CompilerPipelineGlobalUFunctionTest::ExecuteGeneratedStaticIntFunction(
		*this,
		GeneratedClass,
		ScriptFunction,
		RuntimeResult);
	bPassed &= TestTrue(
		TEXT("Sanitized-module global UFUNCTION scenario should execute the generated statics function through RuntimeCallEvent"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Sanitized-module global UFUNCTION scenario should return the original global function value through the sanitized statics class"),
			RuntimeResult,
			77);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
