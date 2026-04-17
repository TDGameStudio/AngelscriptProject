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
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelinePropertyDefaultTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.StringDefaultPreservesCommentMarkersInsideLiteral"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/StringDefaultPreservesCommentMarkersInsideLiteral.as"));
	static const FString ClassName(TEXT("UCompilerStringDefaultCarrier"));
	static const FString MessagePropertyName(TEXT("Message"));
	static const FString BlockTextPropertyName(TEXT("BlockText"));
	static const FName VerifyFunctionName(TEXT("VerifyDefaults"));
	static const FString ExpectedDefaultsCode(TEXT("Message = \"He said \\\"//not a comment\\\"\";BlockText = \"/*literal*/\";"));
	static const FString ExpectedMessage(TEXT("He said \"//not a comment\""));
	static const FString ExpectedBlockText(TEXT("/*literal*/"));
	static const int32 ExpectedVerifyResult = 42;

	struct FRuntimeDefaultObservation
	{
		FString DefaultMessage;
		FString DefaultBlockText;
		FString RuntimeMessage;
		FString RuntimeBlockText;
		int32 VerifyResult = INDEX_NONE;
	};

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerPropertyDefaultFixtures"));
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

	FString JoinMessages(const TArray<FString>& Messages)
	{
		return FString::Join(Messages, TEXT(" | "));
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

	bool ReadStringPropertyValue(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		FStrProperty* Property,
		UObject* Object,
		FString& OutValue)
	{
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should expose the reflected FString property"), Context),
				Property)
			|| !Test.TestNotNull(
				*FString::Printf(TEXT("%s should expose the target object"), Context),
				Object))
		{
			return false;
		}

		OutValue = Property->GetPropertyValue_InContainer(Object);
		return true;
	}

	bool VerifyStringValue(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const FString& ActualValue,
		const FString& ExpectedValue)
	{
		return Test.TestEqual(Context, ActualValue, ExpectedValue);
	}
}

using namespace CompilerPipelinePropertyDefaultTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerStringDefaultPreservesCommentMarkersInsideLiteralTest,
	"Angelscript.TestModule.Compiler.EndToEnd.StringDefaultPreservesCommentMarkersInsideLiteral",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerStringDefaultPreservesCommentMarkersInsideLiteralTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UCompilerStringDefaultCarrier : UObject
{
	UPROPERTY()
	FString Message;

	UPROPERTY()
	FString BlockText;

	default Message = "He said \"//not a comment\"";
	default BlockText = "/*literal*/";

	UFUNCTION()
	int VerifyDefaults()
	{
		if (!(Message == "He said \"//not a comment\""))
			return 10;

		if (!(BlockText == "/*literal*/"))
			return 20;

		return 42;
	}
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelinePropertyDefaultTest::WriteFixture(
		CompilerPipelinePropertyDefaultTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelinePropertyDefaultTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelinePropertyDefaultTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelinePropertyDefaultTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	if (PreprocessMessages.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Preprocess diagnostics: %s"),
			*CompilerPipelinePropertyDefaultTest::JoinMessages(PreprocessMessages)));
	}

	bPassed &= TestTrue(
		TEXT("String default literal scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("String default literal scenario should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("String default literal scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("String default literal scenario should emit exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	bPassed &= TestEqual(
		TEXT("String default literal scenario should preserve the expected module name"),
		ModuleDesc->ModuleName,
		CompilerPipelinePropertyDefaultTest::ModuleName.ToString());

	const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(CompilerPipelinePropertyDefaultTest::ClassName);
	if (!TestTrue(TEXT("String default literal scenario should parse the annotated class descriptor"), ClassDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("String default literal scenario should preserve the exact defaults code text"),
		ClassDesc->DefaultsCode,
		CompilerPipelinePropertyDefaultTest::ExpectedDefaultsCode);
	bPassed &= TestTrue(
		TEXT("String default literal scenario should keep the line-comment marker inside the defaults code"),
		ClassDesc->DefaultsCode.Contains(TEXT("//not a comment")));
	bPassed &= TestTrue(
		TEXT("String default literal scenario should keep the block-comment marker inside the defaults code"),
		ClassDesc->DefaultsCode.Contains(TEXT("/*literal*/")));

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelinePropertyDefaultTest::ModuleName,
		CompilerPipelinePropertyDefaultTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	if (Summary.Diagnostics.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Compile diagnostics: %s"),
			*CompilerPipelinePropertyDefaultTest::JoinDiagnostics(Summary.Diagnostics)));
	}

	bPassed &= TestTrue(
		TEXT("String default literal scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("String default literal scenario should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("String default literal scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("String default literal scenario should finish with a fully handled compile result"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("String default literal scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled || !Summary.bCompileSucceeded)
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelinePropertyDefaultTest::ClassName);
	if (!TestNotNull(TEXT("String default literal scenario should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	FStrProperty* MessageProperty = FindFProperty<FStrProperty>(GeneratedClass, *CompilerPipelinePropertyDefaultTest::MessagePropertyName);
	FStrProperty* BlockTextProperty = FindFProperty<FStrProperty>(GeneratedClass, *CompilerPipelinePropertyDefaultTest::BlockTextPropertyName);
	UFunction* VerifyDefaultsFunction = FindGeneratedFunction(GeneratedClass, CompilerPipelinePropertyDefaultTest::VerifyFunctionName);
	if (!TestNotNull(TEXT("String default literal scenario should materialize the Message property"), MessageProperty)
		|| !TestNotNull(TEXT("String default literal scenario should materialize the BlockText property"), BlockTextProperty)
		|| !TestNotNull(TEXT("String default literal scenario should materialize the verification function"), VerifyDefaultsFunction))
	{
		return false;
	}

	UObject* DefaultObject = GeneratedClass->GetDefaultObject();
	UObject* RuntimeObject = NewObject<UObject>(GetTransientPackage(), GeneratedClass, TEXT("CompilerStringDefaultCarrier"));
	if (!TestNotNull(TEXT("String default literal scenario should expose the generated CDO"), DefaultObject)
		|| !TestNotNull(TEXT("String default literal scenario should instantiate the generated class"), RuntimeObject))
	{
		return false;
	}

	CompilerPipelinePropertyDefaultTest::FRuntimeDefaultObservation Observation;
	bPassed &= CompilerPipelinePropertyDefaultTest::ReadStringPropertyValue(
		*this,
		TEXT("String default literal scenario should read Message from the CDO"),
		MessageProperty,
		DefaultObject,
		Observation.DefaultMessage);
	bPassed &= CompilerPipelinePropertyDefaultTest::ReadStringPropertyValue(
		*this,
		TEXT("String default literal scenario should read BlockText from the CDO"),
		BlockTextProperty,
		DefaultObject,
		Observation.DefaultBlockText);
	bPassed &= CompilerPipelinePropertyDefaultTest::ReadStringPropertyValue(
		*this,
		TEXT("String default literal scenario should read Message from a runtime instance"),
		MessageProperty,
		RuntimeObject,
		Observation.RuntimeMessage);
	bPassed &= CompilerPipelinePropertyDefaultTest::ReadStringPropertyValue(
		*this,
		TEXT("String default literal scenario should read BlockText from a runtime instance"),
		BlockTextProperty,
		RuntimeObject,
		Observation.RuntimeBlockText);

	bPassed &= CompilerPipelinePropertyDefaultTest::VerifyStringValue(
		*this,
		TEXT("String default literal scenario should preserve Message on the CDO"),
		Observation.DefaultMessage,
		CompilerPipelinePropertyDefaultTest::ExpectedMessage);
	bPassed &= CompilerPipelinePropertyDefaultTest::VerifyStringValue(
		*this,
		TEXT("String default literal scenario should preserve BlockText on the CDO"),
		Observation.DefaultBlockText,
		CompilerPipelinePropertyDefaultTest::ExpectedBlockText);
	bPassed &= CompilerPipelinePropertyDefaultTest::VerifyStringValue(
		*this,
		TEXT("String default literal scenario should preserve Message on runtime instances"),
		Observation.RuntimeMessage,
		CompilerPipelinePropertyDefaultTest::ExpectedMessage);
	bPassed &= CompilerPipelinePropertyDefaultTest::VerifyStringValue(
		*this,
		TEXT("String default literal scenario should preserve BlockText on runtime instances"),
		Observation.RuntimeBlockText,
		CompilerPipelinePropertyDefaultTest::ExpectedBlockText);

	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(
		&Engine,
		RuntimeObject,
		VerifyDefaultsFunction,
		Observation.VerifyResult);
	bPassed &= TestTrue(
		TEXT("String default literal scenario should execute the generated verification function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("String default literal scenario should keep comment markers and escaped quotes visible to script runtime code"),
			Observation.VerifyResult,
			CompilerPipelinePropertyDefaultTest::ExpectedVerifyResult);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
