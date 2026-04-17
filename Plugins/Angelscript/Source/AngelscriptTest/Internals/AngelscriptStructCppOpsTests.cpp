#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../../AngelscriptRuntime/Core/AngelscriptBinds.h"
#include "Internals/AngelscriptStructCppOpsTestTypes.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptStructCppOpsTests_Private
{
	UScriptStruct* BuildScriptStruct(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const char* ModuleName,
		const FString& Source,
		const char* TypeName)
	{
		asIScriptModule* Module = AngelscriptTestSupport::BuildModule(Test, Engine, ModuleName, Source);
		if (Module == nullptr)
		{
			return nullptr;
		}

		FString UnrealName = UTF8_TO_TCHAR(TypeName);
		if (UnrealName.Len() >= 2 && UnrealName[0] == 'F' && FChar::IsUpper(UnrealName[1]))
		{
			UnrealName.RightChopInline(1, EAllowShrinking::No);
		}

		UScriptStruct* Struct = FindObject<UScriptStruct>(FAngelscriptEngine::GetPackage(), *UnrealName);
		if (!Test.TestNotNull(TEXT("Compiled script struct should have a backing UScriptStruct"), Struct))
		{
			return nullptr;
		}
		return Struct;
	}
}

using namespace AngelscriptTest_Internals_AngelscriptStructCppOpsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStructNotBlueprintTypeByDefaultTest,
	"Angelscript.TestModule.Internals.StructCppOps.NotBlueprintTypeByDefault",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptStructNotBlueprintTypeByDefaultTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	UScriptStruct* Struct = BuildScriptStruct(
		*this,
		Engine,
		"StructCppOpsScopeModule",
		TEXT(R"ANGELSCRIPT(
struct FScopeConstructStruct
{
	int Value = 7;
}
)ANGELSCRIPT"),
		"FScopeConstructStruct");
	if (Struct == nullptr)
	{
		return false;
	}

	TestFalse(TEXT("Script structs should not be BlueprintType by default"), Struct->GetBoolMetaData(TEXT("BlueprintType")));
	bPassed = !Struct->GetBoolMetaData(TEXT("BlueprintType"));
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStructCppOpsValueClassUsesCppStructOpsTest,
	"Angelscript.TestModule.Internals.StructCppOps.ValueClassUsesCppStructOps",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptStructCppOpsValueClassUsesCppStructOpsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FAngelscriptStructCppOpsLifecycleFixture::ResetCounters();
	UScriptStruct* Struct = FAngelscriptStructCppOpsLifecycleFixture::StaticStruct();
	if (!TestNotNull(TEXT("StructCppOps fixture should expose a native UScriptStruct"), Struct))
	{
		return false;
	}

	UScriptStruct::ICppStructOps* Ops = Struct->GetCppStructOps();
	if (!TestNotNull(TEXT("StructCppOps fixture should expose cpp struct ops"), Ops))
	{
		return false;
	}

	bPassed &= TestEqual(TEXT("StructCppOps fixture should keep the expected native alignment"), Struct->GetMinAlignment(), static_cast<int32>(alignof(FAngelscriptStructCppOpsLifecycleFixture)));
	bPassed &= TestEqual(TEXT("StructCppOps fixture should report cpp ops size"), Ops->GetSize(), static_cast<int32>(sizeof(FAngelscriptStructCppOpsLifecycleFixture)));
	bPassed &= TestTrue(TEXT("StructCppOps fixture should expose copy support through cpp ops"), Ops->HasCopy());
	bPassed &= TestTrue(TEXT("StructCppOps fixture should expose destructor support through cpp ops"), Ops->HasDestructor());

	FAngelscriptBinds BoundType = FAngelscriptBinds::ValueClass("FStructCppOpsLifecycleFixtureNative", Struct, FBindFlags());
	asITypeInfo* TypeInfo = BoundType.GetTypeInfo();
	if (!TestNotNull(TEXT("ValueClass should register a script type for the native struct"), TypeInfo))
	{
		return false;
	}

	bPassed &= TestEqual(TEXT("ValueClass should use cpp ops size for the bound type"), static_cast<int32>(TypeInfo->GetSize()), Ops->GetSize());
	bPassed &= TestEqual(TEXT("ValueClass should preserve the struct alignment"), TypeInfo->alignment, Struct->GetMinAlignment());

	void* SourceMemory = FMemory::Malloc(Ops->GetSize(), Struct->GetMinAlignment());
	void* DestinationMemory = FMemory::Malloc(Ops->GetSize(), Struct->GetMinAlignment());
	bool bSourceInitialized = false;
	bool bDestinationInitialized = false;
	ON_SCOPE_EXIT
	{
		if (bDestinationInitialized)
		{
			Struct->DestroyStruct(DestinationMemory, 1);
		}

		if (bSourceInitialized)
		{
			Struct->DestroyStruct(SourceMemory, 1);
		}

		FMemory::Free(DestinationMemory);
		FMemory::Free(SourceMemory);
	};

	if (!TestNotNull(TEXT("StructCppOps fixture should allocate source memory"), SourceMemory)
		|| !TestNotNull(TEXT("StructCppOps fixture should allocate destination memory"), DestinationMemory))
	{
		return false;
	}

	Struct->InitializeStruct(SourceMemory, 1);
	bSourceInitialized = true;
	auto* SourceValue = static_cast<FAngelscriptStructCppOpsLifecycleFixture*>(SourceMemory);
	bPassed &= TestEqual(TEXT("InitializeStruct should run the default constructor once"), FAngelscriptStructCppOpsLifecycleFixture::DefaultConstructorCount, 1);
	bPassed &= TestEqual(TEXT("InitializeStruct should write the sentinel value"), SourceValue->SentinelValue, FAngelscriptStructCppOpsLifecycleFixture::DefaultSentinelValue);
	bPassed &= TestEqual(TEXT("InitializeStruct should write the payload value"), SourceValue->PayloadValue, FAngelscriptStructCppOpsLifecycleFixture::DefaultPayloadValue);

	SourceValue->PayloadValue = 9001;

	Struct->InitializeStruct(DestinationMemory, 1);
	bDestinationInitialized = true;
	bPassed &= TestEqual(TEXT("Destination InitializeStruct should run the default constructor again"), FAngelscriptStructCppOpsLifecycleFixture::DefaultConstructorCount, 2);

	Struct->CopyScriptStruct(DestinationMemory, SourceMemory, 1);
	auto* DestinationValue = static_cast<FAngelscriptStructCppOpsLifecycleFixture*>(DestinationMemory);
	bPassed &= TestEqual(TEXT("CopyScriptStruct should route through the native copy op"), FAngelscriptStructCppOpsLifecycleFixture::CopyCount, 1);
	bPassed &= TestEqual(TEXT("CopyScriptStruct should copy the sentinel value"), DestinationValue->SentinelValue, SourceValue->SentinelValue);
	bPassed &= TestEqual(TEXT("CopyScriptStruct should copy the payload value"), DestinationValue->PayloadValue, SourceValue->PayloadValue);

	Struct->DestroyStruct(DestinationMemory, 1);
	bDestinationInitialized = false;
	Struct->DestroyStruct(SourceMemory, 1);
	bSourceInitialized = false;
	bPassed &= TestEqual(TEXT("DestroyStruct should run both native destructors"), FAngelscriptStructCppOpsLifecycleFixture::DestructorCount, 2);

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
