#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "../../AngelscriptRuntime/Core/AngelscriptGASActor.h"
#include "../../AngelscriptRuntime/Core/AngelscriptGASCharacter.h"
#include "../../AngelscriptRuntime/Core/AngelscriptGASPawn.h"

#include "Components/ActorTestSpawner.h"
#include "Components/InputComponent.h"
#include "GameplayTagsManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Core_AngelscriptGASActorBaseTests_Private
{
	bool GetAnyGameplayTag(FAutomationTestBase& Test, FGameplayTag& OutTag)
	{
		FGameplayTagContainer AllTags;
		UGameplayTagsManager::Get().RequestAllGameplayTags(AllTags, false);

		TArray<FGameplayTag> AvailableTags;
		AllTags.GetGameplayTagArray(AvailableTags);
		if (!Test.TestTrue(TEXT("GAS character scenario requires at least one registered gameplay tag"), AvailableTags.Num() > 0))
		{
			return false;
		}

		OutTag = AvailableTags[0];
		return true;
	}

	template <typename ActorType>
	bool ExpectReplicatedAbilitySystem(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		ActorType* Actor)
	{
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should spawn an actor instance"), Context),
				Actor))
		{
			return false;
		}

		if (!Test.TestNotNull(
				*FString::Printf(TEXT("%s should create an ability-system component"), Context),
				Actor->AbilitySystem))
		{
			return false;
		}

		bool bPassed = true;
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s constructor should mark the ability-system component replicated"), Context),
			Actor->AbilitySystem->GetIsReplicated());
		bPassed &= Test.TestTrue(
			*FString::Printf(TEXT("%s should expose the same component through GetAbilitySystemComponent"), Context),
			Actor->GetAbilitySystemComponent() == Actor->AbilitySystem);
		return bPassed;
	}
}

using namespace AngelscriptTest_Core_AngelscriptGASActorBaseTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASCharacterInputAndOwnedTagsTest,
	"Angelscript.TestModule.Engine.GAS.Character.ForwardsInputSetupAndOwnedTags",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGASActorBaseAbilitySystemAndPawnInputTest,
	"Angelscript.TestModule.Engine.GAS.ActorBase.CreatesReplicatedAbilitySystemAndPawnForwardsInput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGASCharacterInputAndOwnedTagsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	static const FName ModuleName(TEXT("ScenarioGASCharacterInputBridge"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	FGameplayTag OwnedTag;
	if (!GetAnyGameplayTag(*this, OwnedTag))
	{
		return false;
	}

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioGASCharacterInputBridge.as"),
		TEXT(R"AS(
UCLASS()
class AAutomationGASCharacter : AAngelscriptGASCharacter
{
	UPROPERTY()
	int SetupCalls = 0;

	UFUNCTION(BlueprintOverride)
	void SetupCharacterInput(UInputComponent PlayerInputComponent)
	{
		SetupCalls += 1;
	}
}
)AS"),
		TEXT("AAutomationGASCharacter"));
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASCharacter* Character = SpawnScriptActor<AAngelscriptGASCharacter>(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("GAS character bridge scenario should spawn the generated character"), Character))
	{
		return false;
	}

	if (!TestNotNull(TEXT("GAS character bridge scenario should create an ability-system component"), Character->AbilitySystem))
	{
		return false;
	}

	TestTrue(
		TEXT("AAngelscriptGASCharacter constructor should mark the ability-system component replicated"),
		Character->AbilitySystem->GetIsReplicated());
	TestTrue(
		TEXT("GetAbilitySystemComponent should return the same component stored on the character"),
		Character->GetAbilitySystemComponent() == Character->AbilitySystem);

	Character->AbilitySystem->InitAbilityActorInfo(Character, Character);
	Character->AbilitySystem->AddLooseGameplayTag(OwnedTag);

	UInputComponent* InputComponent = NewObject<UInputComponent>(Character, TEXT("AutomationInputComponent"));
	if (!TestNotNull(TEXT("GAS character bridge scenario should create an input component"), InputComponent))
	{
		return false;
	}

	Character->SetupPlayerInputComponent(InputComponent);

	int32 SetupCalls = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Character, TEXT("SetupCalls"), SetupCalls))
	{
		return false;
	}

	TestEqual(
		TEXT("SetupPlayerInputComponent should forward once into the script SetupCharacterInput override"),
		SetupCalls,
		1);

	FGameplayTagContainer OwnedTags;
	Character->GetOwnedGameplayTags(OwnedTags);

	TestTrue(
		TEXT("GetOwnedGameplayTags should forward the ability-system component's loose gameplay tags"),
		OwnedTags.HasTagExact(OwnedTag));

	ASTEST_END_SHARE_CLEAN
	return true;
}

bool FAngelscriptGASActorBaseAbilitySystemAndPawnInputTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	static const FName ModuleName(TEXT("ScenarioGASActorBaseBridge"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	{
		FAngelscriptEngineScope EngineScope(Engine);
		if (!TestTrue(
				TEXT("GAS actor-base bridge scenario should compile"),
				CompileAnnotatedModuleFromMemory(
					&Engine,
					ModuleName,
					TEXT("ScenarioGASActorBaseBridge.as"),
					TEXT(R"AS(
UCLASS()
class AAutomationGASActor : AAngelscriptGASActor
{
}

UCLASS()
class AAutomationGASPawn : AAngelscriptGASPawn
{
	UPROPERTY()
	int SetupCalls = 0;

	UFUNCTION(BlueprintOverride)
	void SetupPawnInput(UInputComponent PlayerInputComponent)
	{
		SetupCalls += 1;
	}
}
)AS"))))
		{
			return false;
		}
	}

	UClass* ActorClass = FindGeneratedClass(&Engine, TEXT("AAutomationGASActor"));
	UClass* PawnClass = FindGeneratedClass(&Engine, TEXT("AAutomationGASPawn"));
	if (!TestNotNull(TEXT("GAS actor-base bridge scenario should generate the actor class"), ActorClass)
		|| !TestNotNull(TEXT("GAS actor-base bridge scenario should generate the pawn class"), PawnClass))
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AAngelscriptGASActor* Actor = SpawnScriptActor<AAngelscriptGASActor>(*this, Spawner, ActorClass);
	AAngelscriptGASPawn* Pawn = SpawnScriptActor<AAngelscriptGASPawn>(*this, Spawner, PawnClass);
	bool bPassed = true;
	bPassed &= ExpectReplicatedAbilitySystem(*this, TEXT("GAS actor-base actor scenario"), Actor);
	bPassed &= ExpectReplicatedAbilitySystem(*this, TEXT("GAS actor-base pawn scenario"), Pawn);

	if (!bPassed)
	{
		return false;
	}

	UInputComponent* InputComponent = NewObject<UInputComponent>(Pawn, TEXT("AutomationPawnInputComponent"));
	if (!TestNotNull(TEXT("GAS actor-base pawn scenario should create an input component"), InputComponent))
	{
		return false;
	}

	Pawn->SetupPlayerInputComponent(InputComponent);
	Pawn->SetupPlayerInputComponent(InputComponent);

	int32 SetupCalls = 0;
	if (!ReadPropertyValue<FIntProperty>(*this, Pawn, TEXT("SetupCalls"), SetupCalls))
	{
		return false;
	}

	TestEqual(
		TEXT("SetupPlayerInputComponent should forward every invocation into the script SetupPawnInput override"),
		SetupCalls,
		2);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
