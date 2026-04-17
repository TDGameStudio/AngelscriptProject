#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Engine/Blueprint.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/PackageName.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/Package.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace ScriptClassCreationTest
{
	FAngelscriptEngine& AcquireFreshScriptClassEngine()
	{
		DestroySharedAndStrayGlobalTestEngine();
		return AcquireCleanSharedCloneEngine();
	}

	UBlueprint* CreateTransientBlueprintChild(
		FAutomationTestBase& Test,
		UClass* ParentClass,
		FStringView Suffix,
		const TCHAR* CallingContext = TEXT("AngelscriptScriptClassCreationTests"))
	{
		if (!Test.TestNotNull(TEXT("Blueprint parent class should be valid"), ParentClass))
		{
			return nullptr;
		}

		const FString PackagePath = FString::Printf(
			TEXT("/Temp/AngelscriptScriptClass_%.*s_%s"),
			Suffix.Len(),
			Suffix.GetData(),
			*FGuid::NewGuid().ToString(EGuidFormats::Digits));
		UPackage* BlueprintPackage = CreatePackage(*PackagePath);
		if (!Test.TestNotNull(TEXT("Transient blueprint package should be created"), BlueprintPackage))
		{
			return nullptr;
		}

		BlueprintPackage->SetFlags(RF_Transient);
		const FName BlueprintName(*FPackageName::GetLongPackageAssetName(PackagePath));

		UBlueprint* Blueprint = FKismetEditorUtilities::CreateBlueprint(
			ParentClass,
			BlueprintPackage,
			BlueprintName,
			BPTYPE_Normal,
			UBlueprint::StaticClass(),
			UBlueprintGeneratedClass::StaticClass(),
			CallingContext);
		if (!Test.TestNotNull(TEXT("Transient blueprint asset should be created"), Blueprint))
		{
			return nullptr;
		}

		return Blueprint;
	}

	bool CompileAndValidateBlueprint(FAutomationTestBase& Test, UBlueprint& Blueprint)
	{
		FKismetEditorUtilities::CompileBlueprint(&Blueprint);
		return Test.TestNotNull(TEXT("Blueprint should compile to a generated class"), Blueprint.GeneratedClass.Get());
	}

	void CleanupBlueprint(UBlueprint*& Blueprint)
	{
		if (Blueprint == nullptr)
		{
			return;
		}

		if (UClass* BlueprintClass = Blueprint->GeneratedClass)
		{
			BlueprintClass->MarkAsGarbage();
		}

		if (UPackage* BlueprintPackage = Blueprint->GetOutermost())
		{
			BlueprintPackage->MarkAsGarbage();
		}

		Blueprint->MarkAsGarbage();
		CollectGarbage(RF_NoFlags, true);
		Blueprint = nullptr;
	}

	struct FScopedTransientBlueprint
	{
		UBlueprint* BlueprintAsset = nullptr;

		~FScopedTransientBlueprint()
		{
			CleanupBlueprint(BlueprintAsset);
		}

		UClass* GetGeneratedClass() const
		{
			return BlueprintAsset != nullptr ? BlueprintAsset->GeneratedClass.Get() : nullptr;
		}
	};
}

using namespace ScriptClassCreationTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassCompilesToUClassTest,
	"Angelscript.TestModule.ScriptClass.CompilesToUClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassCanSpawnInTestWorldTest,
	"Angelscript.TestModule.ScriptClass.CanSpawnInTestWorld",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassMultiSpawnKeepsStateIsolationTest,
	"Angelscript.TestModule.ScriptClass.MultiSpawnKeepsStateIsolation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassBlueprintChildCompilesTest,
	"Angelscript.TestModule.ScriptClass.BlueprintChildCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassCDOHasExpectedDefaultsTest,
	"Angelscript.TestModule.ScriptClass.CDOHasExpectedDefaults",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassRecompileDoesNotCrashClassSwitchTest,
	"Angelscript.TestModule.ScriptClass.RecompileDoesNotCrashClassSwitch",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassNonUClassTypeCannotSpawnTest,
	"Angelscript.TestModule.ScriptClass.NonUClassTypeCannotSpawn",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioScriptClassRenameReplacesOldClassTest,
	"Angelscript.TestModule.ScriptClass.RenameReplacesOldClass",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioScriptClassCompilesToUClassTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassCompilesToUClass"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassCompilesToUClass.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassCompilesToUClass : AActor
{
	UPROPERTY()
	int SpawnMarker = 7;
}
)AS"),
		TEXT("AScenarioScriptClassCompilesToUClass"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	TestTrue(TEXT("Script-class compile scenario should produce an actor-derived generated UClass"), ScriptClass->IsChildOf(AActor::StaticClass()));

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (Actor == nullptr)
	{
		return false;
	}

	int32 SpawnMarker = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("SpawnMarker"), SpawnMarker))
	{
		return false;
	}

	TestEqual(TEXT("Script-class compile scenario should instantiate an actor with script property defaults"), SpawnMarker, 7);
	return true;
}

bool FAngelscriptScenarioScriptClassCanSpawnInTestWorldTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassCanSpawnInTestWorld"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassCanSpawnInTestWorld.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassCanSpawnInTestWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}
}
)AS"),
		TEXT("AScenarioScriptClassCanSpawnInTestWorld"));
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

	BeginPlayActor(Engine, *Actor);

	int32 BeginPlayObserved = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayObserved"), BeginPlayObserved))
	{
		return false;
	}

	TestEqual(TEXT("Script-class spawn scenario should observe BeginPlay after entering the test world"), BeginPlayObserved, 1);
	return true;
}

bool FAngelscriptScenarioScriptClassMultiSpawnKeepsStateIsolationTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassMultiSpawnKeepsStateIsolation"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassMultiSpawnKeepsStateIsolation.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassMultiSpawnKeepsStateIsolation : AActor
{
	UPROPERTY()
	int LocalState = 3;
}
)AS"),
		TEXT("AScenarioScriptClassMultiSpawnKeepsStateIsolation"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* FirstActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	AActor* SecondActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("State-isolation scenario should spawn first actor"), FirstActor)
		|| !TestNotNull(TEXT("State-isolation scenario should spawn second actor"), SecondActor))
	{
		return false;
	}

	FIntProperty* LocalStateProperty = FindFProperty<FIntProperty>(ScriptClass, TEXT("LocalState"));
	if (!TestNotNull(TEXT("State-isolation scenario should expose LocalState property"), LocalStateProperty))
	{
		return false;
	}

	LocalStateProperty->SetPropertyValue_InContainer(FirstActor, 11);

	int32 FirstValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, FirstActor, TEXT("LocalState"), FirstValue))
	{
		return false;
	}

	int32 SecondValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SecondActor, TEXT("LocalState"), SecondValue))
	{
		return false;
	}

	TestTrue(TEXT("State-isolation scenario should spawn distinct actor instances"), FirstActor != SecondActor);
	TestEqual(TEXT("State-isolation scenario should keep the mutated value on the first actor"), FirstValue, 11);
	TestEqual(TEXT("State-isolation scenario should keep the second actor at its own default state"), SecondValue, 3);
	return true;
}

bool FAngelscriptScenarioScriptClassBlueprintChildCompilesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassBlueprintChildCompiles"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassBlueprintChildCompiles.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassBlueprintChildCompiles : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}
}
)AS"),
		TEXT("AScenarioScriptClassBlueprintChildCompiles"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	ScriptClassCreationTest::FScopedTransientBlueprint Blueprint;
	Blueprint.BlueprintAsset = ScriptClassCreationTest::CreateTransientBlueprintChild(*this, ScriptClass, TEXT("ScriptClassBlueprintChild"));
	if (Blueprint.BlueprintAsset == nullptr)
	{
		return false;
	}

	if (!ScriptClassCreationTest::CompileAndValidateBlueprint(*this, *Blueprint.BlueprintAsset))
	{
		return false;
	}

	UClass* BlueprintClass = Blueprint.GetGeneratedClass();
	if (!TestNotNull(TEXT("Blueprint-child scenario should provide a generated blueprint class"), BlueprintClass))
	{
		return false;
	}

	TestTrue(TEXT("Blueprint-child scenario should generate a blueprint class inheriting from the script parent"), BlueprintClass->IsChildOf(ScriptClass));

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* Actor = SpawnScriptActor(*this, Spawner, BlueprintClass);
	if (Actor == nullptr)
	{
		return false;
	}

	BeginPlayActor(Engine, *Actor);

	int32 BeginPlayCount = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Actor, TEXT("BeginPlayCount"), BeginPlayCount))
	{
		return false;
	}

	TestEqual(TEXT("Blueprint-child scenario should preserve the script BeginPlay override when spawned"), BeginPlayCount, 1);
	return true;
}

bool FAngelscriptScenarioScriptClassCDOHasExpectedDefaultsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassCDOHasExpectedDefaults"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassCDOHasExpectedDefaults.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassCDOHasExpectedDefaults : AActor
{
	UPROPERTY()
	int DefaultCounter = 21;

	UPROPERTY()
	bool bDefaultFlag = true;

	UPROPERTY()
	FString DefaultLabel = "CDOStable";
}
)AS"),
		TEXT("AScenarioScriptClassCDOHasExpectedDefaults"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	UObject* DefaultObject = ScriptClass->GetDefaultObject();
	if (!TestNotNull(TEXT("CDO-defaults scenario should provide a generated class default object"), DefaultObject))
	{
		return false;
	}

	int32 DefaultCounter = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, DefaultObject, TEXT("DefaultCounter"), DefaultCounter))
	{
		return false;
	}

	bool bDefaultFlag = false;
	if (!ReadPropertyValue<FBoolProperty>(*this, DefaultObject, TEXT("bDefaultFlag"), bDefaultFlag))
	{
		return false;
	}

	FString DefaultLabel;
	if (!ReadPropertyValue<FStrProperty>(*this, DefaultObject, TEXT("DefaultLabel"), DefaultLabel))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* SpawnedActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (SpawnedActor == nullptr)
	{
		return false;
	}

	int32 SpawnedDefaultCounter = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, SpawnedActor, TEXT("DefaultCounter"), SpawnedDefaultCounter))
	{
		return false;
	}

	FString SpawnedDefaultLabel;
	if (!ReadPropertyValue<FStrProperty>(*this, SpawnedActor, TEXT("DefaultLabel"), SpawnedDefaultLabel))
	{
		return false;
	}

	TestEqual(TEXT("CDO-defaults scenario should preserve integer defaults on the class default object"), DefaultCounter, 21);
	TestTrue(TEXT("CDO-defaults scenario should preserve boolean defaults on the class default object"), bDefaultFlag);
	TestEqual(TEXT("CDO-defaults scenario should preserve string defaults on the class default object"), DefaultLabel, FString(TEXT("CDOStable")));
	TestEqual(TEXT("CDO-defaults scenario should apply class default integer values to spawned actor instances"), SpawnedDefaultCounter, 21);
	TestEqual(TEXT("CDO-defaults scenario should apply class default string values to spawned actor instances"), SpawnedDefaultLabel, FString(TEXT("CDOStable")));
	return true;
}

bool FAngelscriptScenarioScriptClassRecompileDoesNotCrashClassSwitchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassRecompileDoesNotCrashClassSwitch"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* InitialClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassRecompileDoesNotCrashClassSwitch.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 1;
}
)AS"),
		TEXT("AScenarioScriptClassRecompileDoesNotCrashClassSwitch"));
	if (InitialClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* FirstGenerationActor = SpawnScriptActor(*this, Spawner, InitialClass);
	if (FirstGenerationActor == nullptr)
	{
		return false;
	}

	int32 InitialGenerationValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, FirstGenerationActor, TEXT("GenerationValue"), InitialGenerationValue))
	{
		return false;
	}

	UClass* RecompiledClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassRecompileDoesNotCrashClassSwitch.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassRecompileDoesNotCrashClassSwitch : AActor
{
	UPROPERTY()
	int GenerationValue = 2;

	UPROPERTY()
	int AddedAfterRecompile = 17;
}
)AS"),
		TEXT("AScenarioScriptClassRecompileDoesNotCrashClassSwitch"));
	if (RecompiledClass == nullptr)
	{
		return false;
	}

	AActor* RecompiledActor = SpawnScriptActor(*this, Spawner, RecompiledClass);
	if (RecompiledActor == nullptr)
	{
		return false;
	}

	int32 RecompiledGenerationValue = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, RecompiledActor, TEXT("GenerationValue"), RecompiledGenerationValue))
	{
		return false;
	}

	int32 AddedAfterRecompile = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, RecompiledActor, TEXT("AddedAfterRecompile"), AddedAfterRecompile))
	{
		return false;
	}

	TestEqual(TEXT("Recompile scenario should produce the initial default before class switch"), InitialGenerationValue, 1);
	TestEqual(TEXT("Recompile scenario should expose updated defaults after recompiling the same script class"), RecompiledGenerationValue, 2);
	TestEqual(TEXT("Recompile scenario should expose newly added reflected properties after class switch"), AddedAfterRecompile, 17);
	return true;
}

bool FAngelscriptScenarioScriptClassNonUClassTypeCannotSpawnTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ScriptClassCreationTest::AcquireFreshScriptClassEngine();
	FAngelscriptEngineScope EngineScope(Engine);
	static const FName ModuleName(TEXT("ScenarioScriptClassNonUClassTypeCannotSpawn"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* NonActorClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassNonUClassTypeCannotSpawn.as"),
		TEXT(R"AS(
UCLASS()
class UScenarioScriptClassNonUClassTypeCannotSpawn : UObject
{
	UPROPERTY()
	int Value = 5;
}
)AS"),
		TEXT("UScenarioScriptClassNonUClassTypeCannotSpawn"));
	if (NonActorClass == nullptr)
	{
		return false;
	}

	TestFalse(TEXT("Non-uclass-type spawn scenario should compile a generated class that is not actor-derived"), NonActorClass->IsChildOf(AActor::StaticClass()));

	UObject* ObjectInstance = NewObject<UObject>(GetTransientPackage(), NonActorClass);
	if (!TestNotNull(TEXT("Non-uclass-type spawn scenario should still allow plain UObject creation"), ObjectInstance))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	FActorSpawnParameters SpawnParameters;
	AActor* SpawnedActor = Spawner.GetWorld().SpawnActor<AActor>(NonActorClass, FVector::ZeroVector, FRotator::ZeroRotator, SpawnParameters);
	TestNull(TEXT("Non-uclass-type spawn scenario should reject spawning non-actor generated classes into the world"), SpawnedActor);
	return true;
}

bool FAngelscriptScenarioScriptClassRenameReplacesOldClassTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioScriptClassRenameReplacesOldClass"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedInitializedTestEngine(Engine);
	};

	UClass* OldClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassRenameReplacesOldClass.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassRenameOld : AActor
{
	UPROPERTY()
	int Version = 1;
}
)AS"),
		TEXT("AScenarioScriptClassRenameOld"));
	if (OldClass == nullptr)
	{
		return false;
	}

	UClass* NewClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioScriptClassRenameReplacesOldClass.as"),
		TEXT(R"AS(
UCLASS()
class AScenarioScriptClassRenameNew : AActor
{
	UPROPERTY()
	int Version = 2;
}
)AS"),
		TEXT("AScenarioScriptClassRenameNew"));
	if (!TestNotNull(TEXT("Rename scenario should compile the renamed generated class"), NewClass))
	{
		return false;
	}

	TestTrue(TEXT("Rename scenario should expose the new generated class by its new name"), FindGeneratedClass(&Engine, TEXT("AScenarioScriptClassRenameNew")) == NewClass);
	TestTrue(TEXT("Rename scenario should keep the old generated class address distinct from the new class"), OldClass != NewClass);
	TestTrue(TEXT("Rename scenario should move the old generated class out of the active class name"), OldClass->GetName().Contains(TEXT("REPLACED")) || OldClass->GetName() != TEXT("AScenarioScriptClassRenameOld"));


	FIntProperty* VersionProperty = FindFProperty<FIntProperty>(NewClass, TEXT("Version"));
	if (!TestNotNull(TEXT("Rename scenario should expose the new reflected property on the renamed class"), VersionProperty))
	{
		return false;
	}

	bPassed = TestEqual(TEXT("Rename scenario should apply the renamed class default value after replacement"), VersionProperty->GetPropertyValue_InContainer(NewClass->GetDefaultObject()), 2);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
