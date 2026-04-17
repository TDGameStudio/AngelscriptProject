#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASClass.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_ClassGenerator_AngelscriptASClassComponentMetadataTests_Private
{
	static const FName ASClassComponentMetadataModuleName(TEXT("ASClassComponentMetadata"));
	static const FString ASClassComponentMetadataFilename(TEXT("ASClassComponentMetadata.as"));
	static const FName ASClassComponentMetadataDerivedClassName(TEXT("AMetadataDerivedActor"));
	static const FName ASClassComponentMetadataBaseClassName(TEXT("AMetadataBaseActor"));
	static const FName ASClassRootComponentName(TEXT("RootScene"));
	static const FName ASClassBillboardComponentName(TEXT("Billboard"));
	static const FName ASClassOverrideVariableName(TEXT("ReplacementBillboard"));

	static const FName ASClassComponentMetadataSoftReloadModuleName(TEXT("ASClassComponentMetadataSoftReload"));
	static const FString ASClassComponentMetadataSoftReloadFilename(TEXT("ASClassComponentMetadataSoftReload.as"));
	static const FName ASClassComponentMetadataSoftReloadDerivedClassName(TEXT("ASoftMetadataDerivedActor"));
	static const FName ASClassComponentMetadataSoftReloadBaseClassName(TEXT("ASoftMetadataBaseActor"));
	static const FName ASClassSoftReloadRootComponentClassName(TEXT("USoftMetadataRootComponent"));
	static const FName ASClassSoftReloadReplacementComponentClassName(TEXT("USoftMetadataReplacementBillboardComponent"));

	bool IsHandledReloadResult(const ECompileResult ReloadResult)
	{
		return ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled;
	}

	struct FDefaultComponentMetadataSnapshot
	{
		FName ComponentClassName = NAME_None;
		FName ComponentName = NAME_None;
		FName Attach = NAME_None;
		FName AttachSocket = NAME_None;
		bool bIsRoot = false;
		bool bEditorOnly = false;

		bool operator==(const FDefaultComponentMetadataSnapshot& Other) const
		{
			return ComponentClassName == Other.ComponentClassName
				&& ComponentName == Other.ComponentName
				&& Attach == Other.Attach
				&& AttachSocket == Other.AttachSocket
				&& bIsRoot == Other.bIsRoot
				&& bEditorOnly == Other.bEditorOnly;
		}
	};

	struct FOverrideComponentMetadataSnapshot
	{
		FName ComponentClassName = NAME_None;
		FName OverrideComponentName = NAME_None;
		FName VariableName = NAME_None;

		bool operator==(const FOverrideComponentMetadataSnapshot& Other) const
		{
			return ComponentClassName == Other.ComponentClassName
				&& OverrideComponentName == Other.OverrideComponentName
				&& VariableName == Other.VariableName;
		}
	};

	const UASClass::FDefaultComponent* FindDefaultComponentEntryByName(const UASClass* ScriptClass, FName ComponentName)
	{
		if (ScriptClass == nullptr)
		{
			return nullptr;
		}

		return ScriptClass->DefaultComponents.FindByPredicate([ComponentName](const UASClass::FDefaultComponent& Entry)
		{
			return Entry.ComponentName == ComponentName;
		});
	}

	const UASClass::FOverrideComponent* FindOverrideComponentEntryByVariableName(const UASClass* ScriptClass, FName VariableName)
	{
		if (ScriptClass == nullptr)
		{
			return nullptr;
		}

		return ScriptClass->OverrideComponents.FindByPredicate([VariableName](const UASClass::FOverrideComponent& Entry)
		{
			return Entry.VariableName == VariableName;
		});
	}

	TArray<FDefaultComponentMetadataSnapshot> SnapshotDefaultComponentLayoutMetadata(const UASClass* ScriptClass)
	{
		TArray<FDefaultComponentMetadataSnapshot> Snapshot;
		if (ScriptClass == nullptr)
		{
			return Snapshot;
		}

		Snapshot.Reserve(ScriptClass->DefaultComponents.Num());
		for (const UASClass::FDefaultComponent& Entry : ScriptClass->DefaultComponents)
		{
			Snapshot.Add({
				Entry.ComponentClass != nullptr ? Entry.ComponentClass->GetFName() : NAME_None,
				Entry.ComponentName,
				Entry.Attach,
				Entry.AttachSocket,
				Entry.bIsRoot,
				Entry.bEditorOnly
			});
		}

		return Snapshot;
	}

	TArray<FOverrideComponentMetadataSnapshot> SnapshotOverrideComponentLayoutMetadata(const UASClass* ScriptClass)
	{
		TArray<FOverrideComponentMetadataSnapshot> Snapshot;
		if (ScriptClass == nullptr)
		{
			return Snapshot;
		}

		Snapshot.Reserve(ScriptClass->OverrideComponents.Num());
		for (const UASClass::FOverrideComponent& Entry : ScriptClass->OverrideComponents)
		{
			Snapshot.Add({
				Entry.ComponentClass != nullptr ? Entry.ComponentClass->GetFName() : NAME_None,
				Entry.OverrideComponentName,
				Entry.VariableName
			});
		}

		return Snapshot;
	}

	USceneComponent* FindSceneComponentByName(const AActor* Actor, FName ComponentName)
	{
		if (Actor == nullptr)
		{
			return nullptr;
		}

		for (UActorComponent* Component : Actor->GetComponents())
		{
			if (Component != nullptr && Component->GetFName() == ComponentName)
			{
				return Cast<USceneComponent>(Component);
			}
		}

		return nullptr;
	}
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptASClassComponentMetadataTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassDefaultComponentMetadataCapturesRootAndAttachLayoutTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.DefaultComponentMetadataCapturesRootAndAttachLayout",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassDefaultComponentMetadataCapturesRootAndAttachLayoutTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassComponentMetadataModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class UMetadataRootComponent : USceneComponent
{
}

UCLASS()
class UMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class UMetadataReplacementBillboardComponent : UMetadataBillboardComponent
{
}

UCLASS()
class AMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UMetadataBillboardComponent Billboard;
}

UCLASS()
class AMetadataDerivedActor : AMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	UMetadataReplacementBillboardComponent ReplacementBillboard;
}
)AS");

	UClass* DerivedActorClass = CompileScriptModule(
		*this,
		Engine,
		ASClassComponentMetadataModuleName,
		ASClassComponentMetadataFilename,
		ScriptSource,
		ASClassComponentMetadataDerivedClassName);
	if (DerivedActorClass == nullptr)
	{
		return false;
	}

	UASClass* BaseActorClass = Cast<UASClass>(FindGeneratedClass(&Engine, ASClassComponentMetadataBaseClassName));
	UASClass* DerivedASClass = Cast<UASClass>(DerivedActorClass);
	UClass* RootComponentClass = FindGeneratedClass(&Engine, TEXT("UMetadataRootComponent"));
	UClass* BillboardComponentClass = FindGeneratedClass(&Engine, TEXT("UMetadataBillboardComponent"));
	UClass* ReplacementBillboardComponentClass = FindGeneratedClass(&Engine, TEXT("UMetadataReplacementBillboardComponent"));
	if (!TestNotNull(TEXT("ASClass component metadata test should resolve the generated base actor class"), BaseActorClass)
		|| !TestNotNull(TEXT("ASClass component metadata test should compile the derived actor to a UASClass"), DerivedASClass)
		|| !TestNotNull(TEXT("ASClass component metadata test should resolve the generated root component class"), RootComponentClass)
		|| !TestNotNull(TEXT("ASClass component metadata test should resolve the generated billboard component class"), BillboardComponentClass)
		|| !TestNotNull(TEXT("ASClass component metadata test should resolve the generated replacement component class"), ReplacementBillboardComponentClass))
	{
		return false;
	}

	const UASClass::FDefaultComponent* RootEntry = FindDefaultComponentEntryByName(BaseActorClass, ASClassRootComponentName);
	const UASClass::FDefaultComponent* BillboardEntry = FindDefaultComponentEntryByName(BaseActorClass, ASClassBillboardComponentName);
	const UASClass::FOverrideComponent* OverrideEntry = FindOverrideComponentEntryByVariableName(DerivedASClass, ASClassOverrideVariableName);

	TestEqual(TEXT("ASClass component metadata test should record exactly two default components on the base class"), BaseActorClass->DefaultComponents.Num(), 2);
	TestEqual(TEXT("ASClass component metadata test should record exactly one override component on the derived class"), DerivedASClass->OverrideComponents.Num(), 1);

	if (!TestNotNull(TEXT("ASClass component metadata test should record a root-scene default component entry"), RootEntry)
		|| !TestNotNull(TEXT("ASClass component metadata test should record a billboard default component entry"), BillboardEntry)
		|| !TestNotNull(TEXT("ASClass component metadata test should record the derived override entry"), OverrideEntry))
	{
		return false;
	}

	TestTrue(TEXT("ASClass component metadata test should mark RootScene as the root component"), RootEntry->bIsRoot);
	TestTrue(TEXT("ASClass component metadata test should keep RootScene unattached"), RootEntry->Attach.IsNone());
	TestTrue(TEXT("ASClass component metadata test should preserve the generated root component class"), RootEntry->ComponentClass == RootComponentClass);

	TestFalse(TEXT("ASClass component metadata test should keep Billboard out of the root slot"), BillboardEntry->bIsRoot);
	TestEqual(TEXT("ASClass component metadata test should attach Billboard to RootScene"), BillboardEntry->Attach, ASClassRootComponentName);
	TestTrue(TEXT("ASClass component metadata test should preserve the generated billboard component class"), BillboardEntry->ComponentClass == BillboardComponentClass);

	TestEqual(TEXT("ASClass component metadata test should record which base component gets overridden"), OverrideEntry->OverrideComponentName, ASClassBillboardComponentName);
	TestEqual(TEXT("ASClass component metadata test should record the overriding property name"), OverrideEntry->VariableName, ASClassOverrideVariableName);
	TestTrue(TEXT("ASClass component metadata test should preserve the generated override component class"), OverrideEntry->ComponentClass == ReplacementBillboardComponentClass);
	ASTEST_END_SHARE_FRESH

	return true;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASClassSoftReloadPreservesDefaultComponentMetadataWithoutDuplicationTest,
	"Angelscript.TestModule.ClassGenerator.ASClass.SoftReloadPreservesDefaultComponentMetadataWithoutDuplication",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASClassSoftReloadPreservesDefaultComponentMetadataWithoutDuplicationTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASClassComponentMetadataSoftReloadModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class USoftMetadataRootComponent : USceneComponent
{
}

UCLASS()
class USoftMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class USoftMetadataReplacementBillboardComponent : USoftMetadataBillboardComponent
{
}

UCLASS()
class ASoftMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USoftMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USoftMetadataBillboardComponent Billboard;
}

UCLASS()
class ASoftMetadataDerivedActor : ASoftMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	USoftMetadataReplacementBillboardComponent ReplacementBillboard;

	UFUNCTION()
	int GetVersion()
	{
		return 1;
	}
}
)AS");

	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class USoftMetadataRootComponent : USceneComponent
{
}

UCLASS()
class USoftMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class USoftMetadataReplacementBillboardComponent : USoftMetadataBillboardComponent
{
}

UCLASS()
class ASoftMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USoftMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USoftMetadataBillboardComponent Billboard;
}

UCLASS()
class ASoftMetadataDerivedActor : ASoftMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	USoftMetadataReplacementBillboardComponent ReplacementBillboard;

	UFUNCTION()
	int GetVersion()
	{
		return 2;
	}
}
)AS");

	UClass* InitialDerivedClass = CompileScriptModule(
		*this,
		Engine,
		ASClassComponentMetadataSoftReloadModuleName,
		ASClassComponentMetadataSoftReloadFilename,
		ScriptV1,
		ASClassComponentMetadataSoftReloadDerivedClassName);
	if (InitialDerivedClass == nullptr)
	{
		return false;
	}

	UASClass* InitialBaseClass = Cast<UASClass>(FindGeneratedClass(&Engine, ASClassComponentMetadataSoftReloadBaseClassName));
	UASClass* InitialDerivedASClass = Cast<UASClass>(InitialDerivedClass);
	UClass* InitialRootComponentClass = FindGeneratedClass(&Engine, ASClassSoftReloadRootComponentClassName);
	UClass* InitialReplacementComponentClass = FindGeneratedClass(&Engine, ASClassSoftReloadReplacementComponentClassName);
	if (!TestNotNull(TEXT("ASClass component metadata soft-reload scenario should resolve the generated base actor class before reload"), InitialBaseClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should compile the derived actor as a UASClass before reload"), InitialDerivedASClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should resolve the generated root component class before reload"), InitialRootComponentClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should resolve the generated replacement component class before reload"), InitialReplacementComponentClass))
	{
		return false;
	}

	const TArray<FDefaultComponentMetadataSnapshot> InitialDefaultSnapshot = SnapshotDefaultComponentLayoutMetadata(InitialBaseClass);
	const TArray<FOverrideComponentMetadataSnapshot> InitialOverrideSnapshot = SnapshotOverrideComponentLayoutMetadata(InitialDerivedASClass);

	TestEqual(TEXT("ASClass component metadata soft-reload scenario should start with two default-component metadata entries"), InitialDefaultSnapshot.Num(), 2);
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should start with one override-component metadata entry"), InitialOverrideSnapshot.Num(), 1);

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(
		TEXT("ASClass component metadata soft-reload scenario should compile the body-only update on the soft reload path"),
		CompileModuleWithResult(&Engine, ECompileType::SoftReloadOnly, ASClassComponentMetadataSoftReloadModuleName, ASClassComponentMetadataSoftReloadFilename, ScriptV2, ReloadResult)))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("ASClass component metadata soft-reload scenario should stay on a handled soft reload path"),
		IsHandledReloadResult(ReloadResult)))
	{
		return false;
	}

	UASClass* ReloadedBaseClass = Cast<UASClass>(FindGeneratedClass(&Engine, ASClassComponentMetadataSoftReloadBaseClassName));
	UASClass* ReloadedDerivedClass = Cast<UASClass>(FindGeneratedClass(&Engine, ASClassComponentMetadataSoftReloadDerivedClassName));
	UClass* ReloadedRootComponentClass = FindGeneratedClass(&Engine, ASClassSoftReloadRootComponentClassName);
	UClass* ReloadedReplacementComponentClass = FindGeneratedClass(&Engine, ASClassSoftReloadReplacementComponentClassName);
	UFunction* GetVersionAfterReload = ReloadedDerivedClass != nullptr ? FindGeneratedFunction(ReloadedDerivedClass, TEXT("GetVersion")) : nullptr;
	if (!TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still expose the generated base actor class after reload"), ReloadedBaseClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still expose the generated derived actor class after reload"), ReloadedDerivedClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still expose the generated root component class after reload"), ReloadedRootComponentClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still expose the generated replacement component class after reload"), ReloadedReplacementComponentClass)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still expose GetVersion after reload"), GetVersionAfterReload))
	{
		return false;
	}

	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve the base UASClass instance"), ReloadedBaseClass == InitialBaseClass);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve the derived UASClass instance"), ReloadedDerivedClass == InitialDerivedASClass);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve the generated root component class"), ReloadedRootComponentClass == InitialRootComponentClass);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve the generated replacement component class"), ReloadedReplacementComponentClass == InitialReplacementComponentClass);

	const TArray<FDefaultComponentMetadataSnapshot> ReloadedDefaultSnapshot = SnapshotDefaultComponentLayoutMetadata(ReloadedBaseClass);
	const TArray<FOverrideComponentMetadataSnapshot> ReloadedOverrideSnapshot = SnapshotOverrideComponentLayoutMetadata(ReloadedDerivedClass);
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should keep the default-component count stable"), ReloadedDefaultSnapshot.Num(), InitialDefaultSnapshot.Num());
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should keep the override-component count stable"), ReloadedOverrideSnapshot.Num(), InitialOverrideSnapshot.Num());
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve default-component metadata without duplication"), ReloadedDefaultSnapshot == InitialDefaultSnapshot);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should preserve override-component metadata without duplication"), ReloadedOverrideSnapshot == InitialOverrideSnapshot);

	const UASClass::FDefaultComponent* RootEntryAfterReload = FindDefaultComponentEntryByName(ReloadedBaseClass, ASClassRootComponentName);
	const UASClass::FDefaultComponent* BillboardEntryAfterReload = FindDefaultComponentEntryByName(ReloadedBaseClass, ASClassBillboardComponentName);
	const UASClass::FOverrideComponent* OverrideEntryAfterReload = FindOverrideComponentEntryByVariableName(ReloadedDerivedClass, ASClassOverrideVariableName);
	if (!TestNotNull(TEXT("ASClass component metadata soft-reload scenario should keep the root metadata entry"), RootEntryAfterReload)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should keep the billboard metadata entry"), BillboardEntryAfterReload)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should keep the override metadata entry"), OverrideEntryAfterReload))
	{
		return false;
	}

	TestTrue(TEXT("ASClass component metadata soft-reload scenario should keep RootScene as the unique root"), RootEntryAfterReload->bIsRoot);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should keep RootScene unattached"), RootEntryAfterReload->Attach.IsNone());
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should keep Billboard attached to RootScene"), BillboardEntryAfterReload->Attach, ASClassRootComponentName);
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should keep the override pointed at Billboard"), OverrideEntryAfterReload->OverrideComponentName, ASClassBillboardComponentName);
	TestEqual(TEXT("ASClass component metadata soft-reload scenario should keep the override property name stable"), OverrideEntryAfterReload->VariableName, ASClassOverrideVariableName);

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();
	AActor* ReloadedActor = SpawnScriptActor(*this, Spawner, ReloadedDerivedClass);
	if (!TestNotNull(TEXT("ASClass component metadata soft-reload scenario should spawn the reloaded actor class"), ReloadedActor))
	{
		return false;
	}

	USceneComponent* RuntimeRootComponent = ReloadedActor->GetRootComponent();
	USceneComponent* RuntimeBillboardComponent = FindSceneComponentByName(ReloadedActor, ASClassBillboardComponentName);
	if (!TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still create a runtime root component"), RuntimeRootComponent)
		|| !TestNotNull(TEXT("ASClass component metadata soft-reload scenario should still create the overridden Billboard component"), RuntimeBillboardComponent))
	{
		return false;
	}

	TestTrue(TEXT("ASClass component metadata soft-reload scenario should keep the runtime root component class aligned with metadata"), RuntimeRootComponent->GetClass() == ReloadedRootComponentClass);
	TestTrue(TEXT("ASClass component metadata soft-reload scenario should keep the Billboard slot attached to the root"), RuntimeBillboardComponent->GetAttachParent() == RuntimeRootComponent);

	int32 VersionAfterReload = 0;
	if (!TestTrue(
		TEXT("ASClass component metadata soft-reload scenario should execute the reloaded generated function"),
		ExecuteGeneratedIntEventOnGameThread(&Engine, ReloadedActor, GetVersionAfterReload, VersionAfterReload)))
	{
		return false;
	}

	TestEqual(TEXT("ASClass component metadata soft-reload scenario should observe the updated function body after reload"), VersionAfterReload, 2);
	ASTEST_END_SHARE_FRESH

	return true;
}

#endif
