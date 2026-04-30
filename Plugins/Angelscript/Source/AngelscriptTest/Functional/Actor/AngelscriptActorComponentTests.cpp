#include "CQTest.h"
#include "Functional/Actor/AngelscriptActorTestHelpers.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptFunctionalTestUtils;
using namespace AngelscriptReflectiveAccess;
using namespace AngelscriptActorTestUtils;

TEST_CLASS_WITH_FLAGS(FAngelscriptActorComponentTest,
	"Angelscript.TestModule.Actor.Component",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(CreateComponent)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		static const FName ModuleName(TEXT("TestActorCreateComponent"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ScriptClass = CompileScriptModule(*TestRunner, Engine, ModuleName,
			TEXT("TestActorCreateComponent.as"),
			TEXT(R"AS(
UCLASS()
class ATestActorCreateComponent : AActor
{
	UFUNCTION()
	int RunCreateComponentTest()
	{
		UActorComponent Created = CreateComponent(USceneComponent::StaticClass(), n"DynamicScene");
		if (Created == nullptr)
			return 10;

		UActorComponent Created2 = CreateComponent(USceneComponent::StaticClass(), n"DynamicScene2");
		if (Created2 == nullptr)
			return 20;

		TArray<USceneComponent> AllScenes;
		GetComponentsByClass(AllScenes);
		if (AllScenes.Num() < 2)
			return 30;

		return 1;
	}
}
)AS"),
			TEXT("ATestActorCreateComponent"));
		if (ScriptClass == nullptr) return;

		FAngelscriptTestWorld W(*TestRunner, Engine);
		if (!W.IsValid()) return;
		AActor* Actor = W.SpawnActorOfClass(ScriptClass);
		if (!TestRunner->TestNotNull(TEXT("Actor should spawn"), Actor)) return;
		W.BeginPlay(*Actor);

		FFunctionInvoker Invoker(*TestRunner, Actor, FName(TEXT("RunCreateComponentTest")));
		if (!Invoker.IsValid()) return;
		TestRunner->TestEqual(TEXT("CreateComponent should create and register components on the actor"),
			Invoker.CallAndReturn<int32>(INDEX_NONE), 1);
	}

	TEST_METHOD(GetComponent)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		static const FName ModuleName(TEXT("TestActorGetComponent"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ScriptClass = CompileScriptModule(*TestRunner, Engine, ModuleName,
			TEXT("TestActorGetComponent.as"),
			TEXT(R"AS(
UCLASS()
class ATestActorGetComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	int RunGetComponentTest()
	{
		UActorComponent Found = GetComponent(USceneComponent::StaticClass());
		if (Found == nullptr)
			return 10;

		UActorComponent NotFound = GetComponent(UStaticMeshComponent::StaticClass());
		if (NotFound != nullptr)
			return 20;

		UActorComponent ByName = GetComponent(USceneComponent::StaticClass(), n"RootScene");
		if (ByName == nullptr)
			return 30;

		return 1;
	}
}
)AS"),
			TEXT("ATestActorGetComponent"));
		if (ScriptClass == nullptr) return;

		FAngelscriptTestWorld W(*TestRunner, Engine);
		if (!W.IsValid()) return;
		AActor* Actor = W.SpawnActorOfClass(ScriptClass);
		if (!TestRunner->TestNotNull(TEXT("Actor should spawn"), Actor)) return;
		W.BeginPlay(*Actor);

		FFunctionInvoker Invoker(*TestRunner, Actor, FName(TEXT("RunGetComponentTest")));
		if (!Invoker.IsValid()) return;
		TestRunner->TestEqual(TEXT("GetComponent should find existing and return null for missing"),
			Invoker.CallAndReturn<int32>(INDEX_NONE), 1);
	}

	TEST_METHOD(GetOrCreateComponent)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		static const FName ModuleName(TEXT("TestActorGetOrCreateComponent"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ScriptClass = CompileScriptModule(*TestRunner, Engine, ModuleName,
			TEXT("TestActorGetOrCreateComponent.as"),
			TEXT(R"AS(
UCLASS()
class ATestActorGetOrCreateComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	int RunGetOrCreateComponentTest()
	{
		UActorComponent First = GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene");
		if (First == nullptr)
			return 10;

		UActorComponent Second = GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene");
		if (Second == nullptr)
			return 20;
		if (First != Second)
			return 30;

		return 1;
	}
}
)AS"),
			TEXT("ATestActorGetOrCreateComponent"));
		if (ScriptClass == nullptr) return;

		FAngelscriptTestWorld W(*TestRunner, Engine);
		if (!W.IsValid()) return;
		AActor* Actor = W.SpawnActorOfClass(ScriptClass);
		if (!TestRunner->TestNotNull(TEXT("Actor should spawn"), Actor)) return;
		W.BeginPlay(*Actor);

		FFunctionInvoker Invoker(*TestRunner, Actor, FName(TEXT("RunGetOrCreateComponentTest")));
		if (!Invoker.IsValid()) return;
		TestRunner->TestEqual(TEXT("GetOrCreateComponent should reuse existing and create on first access"),
			Invoker.CallAndReturn<int32>(INDEX_NONE), 1);
	}

	TEST_METHOD(GetAllComponents)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		static const FName ModuleName(TEXT("TestActorGetAllComponents"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ScriptClass = CompileScriptModule(*TestRunner, Engine, ModuleName,
			TEXT("TestActorGetAllComponents.as"),
			TEXT(R"AS(
UCLASS()
class UTestCompA : USceneComponent {}
UCLASS()
class UTestCompB : USceneComponent {}

UCLASS()
class ATestActorGetAllComponents : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestCompA CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB;

	UFUNCTION()
	int RunGetAllComponentsTest()
	{
		TArray<UActorComponent> AllComps;
		GetAllComponents(USceneComponent::StaticClass(), AllComps);
		if (AllComps.Num() != 2)
			return 10;

		TArray<UActorComponent> OnlyB;
		GetAllComponents(UTestCompB::StaticClass(), OnlyB);
		if (OnlyB.Num() != 1)
			return 20;

		TArray<UActorComponent> NoMatch;
		GetAllComponents(UStaticMeshComponent::StaticClass(), NoMatch);
		if (NoMatch.Num() != 0)
			return 30;

		return 1;
	}
}
)AS"),
			TEXT("ATestActorGetAllComponents"));
		if (ScriptClass == nullptr) return;

		FAngelscriptTestWorld W(*TestRunner, Engine);
		if (!W.IsValid()) return;
		AActor* Actor = W.SpawnActorOfClass(ScriptClass);
		if (!TestRunner->TestNotNull(TEXT("Actor should spawn"), Actor)) return;
		W.BeginPlay(*Actor);

		FFunctionInvoker Invoker(*TestRunner, Actor, FName(TEXT("RunGetAllComponentsTest")));
		if (!Invoker.IsValid()) return;
		TestRunner->TestEqual(TEXT("GetAllComponents should filter by class and return correct counts"),
			Invoker.CallAndReturn<int32>(INDEX_NONE), 1);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
