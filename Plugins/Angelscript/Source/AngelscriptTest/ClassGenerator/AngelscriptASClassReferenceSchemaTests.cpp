#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptNativeScriptTestObject.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/FastReferenceCollector.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"
#include "UObject/WeakObjectPtrTemplates.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_ClassGenerator_AngelscriptASClassReferenceSchemaTests_Private
{
	static const FName ReferenceSchemaModuleName(TEXT("ASClassReferenceSchema"));
	static const FString ReferenceSchemaFilename(TEXT("ASClassReferenceSchema.as"));
	static const FName ReferenceSchemaClassName(TEXT("UReferenceSchemaHolder"));
	static const FName ReferenceSchemaSoftReloadModuleName(TEXT("ASClassReferenceSchemaSoftReload"));
	static const FString ReferenceSchemaSoftReloadFilename(TEXT("ASClassReferenceSchemaSoftReload.as"));
	static const FName ReferenceSchemaSoftReloadClassName(TEXT("UReferenceSchemaReloadHolder"));

	struct FStoreParams
	{
		UObject* InValue = nullptr;
	};

	struct FGetStoredParams
	{
		UObject* ReturnValue = nullptr;
	};

	struct FGetVersionParams
	{
		int32 ReturnValue = 0;
	};

	UFunction* RequireGeneratedFunction(
		FAutomationTestBase& Test,
		UClass* OwnerClass,
		FName FunctionName,
		const TCHAR* Context)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, FunctionName);
		Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose generated function '%s'"), Context, *FunctionName.ToString()),
			Function);
		return Function;
	}

	bool InvokeGeneratedFunction(
		FAngelscriptEngine& Engine,
		UObject* Object,
		UFunction* Function,
		void* Params)
	{
		if (!::IsValid(Object) || Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope FunctionScope(Engine, Object);
		if (UASFunction* ScriptFunction = Cast<UASFunction>(Function))
		{
			ScriptFunction->RuntimeCallEvent(Object, Params);
		}
		else
		{
			Object->ProcessEvent(Function, Params);
		}

		return true;
	}

	int32 CountSchemaMembers(UE::GC::FSchemaView Schema)
	{
		if (Schema.IsEmpty())
		{
			return 0;
		}

		int32 Count = 0;
		for (const UE::GC::FMemberWord* WordIt = Schema.GetWords(); true; ++WordIt)
		{
			const UE::GC::Private::FMemberWordUnpacked Quad(WordIt->Members);
			for (UE::GC::Private::FMemberUnpacked Member : Quad.Members)
			{
				switch (Member.Type)
				{
				case UE::GC::EMemberType::StridedArray:
				case UE::GC::EMemberType::StructArray:
				case UE::GC::EMemberType::StructSet:
				case UE::GC::EMemberType::FreezableStructArray:
				case UE::GC::EMemberType::Optional:
				case UE::GC::EMemberType::MemberARO:
					++WordIt;
					break;
				case UE::GC::EMemberType::ARO:
				case UE::GC::EMemberType::SlowARO:
				case UE::GC::EMemberType::Stop:
					return Count;
				default:
					break;
				}

				++Count;
			}
		}
	}
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptASClassReferenceSchemaTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassRuntimeAddReferencedObjectsKeepsScriptOnlyObjectReferenceAliveTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.RuntimeAddReferencedObjectsKeepsScriptOnlyObjectReferenceAlive",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassRuntimeAddReferencedObjectsKeepsScriptOnlyObjectReferenceAliveTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ReferenceSchemaModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UReferenceSchemaHolder : UObject
{
	UObject HiddenRef = nullptr;

	UFUNCTION()
	void Store(UObject InValue)
	{
		HiddenRef = InValue;
	}

	UFUNCTION()
	UObject GetStored() const
	{
		return HiddenRef;
	}
}
)AS");

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ReferenceSchemaModuleName,
		ReferenceSchemaFilename,
		ScriptSource,
		ReferenceSchemaClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UASClass* ScriptASClass = Cast<UASClass>(ScriptClass);
	if (!TestNotNull(TEXT("Reference-schema GC scenario should compile to a UASClass"), ScriptASClass))
	{
		return false;
	}

	TestNull(TEXT("Reference-schema GC scenario should keep HiddenRef out of reflected UPROPERTY storage"), FindFProperty<FProperty>(ScriptClass, TEXT("HiddenRef")));
	TestTrue(TEXT("Reference-schema GC scenario should build a non-empty GC schema for the script-only object field"), !ScriptASClass->ReferenceSchema.Get().IsEmpty());

	UFunction* StoreFunction = RequireGeneratedFunction(*this, ScriptClass, TEXT("Store"), TEXT("Reference-schema GC scenario"));
	UFunction* GetStoredFunction = RequireGeneratedFunction(*this, ScriptClass, TEXT("GetStored"), TEXT("Reference-schema GC scenario"));
	if (StoreFunction == nullptr || GetStoredFunction == nullptr)
	{
		return false;
	}

	UObject* Holder = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("ReferenceSchemaHolder"));
	if (!TestNotNull(TEXT("Reference-schema GC scenario should instantiate the generated holder"), Holder))
	{
		return false;
	}

	Holder->AddToRoot();
	ON_SCOPE_EXIT
	{
		if (Holder != nullptr)
		{
			Holder->RemoveFromRoot();
			Holder->MarkAsGarbage();
		}

		CollectGarbage(RF_NoFlags, true);
	};

	UAngelscriptNativeScriptTestObject* StrongTarget = NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage(), TEXT("ReferenceSchemaTarget"));
	if (!TestNotNull(TEXT("Reference-schema GC scenario should create a transient target UObject"), StrongTarget))
	{
		return false;
	}

	TWeakObjectPtr<UAngelscriptNativeScriptTestObject> WeakTarget = StrongTarget;

	FStoreParams StoreParams;
	StoreParams.InValue = StrongTarget;
	if (!TestTrue(TEXT("Reference-schema GC scenario should store the transient target through ProcessEvent"), InvokeGeneratedFunction(Engine, Holder, StoreFunction, &StoreParams)))
	{
		return false;
	}

	FGetStoredParams GetStoredBeforeGC;
	if (!TestTrue(TEXT("Reference-schema GC scenario should read back the stored object before GC"), InvokeGeneratedFunction(Engine, Holder, GetStoredFunction, &GetStoredBeforeGC)))
	{
		return false;
	}

	TestTrue(TEXT("Reference-schema GC scenario should return the same target before GC"), GetStoredBeforeGC.ReturnValue == StrongTarget);

	StrongTarget = nullptr;
	CollectGarbage(RF_NoFlags, true);

	TestTrue(TEXT("Reference-schema GC scenario should keep the target alive while the rooted holder keeps a script-only reference"), WeakTarget.IsValid());

	FGetStoredParams GetStoredAfterGC;
	if (!TestTrue(TEXT("Reference-schema GC scenario should still expose the stored object after GC"), InvokeGeneratedFunction(Engine, Holder, GetStoredFunction, &GetStoredAfterGC)))
	{
		return false;
	}

	TestTrue(TEXT("Reference-schema GC scenario should preserve the same object identity after GC"), GetStoredAfterGC.ReturnValue == WeakTarget.Get());

	FStoreParams ClearParams;
	if (!TestTrue(TEXT("Reference-schema GC scenario should clear the script-only object reference"), InvokeGeneratedFunction(Engine, Holder, StoreFunction, &ClearParams)))
	{
		return false;
	}

	FGetStoredParams GetStoredAfterClear;
	if (!TestTrue(TEXT("Reference-schema GC scenario should still execute GetStored after clearing the script-only field"), InvokeGeneratedFunction(Engine, Holder, GetStoredFunction, &GetStoredAfterClear)))
	{
		return false;
	}

	TestNull(TEXT("Reference-schema GC scenario should report a null stored object after clearing the script-only field"), GetStoredAfterClear.ReturnValue);

	CollectGarbage(RF_NoFlags, true);
	TestFalse(TEXT("Reference-schema GC scenario should release the transient target after clearing the last script-only reference"), WeakTarget.IsValid());
	ASTEST_END_SHARE_FRESH

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassReferenceSchemaDoesNotDuplicateAcrossRepeatedSoftReloadTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.ReferenceSchema.DoesNotDuplicateAcrossRepeatedSoftReload",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassReferenceSchemaDoesNotDuplicateAcrossRepeatedSoftReloadTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ReferenceSchemaSoftReloadModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class UReferenceSchemaReloadHolder : UObject
{
	UObject HiddenRef = nullptr;

	UFUNCTION()
	void Store(UObject InValue)
	{
		HiddenRef = InValue;
	}

	UFUNCTION()
	UObject GetStored() const
	{
		return HiddenRef;
	}

	UFUNCTION()
	int GetVersion() const
	{
		return 1;
	}
}
)AS");

	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class UReferenceSchemaReloadHolder : UObject
{
	UObject HiddenRef = nullptr;

	UFUNCTION()
	void Store(UObject InValue)
	{
		HiddenRef = InValue;
	}

	UFUNCTION()
	UObject GetStored() const
	{
		return HiddenRef;
	}

	UFUNCTION()
	int GetVersion() const
	{
		return 2;
	}
}
)AS");

	const FString ScriptV3 = TEXT(R"AS(
UCLASS()
class UReferenceSchemaReloadHolder : UObject
{
	UObject HiddenRef = nullptr;

	UFUNCTION()
	void Store(UObject InValue)
	{
		HiddenRef = InValue;
	}

	UFUNCTION()
	UObject GetStored() const
	{
		return HiddenRef;
	}

	UFUNCTION()
	int GetVersion() const
	{
		return 3;
	}
}
)AS");

	UClass* InitialClass = CompileScriptModule(
		*this,
		Engine,
		ReferenceSchemaSoftReloadModuleName,
		ReferenceSchemaSoftReloadFilename,
		ScriptV1,
		ReferenceSchemaSoftReloadClassName);
	if (InitialClass == nullptr)
	{
		return false;
	}

	UASClass* InitialASClass = Cast<UASClass>(InitialClass);
	if (!TestNotNull(TEXT("Reference-schema soft-reload scenario should compile the generated holder as a UASClass"), InitialASClass))
	{
		return false;
	}

	const int32 InitialMemberCount = CountSchemaMembers(InitialASClass->ReferenceSchema.Get());
	if (!TestTrue(TEXT("Reference-schema soft-reload scenario should start with a non-empty GC schema"), InitialMemberCount > 0))
	{
		return false;
	}

	UFunction* StoreFunction = RequireGeneratedFunction(
		*this,
		InitialClass,
		TEXT("Store"),
		TEXT("Reference-schema soft-reload scenario"));
	UFunction* GetStoredFunction = RequireGeneratedFunction(
		*this,
		InitialClass,
		TEXT("GetStored"),
		TEXT("Reference-schema soft-reload scenario"));
	UFunction* GetVersionFunction = RequireGeneratedFunction(
		*this,
		InitialClass,
		TEXT("GetVersion"),
		TEXT("Reference-schema soft-reload scenario"));
	if (StoreFunction == nullptr || GetStoredFunction == nullptr || GetVersionFunction == nullptr)
	{
		return false;
	}

	FGetVersionParams GetVersionBeforeReload;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should execute GetVersion before reload"),
			InvokeGeneratedFunction(Engine, InitialASClass->GetDefaultObject(), GetVersionFunction, &GetVersionBeforeReload)))
	{
		return false;
	}
	TestEqual(TEXT("Reference-schema soft-reload scenario should start at version 1"), GetVersionBeforeReload.ReturnValue, 1);

	ECompileResult FirstReloadResult = ECompileResult::Error;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should compile the first body-only update on the soft reload path"),
			CompileModuleWithResult(
				&Engine,
				ECompileType::SoftReloadOnly,
				ReferenceSchemaSoftReloadModuleName,
				ReferenceSchemaSoftReloadFilename,
				ScriptV2,
				FirstReloadResult)))
	{
		return false;
	}
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should keep the first reload on a handled soft reload path"),
			FirstReloadResult == ECompileResult::FullyHandled || FirstReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UASClass* FirstReloadClass = Cast<UASClass>(FindGeneratedClass(&Engine, ReferenceSchemaSoftReloadClassName));
	UFunction* GetVersionAfterFirstReload = FirstReloadClass != nullptr ? FindGeneratedFunction(FirstReloadClass, TEXT("GetVersion")) : nullptr;
	if (!TestNotNull(TEXT("Reference-schema soft-reload scenario should still expose the holder class after the first reload"), FirstReloadClass)
		|| !TestNotNull(TEXT("Reference-schema soft-reload scenario should still expose GetVersion after the first reload"), GetVersionAfterFirstReload))
	{
		return false;
	}

	TestTrue(TEXT("Reference-schema soft-reload scenario should preserve the UASClass instance after the first reload"), FirstReloadClass == InitialASClass);
	TestEqual(
		TEXT("Reference-schema soft-reload scenario should keep the schema member count stable after the first reload"),
		CountSchemaMembers(FirstReloadClass->ReferenceSchema.Get()),
		InitialMemberCount);

	FGetVersionParams GetVersionAfterReloadOne;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should execute GetVersion after the first reload"),
			InvokeGeneratedFunction(Engine, FirstReloadClass->GetDefaultObject(), GetVersionAfterFirstReload, &GetVersionAfterReloadOne)))
	{
		return false;
	}
	TestEqual(TEXT("Reference-schema soft-reload scenario should advance to version 2 after the first reload"), GetVersionAfterReloadOne.ReturnValue, 2);

	ECompileResult SecondReloadResult = ECompileResult::Error;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should compile the second body-only update on the soft reload path"),
			CompileModuleWithResult(
				&Engine,
				ECompileType::SoftReloadOnly,
				ReferenceSchemaSoftReloadModuleName,
				ReferenceSchemaSoftReloadFilename,
				ScriptV3,
				SecondReloadResult)))
	{
		return false;
	}
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should keep the second reload on a handled soft reload path"),
			SecondReloadResult == ECompileResult::FullyHandled || SecondReloadResult == ECompileResult::PartiallyHandled))
	{
		return false;
	}

	UASClass* SecondReloadClass = Cast<UASClass>(FindGeneratedClass(&Engine, ReferenceSchemaSoftReloadClassName));
	UFunction* GetVersionAfterSecondReload = SecondReloadClass != nullptr ? FindGeneratedFunction(SecondReloadClass, TEXT("GetVersion")) : nullptr;
	if (!TestNotNull(TEXT("Reference-schema soft-reload scenario should still expose the holder class after the second reload"), SecondReloadClass)
		|| !TestNotNull(TEXT("Reference-schema soft-reload scenario should still expose GetVersion after the second reload"), GetVersionAfterSecondReload))
	{
		return false;
	}

	TestTrue(TEXT("Reference-schema soft-reload scenario should preserve the UASClass instance after the second reload"), SecondReloadClass == InitialASClass);
	TestEqual(
		TEXT("Reference-schema soft-reload scenario should keep the schema member count stable after the second reload"),
		CountSchemaMembers(SecondReloadClass->ReferenceSchema.Get()),
		InitialMemberCount);

	FGetVersionParams GetVersionAfterReloadTwo;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should execute GetVersion after the second reload"),
			InvokeGeneratedFunction(Engine, SecondReloadClass->GetDefaultObject(), GetVersionAfterSecondReload, &GetVersionAfterReloadTwo)))
	{
		return false;
	}
	TestEqual(TEXT("Reference-schema soft-reload scenario should advance to version 3 after the second reload"), GetVersionAfterReloadTwo.ReturnValue, 3);

	UObject* Holder = NewObject<UObject>(GetTransientPackage(), SecondReloadClass, TEXT("ReferenceSchemaSoftReloadHolder"));
	if (!TestNotNull(TEXT("Reference-schema soft-reload scenario should instantiate the reloaded holder"), Holder))
	{
		return false;
	}

	Holder->AddToRoot();
	ON_SCOPE_EXIT
	{
		if (Holder != nullptr)
		{
			Holder->RemoveFromRoot();
			Holder->MarkAsGarbage();
		}

		CollectGarbage(RF_NoFlags, true);
	};

	UAngelscriptNativeScriptTestObject* StrongTarget =
		NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage(), TEXT("ReferenceSchemaSoftReloadTarget"));
	if (!TestNotNull(TEXT("Reference-schema soft-reload scenario should create a transient target UObject"), StrongTarget))
	{
		return false;
	}

	TWeakObjectPtr<UAngelscriptNativeScriptTestObject> WeakTarget = StrongTarget;

	FStoreParams StoreParams;
	StoreParams.InValue = StrongTarget;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should store the transient target after repeated reloads"),
			InvokeGeneratedFunction(Engine, Holder, StoreFunction, &StoreParams)))
	{
		return false;
	}

	StrongTarget = nullptr;
	CollectGarbage(RF_NoFlags, true);
	TestTrue(TEXT("Reference-schema soft-reload scenario should keep the transient target alive after repeated reloads"), WeakTarget.IsValid());

	FGetStoredParams GetStoredAfterGC;
	if (!TestTrue(
			TEXT("Reference-schema soft-reload scenario should still expose the stored object after repeated reloads and GC"),
			InvokeGeneratedFunction(Engine, Holder, GetStoredFunction, &GetStoredAfterGC)))
	{
		return false;
	}

	TestTrue(
		TEXT("Reference-schema soft-reload scenario should preserve the same stored object identity after repeated reloads"),
		GetStoredAfterGC.ReturnValue == WeakTarget.Get());

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
