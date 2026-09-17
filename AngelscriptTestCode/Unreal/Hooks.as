/**
 * @version v1
 * @summary Preprocessor and compilation hooks on UCLASS carriers.
 * @topic Unreal
 * @topic Hooks
 *
 * async-load-consumer-actor
 * class-analyze-hook-carrier
 * default-blueprint-access-uses-settings
 * editor-conditional-members
 * explicit-context-controls-flags-and-defaults
 * hook-moments-emit-summary-backed-compilation-events
 * macro-detection
 * summary-available-at-existing-hook-points
 * summary-reports-coverage-fixture-shape
 */
/**
 * @begin async-load-consumer-actor
 * @summary The consumer half of the async-load comparison: an actor that imports the async provider and initialises a property from the imported multiplier. The same module must preprocess identically whether loaded synchronously.
 * @topic Hooks
 */
import Tests.Preprocessor.AsyncLoad.Provider;

class AAsyncLoadMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int StoredValue = ProviderMultiplier;

	/**
	 * Observe that the imported multiplier supplied the property default.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs a freshly constructed actor
	 * @Return true when StoredValue is 3
	 * @Boundary imported default
	 */
	UFUNCTION()
	bool StoredValueDefaultsToImportedMultiplier()
	{
		return StoredValue == 3;
	}

	/**
	 * Observe that consuming the provider leaves the property untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseProvider() then StoredValue
	 * @Return true when the product is 21 and StoredValue stays 3
	 * @Boundary no mutation
	 */
	UFUNCTION()
	bool ConsumingProviderLeavesStoredValue()
	{
		int Product = UseProvider();

		if (Product != 21)
		{
			return false;
		}

		return StoredValue == 3;
	}
}

/**
 * Multiplies the imported value by the imported multiplier.
 *
 * @Covers Preprocessor.Imports
 * @Inputs the imported ProvideValue and ProviderMultiplier
 * @Return 21
 */
int UseProvider()
{
	return ProvideValue() * ProviderMultiplier;
}
/** @end */
/**
 * @begin class-analyze-hook-carrier
 * @summary A carrier for the class-analyze hook. C++ injects a generated static that returns 31, but that value is hook injection rather than anything authored here; this script's own Entry returns 5, which is the authored oracle.
 * @topic Hooks
 */
UCLASS()
class UClassAnalyzeHookCarrier : UObject
{
	/**
	 * The authored entry point whose value the hook does not alter.
	 *
	 * @Covers Preprocessor.Events
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	int Entry()
	{
		return 5;
	}

	/**
	 * Observe that the authored return survives the analyze hook.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs Entry()
	 * @Return true when the value is 5
	 */
	UFUNCTION()
	bool ClassAnalyzeHookKeepsAuthoredReturn()
	{
		return Entry() == 5;
	}
}
/** @end */
/**
 * @begin default-blueprint-access-uses-settings
 * @summary A UPROPERTY carrying no explicit access specifier inherits the default Blueprint access from project settings, while one marked BlueprintReadWrite opts out of that default. The observers construct carriers and check that.
 * @topic Hooks
 */
UCLASS()
class UBlueprintAccessDefaultSpecifierCarrier : UObject
{
	UPROPERTY() int ImplicitAccess;
	UPROPERTY(BlueprintReadWrite) int ExplicitAccess;

	/**
	 * Observe that the implicit-access field defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs a freshly constructed carrier
	 * @Return true when ImplicitAccess is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ImplicitAccessDefaultsToZero()
	{
		return ImplicitAccess == 0;
	}

	/**
	 * Observe that the explicit-access field defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs a freshly constructed carrier
	 * @Return true when ExplicitAccess is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ExplicitAccessDefaultsToZero()
	{
		return ExplicitAccess == 0;
	}

	/**
	 * Observe that writing to this carrier leaves a sibling untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs this carrier written to, compared against a second carrier
	 * @Return true when this carrier holds the writes and the other stays zero
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool AccessFieldsAreIndependentAcrossInstances()
	{
		UBlueprintAccessDefaultSpecifierCarrier Other =
			Cast<UBlueprintAccessDefaultSpecifierCarrier>(
				NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0351 setup: NewObject returned null");
		}

		ImplicitAccess = 7;
		ExplicitAccess = 9;

		if (ImplicitAccess != 7)
		{
			return false;
		}

		if (ExplicitAccess != 9)
		{
			return false;
		}

		if (Other.ImplicitAccess != 0)
		{
			return false;
		}

		return Other.ExplicitAccess == 0;
	}
}
/** @end */
/**
 * @begin editor-conditional-members
 * @summary Members guarded by #if EDITOR are legal, unlike members guarded by an unknown flag: EDITOR is a supported condition. CSV marks the row as a negative diagnostic, but the C++ method asserts preprocessing succeeds, so this.
 * @topic Hooks
 */
UCLASS()
class UEditorConditionalCarrier : UObject
{
	/**
	 * The accepted condition: EDITOR is a supported condition, so the members
	 * inside it are kept and preprocessing succeeds.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the flag EDITOR
	 * @Return the members below are declared
	 */
#if EDITOR
	UPROPERTY()
	int EditorValue;

	/**
	 * Reports the editor-side value.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ReadEditorValue()
	{
		return 7;
	}

	/**
	 * Observe that the editor-only function reports 7.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs ReadEditorValue()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool EditorConditionalFunctionRuns()
	{
		return ReadEditorValue() == 7;
	}

	/**
	 * Observe that the editor-only property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs a freshly constructed carrier
	 * @Return true when EditorValue is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool EditorConditionalPropertyDefaultsToZero()
	{
		return EditorValue == 0;
	}

	/**
	 * Observe that assigning the property leaves the function unaffected.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs EditorValue assigned to 4, then ReadEditorValue
	 * @Return true when the property holds 4 and the function still reports 7
	 * @Boundary property independence
	 */
	UFUNCTION()
	bool EditorConditionalPropertyIsIndependent()
	{
		EditorValue = 4;

		if (ReadEditorValue() != 7)
		{
			return false;
		}

		return EditorValue == 4;
	}
#endif
}
/** @end */
/**
 * @begin explicit-context-controls-flags-and-defaults
 * @summary An explicit preprocessor context selects which of two class definitions is live: with CONTEXT_ENABLED set, only the first carrier is detected, and the one in the #else branch never exists. The observers check the live.
 * @topic Hooks
 */
#if CONTEXT_ENABLED
UCLASS()
class UExplicitContextCarrier : UObject
{
	/**
	 * A no-op method on the live carrier.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void ImplicitFunction()
	{
	}

	UPROPERTY()
	int ImplicitProperty;

	/**
	 * Observe that the property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs a freshly constructed carrier
	 * @Return true when ImplicitProperty is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ImplicitPropertyDefaultsToZero()
	{
		return ImplicitProperty == 0;
	}

	/**
	 * Observe that calling the function leaves the property untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs ImplicitFunction() then ImplicitProperty
	 * @Return true when the property is still 0
	 * @Boundary no mutation
	 */
	UFUNCTION()
	bool ImplicitFunctionDoesNotMutateProperty()
	{
		ImplicitFunction();
		return ImplicitProperty == 0;
	}
}
#else
UCLASS()
class UWrongContextCarrier : UObject
{
	UPROPERTY()
	int WrongProperty;
}
#endif
/** @end */
/**
 * @begin hook-moments-emit-summary-backed-compilation-events
 * @summary A fixture for the ProcessChunks and PostProcessCode compilation events: one class, one property and one function, so the events fire with a summary that describes exactly those. The observers confirm the accessor default.
 * @topic Hooks
 */
UCLASS()
class UCompilationEventsHookMoments : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Reads back the property value.
	 *
	 * @Covers Preprocessor.Events
	 * @Inputs the carrier's Value
	 * @Return the stored value
	 */
	UFUNCTION()
	int Entry()
	{
		return Value;
	}

	/**
	 * Observe the default state of the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs a freshly constructed carrier
	 * @Return true when Entry reports 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool CompilationEventsValueDefaultsToZero()
	{
		return Entry() == 0;
	}

	/**
	 * Observe that an assignment writes back through the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs Value assigned to 5, then Entry
	 * @Return true when the accessor reports 5
	 * @Boundary assigned value
	 */
	UFUNCTION()
	bool CompilationEventsValueWritesBack()
	{
		Value = 5;
		return Entry() == 5;
	}
}
/** @end */
/**
 * @begin macro-detection
 * @summary Macro detection on a script class: the preprocessor records the property macro Mesh and the function macro BeginPlay. The mesh is left at its default, and the empty BeginPlay override is a no-op that does not assign it.
 * @topic Hooks
 */
class AMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UStaticMesh Mesh;

	/**
	 * An empty lifecycle override that must not assign the mesh.
	 *
	 * @Covers Preprocessor.Macros
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}

	/**
	 * Observe that the mesh is left at its null default.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Macros
	 * @Inputs a freshly constructed actor
	 * @Return true when Mesh is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool MeshDefaultsToNull()
	{
		return Mesh is null;
	}

	/**
	 * Observe that running the empty override leaves the mesh null.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Macros
	 * @Inputs BeginPlay() then Mesh
	 * @Return true when Mesh is still null
	 * @Boundary no-op override
	 */
	UFUNCTION()
	bool EmptyBeginPlayLeavesMeshNull()
	{
		BeginPlay();
		return Mesh is null;
	}
}
/** @end */
/**
 * @begin summary-available-at-existing-hook-points
 * @summary A minimal UCLASS used as a summary fixture: the preprocessor summary must count exactly one class and one property, and the PostProcessCode hook must receive non-empty code. The observers confirm the property default and.
 * @topic Hooks
 */
UCLASS()
class USummaryHookCarrier : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that the property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs a freshly constructed carrier
	 * @Return true when Value is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool SummaryValueDefaultsToZero()
	{
		return Value == 0;
	}

	/**
	 * Observe that writing this carrier leaves a sibling untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs this carrier written to, compared against a second carrier
	 * @Return true when this carrier holds the write and the other stays zero
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool SummaryValueIsIndependentAcrossInstances()
	{
		USummaryHookCarrier Other =
			Cast<USummaryHookCarrier>(
				NewObject(GetTransientPackage(), USummaryHookCarrier::StaticClass(), n"SummaryHookCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0353 setup: NewObject returned null");
		}

		Value = 11;

		if (Value != 11)
		{
			return false;
		}

		return Other.Value == 0;
	}
}
/** @end */
/**
 * @begin summary-reports-coverage-fixture-shape
 * @summary A coverage fixture whose shape exercises one of each counted construct: one enum, one UCLASS, one UFUNCTION and one UPROPERTY, so the preprocessor summary reports one of each. The observers confirm the accessor.
 * @topic Hooks
 */
UENUM()
enum ECoveragePreprocessorState
{
	Idle,
	Active
}

UCLASS()
class UCoveragePreprocessorSummaryCarrier : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Reads back the property value.
	 *
	 * @Covers Preprocessor.Summary
	 * @Inputs the carrier's Value
	 * @Return the stored value
	 */
	UFUNCTION()
	int GetValue()
	{
		return Value;
	}

	/**
	 * Observe the default state of the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs a freshly constructed carrier
	 * @Return true when GetValue reports 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool CoverageFixtureValueDefaultsToZero()
	{
		return GetValue() == 0;
	}

	/**
	 * Observe that an assignment writes back through the accessor.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Summary
	 * @Inputs Value assigned to 1, then the enum members compared
	 * @Return true when the accessor reports 1 and the members differ
	 * @Boundary assigned value
	 */
	UFUNCTION()
	bool CoverageFixtureValueWritesBack()
	{
		Value = 1;

		if (GetValue() != 1)
		{
			return false;
		}

		return ECoveragePreprocessorState::Idle != ECoveragePreprocessorState::Active;
	}
}
/** @end */
