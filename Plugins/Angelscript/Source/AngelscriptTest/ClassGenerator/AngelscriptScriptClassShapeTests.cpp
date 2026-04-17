#include "Shared/AngelscriptScenarioTestUtils.h"

#include "ClassGenerator/ASClass.h"
#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ScriptClassShapeTest
{
	FAngelscriptEngine& AcquireFreshScriptClassShapeEngine()
	{
		DestroySharedAndStrayGlobalTestEngine();
		return AcquireCleanSharedCloneEngine();
	}

	int32 CountDeclaredProperties(const UClass& ScriptClass)
	{
		int32 PropertyCount = 0;
		for (TFieldIterator<FProperty> It(&ScriptClass, EFieldIteratorFlags::ExcludeSuper); It; ++It)
		{
			++PropertyCount;
		}

		return PropertyCount;
	}
}

using namespace ScriptClassShapeTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptInheritancePreservesParentPropertyAndOverrideTest,
	"Angelscript.TestModule.ScriptClass.ScriptInheritancePreservesParentPropertyAndOverride",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioScriptInheritancePreservesParentPropertyAndOverrideTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassShapeTest::AcquireFreshScriptClassShapeEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassScriptInheritance"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	static const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AScenarioScriptInheritanceParent : AActor
{
	UPROPERTY()
	int ParentValue = 21;

	UFUNCTION(BlueprintEvent)
	int GetValue()
	{
		return ParentValue;
	}
}

UCLASS()
class AScenarioScriptInheritanceChild : AScenarioScriptInheritanceParent
{
	UFUNCTION(BlueprintOverride)
	int GetValue()
	{
		return ParentValue * 10 + 7;
	}
}
)AS");

	UClass* ParentClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassScriptInheritance.as"),
		ScriptSource,
		TEXT("AScenarioScriptInheritanceParent"));
	if (ParentClass == nullptr)
	{
		return false;
	}

	UClass* ChildClass = FindGeneratedClass(&Engine, TEXT("AScenarioScriptInheritanceChild"));
	if (!TestNotNull(TEXT("Script-inheritance scenario should generate the child class"), ChildClass))
	{
		return false;
	}

	UASClass* ParentASClass = Cast<UASClass>(ParentClass);
	UASClass* ChildASClass = Cast<UASClass>(ChildClass);
	if (!TestNotNull(TEXT("Script-inheritance scenario should compile the parent as a UASClass"), ParentASClass)
		|| !TestNotNull(TEXT("Script-inheritance scenario should compile the child as a UASClass"), ChildASClass))
	{
		return false;
	}

	TestTrue(TEXT("Script-inheritance scenario should keep the child class actor-derived"), ChildClass->IsChildOf(AActor::StaticClass()));
	TestTrue(TEXT("Script-inheritance scenario should make the child class inherit from the parent class"), ChildClass->IsChildOf(ParentClass));
	TestEqual(TEXT("Script-inheritance scenario should keep the generated child superclass exact"), ChildClass->GetSuperClass(), ParentClass);
	TestEqual(TEXT("Script-inheritance parent should already be its own most-up-to-date class"), ParentASClass->GetMostUpToDateClass(), ParentClass);
	TestEqual(TEXT("Script-inheritance child should already be its own most-up-to-date class"), ChildASClass->GetMostUpToDateClass(), ChildClass);

	UObject* ChildDefaultObject = ChildClass->GetDefaultObject();
	if (!TestNotNull(TEXT("Script-inheritance scenario should provide a child CDO"), ChildDefaultObject))
	{
		return false;
	}

	int32 ChildDefaultParentValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ChildDefaultObject, TEXT("ParentValue"), ChildDefaultParentValue))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* ParentActor = SpawnScriptActor(*this, Spawner, ParentClass);
	AActor* ChildActor = SpawnScriptActor(*this, Spawner, ChildClass);
	if (!TestNotNull(TEXT("Script-inheritance scenario should spawn the parent actor"), ParentActor)
		|| !TestNotNull(TEXT("Script-inheritance scenario should spawn the child actor"), ChildActor))
	{
		return false;
	}

	int32 ChildInstanceParentValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, ChildActor, TEXT("ParentValue"), ChildInstanceParentValue))
	{
		return false;
	}

	UFunction* ParentGetValueFunction = FindGeneratedFunction(ParentClass, TEXT("GetValue"));
	UFunction* ChildGetValueFunction = FindGeneratedFunction(ChildClass, TEXT("GetValue"));
	if (!TestNotNull(TEXT("Script-inheritance scenario should generate the parent GetValue function"), ParentGetValueFunction)
		|| !TestNotNull(TEXT("Script-inheritance scenario should generate the child GetValue function"), ChildGetValueFunction))
	{
		return false;
	}

	int32 ParentResult = 0;
	int32 ChildResult = 0;
	if (!TestTrue(TEXT("Script-inheritance scenario should execute the parent GetValue function"), ExecuteGeneratedIntEventOnGameThread(&Engine, ParentActor, ParentGetValueFunction, ParentResult))
		|| !TestTrue(TEXT("Script-inheritance scenario should execute the child GetValue function"), ExecuteGeneratedIntEventOnGameThread(&Engine, ChildActor, ChildGetValueFunction, ChildResult)))
	{
		return false;
	}

	TestEqual(TEXT("Script-inheritance scenario should flow the parent default value into the child CDO"), ChildDefaultParentValue, 21);
	TestEqual(TEXT("Script-inheritance scenario should expose the inherited parent property on child instances"), ChildInstanceParentValue, 21);
	TestEqual(TEXT("Script-inheritance scenario should preserve the parent function result on the parent actor"), ParentResult, 21);
	TestEqual(TEXT("Script-inheritance scenario should dispatch the child override instead of the parent implementation"), ChildResult, 217);
	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioEmptyActorCompilesAndSpawnsTest,
	"Angelscript.TestModule.ScriptClass.EmptyActorCompilesAndSpawns",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioEmptyActorCompilesAndSpawnsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassShapeTest::AcquireFreshScriptClassShapeEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassEmptyActor"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	static const FString ScriptSource = TEXT(R"AS(
UCLASS()
class AEmptyScriptActor : AActor
{
}
)AS");

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassEmptyActor.as"),
		ScriptSource,
		TEXT("AEmptyScriptActor"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UASClass* ASClass = Cast<UASClass>(ScriptClass);
	if (!TestNotNull(TEXT("Empty script actor scenario should generate a UASClass"), ASClass))
	{
		return false;
	}

	TestTrue(TEXT("Empty script actor scenario should stay actor-derived"), ScriptClass->IsChildOf(AActor::StaticClass()));
	TestEqual(TEXT("Empty script actor scenario should use AActor as the exact generated superclass"), ScriptClass->GetSuperClass(), AActor::StaticClass());
	TestEqual(TEXT("Empty script actor scenario should not synthesize any declared user properties"), ScriptClassShapeTest::CountDeclaredProperties(*ScriptClass), 0);

	UObject* ClassDefaultObject = ScriptClass->GetDefaultObject();
	if (!TestNotNull(TEXT("Empty script actor scenario should provide a class default object"), ClassDefaultObject))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Empty script actor scenario should spawn the generated actor class"), Actor))
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);
	TestTrue(TEXT("Empty script actor scenario should enter BeginPlay even without user properties or functions"), Actor->HasActorBegunPlay());
	TestTrue(TEXT("Empty script actor scenario should allow the spawned actor to enter the destroy flow"), Actor->Destroy());
	TestTrue(TEXT("Empty script actor scenario should mark the actor as being destroyed after Destroy()"), Actor->IsActorBeingDestroyed());
	return true;
}

#endif
