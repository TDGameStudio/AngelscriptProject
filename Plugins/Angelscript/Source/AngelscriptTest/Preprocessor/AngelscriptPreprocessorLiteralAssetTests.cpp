#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorLiteralAssetTests_Private
{
	FString GetPreprocessorLiteralAssetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorLiteralAssetFixtures"));
	}

	FString WritePreprocessorLiteralAssetFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorLiteralAssetFixtureRoot(), RelativeScriptPath);
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
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorLiteralAssetTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorLiteralAssetGetterAndPostInitRegistrationTest,
	"Angelscript.TestModule.Preprocessor.LiteralAssets.GenerateGetterAndPostInitRegistration",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorLiteralAssetGetterAndPostInitRegistrationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/LiteralAssets/GenerateGetterAndPostInitRegistration.as");
	const FString AbsoluteScriptPath = WritePreprocessorLiteralAssetFixture(
		RelativeScriptPath,
		TEXT("asset PreviewAsset of UObject\n")
		TEXT("{\n")
		TEXT("}\n\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return 7;\n")
		TEXT("}\n"));

	static const FString ExpectedModuleName = TEXT("Tests.Preprocessor.LiteralAssets.GenerateGetterAndPostInitRegistration");
	static const FString ExpectedGetterName = TEXT("GetPreviewAsset");

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	if (!TestTrue(
		TEXT("Literal-asset preprocessing should succeed for a minimal asset declaration plus Entry function"),
		bPreprocessSucceeded))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	if (!TestEqual(
		TEXT("Literal-asset preprocessing should keep exactly one module descriptor"),
		Modules.Num(),
		1))
	{
		return false;
	}

	const FAngelscriptModuleDesc* LiteralAssetModule = FindModuleByName(Modules, ExpectedModuleName);
	if (!TestNotNull(
		TEXT("Literal-asset preprocessing should emit the expected module descriptor"),
		LiteralAssetModule))
	{
		return false;
	}

	if (!TestEqual(
		TEXT("Literal-asset preprocessing should emit exactly one code section for the single source file"),
		LiteralAssetModule->Code.Num(),
		1))
	{
		return false;
	}

	const FString& ProcessedCode = LiteralAssetModule->Code[0].Code;
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

	const bool bHasNoDiagnostics = TestTrue(
		TEXT("Literal-asset preprocessing should not emit diagnostics for the valid source file"),
		Diagnostics == nullptr || Diagnostics->Diagnostics.Num() == 0);
	const bool bStripsOriginalDeclaration = TestFalse(
		TEXT("Literal-asset preprocessing should remove the original asset declaration text from emitted code"),
		ProcessedCode.Contains(TEXT("asset PreviewAsset of UObject")));
	const bool bKeepsEntryFunction = TestTrue(
		TEXT("Literal-asset preprocessing should preserve unrelated script code after rewriting the asset declaration"),
		ProcessedCode.Contains(TEXT("int Entry()")));
	const bool bGeneratesBackingField = TestTrue(
		TEXT("Literal-asset preprocessing should generate the backing asset field"),
		ProcessedCode.Contains(TEXT("UObject __Asset_PreviewAsset;")));
	const bool bGeneratesPropertyGetter = TestTrue(
		TEXT("Literal-asset preprocessing should generate the property getter declaration"),
		ProcessedCode.Contains(TEXT("UObject GetPreviewAsset() property")));
	const bool bGeneratesCreateLiteralAssetCall = TestTrue(
		TEXT("Literal-asset preprocessing should generate the literal-asset creation call inside the getter"),
		ProcessedCode.Contains(TEXT("__CreateLiteralAsset(UObject, \"PreviewAsset\")")));
	const bool bGeneratesPostLiteralAssetSetupCall = TestTrue(
		TEXT("Literal-asset preprocessing should generate the post-literal-asset setup call inside the getter"),
		ProcessedCode.Contains(TEXT("__PostLiteralAssetSetup(__Asset_PreviewAsset, \"PreviewAsset\");")));
	const bool bRegistersSinglePostInitFunction = TestEqual(
		TEXT("Literal-asset preprocessing should register exactly one post-init function for the generated getter"),
		LiteralAssetModule->PostInitFunctions.Num(),
		1);
	const bool bRegistersExpectedGetterName = bRegistersSinglePostInitFunction
		&& TestEqual(
			TEXT("Literal-asset preprocessing should register the generated getter as the post-init function"),
			LiteralAssetModule->PostInitFunctions[0],
			ExpectedGetterName);

	bPassed =
		bHasNoDiagnostics &&
		bStripsOriginalDeclaration &&
		bKeepsEntryFunction &&
		bGeneratesBackingField &&
		bGeneratesPropertyGetter &&
		bGeneratesCreateLiteralAssetCall &&
		bGeneratesPostLiteralAssetSetupCall &&
		bRegistersSinglePostInitFunction &&
		bRegistersExpectedGetterName;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorLiteralAssetSkipStringAndCommentDecoysTest,
	"Angelscript.TestModule.Preprocessor.LiteralAssets.SkipStringAndCommentDecoys",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorLiteralAssetSkipStringAndCommentDecoysTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/LiteralAssets/SkipStringAndCommentDecoys.as");
	const FString AbsoluteScriptPath = WritePreprocessorLiteralAssetFixture(
		RelativeScriptPath,
		TEXT("asset RealAsset of UObject\n")
		TEXT("\n")
		TEXT("FString BuildAssetText()\n")
		TEXT("{\n")
		TEXT("    return \"asset FakeAsset of UObject\";\n")
		TEXT("}\n")
		TEXT("\n")
		TEXT("// asset CommentAsset of UObject\n")
		TEXT("int Entry()\n")
		TEXT("{\n")
		TEXT("    return BuildAssetText().Len();\n")
		TEXT("}\n"));

	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	static const FString ExpectedModuleName = TEXT("Tests.Preprocessor.LiteralAssets.SkipStringAndCommentDecoys");

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptModuleDesc* LiteralAssetModule = FindModuleByName(Modules, ExpectedModuleName);
	const FString ProcessedCode = (LiteralAssetModule != nullptr && LiteralAssetModule->Code.Num() > 0)
		? LiteralAssetModule->Code[0].Code
		: FString();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

	const bool bHasNoDiagnostics = TestTrue(
		TEXT("Literal-asset decoy preprocessing should keep diagnostics empty"),
		Diagnostics == nullptr || Diagnostics->Diagnostics.Num() == 0);
	const bool bPreprocessSucceededCheck = TestTrue(
		TEXT("Literal-asset decoy preprocessing should succeed"),
		bPreprocessSucceeded);
	const bool bEmitsSingleModule = TestEqual(
		TEXT("Literal-asset decoy preprocessing should keep exactly one module descriptor"),
		Modules.Num(),
		1);
	const bool bFindsExpectedModule = TestNotNull(
		TEXT("Literal-asset decoy preprocessing should emit the expected module descriptor"),
		LiteralAssetModule);
	const bool bKeepsSingleCodeSection = (LiteralAssetModule != nullptr)
		&& TestEqual(
			TEXT("Literal-asset decoy preprocessing should keep exactly one code section"),
			LiteralAssetModule->Code.Num(),
			1);
	const bool bRegistersSinglePostInitFunction = (LiteralAssetModule != nullptr)
		&& TestEqual(
			TEXT("Literal-asset decoy preprocessing should register exactly one post-init function"),
			LiteralAssetModule->PostInitFunctions.Num(),
			1);
	const bool bRegistersOnlyRealGetter = bRegistersSinglePostInitFunction
		&& TestEqual(
			TEXT("Literal-asset decoy preprocessing should register only the real asset getter"),
			LiteralAssetModule->PostInitFunctions[0],
			FString(TEXT("GetRealAsset")));
	const bool bGeneratesRealBackingField = TestTrue(
		TEXT("Literal-asset decoy preprocessing should still generate the real asset backing field"),
		ProcessedCode.Contains(TEXT("UObject __Asset_RealAsset;")));
	const bool bGeneratesRealGetter = TestTrue(
		TEXT("Literal-asset decoy preprocessing should still generate the real asset getter"),
		ProcessedCode.Contains(TEXT("UObject GetRealAsset() property")));
	const bool bKeepsStringLiteralUnchanged = TestTrue(
		TEXT("Literal-asset decoy preprocessing should preserve the fake asset string literal text"),
		ProcessedCode.Contains(TEXT("\"asset FakeAsset of UObject\"")));
	const bool bDoesNotGenerateFakeField = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate a backing field for the fake string asset"),
		ProcessedCode.Contains(TEXT("__Asset_FakeAsset")));
	const bool bDoesNotGenerateFakeGetter = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate a getter for the fake string asset"),
		ProcessedCode.Contains(TEXT("GetFakeAsset() property")));
	const bool bDoesNotGenerateFakeCreate = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate literal-asset creation for the fake string asset"),
		ProcessedCode.Contains(TEXT("__CreateLiteralAsset(UObject, \"FakeAsset\")")));
	const bool bDoesNotGenerateCommentField = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate a backing field for the comment decoy"),
		ProcessedCode.Contains(TEXT("__Asset_CommentAsset")));
	const bool bDoesNotGenerateCommentGetter = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate a getter for the comment decoy"),
		ProcessedCode.Contains(TEXT("GetCommentAsset() property")));
	const bool bDoesNotGenerateCommentCreate = TestFalse(
		TEXT("Literal-asset decoy preprocessing should not generate literal-asset creation for the comment decoy"),
		ProcessedCode.Contains(TEXT("__CreateLiteralAsset(UObject, \"CommentAsset\")")));

	bPassed =
		bHasNoDiagnostics &&
		bPreprocessSucceededCheck &&
		bEmitsSingleModule &&
		bFindsExpectedModule &&
		bKeepsSingleCodeSection &&
		bRegistersSinglePostInitFunction &&
		bRegistersOnlyRealGetter &&
		bGeneratesRealBackingField &&
		bGeneratesRealGetter &&
		bKeepsStringLiteralUnchanged &&
		bDoesNotGenerateFakeField &&
		bDoesNotGenerateFakeGetter &&
		bDoesNotGenerateFakeCreate &&
		bDoesNotGenerateCommentField &&
		bDoesNotGenerateCommentGetter &&
		bDoesNotGenerateCommentCreate;

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
