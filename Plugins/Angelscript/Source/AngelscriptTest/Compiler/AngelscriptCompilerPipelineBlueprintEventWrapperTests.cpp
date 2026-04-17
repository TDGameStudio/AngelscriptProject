#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
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

namespace CompilerPipelineBlueprintEventWrapperTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.BlueprintEventWrapperExecutesImplementation"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/BlueprintEventWrapperExecutesImplementation.as"));
	static const FString ClassName(TEXT("UCompilerBlueprintEventWrapperCarrier"));
	static const FString ComputeFunctionName(TEXT("Compute"));
	static const FString EntryFunctionName(TEXT("Entry"));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerBlueprintEventWrapperFixtures"));
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
}

using namespace CompilerPipelineBlueprintEventWrapperTest;

namespace CompilerPipelineBlueprintEventMixedPushTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.BlueprintEventWrapperUsesMixedPushPaths"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/BlueprintEventWrapperUsesMixedPushPaths.as"));
	static const FString ClassName(TEXT("UCompilerBlueprintEventMixedPushCarrier"));
	static const FString EvaluateFunctionName(TEXT("EvaluateMixedPush"));
	static const FString EntryFunctionName(TEXT("Entry"));
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerBlueprintEventWrapperExecutesImplementationTest,
	"Angelscript.TestModule.Compiler.EndToEnd.BlueprintEventWrapperExecutesImplementation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerBlueprintEventWrapperExecutesImplementationTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UCompilerBlueprintEventWrapperCarrier : UObject
{
	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		return Value + 21;
	}

	UFUNCTION()
	int Entry()
	{
		return Compute(21);
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineBlueprintEventWrapperTest::WriteFixture(
		CompilerPipelineBlueprintEventWrapperTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineBlueprintEventWrapperTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineBlueprintEventWrapperTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineBlueprintEventWrapperTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("BlueprintEvent wrapper scenario should keep preprocessing errors at zero"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("BlueprintEvent wrapper scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("BlueprintEvent wrapper scenario should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(CompilerPipelineBlueprintEventWrapperTest::ClassName);
	if (!TestTrue(TEXT("BlueprintEvent wrapper scenario should parse the annotated class descriptor"), ClassDesc.IsValid()))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptFunctionDesc> ComputeDesc = ClassDesc->GetMethod(CompilerPipelineBlueprintEventWrapperTest::ComputeFunctionName);
	const TSharedPtr<FAngelscriptFunctionDesc> EntryDesc = ClassDesc->GetMethod(CompilerPipelineBlueprintEventWrapperTest::EntryFunctionName);
	if (!TestTrue(TEXT("BlueprintEvent wrapper scenario should parse the BlueprintEvent function descriptor"), ComputeDesc.IsValid())
		|| !TestTrue(TEXT("BlueprintEvent wrapper scenario should parse the entry function descriptor"), EntryDesc.IsValid()))
	{
		return false;
	}

	const FString& ProcessedCode = ModuleDesc->Code[0].Code;
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should mark Compute as a BlueprintEvent during preprocessing"),
		ComputeDesc->bBlueprintEvent);
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should leave Compute overridable during preprocessing"),
		ComputeDesc->bCanOverrideEvent);
	bPassed &= TestFalse(
		TEXT("BlueprintEvent wrapper scenario should not make a plain BlueprintEvent callable from blueprint by default"),
		ComputeDesc->bBlueprintCallable);
	bPassed &= TestEqual(
		TEXT("BlueprintEvent wrapper scenario should rename the backing script implementation"),
		ComputeDesc->ScriptFunctionName,
		FString(TEXT("Compute_Implementation")));
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should inject an __Evt_Execute wrapper call into the processed code"),
		ProcessedCode.Contains(TEXT("__Evt_Execute(this, __STATIC_NAME(")));

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineBlueprintEventWrapperTest::ModuleName,
		CompilerPipelineBlueprintEventWrapperTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("BlueprintEvent wrapper scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelineBlueprintEventWrapperTest::ClassName);
	if (!TestNotNull(TEXT("BlueprintEvent wrapper scenario should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	UFunction* ComputeFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelineBlueprintEventWrapperTest::ComputeFunctionName);
	UFunction* EntryFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelineBlueprintEventWrapperTest::EntryFunctionName);
	if (!TestNotNull(TEXT("BlueprintEvent wrapper scenario should materialize the generated event wrapper function"), ComputeFunction)
		|| !TestNotNull(TEXT("BlueprintEvent wrapper scenario should materialize the generated entry function"), EntryFunction))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should surface Compute as a BlueprintEvent UFunction"),
		ComputeFunction->HasAnyFunctionFlags(FUNC_BlueprintEvent));
	bPassed &= TestFalse(
		TEXT("BlueprintEvent wrapper scenario should keep Compute non-blueprint-callable without an explicit BlueprintCallable specifier"),
		ComputeFunction->HasAnyFunctionFlags(FUNC_BlueprintCallable));

	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass, TEXT("CompilerBlueprintEventWrapperCarrier"));
	if (!TestNotNull(TEXT("BlueprintEvent wrapper scenario should instantiate the generated class"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, EntryFunction, Result);
	bPassed &= TestTrue(
		TEXT("BlueprintEvent wrapper scenario should execute the generated entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("BlueprintEvent wrapper scenario should route through the wrapper and return the _Implementation result"),
			Result,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerBlueprintEventWrapperUsesMixedPushPathsTest,
	"Angelscript.TestModule.Compiler.EndToEnd.BlueprintEventWrapperUsesMixedPushPaths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerBlueprintEventWrapperUsesMixedPushPathsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UCompilerBlueprintEventMixedPushCarrier : UObject
{
	UFUNCTION(BlueprintEvent)
	int EvaluateMixedPush(const FString& Label, TSubclassOf<AActor> TypeValue)
	{
		return TypeValue == AActor::StaticClass() ? 42 : 0;
	}

	UFUNCTION()
	int Entry()
	{
		return EvaluateMixedPush("Alpha", AActor::StaticClass());
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineBlueprintEventWrapperTest::WriteFixture(
		CompilerPipelineBlueprintEventMixedPushTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineBlueprintEventMixedPushTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineBlueprintEventMixedPushTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineBlueprintEventWrapperTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should keep preprocessing errors at zero"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(CompilerPipelineBlueprintEventMixedPushTest::ClassName);
	if (!TestTrue(TEXT("Mixed-push BlueprintEvent wrapper scenario should parse the annotated class descriptor"), ClassDesc.IsValid()))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptFunctionDesc> EventDesc = ClassDesc->GetMethod(CompilerPipelineBlueprintEventMixedPushTest::EvaluateFunctionName);
	const TSharedPtr<FAngelscriptFunctionDesc> EntryDesc = ClassDesc->GetMethod(CompilerPipelineBlueprintEventMixedPushTest::EntryFunctionName);
	if (!TestTrue(TEXT("Mixed-push BlueprintEvent wrapper scenario should parse the BlueprintEvent function descriptor"), EventDesc.IsValid())
		|| !TestTrue(TEXT("Mixed-push BlueprintEvent wrapper scenario should parse the entry function descriptor"), EntryDesc.IsValid()))
	{
		return false;
	}

	const FString& ProcessedCode = ModuleDesc->Code[0].Code;
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should mark EvaluateMixedPush as a BlueprintEvent during preprocessing"),
		EventDesc->bBlueprintEvent);
	bPassed &= TestEqual(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should rename the backing script implementation"),
		EventDesc->ScriptFunctionName,
		FString(TEXT("EvaluateMixedPush_Implementation")));
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should use specialized ref push code for const FString arguments"),
		ProcessedCode.Contains(TEXT("__Evt_PushArgumentRef__FString(Label);")));
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should use generic push code for TSubclassOf arguments"),
		ProcessedCode.Contains(TEXT("__Evt_PushArgument(TypeValue);")));

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineBlueprintEventMixedPushTest::ModuleName,
		CompilerPipelineBlueprintEventMixedPushTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary);

	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelineBlueprintEventMixedPushTest::ClassName);
	if (!TestNotNull(TEXT("Mixed-push BlueprintEvent wrapper scenario should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	UFunction* EventFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelineBlueprintEventMixedPushTest::EvaluateFunctionName);
	UFunction* EntryFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelineBlueprintEventMixedPushTest::EntryFunctionName);
	if (!TestNotNull(TEXT("Mixed-push BlueprintEvent wrapper scenario should materialize the generated event wrapper function"), EventFunction)
		|| !TestNotNull(TEXT("Mixed-push BlueprintEvent wrapper scenario should materialize the generated entry function"), EntryFunction))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should surface EvaluateMixedPush as a BlueprintEvent UFunction"),
		EventFunction->HasAnyFunctionFlags(FUNC_BlueprintEvent));

	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass, TEXT("CompilerBlueprintEventMixedPushCarrier"));
	if (!TestNotNull(TEXT("Mixed-push BlueprintEvent wrapper scenario should instantiate the generated class"), RuntimeObject))
	{
		return false;
	}

	int32 Result = 0;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, RuntimeObject, EntryFunction, Result);
	bPassed &= TestTrue(
		TEXT("Mixed-push BlueprintEvent wrapper scenario should execute the generated entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Mixed-push BlueprintEvent wrapper scenario should route through the wrapper and preserve mixed push arguments"),
			Result,
			42);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
