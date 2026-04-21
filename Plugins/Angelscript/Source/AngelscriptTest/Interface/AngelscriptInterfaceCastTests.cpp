#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptType.h"
#include "ClassGenerator/ASClass.h"

#include "Components/ActorTestSpawner.h"
#include "Containers/StringConv.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceCastTests_Private
{
	asITypeInfo* FindBoundScriptTypeInfo(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UClass* Class,
		const TCHAR* Label)
	{
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s generated class should exist"), Label),
			Class))
		{
			return nullptr;
		}

		asIScriptEngine* ScriptEngine = Engine.GetScriptEngine();
		if (!Test.TestNotNull(TEXT("Scenario script engine should exist"), ScriptEngine))
		{
			return nullptr;
		}

		asITypeInfo* TypeInfo = nullptr;
		if (const UASClass* ScriptClass = Cast<UASClass>(Class))
		{
			TypeInfo = static_cast<asITypeInfo*>(ScriptClass->ScriptTypePtr);
		}

		if (TypeInfo == nullptr)
		{
			const FString TypeName = FAngelscriptType::GetBoundClassName(Class);
			const FTCHARToUTF8 TypeNameUtf8(*TypeName);
			TypeInfo = ScriptEngine->GetTypeInfoByName(TypeNameUtf8.Get());
			Test.TestNotNull(
				*FString::Printf(TEXT("%s script type '%s' should exist"), Label, *TypeName),
				TypeInfo);
		}

		return TypeInfo;
	}
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceCastTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceCastSuccessTest,
	"Angelscript.TestModule.Interface.CastSuccess",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceCastFailTest,
	"Angelscript.TestModule.Interface.CastFail",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceMethodCallTest,
	"Angelscript.TestModule.Interface.MethodCall",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceCastFastPathGuardsAndPositivePathTest,
	"Angelscript.TestModule.Interface.CastFastPath.GuardsAndPositivePath",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-interface): CastFastPath scenario module fails to generate UUIDamageableCastFastPath type on UE 5.7

bool FAngelscriptScenarioInterfaceCastSuccessTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceCastSuccess"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceCastSuccess.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableCastOk
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceCastSuccess : AActor, UIDamageableCastOk
{
	UPROPERTY()
	int CastSucceeded = 0;

	UFUNCTION()
	void TakeDamage(float Amount) {}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIDamageableCastOk Casted = Cast<UIDamageableCastOk>(Self);
		if (Casted != nullptr)
		{
			CastSucceeded = 1;
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceCastSuccess"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*Actor);

	int32 CastSucceeded = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("CastSucceeded"), CastSucceeded))
	{
		return false;
	}

	TestEqual(TEXT("Cast to interface should succeed for implementing actor"), CastSucceeded, 1);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceCastFailTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceCastFail"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceCastFail.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableCastFail
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceCastFail : AActor
{
	UPROPERTY()
	int CastReturnedNull = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIDamageableCastFail Casted = Cast<UIDamageableCastFail>(Self);
		if (Casted == nullptr)
		{
			CastReturnedNull = 1;
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceCastFail"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*Actor);

	int32 CastReturnedNull = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("CastReturnedNull"), CastReturnedNull))
	{
		return false;
	}

	TestEqual(TEXT("Cast to interface should fail for non-implementing actor"), CastReturnedNull, 1);
	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceMethodCallTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceMethodCall"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceMethodCall.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableMethodCall
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceMethodCall : AActor, UIDamageableMethodCall
{
	UPROPERTY()
	int CastSucceeded = 0;

	UPROPERTY()
	int MethodCalled = 0;

	UFUNCTION()
	void TakeDamage(float Amount)
	{
		MethodCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UIDamageableMethodCall Casted = Cast<UIDamageableMethodCall>(Self);
		if (Casted != nullptr)
		{
			CastSucceeded = 1;
			Casted.TakeDamage(42.0);
		}
	}
}
)AS"),
		TEXT("AScenarioInterfaceMethodCall"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableMethodCall"));
	TestNotNull(TEXT("Interface class should exist"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("ScriptClass should implement UIDamageableMethodCall"), ScriptClass->ImplementsInterface(InterfaceClass));
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(*Actor);

	int32 CastSucceeded = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("CastSucceeded"), CastSucceeded))
	{
		return false;
	}
	TestEqual(TEXT("Cast to interface type should succeed"), CastSucceeded, 1);

	int32 MethodCalled = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("MethodCalled"), MethodCalled))
	{
		return false;
	}
	TestEqual(TEXT("Method should have been called via interface reference"), MethodCalled, 1);

	ASTEST_END_SHARE_FRESH

	return true;
}

bool FAngelscriptScenarioInterfaceCastFastPathGuardsAndPositivePathTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("ScenarioInterfaceCastFastPath"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ImplementingClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceCastFastPath.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableCastFastPath
{
	void TakeDamage(float Amount);
}

UCLASS()
class AScenarioInterfaceCastFastPath : AActor, UIDamageableCastFastPath
{
	UFUNCTION()
	void TakeDamage(float Amount)
	{
	}
}

UCLASS()
class AScenarioInterfaceCastPlain : AActor
{
}
)AS"),
		TEXT("AScenarioInterfaceCastFastPath"));
	if (ImplementingClass == nullptr)
	{
		return false;
	}

	UClass* PlainClass = FindGeneratedClass(&Engine, TEXT("AScenarioInterfaceCastPlain"));
	if (!TestNotNull(TEXT("Plain cast target class should exist"), PlainClass))
	{
		return false;
	}

	UClass* InterfaceClass = FindGeneratedClass(&Engine, TEXT("UIDamageableCastFastPath"));
	if (!TestNotNull(TEXT("Generated interface class should exist"), InterfaceClass))
	{
		return false;
	}

	TestTrue(
		TEXT("Implementing class should satisfy the generated interface"),
		ImplementingClass->ImplementsInterface(InterfaceClass));
	TestFalse(
		TEXT("Plain class should not satisfy the generated interface"),
		PlainClass->ImplementsInterface(InterfaceClass));

	asITypeInfo* ImplementingType = FindBoundScriptTypeInfo(*this, Engine, ImplementingClass, TEXT("Implementing actor"));
	asITypeInfo* PlainType = FindBoundScriptTypeInfo(*this, Engine, PlainClass, TEXT("Plain actor"));
	asITypeInfo* InterfaceType = FindBoundScriptTypeInfo(*this, Engine, InterfaceClass, TEXT("Interface"));
	if (ImplementingType == nullptr || PlainType == nullptr || InterfaceType == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor* ImplementingActor = SpawnScriptActor(*this, Spawner, ImplementingClass);
	AActor* PlainActor = SpawnScriptActor(*this, Spawner, PlainClass);
	if (ImplementingActor == nullptr || PlainActor == nullptr)
	{
		return false;
	}

	TestTrue(
		TEXT("Fast path should accept an implementing actor when the target is an interface"),
		FAngelscriptEngine::CanCastScriptObjectToUnrealInterface(ImplementingType, InterfaceType, ImplementingActor));
	TestFalse(
		TEXT("Fast path should reject a plain actor when the target is an interface"),
		FAngelscriptEngine::CanCastScriptObjectToUnrealInterface(PlainType, InterfaceType, PlainActor));
	TestFalse(
		TEXT("Fast path should reject non-interface target types"),
		FAngelscriptEngine::CanCastScriptObjectToUnrealInterface(ImplementingType, PlainType, ImplementingActor));
	TestFalse(
		TEXT("Fast path should reject null object pointers"),
		FAngelscriptEngine::CanCastScriptObjectToUnrealInterface(ImplementingType, InterfaceType, nullptr));

	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
