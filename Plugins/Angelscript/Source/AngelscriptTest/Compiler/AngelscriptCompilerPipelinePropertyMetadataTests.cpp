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
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelinePropertyMetadataTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.PropertyCallbackMetadataRoundTrip"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/PropertyCallbackMetadataRoundTrip.as"));
	static const FString ClassName(TEXT("UPropertyCallbackCarrier"));
	static const FString PropertyName(TEXT("TrackedValue"));
	static const FString EntryFunctionDeclaration(TEXT("int Entry()"));
	static const FString OnRepFunctionName(TEXT("OnRep_TrackedValue"));
	static const FString GetterFunctionName(TEXT("GetTrackedValue"));
	static const FString SetterFunctionName(TEXT("SetTrackedValue"));
	static const int32 ExpectedEntryValue = 42;

	struct FPropertyCallbackValidationScenario
	{
		const TCHAR* Label;
		FName ModuleName;
		FString RelativeScriptPath;
		const TCHAR* ScriptSource;
		const TCHAR* ExpectedMessageFragment;
		int32 ExpectedRow;
	};

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerPropertyMetadataFixtures"));
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

	FString GetPropertyMeta(const TSharedPtr<FAngelscriptPropertyDesc>& PropertyDesc, const TCHAR* Key)
	{
		if (!PropertyDesc.IsValid())
		{
			return FString();
		}

		const FString* Value = PropertyDesc->Meta.Find(FName(Key));
		return Value != nullptr ? *Value : FString();
	}

	FString JoinDiagnostics(const TArray<FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics)
	{
		TArray<FString> Lines;
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Diagnostics)
		{
			Lines.Add(FString::Printf(
				TEXT("[%s] %s(%d:%d) %s"),
				Diagnostic.bIsError ? TEXT("Error") : (Diagnostic.bIsInfo ? TEXT("Info") : TEXT("Warning")),
				*Diagnostic.Section,
				Diagnostic.Row,
				Diagnostic.Column,
				*Diagnostic.Message));
		}

		return FString::Join(Lines, TEXT(" | "));
	}

	const FAngelscriptCompileTraceDiagnosticSummary* FindMatchingErrorDiagnostic(
		const TArray<FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics,
		const FString& MessageFragment)
	{
		return Diagnostics.FindByPredicate(
			[&MessageFragment](const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic)
			{
				return Diagnostic.bIsError && Diagnostic.Message.Contains(MessageFragment);
			});
	}
}

using namespace CompilerPipelinePropertyMetadataTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerPropertyCallbackMetadataRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.PropertyCallbackMetadataRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerPropertyCallbackSignatureValidationReportsDiagnosticsTest,
	"Angelscript.TestModule.Compiler.EndToEnd.PropertyCallbackSignatureValidationReportsDiagnostics",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerPropertyCallbackMetadataRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue, BlueprintGetter=GetTrackedValue, BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	void OnRep_TrackedValue()
	{
	}

	UFUNCTION(BlueprintPure)
	int GetTrackedValue() const
	{
		return TrackedValue;
	}

	UFUNCTION()
	void SetTrackedValue(int Value)
	{
		TrackedValue = Value;
	}
}

int Entry()
{
	return 42;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelinePropertyMetadataTest::WriteFixture(
		CompilerPipelinePropertyMetadataTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelinePropertyMetadataTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelinePropertyMetadataTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelinePropertyMetadataTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("Property callback metadata scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Property callback metadata scenario should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Property callback metadata scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Property callback metadata scenario should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	bPassed &= TestEqual(
		TEXT("Property callback metadata scenario should preserve the expected module name"),
		ModuleDesc->ModuleName,
		CompilerPipelinePropertyMetadataTest::ModuleName.ToString());

	const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(CompilerPipelinePropertyMetadataTest::ClassName);
	if (!TestTrue(TEXT("Property callback metadata scenario should parse the annotated class descriptor"), ClassDesc.IsValid()))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptPropertyDesc> PropertyDesc = ClassDesc->GetProperty(CompilerPipelinePropertyMetadataTest::PropertyName);
	const TSharedPtr<FAngelscriptFunctionDesc> OnRepDesc = ClassDesc->GetMethod(CompilerPipelinePropertyMetadataTest::OnRepFunctionName);
	const TSharedPtr<FAngelscriptFunctionDesc> GetterDesc = ClassDesc->GetMethod(CompilerPipelinePropertyMetadataTest::GetterFunctionName);
	const TSharedPtr<FAngelscriptFunctionDesc> SetterDesc = ClassDesc->GetMethod(CompilerPipelinePropertyMetadataTest::SetterFunctionName);
	if (!TestTrue(TEXT("Property callback metadata scenario should parse the annotated property descriptor"), PropertyDesc.IsValid())
		|| !TestTrue(TEXT("Property callback metadata scenario should parse the RepNotify callback descriptor"), OnRepDesc.IsValid())
		|| !TestTrue(TEXT("Property callback metadata scenario should parse the BlueprintGetter descriptor"), GetterDesc.IsValid())
		|| !TestTrue(TEXT("Property callback metadata scenario should parse the BlueprintSetter descriptor"), SetterDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Preprocessor should mark ReplicatedUsing properties as replicated"),
		PropertyDesc->bReplicated);
	bPassed &= TestTrue(
		TEXT("Preprocessor should mark ReplicatedUsing properties as rep-notify"),
		PropertyDesc->bRepNotify);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the ReplicatedUsing callback name"),
		CompilerPipelinePropertyMetadataTest::GetPropertyMeta(PropertyDesc, TEXT("ReplicatedUsing")),
		CompilerPipelinePropertyMetadataTest::OnRepFunctionName);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the BlueprintGetter callback name"),
		CompilerPipelinePropertyMetadataTest::GetPropertyMeta(PropertyDesc, TEXT("BlueprintGetter")),
		CompilerPipelinePropertyMetadataTest::GetterFunctionName);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the BlueprintSetter callback name"),
		CompilerPipelinePropertyMetadataTest::GetPropertyMeta(PropertyDesc, TEXT("BlueprintSetter")),
		CompilerPipelinePropertyMetadataTest::SetterFunctionName);
	bPassed &= TestTrue(
		TEXT("Preprocessor should keep the BlueprintGetter callback marked BlueprintPure"),
		GetterDesc->bBlueprintPure);

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelinePropertyMetadataTest::ModuleName,
		CompilerPipelinePropertyMetadataTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	if (Summary.Diagnostics.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Compile diagnostics: %s"),
			*CompilerPipelinePropertyMetadataTest::JoinDiagnostics(Summary.Diagnostics)));
	}

	bPassed &= TestTrue(
		TEXT("Property callback metadata scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Property callback metadata scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Property callback metadata scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Property callback metadata scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	int32 EntryResult = 0;
	const bool bExecuted = ExecuteIntFunction(
		&Engine,
		CompilerPipelinePropertyMetadataTest::RelativeScriptPath,
		CompilerPipelinePropertyMetadataTest::ModuleName,
		CompilerPipelinePropertyMetadataTest::EntryFunctionDeclaration,
		EntryResult);
	bPassed &= TestTrue(
		TEXT("Property callback metadata scenario should execute the compiled entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Property callback metadata scenario should preserve module execution after metadata propagation"),
			EntryResult,
			CompilerPipelinePropertyMetadataTest::ExpectedEntryValue);
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelinePropertyMetadataTest::ClassName);
	if (!TestNotNull(TEXT("Property callback metadata scenario should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	FIntProperty* TrackedValueProperty = FindFProperty<FIntProperty>(GeneratedClass, *CompilerPipelinePropertyMetadataTest::PropertyName);
	UFunction* OnRepFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelinePropertyMetadataTest::OnRepFunctionName);
	UFunction* GetterFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelinePropertyMetadataTest::GetterFunctionName);
	UFunction* SetterFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelinePropertyMetadataTest::SetterFunctionName);
	if (!TestNotNull(TEXT("Property callback metadata scenario should materialize the generated property"), TrackedValueProperty)
		|| !TestNotNull(TEXT("Property callback metadata scenario should materialize the generated RepNotify callback"), OnRepFunction)
		|| !TestNotNull(TEXT("Property callback metadata scenario should materialize the generated BlueprintGetter callback"), GetterFunction)
		|| !TestNotNull(TEXT("Property callback metadata scenario should materialize the generated BlueprintSetter callback"), SetterFunction))
	{
		return false;
	}

	FIntProperty* GetterReturnProperty = CastField<FIntProperty>(GetterFunction->GetReturnProperty());
	FIntProperty* SetterValueProperty = FindFProperty<FIntProperty>(SetterFunction, TEXT("Value"));

	bPassed &= TestTrue(
		TEXT("Generated property should carry CPF_Net"),
		TrackedValueProperty->HasAnyPropertyFlags(CPF_Net));
	bPassed &= TestTrue(
		TEXT("Generated property should carry CPF_RepNotify"),
		TrackedValueProperty->HasAnyPropertyFlags(CPF_RepNotify));
	bPassed &= TestEqual(
		TEXT("Generated property should preserve the RepNotify callback name"),
		TrackedValueProperty->RepNotifyFunc,
		FName(*CompilerPipelinePropertyMetadataTest::OnRepFunctionName));
	bPassed &= TestEqual(
		TEXT("Generated property should preserve BlueprintGetter metadata"),
		TrackedValueProperty->GetMetaData(TEXT("BlueprintGetter")),
		CompilerPipelinePropertyMetadataTest::GetterFunctionName);
	bPassed &= TestEqual(
		TEXT("Generated property should preserve BlueprintSetter metadata"),
		TrackedValueProperty->GetMetaData(TEXT("BlueprintSetter")),
		CompilerPipelinePropertyMetadataTest::SetterFunctionName);
	bPassed &= TestEqual(
		TEXT("Generated RepNotify callback should not expose parameters"),
		OnRepFunction->NumParms,
		0);
	bPassed &= TestNotNull(
		TEXT("Generated BlueprintGetter callback should return int"),
		GetterReturnProperty);
	bPassed &= TestEqual(
		TEXT("Generated BlueprintSetter callback should expose exactly one parameter"),
		SetterFunction->NumParms,
		1);
	bPassed &= TestNotNull(
		TEXT("Generated BlueprintSetter callback should expose an int Value parameter"),
		SetterValueProperty);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptCompilerPropertyCallbackSignatureValidationReportsDiagnosticsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const TArray<CompilerPipelinePropertyMetadataTest::FPropertyCallbackValidationScenario> Scenarios = {
		{
			TEXT("ReplicatedUsing callback should reject more than one argument"),
			FName(TEXT("Tests.Compiler.PropertyCallbackValidation.RepNotifyTooManyArgs")),
			TEXT("Tests/Compiler/PropertyCallbackValidation/RepNotifyTooManyArgs.as"),
			TEXT(R"AS(
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue)
	int TrackedValue;

	UFUNCTION()
	void OnRep_TrackedValue(int OldValue, int NewValue)
	{
	}
}
)AS"),
			TEXT("can not have more than 1 argument."),
			9
		},
		{
			TEXT("BlueprintSetter callback should reject a mismatched value type"),
			FName(TEXT("Tests.Compiler.PropertyCallbackValidation.SetterTypeMismatch")),
			TEXT("Tests/Compiler/PropertyCallbackValidation/SetterTypeMismatch.as"),
			TEXT(R"AS(
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	void SetTrackedValue(float Value)
	{
	}
}
)AS"),
			TEXT("takes an argument of type 'float', but the value written is of type 'int'."),
			9
		},
		{
			TEXT("BlueprintGetter callback should require BlueprintPure"),
			FName(TEXT("Tests.Compiler.PropertyCallbackValidation.GetterNeedsBlueprintPure")),
			TEXT("Tests/Compiler/PropertyCallbackValidation/GetterNeedsBlueprintPure.as"),
			TEXT(R"AS(
UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintGetter=GetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	int GetTrackedValue() const
	{
		return TrackedValue;
	}
}
)AS"),
			TEXT("needs to be marked as BlueprintPure."),
			5
		}
	};

	for (const CompilerPipelinePropertyMetadataTest::FPropertyCallbackValidationScenario& Scenario : Scenarios)
	{
		Engine.ResetDiagnostics();

		FAngelscriptCompileTraceSummary Summary;
		const bool bCompiled = CompileModuleWithSummary(
			&Engine,
			ECompileType::FullReload,
			Scenario.ModuleName,
			Scenario.RelativeScriptPath,
			Scenario.ScriptSource,
			true,
			Summary,
			true);

		if (Summary.Diagnostics.Num() > 0)
		{
			AddInfo(FString::Printf(TEXT("%s diagnostics: %s"), Scenario.Label, *CompilerPipelinePropertyMetadataTest::JoinDiagnostics(Summary.Diagnostics)));
		}

		const FAngelscriptCompileTraceDiagnosticSummary* MatchingDiagnostic =
			CompilerPipelinePropertyMetadataTest::FindMatchingErrorDiagnostic(Summary.Diagnostics, Scenario.ExpectedMessageFragment);

		bPassed &= TestFalse(FString::Printf(TEXT("%s should fail compile"), Scenario.Label), bCompiled);
		bPassed &= TestFalse(FString::Printf(TEXT("%s should keep bCompileSucceeded false"), Scenario.Label), Summary.bCompileSucceeded);
		bPassed &= TestTrue(FString::Printf(TEXT("%s should record preprocessor usage"), Scenario.Label), Summary.bUsedPreprocessor);
		bPassed &= TestNotNull(FString::Printf(TEXT("%s should emit the expected callback diagnostic"), Scenario.Label), MatchingDiagnostic);
		if (MatchingDiagnostic != nullptr)
		{
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should pin the diagnostic row to the callback/property declaration"), Scenario.Label),
				MatchingDiagnostic->Row,
				Scenario.ExpectedRow);
		}

		UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelinePropertyMetadataTest::ClassName);
		// UE 5.7: a failed compile may leave a skeleton UClass registered in
		// the object graph until the next GC pass. Accept either "no class"
		// (ideal) or "class marked as GC target" as a successful teardown.
		const bool bGeneratedClassIsGone =
			GeneratedClass == nullptr
			|| GeneratedClass->HasAnyFlags(RF_MirroredGarbage)
			|| !::IsValid(GeneratedClass);
		bPassed &= TestTrue(
			FString::Printf(TEXT("%s should not leave behind a live generated class after compile failure"), Scenario.Label),
			bGeneratedClassIsGone);

		Engine.DiscardModule(*Scenario.ModuleName.ToString());
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
