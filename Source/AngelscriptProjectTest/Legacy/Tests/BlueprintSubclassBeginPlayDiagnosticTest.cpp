#include "AngelscriptEngine.h"
#include "Editor.h"
#include "Engine/World.h"
#include "EngineUtils.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Tests/AutomationCommon.h"
#include "Tests/AutomationEditorCommon.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FBlueprintSubclassBeginPlayDiagnosticTest,
	"AngelscriptProject.Diagnostic.BlueprintSubclass.BeginPlayFromMap",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FBlueprintSubclassBeginPlayDiagnosticTest::RunTest(const FString& Parameters)
{
	// Step 1: Load the map
	ADD_LATENT_AUTOMATION_COMMAND(FEditorLoadMap(FString(TEXT("/Game/Test/ActorTestMap"))));
	ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));

	// Step 2: Start PIE (false = actual PIE, not simulate)
	ADD_LATENT_AUTOMATION_COMMAND(FStartPIECommand(false));
	ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(3.0f));

	// Step 3: Inspect actors in PIE world
	ADD_LATENT_AUTOMATION_COMMAND(FFunctionLatentCommand([this]() -> bool
	{
		AddInfo(TEXT("=== BeginPlay Diagnostic — PIE World Inspection ==="));

		// Find the current script actor class from Script/Game/Example_Actor.as
		UClass* ScriptActorClass = FindFirstObject<UClass>(TEXT("AExampleActorType"), EFindFirstObjectOptions::None);
		if (ScriptActorClass == nullptr)
		{
			AddError(TEXT("AExampleActorType not found. Script/Game/Example_Actor.as may not be compiled."));
			return true;
		}

		AddInfo(FString::Printf(TEXT("[ScriptClass] AExampleActorType — super: %s"),
			*ScriptActorClass->GetSuperClass()->GetName()));

		// Dump BeginPlay-related functions on the script class
		for (TFieldIterator<UFunction> It(ScriptActorClass, EFieldIteratorFlags::IncludeSuper); It; ++It)
		{
			if (It->GetName().Contains(TEXT("BeginPlay")))
			{
				AddInfo(FString::Printf(TEXT("  [func] %s  owner=%s  flags=0x%08X"),
					*It->GetName(), *It->GetOuter()->GetName(), (uint32)It->FunctionFlags));
			}
		}

		// Get PIE world
		UWorld* PIEWorld = nullptr;
		if (GEditor != nullptr && GEditor->GetPIEWorldContext() != nullptr)
		{
			PIEWorld = GEditor->GetPIEWorldContext()->World();
		}

		if (PIEWorld == nullptr)
		{
			for (const FWorldContext& Context : GEngine->GetWorldContexts())
			{
				if (Context.WorldType == EWorldType::PIE && Context.World() != nullptr)
				{
					PIEWorld = Context.World();
					break;
				}
			}
		}

		if (PIEWorld == nullptr)
		{
			AddError(TEXT("PIE world not found. PIE may not have started properly."));
			return true;
		}

		AddInfo(FString::Printf(TEXT("[PIE World] %s"), *PIEWorld->GetName()));

		// Iterate all actors in PIE world
		int32 TotalActors = 0;
		int32 ScriptChildCount = 0;

		for (TActorIterator<AActor> It(PIEWorld); It; ++It)
		{
			AActor* Actor = *It;
			TotalActors++;

			UClass* ActorClass = Actor->GetClass();
			const bool bIsScriptChild = ActorClass->IsChildOf(ScriptActorClass);

			if (!bIsScriptChild)
			{
				continue;
			}

			ScriptChildCount++;
			const bool bIsBlueprintSubclass = (ActorClass != ScriptActorClass);
			const bool bHasBegunPlay = Actor->HasActorBegunPlay();

			AddInfo(FString::Printf(TEXT("[Actor] %s  class=%s  isBPSubclass=%s  hasBegunPlay=%s"),
				*Actor->GetName(),
				*ActorClass->GetName(),
				bIsBlueprintSubclass ? TEXT("YES") : TEXT("NO"),
				bHasBegunPlay ? TEXT("YES") : TEXT("NO")));

			// Class hierarchy
			AddInfo(FString::Printf(TEXT("  ClassPath: %s"), *ActorClass->GetPathName()));
			AddInfo(FString::Printf(TEXT("  SuperClass: %s"), *ActorClass->GetSuperClass()->GetName()));

			// Check ReceiveBeginPlay ownership
			UFunction* ReceiveBeginPlay = ActorClass->FindFunctionByName(TEXT("ReceiveBeginPlay"));
			if (ReceiveBeginPlay != nullptr)
			{
				const bool bOwnedByThisClass = (ReceiveBeginPlay->GetOuter() == ActorClass);
				AddInfo(FString::Printf(TEXT("  ReceiveBeginPlay: owner=%s  ownedByThisClass=%s"),
					*ReceiveBeginPlay->GetOuter()->GetName(),
					bOwnedByThisClass ? TEXT("YES") : TEXT("NO")));

				if (bIsBlueprintSubclass && bOwnedByThisClass)
				{
					AddWarning(TEXT("  >>> Blueprint has its OWN ReceiveBeginPlay — likely overrides script parent's BeginPlay with empty graph!"));
				}
			}
			else
			{
				AddInfo(TEXT("  ReceiveBeginPlay: NOT FOUND"));
			}

			// BP class owned functions
			if (bIsBlueprintSubclass)
			{
				AddInfo(TEXT("  Functions owned by BP class (ExcludeSuper):"));
				for (TFieldIterator<UFunction> FuncIt(ActorClass, EFieldIteratorFlags::ExcludeSuper); FuncIt; ++FuncIt)
				{
					AddInfo(FString::Printf(TEXT("    %s  flags=0x%08X"),
						*FuncIt->GetName(), (uint32)FuncIt->FunctionFlags));
				}
			}

			// Check script properties
			FIntProperty* ExampleValueProp = FindFProperty<FIntProperty>(ActorClass, TEXT("ExampleValue"));
			if (ExampleValueProp != nullptr)
			{
				int32 Val = ExampleValueProp->GetPropertyValue_InContainer(Actor);
				AddInfo(FString::Printf(TEXT("  ExampleValue = %d (script default: 15)"), Val));
			}

			// Check Tags
			AddInfo(FString::Printf(TEXT("  Has 'ExampleTag': %s"),
				Actor->Tags.Contains(FName(TEXT("ExampleTag"))) ? TEXT("YES") : TEXT("NO")));

			// Check bReplicates default
			AddInfo(FString::Printf(TEXT("  bReplicates: %s"),
				Actor->GetIsReplicated() ? TEXT("YES") : TEXT("NO")));
		}

		AddInfo(FString::Printf(TEXT("[Summary] Total actors: %d, AExampleActorType children: %d"), TotalActors, ScriptChildCount));

		if (ScriptChildCount == 0)
		{
			AddWarning(TEXT("No AExampleActorType or subclass found in map! Check that the Blueprint is placed in Test/ActorTestMap."));
		}

		AddInfo(TEXT("=== Diagnostic complete. Check 'ScriptOnlyMethod Called' / 'Blueprint did not override this event.' in output log. ==="));
		AddInfo(TEXT("If those messages are MISSING, BeginPlay script code did not execute."));

		return true;
	}));

	// Step 4: End PIE
	ADD_LATENT_AUTOMATION_COMMAND(FEndPlayMapCommand());
	ADD_LATENT_AUTOMATION_COMMAND(FWaitLatentCommand(1.0f));

	return true;
}

#endif
