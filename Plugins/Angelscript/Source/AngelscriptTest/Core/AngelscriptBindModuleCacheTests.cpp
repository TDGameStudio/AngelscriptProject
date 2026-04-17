#include "AngelscriptBinds.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Guid.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptBindModuleCacheTests_Private
{
	FString MakeBindModuleCacheAutomationDirectory()
	{
		return FPaths::Combine(
			FPaths::ProjectSavedDir(),
			TEXT("Automation"),
			TEXT("BindModulesCache"),
			FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	TArray<FString> MakeExpectedBindModules()
	{
		return {
			TEXT("ASRuntimeBind_Alpha"),
			TEXT("ASEditorBind_Beta"),
			TEXT("ASRuntimeBind_Gamma"),
		};
	}

	bool ExpectBindModuleSequence(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const TArray<FString>& Actual,
		const TArray<FString>& Expected)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the bind module count"), Context),
			Actual.Num(),
			Expected.Num());

		for (int32 Index = 0; Index < FMath::Min(Actual.Num(), Expected.Num()); ++Index)
		{
			bOk &= Test.TestEqual(
				*FString::Printf(TEXT("%s should preserve the bind module at index %d"), Context, Index),
				Actual[Index],
				Expected[Index]);
		}

		return bOk;
	}
}

using namespace AngelscriptTest_Core_AngelscriptBindModuleCacheTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindModuleCacheRoundTripAndMissingFileTest,
	"Angelscript.TestModule.Engine.BindConfig.BindModuleCache.RoundTripsOrderAndClearsOnMissingFile",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBindModuleCacheRoundTripAndMissingFileTest::RunTest(const FString& Parameters)
{
	const TArray<FString> ExpectedBindModules = MakeExpectedBindModules();
	const FString CacheDirectory = MakeBindModuleCacheAutomationDirectory();
	const FString CachePath = FPaths::Combine(CacheDirectory, TEXT("BindModules.Cache"));
	const FString MissingCachePath = FPaths::Combine(CacheDirectory, TEXT("MissingBindModules.Cache"));

	IFileManager::Get().MakeDirectory(*CacheDirectory, true);
	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		IFileManager::Get().DeleteDirectory(*CacheDirectory, false, true);
	};

	TArray<FString>& BindModuleNames = FAngelscriptBinds::GetBindModuleNames();
	BindModuleNames = ExpectedBindModules;
	FAngelscriptBinds::SaveBindModules(CachePath);

	if (!TestTrue(
			TEXT("BindModuleCache should write BindModules.Cache to the automation directory"),
			IFileManager::Get().FileExists(*CachePath)))
	{
		return false;
	}

	TArray<FString> SavedLines;
	if (!TestTrue(
			TEXT("BindModuleCache should persist BindModules.Cache as readable string lines"),
			FFileHelper::LoadFileToStringArray(SavedLines, *CachePath)))
	{
		return false;
	}

	if (!ExpectBindModuleSequence(
			*this,
			TEXT("BindModuleCache save path"),
			SavedLines,
			ExpectedBindModules))
	{
		return false;
	}

	FAngelscriptBinds::ResetBindState();
	if (!TestEqual(
			TEXT("BindModuleCache reset should clear the in-memory bind module list before reload"),
			FAngelscriptBinds::GetBindModuleNames().Num(),
			0))
	{
		return false;
	}

	FAngelscriptBinds::LoadBindModules(CachePath);
	if (!ExpectBindModuleSequence(
			*this,
			TEXT("BindModuleCache round-trip"),
			FAngelscriptBinds::GetBindModuleNames(),
			ExpectedBindModules))
	{
		return false;
	}

	BindModuleNames = {
		TEXT("ASRuntimeBind_Stale"),
		TEXT("ASEditorBind_Stale"),
	};

	if (!TestFalse(
			TEXT("BindModuleCache missing-file coverage should use a path that does not exist"),
			IFileManager::Get().FileExists(*MissingCachePath)))
	{
		return false;
	}

	FAngelscriptBinds::LoadBindModules(MissingCachePath);
	return TestEqual(
		TEXT("BindModuleCache missing-file load should clear stale in-memory bind module names"),
		FAngelscriptBinds::GetBindModuleNames().Num(),
		0);
}

#endif
