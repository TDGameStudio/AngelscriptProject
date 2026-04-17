#include "AngelscriptEngine.h"
#include "Angelscript/AngelscriptTestSupport.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Containers/StringConv.h"
#include "Engine/EngineTypes.h"
#include "Math/IntPoint.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptEngineTypeInteropTests_Private
{
	struct FEngineTypeInteropContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FEngineTypeInteropContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FEngineTypeInteropContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};

	FString MakeAutomationTypeInteropName(const TCHAR* Prefix)
	{
		return FString::Printf(
			TEXT("%s_%s"),
			Prefix,
			*FGuid::NewGuid().ToString(EGuidFormats::Digits).Left(8));
	}
}

using namespace AngelscriptTest_Core_AngelscriptEngineTypeInteropTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGetUnrealStructFromTypeIdRejectsNonStructsTest,
	"Angelscript.TestModule.Engine.TypeInterop.GetUnrealStructFromTypeIdRejectsNonStructAndPreservesPlainStructs",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGetUnrealStructFromTypeIdRejectsNonStructsTest::RunTest(const FString& Parameters)
{
	FEngineTypeInteropContextStackGuard ContextGuard;
	DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	ON_SCOPE_EXIT
	{
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		DestroySharedTestEngine();
	};

	TUniquePtr<FAngelscriptEngine> TestEngine = CreateFullTestEngine();
	if (!TestNotNull(TEXT("TypeInterop test should create an isolated full engine"), TestEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineScope EngineScope(*TestEngine);
	asIScriptEngine* ScriptEngine = TestEngine->GetScriptEngine();
	if (!TestNotNull(TEXT("TypeInterop test should expose a live script engine"), ScriptEngine))
	{
		return false;
	}

	const FString ModuleName = MakeAutomationTypeInteropName(TEXT("ASTypeInterop"));
	const FString SingleCastTypeName = MakeAutomationTypeInteropName(TEXT("FAutomationSingleCast"));
	const FString MultiCastTypeName = MakeAutomationTypeInteropName(TEXT("FAutomationMultiCast"));
	const FString ScriptSource = FString::Printf(
		TEXT("delegate void %s(int32 Value);\n")
		TEXT("event void %s(int32 Value);\n")
		TEXT("int Entry() { return 0; }\n"),
		*SingleCastTypeName,
		*MultiCastTypeName);

	const auto ModuleNameAnsi = StringCast<ANSICHAR>(*ModuleName);
	asIScriptModule* Module = BuildModule(*this, *TestEngine, ModuleNameAnsi.Get(), ScriptSource);
	if (!TestNotNull(TEXT("TypeInterop test should compile the delegate/event fixture module"), Module))
	{
		return false;
	}

	const int PlainStructTypeId = ScriptEngine->GetTypeIdByDecl("FIntPoint");
	const int EnumTypeId = ScriptEngine->GetTypeIdByDecl("ECollisionChannel");
	const auto ArrayDeclAnsi = StringCast<ANSICHAR>(TEXT("TArray<FIntPoint>"));
	const int TemplateTypeId = ScriptEngine->GetTypeIdByDecl(ArrayDeclAnsi.Get());
	const auto SingleCastTypeNameAnsi = StringCast<ANSICHAR>(*SingleCastTypeName);
	const auto MultiCastTypeNameAnsi = StringCast<ANSICHAR>(*MultiCastTypeName);
	asITypeInfo* SingleCastTypeInfo = Module->GetTypeInfoByName(SingleCastTypeNameAnsi.Get());
	asITypeInfo* MultiCastTypeInfo = Module->GetTypeInfoByName(MultiCastTypeNameAnsi.Get());

	if (!TestTrue(TEXT("TypeInterop test should resolve a valid FIntPoint type id"), PlainStructTypeId >= 0)
		|| !TestTrue(TEXT("TypeInterop test should resolve a valid ECollisionChannel enum type id"), EnumTypeId >= 0)
		|| !TestTrue(TEXT("TypeInterop test should resolve a valid TArray<FIntPoint> template type id"), TemplateTypeId >= 0)
		|| !TestNotNull(TEXT("TypeInterop test should resolve the declared single-cast delegate type"), SingleCastTypeInfo)
		|| !TestNotNull(TEXT("TypeInterop test should resolve the declared multi-cast event type"), MultiCastTypeInfo))
	{
		return false;
	}

	const int SingleCastTypeId = SingleCastTypeInfo->GetTypeId();
	const int MultiCastTypeId = MultiCastTypeInfo->GetTypeId();
	if (!TestTrue(TEXT("TypeInterop test should produce a valid single-cast delegate type id"), SingleCastTypeId >= 0)
		|| !TestTrue(TEXT("TypeInterop test should produce a valid multi-cast event type id"), MultiCastTypeId >= 0))
	{
		return false;
	}

	UStruct* PlainStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(PlainStructTypeId);
	UStruct* EnumStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(EnumTypeId);
	UStruct* TemplateStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(TemplateTypeId);
	UStruct* SingleCastStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(SingleCastTypeId);
	UStruct* MultiCastStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(MultiCastTypeId);
	UStruct* InvalidStruct = TestEngine->GetUnrealStructFromAngelscriptTypeId(-1);

	bool bPassed = true;
	bPassed &= TestTrue(
		TEXT("TypeInterop test should map the plain FIntPoint type id back to the reflected Unreal struct"),
		PlainStruct == TBaseStructure<FIntPoint>::Get());
	bPassed &= TestNull(
		TEXT("TypeInterop test should reject enum type ids as non-struct Unreal mappings"),
		EnumStruct);
	bPassed &= TestNull(
		TEXT("TypeInterop test should reject template instance type ids as non-plain Unreal structs"),
		TemplateStruct);
	bPassed &= TestNull(
		TEXT("TypeInterop test should reject single-cast delegate type ids as non-struct Unreal mappings"),
		SingleCastStruct);
	bPassed &= TestNull(
		TEXT("TypeInterop test should reject multi-cast event type ids as non-struct Unreal mappings"),
		MultiCastStruct);
	bPassed &= TestNull(
		TEXT("TypeInterop test should reject invalid type ids"),
		InvalidStruct);
	return bPassed;
}

#endif
