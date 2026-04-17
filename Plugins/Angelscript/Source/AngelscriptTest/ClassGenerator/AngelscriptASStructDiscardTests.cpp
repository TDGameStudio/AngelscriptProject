#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASStruct.h"
#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace ASStructDiscardTest
{
	static const FName ModuleName(TEXT("ASStructDiscardModule"));
	static const FName StructName(TEXT("DiscardableStruct"));
	static const FString ScriptFilename(TEXT("ASStructDiscardModule.as"));

	FString GetScriptAbsoluteFilename()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), ScriptFilename);
	}

	UASStruct* FindStruct()
	{
		return FindObject<UASStruct>(FAngelscriptEngine::GetPackage(), *StructName.ToString());
	}
}

using namespace ASStructDiscardTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASStructDiscardModuleClearsScriptTypeAndNativeOpsTest,
	"Angelscript.TestModule.ClassGenerator.ASStruct.DiscardModuleClearsScriptTypeAndNativeOps",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASStructDiscardModuleClearsScriptTypeAndNativeOpsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASStructDiscardTest::ModuleName.ToString());
		IFileManager::Get().Delete(*ASStructDiscardTest::GetScriptAbsoluteFilename(), false, true, true);
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
USTRUCT()
struct FDiscardableStruct
{
	UPROPERTY()
	int Value = 7;

	bool opEquals(const FDiscardableStruct& Other) const
	{
		return Value == Other.Value;
	}

	uint32 Hash() const
	{
		return uint32(Value + 11);
	}

	FString ToString() const
	{
		return "Discardable";
	}
};
)AS");

	if (!TestTrue(
			TEXT("ASStruct discard test should compile the struct module"),
			CompileAnnotatedModuleFromMemory(&Engine, ASStructDiscardTest::ModuleName, ASStructDiscardTest::ScriptFilename, ScriptSource)))
	{
		return false;
	}

	UASStruct* Struct = ASStructDiscardTest::FindStruct();
	if (!TestNotNull(TEXT("ASStruct discard test should register the generated struct in the Angelscript package"), Struct))
	{
		return false;
	}

	Struct->PrepareCppStructOps();

	if (!TestNotNull(TEXT("ASStruct discard test should publish a script type before discard"), Struct->ScriptType)
		|| !TestNotNull(TEXT("ASStruct discard test should create cpp struct ops before discard"), Struct->GetCppStructOps())
		|| !TestNotNull(TEXT("ASStruct discard test should keep the script ToString binding before discard"), Struct->GetToStringFunction()))
	{
		return false;
	}

	TestTrue(
		TEXT("ASStruct discard test should advertise identical-native support before discard"),
		EnumHasAnyFlags(Struct->StructFlags, STRUCT_IdenticalNative));

	const bool bDiscarded = Engine.DiscardModule(*ASStructDiscardTest::ModuleName.ToString());
	bPassed &= TestTrue(TEXT("ASStruct discard test should discard the owning module successfully"), bDiscarded);
	bPassed &= TestFalse(
		TEXT("ASStruct discard test should remove the module record after discard"),
		Engine.GetModuleByModuleName(ASStructDiscardTest::ModuleName.ToString()).IsValid());
	bPassed &= TestNull(TEXT("ASStruct discard test should clear the struct script type after discard"), Struct->ScriptType);
	bPassed &= TestNotNull(
		TEXT("ASStruct discard test should keep the cached cpp struct ops object alive after discard"),
		Struct->GetCppStructOps());
	bPassed &= TestNull(
		TEXT("ASStruct discard test should clear the cached ToString function after discard"),
		Struct->GetToStringFunction());
	bPassed &= TestFalse(
		TEXT("ASStruct discard test should clear STRUCT_IdenticalNative after discard"),
		EnumHasAnyFlags(Struct->StructFlags, STRUCT_IdenticalNative));

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
