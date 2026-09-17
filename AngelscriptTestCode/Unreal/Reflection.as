/**
 * @version v1
 * @summary UCLASS numeric, bool, quat, and default properties.
 * @topic Unreal
 * @topic Reflection
 *
 * container-as-return-value
 * bool-container-properties
 * bool-declaration-defaults
 * bool-replicated-properties
 * bool-write-round-trip
 * class-like-reflection-shape
 * compiles-and-registers-properties
 * container-as-parameter
 * container-iterator-advanced-operations
 * default-enum-property-applied
 * default-float-and-bool-property-applied
 * default-f-name-property-applied
 * default-tags-add-executed-on-c-d-o
 * float-container-properties
 * float-family-boundary-values
 * float-family-declaration-defaults
 * float-family-special-values
 * float-family-write-round-trip
 * float-property-script-mutation-round-trip
 * float-replicated-properties
 * f-quat-class-member-runtime-flow
 * f-quat-container-properties
 * f-quat-declaration-defaults
 * f-quat-write-round-trip
 * geometric-struct-reflection-properties-and-containers
 * int-container-edge-cases
 * int-container-properties
 * int-container-properties-extended
 * int-container-width-completion
 * int-family-boundary-values
 * int-family-declaration-defaults
 * int-family-implicit-and-explicit-zero-defaults
 * int-family-near-boundary-values
 * int-family-write-round-trip
 * int-property-script-read-write-api-surface
 * int-struct-deep-nested-property-paths
 * int-struct-nested-property-widths
 * mixed-container-parameters
 * property-defaults-compile
 * u-class-property-defaults
 * vector4-int-point-int-vector-reflection
 * container-reference-return
 */
/**
 * @begin container-as-return-value
 * @summary A container can be returned by value from a function, so the caller receives the filled container rather than a handle to one. The returned array and map arrive with their elements intact, and a default-constructed.
 * @topic Reflection
 */
UCLASS()
class ACoverageContainerReturnActor : AActor
{
	UPROPERTY()
	int ArraySize;

	UPROPERTY()
	int MapSize;

	UPROPERTY()
	int ArrayFirst;

	UPROPERTY()
	int EmptyArraySize;

	UPROPERTY()
	int EmptyMapSize;

	/**
	 * Build an array and return it by value.
	 */
	TArray<int> MakeArray()
	{
		Print("=== MakeArray ===");
		TArray<int> Result;
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Print("Created array with " + Result.Num() + " elements");
		return Result;
	}

	/**
	 * Build a map and return it by value.
	 */
	TMap<int, FString> MakeMap()
	{
		Print("=== MakeMap ===");
		TMap<int, FString> Result;
		Result.Add(1, "One");
		Result.Add(2, "Two");
		Print("Created map with " + Result.Num() + " entries");
		return Result;
	}

	/**
	 * Run the returns once at play time, so the C++ fixture can read the
	 * resulting property values by path.
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Container as Return Value Test ===");

		TArray<int> MyArray = MakeArray();
		ArraySize = MyArray.Num();
		ArrayFirst = MyArray[0];
		Print("Received array size: " + ArraySize);

		TMap<int, FString> MyMap = MakeMap();
		MapSize = MyMap.Num();
		Print("Received map size: " + MapSize);

		TArray<int> EmptyArray;
		EmptyArraySize = EmptyArray.Num();
		TMap<int, FString> EmptyMap;
		EmptyMapSize = EmptyMap.Num();
	}
}

namespace ControlFlowTest
{
	/**
	 * Observe the returned array: it arrives with all three elements and the
	 * first one intact.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Build an array through the same helper the actor uses
	 * @Return true when the count is 3 and the first element is 10
	 */
	UFUNCTION()
	bool ReturnedArrayKeepsElements()
	{
		TArray<int> Result;
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		if (Result.Num() != 3)
		{
			return false;
		}
		return Result[0] == 10;
	}

	/**
	 * Observe the returned map: it arrives with both entries.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Build a map through the same helper the actor uses
	 * @Return true when the count is 2
	 */
	UFUNCTION()
	bool ReturnedMapKeepsEntries()
	{
		TMap<int, FString> Result;
		Result.Add(1, "One");
		Result.Add(2, "Two");
		return Result.Num() == 2;
	}

	/**
	 * Observe the empty default: default-constructed containers report zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs A default array and a default map
	 * @Return true when both counts are zero
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool ReturnedEmptyContainersReportZero()
	{
		TArray<int> EmptyArray;
		TMap<int, FString> EmptyMap;
		if (EmptyArray.Num() != 0)
		{
			return false;
		}
		return EmptyMap.Num() == 0;
	}
}
/** @end */
/**
 * @begin bool-container-properties
 * @summary Boolean members inside UE containers, filled during BeginPlay: an array, three maps keyed and valued on bool in both directions, and a set that must dedupe a repeated true. A locally constructed actor leaves all of them.
 * @topic Reflection
 */
UCLASS()
class ACoverageBoolContainerActor : AActor
{
	UPROPERTY()
	TArray<bool> BoolArray;

	UPROPERTY()
	TMap<int, bool> IntToBoolMap;

	UPROPERTY()
	TMap<bool, int> BoolToIntMap;

	UPROPERTY()
	TMap<FString, bool> StringToBoolMap;

	UPROPERTY()
	TSet<bool> BoolSet;

	/**
	 * Fills every container.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all five containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoolArray.Add(true);
		BoolArray.Add(false);
		BoolArray.Add(true);

		IntToBoolMap.Add(1, true);
		IntToBoolMap.Add(2, false);

		BoolToIntMap.Add(true, 100);
		BoolToIntMap.Add(false, 200);

		StringToBoolMap.Add("Enabled", true);
		StringToBoolMap.Add("Hidden", false);

		BoolSet.Add(true);
		BoolSet.Add(false);
		BoolSet.Add(true);  // Duplicate
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed actor
	 * @Return true when all five containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool BoolContainersDefaultToEmpty()
	{
		if (BoolArray.Num() != 0)
		{
			return false;
		}

		if (IntToBoolMap.Num() != 0)
		{
			return false;
		}

		if (BoolToIntMap.Num() != 0)
		{
			return false;
		}

		if (StringToBoolMap.Num() != 0)
		{
			return false;
		}

		return BoolSet.Num() == 0;
	}

	/**
	 * Observe the contents of every container after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all five containers
	 * @Return true when every element, entry and set member matches
	 */
	UFUNCTION()
	bool BoolContainersHoldExpectedValues()
	{
		BeginPlay();

		bool IntTrue = false;
		int TrueMapped = 0;
		int FalseMapped = 0;
		bool Enabled = false;
		bool Hidden = true;

		if (BoolArray.Num() != 3)
		{
			return false;
		}

		if (BoolArray[0] != true)
		{
			return false;
		}

		if (BoolArray[1] != false)
		{
			return false;
		}

		if (BoolArray[2] != true)
		{
			return false;
		}

		if (IntToBoolMap.Num() != 2)
		{
			return false;
		}

		if (!IntToBoolMap.Find(1, IntTrue))
		{
			return false;
		}

		if (IntTrue != true)
		{
			return false;
		}

		if (BoolToIntMap.Num() != 2)
		{
			return false;
		}

		if (!BoolToIntMap.Find(true, TrueMapped))
		{
			return false;
		}

		if (TrueMapped != 100)
		{
			return false;
		}

		if (!BoolToIntMap.Find(false, FalseMapped))
		{
			return false;
		}

		if (FalseMapped != 200)
		{
			return false;
		}

		if (StringToBoolMap.Num() != 2)
		{
			return false;
		}

		if (!StringToBoolMap.Find("Enabled", Enabled))
		{
			return false;
		}

		if (Enabled != true)
		{
			return false;
		}

		if (!StringToBoolMap.Find("Hidden", Hidden))
		{
			return false;
		}

		if (Hidden != false)
		{
			return false;
		}

		if (BoolSet.Num() != 2)
		{
			return false;
		}

		if (!BoolSet.Contains(true))
		{
			return false;
		}

		return BoolSet.Contains(false);
	}
}
/** @end */
/**
 * @begin bool-declaration-defaults
 * @summary Boolean UPROPERTY defaults: an explicit true, an explicit false, and one left without an initializer. The observers confirm the defaults and that writing one actor leaves another untouched.
 * @topic Reflection
 */
UCLASS()
class ACoverageBoolDefaultsActor : AActor
{
	UPROPERTY()
	bool TrueValue = true;

	UPROPERTY()
	bool FalseValue = false;

	UPROPERTY()
	bool NoDefaultValue;

	/**
	 * Observe that all three declarations hold their defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are true, false and false
	 * @Boundary default values
	 */
	UFUNCTION()
	bool BoolDefaultsHoldDeclaredValues()
	{
		if (TrueValue != true)
		{
			return false;
		}

		if (FalseValue != false)
		{
			return false;
		}

		return NoDefaultValue == false;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds the writes and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BoolDefaultsAreIndependentAcrossInstances()
	{
		ACoverageBoolDefaultsActor Other =
			Cast<ACoverageBoolDefaultsActor>(
				NewObject(GetTransientPackage(), ACoverageBoolDefaultsActor::StaticClass(), n"CoverageBoolDefaultsActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolDeclarationDefaults setup: NewObject returned null");
		}

		TrueValue = false;
		FalseValue = true;
		NoDefaultValue = true;

		if (TrueValue != false)
		{
			return false;
		}

		if (Other.TrueValue != true)
		{
			return false;
		}

		if (Other.FalseValue != false)
		{
			return false;
		}

		return Other.NoDefaultValue == false;
	}
}
/** @end */
/**
 * @begin bool-replicated-properties
 * @summary Replicated boolean properties: one plain Replicated flag defaulting to true and one ReplicatedUsing flag that invokes an OnRep handler. The observers confirm the defaults and that writing one actor leaves another.
 * @topic Reflection
 */
UCLASS()
class ACoverageBoolReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	bool bReplicatedFlag = true;

	UPROPERTY(ReplicatedUsing=OnRep_Ready)
	bool bReady = false;

	/**
	 * The replication callback wired to bReady.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_Ready()
	{
	}

	/**
	 * Observe that both replicated flags hold their defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when bReplicatedFlag is true and bReady is false
	 * @Boundary default values
	 */
	UFUNCTION()
	bool ReplicatedBoolsHoldDeclaredDefaults()
	{
		if (bReplicatedFlag != true)
		{
			return false;
		}

		return bReady == false;
	}

	/**
	 * Observe that writing one actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds the write and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ReplicatedBoolsAreIndependentAcrossInstances()
	{
		ACoverageBoolReplicationActor Other =
			Cast<ACoverageBoolReplicationActor>(
				NewObject(GetTransientPackage(), ACoverageBoolReplicationActor::StaticClass(), n"CoverageBoolReplicationActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolReplicatedProperties setup: NewObject returned null");
		}

		bReady = true;
		OnRep_Ready();

		if (bReady != true)
		{
			return false;
		}

		if (bReplicatedFlag != true)
		{
			return false;
		}

		if (Other.bReady != false)
		{
			return false;
		}

		return Other.bReplicatedFlag == true;
	}
}
/** @end */
/**
 * @begin bool-write-round-trip
 * @summary A boolean UPROPERTY written through the true/false/true cycle. The observers confirm the starting default, that each write reads back, and that writing one actor leaves another untouched.
 * @topic Reflection
 */
UCLASS()
class ACoverageBoolWriteActor : AActor
{
	UPROPERTY()
	bool BoolValue;

	/**
	 * Observe that the property starts false.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when BoolValue is false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BoolWriteDefaultsToFalse()
	{
		return BoolValue == false;
	}

	/**
	 * Observe that each write in the cycle reads back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BoolValue written true, then false, then true
	 * @Return true when every step reads back its written value
	 */
	UFUNCTION()
	bool BoolWriteRoundTripsThroughValues()
	{
		BoolValue = true;
		if (BoolValue != true)
		{
			return false;
		}

		BoolValue = false;
		if (BoolValue != false)
		{
			return false;
		}

		BoolValue = true;
		return BoolValue == true;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds true and the other stays false
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BoolWriteIsIndependentAcrossInstances()
	{
		ACoverageBoolWriteActor Other =
			Cast<ACoverageBoolWriteActor>(
				NewObject(GetTransientPackage(), ACoverageBoolWriteActor::StaticClass(), n"CoverageBoolWriteActorOther"));
		if (Other == nullptr)
		{
			throw("Test_BoolWriteRoundTrip setup: NewObject returned null");
		}

		BoolValue = true;

		if (BoolValue != true)
		{
			return false;
		}

		return Other.BoolValue == false;
	}
}
/** @end */
/**
 * @begin class-like-reflection-shape
 * @summary The reflection shape of class-like signatures: a plain UClass, a TSubclassOf and a TSoftClassPtr each echoed through a UFUNCTION. The observers confirm the null pass-through, the AActor class identity, and the empty soft.
 * @topic Reflection
 */
UCLASS()
class UCompilerClassLikeShapeCarrier : UObject
{
	/**
	 * Echoes a plain UClass value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a UClass
	 * @Return the same UClass
	 * @Param Value the class to echo
	 */
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSubclassOf value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a TSubclassOf<AActor>
	 * @Return the same TSubclassOf
	 * @Param Value the subclass to echo
	 */
	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	/**
	 * Echoes a TSoftClassPtr value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a TSoftClassPtr<AActor>
	 * @Return the same TSoftClassPtr
	 * @Param Value the soft class pointer to echo
	 */
	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}

	/**
	 * Observe that echoing a null class stays null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoPlainClass(nullptr)
	 * @Return true when the result is null
	 * @Boundary null class
	 */
	UFUNCTION()
	bool ClassLikeShapePlainNullStaysNull()
	{
		return EchoPlainClass(nullptr) == nullptr;
	}

	/**
	 * Observe that the AActor class identity survives the echo.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoActorClass over the AActor class
	 * @Return true when the identity is preserved
	 */
	UFUNCTION()
	bool ClassLikeShapeActorIdentityPreserved()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		TSubclassOf<AActor> Echoed = EchoActorClass(ActorClass);
		return Echoed == ActorClass;
	}

	/**
	 * Observe that an empty soft class pointer echoes back null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EchoSoftActorClass over an empty TSoftClassPtr
	 * @Return true when the echoed value is null
	 * @Boundary empty soft pointer
	 */
	UFUNCTION()
	bool ClassLikeShapeSoftEmptyStaysNull()
	{
		TSoftClassPtr<AActor> Empty;
		TSoftClassPtr<AActor> Echoed = EchoSoftActorClass(Empty);
		return Echoed.IsNull();
	}
}
/** @end */
/**
 * @begin compiles-and-registers-properties
 * @summary A UDataAsset whose properties must register and carry their CDO defaults, together with an actor holding a pointer to that asset. The observers read the asset's defaults and confirm the actor's config pointer starts.
 * @topic Reflection
 */
UCLASS()
class UFunctionalWeaponData : UDataAsset
{
	UPROPERTY(EditAnywhere)
	FString WeaponName;

	UPROPERTY(EditAnywhere, meta = (ClampMin = "0"))
	float BaseDamage = 10.0;

	UPROPERTY(EditAnywhere)
	float FireRate = 0.5;

	UPROPERTY(EditAnywhere)
	int32 MaxAmmo = 30;

	UPROPERTY(EditAnywhere)
	TArray<FName> AllowedAttachments;

	/**
	 * Observe that every registered property holds its CDO default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed asset
	 * @Return true when all five properties match their defaults
	 * @Boundary default values
	 */
	UFUNCTION()
	bool WeaponDataHoldsCDODefaults()
	{
		if (WeaponName.Len() != 0)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(BaseDamage, 10.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FireRate, 0.5))
		{
			return false;
		}

		if (MaxAmmo != 30)
		{
			return false;
		}

		return AllowedAttachments.Num() == 0;
	}

	/**
	 * Observe that writing this asset leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this asset written to, compared against a second asset
	 * @Return true when this asset holds the write and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool WeaponDataInstancesAreIndependent()
	{
		UFunctionalWeaponData Other =
			Cast<UFunctionalWeaponData>(
				NewObject(GetTransientPackage(), UFunctionalWeaponData::StaticClass(), n"FunctionalWeaponDataOther"));
		if (Other == nullptr)
		{
			throw("Test_CompilesAndRegistersProperties setup: NewObject returned null");
		}

		WeaponName = "Rifle";
		MaxAmmo = 7;

		if (WeaponName != "Rifle")
		{
			return false;
		}

		if (Other.WeaponName.Len() != 0)
		{
			return false;
		}

		return Other.MaxAmmo == 30;
	}
}

UCLASS()
class AFunctionalWeaponActor : AActor
{
	UPROPERTY(EditAnywhere)
	UFunctionalWeaponData WeaponConfig;

	/**
	 * Observe that the config pointer starts null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when WeaponConfig is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool WeaponActorConfigDefaultsToNull()
	{
		return WeaponConfig == nullptr;
	}
}
/** @end */
/**
 * @begin container-as-parameter
 * @summary Containers passed by value, by reference and as an out parameter. BeginPlay exercises all three and records the resulting element counts; a locally constructed actor leaves all counters at zero.
 * @topic Reflection
 */
UCLASS()
class ACoverageContainerParameterActor : AActor
{
	UPROPERTY()
	int ResultByValue;

	UPROPERTY()
	int ResultByRef;

	UPROPERTY()
	int ResultByOut;

	/**
	 * Sums a container received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a container passed by value
	 * @Return the sum of all elements
	 * @Param Arr the copied container
	 */
	int SumByValue(TArray<int> Arr)
	{
		int Sum = 0;
		for (int Val : Arr)
		{
			Sum += Val;
		}
		return Sum;
	}

	/**
	 * Appends to a container received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a container passed by reference
	 * @Return nothing; the caller's container gains one element
	 * @Param Arr the container to modify in place
	 */
	void ModifyByRef(TArray<int>&inout Arr)
	{
		Arr.Add(999);
	}

	/**
	 * Fills a container supplied as an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an empty out container
	 * @Return nothing; the container receives three elements
	 * @Param Result the out container to fill
	 */
	void FillOut(TArray<int>&out Result)
	{
		Result.Add(100);
		Result.Add(200);
		Result.Add(300);
	}

	/**
	 * Exercises all three parameter directions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the three counters record the outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		ResultByValue = SumByValue(Values);

		TArray<int> RefArray;
		RefArray.Add(10);
		RefArray.Add(20);
		ModifyByRef(RefArray);
		ResultByRef = RefArray.Num();

		TArray<int> OutArray;
		FillOut(OutArray);
		ResultByOut = OutArray.Num();
	}

	/**
	 * Observe that a locally constructed actor leaves all counters at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool ContainerParameterResultsDefaultToZero()
	{
		if (ResultByValue != 0)
		{
			return false;
		}

		if (ResultByRef != 0)
		{
			return false;
		}

		return ResultByOut == 0;
	}

	/**
	 * Observe the results after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all three counters
	 * @Return true when the counts are 6, 3 and 3
	 */
	UFUNCTION()
	bool ContainerParameterResultsAfterBeginPlay()
	{
		BeginPlay();

		if (ResultByValue != 6)
		{
			return false;
		}

		if (ResultByRef != 3)
		{
			return false;
		}

		return ResultByOut == 3;
	}

	/**
	 * Observe that passing by value copies rather than aliases.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an empty array and a three-element array, both summed by value
	 * @Return true when the sums are 0 and 6 and the source is untouched
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool ContainerByValueCopiesIndependently()
	{
		TArray<int> Empty;
		int EmptySum = SumByValue(Empty);
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		int CopiedSum = SumByValue(Values);

		if (EmptySum != 0)
		{
			return false;
		}

		if (CopiedSum != 6)
		{
			return false;
		}

		return Values.Num() == 3;
	}
}
/** @end */
/**
 * @begin container-iterator-advanced-operations
 * @summary Advanced container iterators: copying and assigning array, map and set iterators, writing through an array iterator, and mutating a map while iterating it by removing and updating entries.
 * @topic Reflection
 */
UCLASS()
class ACoverageContainerIteratorAdvancedActor : AActor
{
	UPROPERTY()
	int ArrayCopyAssignSum = 0;

	UPROPERTY()
	int ArrayMutableWriteSum = 0;

	UPROPERTY()
	int MapCopyAssignKeySum = 0;

	UPROPERTY()
	int MapCopyAssignValueSum = 0;

	UPROPERTY()
	int MapMutationVisitedCount = 0;

	UPROPERTY()
	int MapMutationRemainingCount = 0;

	UPROPERTY()
	int MapMutationUpdatedValueSum = 0;

	UPROPERTY()
	int MapMutationRemovedKeyCount = 0;

	UPROPERTY()
	int SetCopyAssignSum = 0;

	UPROPERTY()
	int SetCopyAssignVisitCount = 0;

	/**
	 * Copies and assigns an array iterator, then writes through one.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the array counters record the outcome
	 */
	void ExerciseArrayIterator()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);

		TArrayIterator<int> Original = Values.Iterator();
		TArrayIterator<int> Copied = Original;
		TArrayIterator<int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			ArrayCopyAssignSum += Original.Proceed();
		}

		while (Copied.CanProceed)
		{
			ArrayCopyAssignSum += Copied.Proceed();
		}

		while (Assigned.CanProceed)
		{
			ArrayCopyAssignSum += Assigned.Proceed();
		}

		TArrayIterator<int> Mutating = Values.Iterator();
		if (Mutating.CanProceed)
		{
			Mutating.Proceed() = 10;
		}

		ArrayMutableWriteSum = Values[0] + Values[1] + Values[2] + Values[3];
	}

	/**
	 * Copies and assigns a map iterator, then mutates a map while iterating.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the map counters record the outcome
	 */
	void ExerciseMapIterator()
	{
		TMap<int, int> Values;
		Values.Add(1, 10);
		Values.Add(2, 20);
		Values.Add(3, 30);

		TMapIterator<int, int> Original = Values.Iterator();
		TMapIterator<int, int> Copied = Original;
		TMapIterator<int, int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			Original.Proceed();
			MapCopyAssignKeySum += Original.GetKey();
			MapCopyAssignValueSum += Original.GetValue();
		}

		while (Copied.CanProceed)
		{
			Copied.Proceed();
			MapCopyAssignKeySum += Copied.GetKey();
			MapCopyAssignValueSum += Copied.GetValue();
		}

		while (Assigned.CanProceed)
		{
			Assigned.Proceed();
			MapCopyAssignKeySum += Assigned.GetKey();
			MapCopyAssignValueSum += Assigned.GetValue();
		}

		TMap<int, int> MutableValues;
		MutableValues.Add(1, 10);
		MutableValues.Add(2, 20);
		MutableValues.Add(3, 30);
		MutableValues.Add(4, 40);

		TMapIterator<int, int> Mutating = MutableValues.Iterator();
		while (Mutating.CanProceed)
		{
			Mutating.Proceed();
			MapMutationVisitedCount++;

			if (Mutating.GetKey() == 2 || Mutating.GetKey() == 4)
			{
				Mutating.RemoveCurrent();
			}
			else
			{
				int NewValue = Mutating.GetValue() + 100;
				Mutating.SetValue(NewValue);
			}
		}

		MapMutationRemainingCount = MutableValues.Num();

		int FoundValue = 0;
		if (MutableValues.Find(1, FoundValue))
		{
			MapMutationUpdatedValueSum += FoundValue;
		}

		if (MutableValues.Find(3, FoundValue))
		{
			MapMutationUpdatedValueSum += FoundValue;
		}

		if (MutableValues.Contains(2))
		{
			MapMutationRemovedKeyCount++;
		}

		if (MutableValues.Contains(4))
		{
			MapMutationRemovedKeyCount++;
		}
	}

	/**
	 * Copies and assigns a set iterator.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the set counters record the outcome
	 */
	void ExerciseSetIterator()
	{
		TSet<int> Values;
		Values.Add(2);
		Values.Add(4);
		Values.Add(8);

		TSetIterator<int> Original = Values.Iterator();
		TSetIterator<int> Copied = Original;
		TSetIterator<int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			SetCopyAssignSum += Original.Proceed();
			SetCopyAssignVisitCount++;
		}

		while (Copied.CanProceed)
		{
			SetCopyAssignSum += Copied.Proceed();
			SetCopyAssignVisitCount++;
		}

		while (Assigned.CanProceed)
		{
			SetCopyAssignSum += Assigned.Proceed();
			SetCopyAssignVisitCount++;
		}
	}

	/**
	 * Runs all three iterator exercises.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; every counter is populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ExerciseArrayIterator();
		ExerciseMapIterator();
		ExerciseSetIterator();
	}

	/**
	 * Observe that a locally constructed actor leaves every counter at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all ten counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool IteratorCountersDefaultToZero()
	{
		if (ArrayCopyAssignSum != 0)
		{
			return false;
		}

		if (ArrayMutableWriteSum != 0)
		{
			return false;
		}

		if (MapCopyAssignKeySum != 0)
		{
			return false;
		}

		if (MapCopyAssignValueSum != 0)
		{
			return false;
		}

		if (MapMutationVisitedCount != 0)
		{
			return false;
		}

		if (MapMutationRemainingCount != 0)
		{
			return false;
		}

		if (MapMutationUpdatedValueSum != 0)
		{
			return false;
		}

		if (MapMutationRemovedKeyCount != 0)
		{
			return false;
		}

		if (SetCopyAssignSum != 0)
		{
			return false;
		}

		return SetCopyAssignVisitCount == 0;
	}

	/**
	 * Observe every counter after the three exercises run.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all three exercises then all ten counters
	 * @Return true when every counter matches its expected value
	 */
	UFUNCTION()
	bool IteratorCountersMatchAfterExercises()
	{
		ExerciseArrayIterator();
		ExerciseMapIterator();
		ExerciseSetIterator();

		if (ArrayCopyAssignSum != 30)
		{
			return false;
		}

		if (ArrayMutableWriteSum != 19)
		{
			return false;
		}

		if (MapCopyAssignKeySum != 18)
		{
			return false;
		}

		if (MapCopyAssignValueSum != 180)
		{
			return false;
		}

		if (MapMutationVisitedCount != 4)
		{
			return false;
		}

		if (MapMutationRemainingCount != 2)
		{
			return false;
		}

		if (MapMutationUpdatedValueSum != 240)
		{
			return false;
		}

		if (MapMutationRemovedKeyCount != 0)
		{
			return false;
		}

		if (SetCopyAssignSum != 42)
		{
			return false;
		}

		return SetCopyAssignVisitCount == 9;
	}
}
/** @end */
/**
 * @begin default-enum-property-applied
 * @summary An enum UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default lands, that the zero member is the unset value, and that instances do not share state.
 * @topic Reflection
 */
enum ETestDirection
{
	Up,
	Down,
	Left,
	Right
}

UCLASS()
class UDefaultEnumCarrier : UObject
{
	UPROPERTY()
	ETestDirection Direction;

	default Direction = ETestDirection::Right;

	/**
	 * Reads the enum as its underlying integer.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the carrier's Direction
	 * @Return the integer value of Direction
	 */
	UFUNCTION()
	int GetDirectionValue()
	{
		return int(Direction);
	}

	/**
	 * Observe that the CDO default was applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 3
	 */
	UFUNCTION()
	bool DefaultEnumAppliesRight()
	{
		return GetDirectionValue() == 3;
	}

	/**
	 * Observe that the first enum member is the zero value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the Up member
	 * @Return true when it is 0
	 * @Boundary zero member
	 */
	UFUNCTION()
	bool DefaultEnumUpIsZero()
	{
		return int(ETestDirection::Up) == 0;
	}

	/**
	 * Observe that writing this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier set to Up, compared against a second carrier
	 * @Return true when this carrier reads 0 and the other reads 3
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool DefaultEnumInstancesAreIndependent()
	{
		UDefaultEnumCarrier Other =
			Cast<UDefaultEnumCarrier>(
				NewObject(GetTransientPackage(), UDefaultEnumCarrier::StaticClass(), n"DefaultEnumCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_DefaultEnumPropertyApplied setup: NewObject returned null");
		}

		Direction = ETestDirection::Up;

		if (GetDirectionValue() != 0)
		{
			return false;
		}

		return Other.GetDirectionValue() == 3;
	}
}
/** @end */
/**
 * @begin default-float-and-bool-property-applied
 * @summary A float and a bool UPROPERTY whose CDO defaults are set with `default` statements. The verifier returns distinct codes so a failure names which default was missed.
 * @topic Reflection
 */
UCLASS()
class UDefaultFloatBoolCarrier : UObject
{
	UPROPERTY()
	float MyFloat;

	UPROPERTY()
	bool bEnabled;

	default MyFloat = 3.14f;
	default bEnabled = true;

	/**
	 * Verifies both defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two defaulted UPROPERTYs
	 * @Return 42 when both hold, otherwise 1 or 2 naming the failed check
	 */
	UFUNCTION()
	int VerifyDefaults()
	{
		if (MyFloat < 3.13f || MyFloat > 3.15f)
		{
			return 1;
		}
		if (!bEnabled)
		{
			return 2;
		}
		return 42;
	}

	/**
	 * Observe that both defaults were applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when verification returns 42
	 */
	UFUNCTION()
	bool DefaultFloatAndBoolVerifyPasses()
	{
		return VerifyDefaults() == 42;
	}

	/**
	 * Observe the float boundary where the default no longer holds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs MyFloat set to 0
	 * @Return true when verification returns 1
	 * @Boundary zero float
	 */
	UFUNCTION()
	bool DefaultFloatZeroBoundaryFailsVerification()
	{
		MyFloat = 0.0f;
		return VerifyDefaults() == 1;
	}

	/**
	 * Observe the bool boundary where the default no longer holds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs bEnabled set to false
	 * @Return true when verification returns 2
	 * @Boundary disabled flag
	 */
	UFUNCTION()
	bool DefaultBoolDisabledBoundaryFailsVerification()
	{
		bEnabled = false;
		return VerifyDefaults() == 2;
	}
}
/** @end */
/**
 * @begin default-f-name-property-applied
 * @summary An FName UPROPERTY whose CDO default is set with a `default` statement. The observers confirm the default name, that it is not NAME_None, and that clearing one instance leaves another intact.
 * @topic Reflection
 */
UCLASS()
class UDefaultFNameCarrier : UObject
{
	UPROPERTY()
	FName MyName;

	default MyName = n"TestName";

	/**
	 * Observe that the CDO default name was applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when MyName is n"TestName"
	 */
	UFUNCTION()
	bool DefaultFNameAppliesTestName()
	{
		return MyName == n"TestName";
	}

	/**
	 * Observe that the default name is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when MyName is not none
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool DefaultFNameIsNotNone()
	{
		return !MyName.IsNone();
	}

	/**
	 * Observe that clearing this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier cleared, compared against a second carrier
	 * @Return true when this carrier is none and the other keeps the default
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool DefaultFNameInstancesAreIndependent()
	{
		UDefaultFNameCarrier Other =
			Cast<UDefaultFNameCarrier>(
				NewObject(GetTransientPackage(), UDefaultFNameCarrier::StaticClass(), n"DefaultFNameCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_DefaultFNamePropertyApplied setup: NewObject returned null");
		}

		MyName = NAME_None;

		if (!MyName.IsNone())
		{
			return false;
		}

		return Other.MyName == n"TestName";
	}
}
/** @end */
/**
 * @begin default-tags-add-executed-on-c-d-o
 * @summary `default` statements that call Tags.Add on the CDO. The verifier returns distinct codes so a failure names which tag is missing.
 * @topic Reflection
 */
UCLASS()
class ADefaultTagsActor : AActor
{
	default Tags.Add(n"Alpha");
	default Tags.Add(n"Beta");

	/**
	 * Verifies that both default tags were added.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the actor's Tags array
	 * @Return 42 when both tags are present, otherwise 1, 2 or 3
	 */
	UFUNCTION()
	int VerifyTags()
	{
		if (!Tags.Contains(n"Alpha"))
		{
			return 1;
		}
		if (!Tags.Contains(n"Beta"))
		{
			return 2;
		}
		if (Tags.Num() < 2)
		{
			return 3;
		}
		return 42;
	}

	/**
	 * Observe that both default tags were applied to the CDO.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when verification returns 42
	 */
	UFUNCTION()
	bool DefaultTagsVerifyPasses()
	{
		return VerifyTags() == 42;
	}

	/**
	 * Observe the boundary where the tags have been cleared.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Tags emptied
	 * @Return true when verification returns 1
	 * @Boundary cleared tags
	 */
	UFUNCTION()
	bool DefaultTagsClearedFailsVerification()
	{
		Tags.Empty();
		return VerifyTags() == 1;
	}
}
/** @end */
/**
 * @begin float-container-properties
 * @summary Float and double members inside TArray and TMap containers, filled during BeginPlay. The observers confirm the defaults are empty and that a script-side fill lands the expected values.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatContainerActor : AActor
{
	UPROPERTY()
	TArray<float> FloatArray;

	UPROPERTY()
	TArray<double> DoubleArray;

	UPROPERTY()
	TMap<int, float> IntToFloatMap;

	UPROPERTY()
	TMap<FString, double> StringToDoubleMap;

	/**
	 * Fills every container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all four containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FloatArray.Add(1.1f);
		FloatArray.Add(2.2f);
		FloatArray.Add(3.3f);

		DoubleArray.Add(4.4);
		DoubleArray.Add(5.5);

		IntToFloatMap.Add(10, 100.5f);
		IntToFloatMap.Add(20, 200.5f);

		StringToDoubleMap.Add("Pi", 3.141592653589793);
		StringToDoubleMap.Add("E", 2.718281828459045);
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatContainersDefaultToEmpty()
	{
		if (FloatArray.Num() != 0)
		{
			return false;
		}

		if (DoubleArray.Num() != 0)
		{
			return false;
		}

		if (IntToFloatMap.Num() != 0)
		{
			return false;
		}

		return StringToDoubleMap.Num() == 0;
	}

	/**
	 * Observe that a script-side fill lands the expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both arrays filled from script
	 * @Return true when both counts and first elements match
	 * @Boundary script fill
	 */
	UFUNCTION()
	bool FloatContainersScriptFillBoundary()
	{
		FloatArray.Add(1.1f);
		FloatArray.Add(2.2f);
		FloatArray.Add(3.3f);
		DoubleArray.Add(4.4);
		DoubleArray.Add(5.5);

		if (FloatArray.Num() != 3)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatArray[0], 1.1, 0.001))
		{
			return false;
		}

		if (DoubleArray.Num() != 2)
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleArray[0], 4.4, 0.001);
	}
}
/** @end */
/**
 * @begin float-family-boundary-values
 * @summary Float and double extremes assigned from script: the smallest positive denormal-adjacent values and the largest finite values. The observers confirm the defaults are zero before any write and that both extremes stick.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatBoundaryActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties default to zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatBoundaryDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that the smallest and largest finite values round-trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both properties written with their smallest and largest values
	 * @Return true when the minima are positive and the maxima are huge
	 * @Boundary extreme values
	 */
	UFUNCTION()
	bool FloatBoundaryScriptMinMax()
	{
		FloatValue = 1.17549435e-38f;
		DoubleValue = 2.2250738585072014e-308;
		bool bMin = FloatValue > 0.0f && DoubleValue > 0.0;
		FloatValue = 3.40282347e+38f;
		DoubleValue = 1.7976931348623157e+308;

		if (!bMin)
		{
			return false;
		}

		if (FloatValue <= 1.0e+38f)
		{
			return false;
		}

		return DoubleValue > 1.0e+308;
	}
}
/** @end */
/**
 * @begin float-family-declaration-defaults
 * @summary Float and double UPROPERTY defaults: two left uninitialized and two carrying initializers. The observers confirm both groups hold their expected values.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatDefaultsActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	UPROPERTY()
	float InitializedFloat = 1.25f;

	UPROPERTY()
	double InitializedDouble = 2.5;

	/**
	 * Observe that the uninitialized properties read as zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both uninitialised values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatDefaultsUninitializedZero()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that the initialized properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.25 and 2.5
	 * @Boundary initialized values
	 */
	UFUNCTION()
	bool FloatDefaultsInitializedBoundary()
	{
		if (!Math::IsNearlyEqual(InitializedFloat, 1.25))
		{
			return false;
		}

		return Math::IsNearlyEqual(InitializedDouble, 2.5);
	}
}
/** @end */
/**
 * @begin float-family-special-values
 * @summary NaN and infinity handling on float and double UPROPERTYs. The C++ runner writes each special through SetByPath and reads it back through VerifyByPath; the observers confirm the defaults are finite before any write.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatSpecialActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties start finite and zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are finite, zero and not NaN
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatSpecialDefaultFiniteEmpty()
	{
		if (!Math::IsFinite(FloatValue))
		{
			return false;
		}

		if (!Math::IsFinite(DoubleValue))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DoubleValue, 0.0))
		{
			return false;
		}

		if (Math::IsNaN(FloatValue))
		{
			return false;
		}

		return !Math::IsNaN(DoubleValue);
	}
}
/** @end */
/**
 * @begin float-family-write-round-trip
 * @summary Script-side writes to float and double UPROPERTYs, first positive then negative. The observers confirm the defaults and that both polarities round-trip.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatWriteActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties default to zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatWriteDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that positive then negative writes both round-trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both properties written positive then negative
	 * @Return true when all four reads match their written values
	 * @Boundary both polarities
	 */
	UFUNCTION()
	bool FloatWriteScriptRoundTripBoundary()
	{
		FloatValue = 3.14159f;
		DoubleValue = 1.4142135623730951;

		if (!Math::IsNearlyEqual(FloatValue, 3.14159, 0.00001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DoubleValue, 1.4142135623730951, 0.00001))
		{
			return false;
		}

		FloatValue = -2.71828f;
		DoubleValue = -1.7320508075688772;

		if (!Math::IsNearlyEqual(FloatValue, -2.71828, 0.00001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, -1.7320508075688772, 0.00001);
	}
}
/** @end */
/**
 * @begin float-property-script-mutation-round-trip
 * @summary UFUNCTIONs mutating float and double UPROPERTYs: a paired assign and two accumulating adds. The observers confirm the defaults, the nominal accumulate-after-assign sequence, and the zero-delta boundary.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatScriptMutationActor : AActor
{
	UPROPERTY()
	float FloatValue = 1.5f;

	UPROPERTY()
	double DoubleValue = 2.25;

	/**
	 * Assigns both properties at once.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the new values
	 * @Return nothing; both properties are overwritten
	 * @Param NewFloat the new float value
	 * @Param NewDouble the new double value
	 */
	UFUNCTION()
	void AssignValues(float NewFloat, double NewDouble)
	{
		FloatValue = NewFloat;
		DoubleValue = NewDouble;
	}

	/**
	 * Adds a delta to the float property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the delta to add
	 * @Return the updated float value
	 * @Param Delta the delta to add
	 */
	UFUNCTION()
	float AddToFloat(float Delta)
	{
		FloatValue += Delta;
		return FloatValue;
	}

	/**
	 * Adds a delta to the double property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the delta to add
	 * @Return the updated double value
	 * @Param Delta the delta to add
	 */
	UFUNCTION()
	double AddToDouble(double Delta)
	{
		DoubleValue += Delta;
		return DoubleValue;
	}

	/**
	 * Observe that both properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.5 and 2.25
	 * @Boundary default values
	 */
	UFUNCTION()
	bool FloatMutationDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 1.5))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 2.25);
	}

	/**
	 * Observe the assign-then-accumulate sequence.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AssignValues followed by both adds
	 * @Return true when both returns and both properties match
	 */
	UFUNCTION()
	bool FloatMutationNominal()
	{
		AssignValues(12.5f, 42.75);
		float AddedF = AddToFloat(0.25f);
		double AddedD = AddToDouble(0.125);

		if (!Math::IsNearlyEqual(AddedF, 12.75, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatValue, 12.75, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(AddedD, 42.875, 0.0001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 42.875, 0.0001);
	}

	/**
	 * Observe that a zero delta leaves the assigned values unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AssignValues followed by zero deltas
	 * @Return true when both returns equal the assigned values
	 * @Boundary zero delta
	 */
	UFUNCTION()
	bool FloatMutationZeroDeltaBoundary()
	{
		AssignValues(12.5f, 42.75);
		float AddedF = AddToFloat(0.0f);
		double AddedD = AddToDouble(0.0);

		if (!Math::IsNearlyEqual(AddedF, 12.5, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AddedD, 42.75, 0.001);
	}
}
/** @end */
/**
 * @begin float-replicated-properties
 * @summary Replicated float and double UPROPERTYs: two plain Replicated members and two ReplicatedUsing members wired to OnRep handlers. The observers confirm the initializers and the zero-assignment boundary.
 * @topic Reflection
 */
UCLASS()
class ACoverageFloatReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	float ReplicatedFloat = 1.25f;

	UPROPERTY(Replicated)
	double ReplicatedDouble = 2.5;

	UPROPERTY(ReplicatedUsing=OnRep_RepNotifyFloat)
	float RepNotifyFloat = 3.75f;

	UPROPERTY(ReplicatedUsing=OnRep_PreciseValue)
	double PreciseValue = 4.5;

	/**
	 * The replication callback wired to RepNotifyFloat.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_RepNotifyFloat()
	{
	}

	/**
	 * The replication callback wired to PreciseValue.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_PreciseValue()
	{
	}

	/**
	 * Observe that all four replicated properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.25, 2.5, 3.75 and 4.5
	 * @Boundary default values
	 */
	UFUNCTION()
	bool FloatReplicationDefaultValues()
	{
		if (!Math::IsNearlyEqual(ReplicatedFloat, 1.25))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(ReplicatedDouble, 2.5))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(RepNotifyFloat, 3.75))
		{
			return false;
		}

		return Math::IsNearlyEqual(PreciseValue, 4.5);
	}

	/**
	 * Observe that a zero assignment overwrites the initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both plain replicated members set to zero
	 * @Return true when both read zero
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool FloatReplicationZeroAssignBoundary()
	{
		ReplicatedFloat = 0.0f;
		ReplicatedDouble = 0.0;

		if (!Math::IsNearlyEqual(ReplicatedFloat, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(ReplicatedDouble, 0.0);
	}
}
/** @end */
/**
 * @begin f-quat-class-member-runtime-flow
 * @summary FQuat class-member runtime flow: a quarter turn is assigned, copied, inverted and used to rotate a vector, with each intermediate recorded in a history array and three boolean outcomes.
 * @topic Reflection
 */
UCLASS()
class ACoverageFQuatRuntimeFlowActor : AActor
{
	UPROPERTY()
	FQuat CurrentQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CopyConstructedQuat;

	UPROPERTY()
	FQuat AssignedQuat;

	UPROPERTY()
	FQuat InverseQuat;

	UPROPERTY()
	FVector RotatedForward;

	UPROPERTY()
	TArray<FQuat> History;

	UPROPERTY()
	bool bCopyEqualsAssigned = false;

	UPROPERTY()
	bool bInverseComposesToIdentity = false;

	UPROPERTY()
	bool bHistoryPreservesValues = false;

	/**
	 * Runs the copy, assign, invert and rotate sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; every member records the flow's outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		const FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		CurrentQuat = LocalTurn;
		CopyConstructedQuat = FQuat(CurrentQuat);
		AssignedQuat = FQuat::Identity;
		AssignedQuat = CopyConstructedQuat;
		InverseQuat = CurrentQuat.Inverse();
		RotatedForward = CurrentQuat.RotateVector(FVector::ForwardVector);

		History.Add(FQuat::Identity);
		History.Add(CurrentQuat);
		History.Add(InverseQuat);

		bCopyEqualsAssigned = CopyConstructedQuat == AssignedQuat;
		bInverseComposesToIdentity = (CurrentQuat * InverseQuat).IsIdentity(0.001);
		bHistoryPreservesValues = History.Num() == 3
			&& History[1].Equals(CurrentQuat, 0.001)
			&& History[2].Equals(InverseQuat, 0.001);
	}

	/**
	 * Observe that a locally constructed actor starts untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the current is identity, history is empty and flags are false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatRuntimeFlowDefaultEmpty()
	{
		if (!CurrentQuat.IsIdentity(0.001))
		{
			return false;
		}

		if (History.Num() != 0)
		{
			return false;
		}

		if (bCopyEqualsAssigned)
		{
			return false;
		}

		if (bInverseComposesToIdentity)
		{
			return false;
		}

		return !bHistoryPreservesValues;
	}

	/**
	 * Observe that copy and assignment produce equal quaternions.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local turn assigned, copied and re-assigned
	 * @Return true when the copy equals the assignment and the current keeps the turn
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FQuatRuntimeFlowCopyIndependenceHint()
	{
		FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		CurrentQuat = LocalTurn;
		CopyConstructedQuat = FQuat(CurrentQuat);
		AssignedQuat = CopyConstructedQuat;

		if (!CopyConstructedQuat.Equals(AssignedQuat, 0.001))
		{
			return false;
		}

		return CurrentQuat.Equals(LocalTurn, 0.001);
	}
}
/** @end */
/**
 * @begin f-quat-container-properties
 * @summary FQuat members inside TArray and TMap containers, filled during BeginPlay. The observers confirm the defaults are empty and that a script-side fill lands the identity and yawed values.
 * @topic Reflection
 */
UCLASS()
class ACoverageFQuatContainerActor : AActor
{
	UPROPERTY()
	TArray<FQuat> QuatArray;

	UPROPERTY()
	TMap<int, FQuat> IntToQuatMap;

	/**
	 * Fills both containers with their oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		QuatArray.Add(FQuat::Identity);
		QuatArray.Add(FQuat(FRotator(0, 90, 0)));
		QuatArray.Add(FQuat(FRotator(90, 0, 0)));

		IntToQuatMap.Add(1, FQuat::Identity);
		IntToQuatMap.Add(2, FQuat(FRotator(0, 45, 0)));
		IntToQuatMap.Add(3, FQuat(FRotator(45, 0, 0)));
	}

	/**
	 * Observe that a locally constructed actor leaves both containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatContainersDefaultToEmpty()
	{
		if (QuatArray.Num() != 0)
		{
			return false;
		}

		return IntToQuatMap.Num() == 0;
	}

	/**
	 * Observe that a script-side fill lands the expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both containers filled from script
	 * @Return true when the count, identity and yawed entries match
	 * @Boundary script fill
	 */
	UFUNCTION()
	bool FQuatContainersScriptFillBoundary()
	{
		QuatArray.Add(FQuat::Identity);
		QuatArray.Add(FQuat(FRotator(0, 90, 0)));
		IntToQuatMap.Add(1, FQuat::Identity);

		if (QuatArray.Num() != 2)
		{
			return false;
		}

		if (!QuatArray[0].Equals(FQuat::Identity, 0.001))
		{
			return false;
		}

		if (Math::Abs(QuatArray[1].Z) <= 0.5)
		{
			return false;
		}

		return IntToQuatMap[1].Equals(FQuat::Identity, 0.001);
	}
}
/** @end */
/**
 * @begin f-quat-declaration-defaults
 * @summary FQuat UPROPERTY defaults: an explicit identity, a constructor expression, a property with no initializer, and one built from a rotator. The observers confirm the identity default and the uninitialized fallback.
 * @topic Reflection
 */
UCLASS()
class ACoverageFQuatDefaultsActor : AActor
{
	UPROPERTY()
	FQuat IdentityQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CustomQuat = FQuat(0, 0, 0.707107, 0.707107);

	UPROPERTY()
	FQuat NoDefaultQuat;

	UPROPERTY()
	FQuat FromRotator = FQuat(FRotator(0, 90, 0));

	/**
	 * Observe that the explicit identity default materializes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when IdentityQuat is the identity
	 * @Boundary identity default
	 */
	UFUNCTION()
	bool FQuatDefaultsIdentity()
	{
		if (!Math::IsNearlyEqual(IdentityQuat.X, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(IdentityQuat.Y, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(IdentityQuat.Z, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(IdentityQuat.W, 1.0);
	}

	/**
	 * Observe that an uninitialized FQuat falls back to identity.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when NoDefaultQuat is the identity
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatDefaultsNoDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(NoDefaultQuat.X, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(NoDefaultQuat.W, 1.0);
	}
}
/** @end */
/**
 * @begin f-quat-write-round-trip
 * @summary Component-wise writes to an FQuat UPROPERTY. The observers confirm the default identity-like state and that each component write sticks.
 * @topic Reflection
 */
UCLASS()
class ACoverageFQuatWriteActor : AActor
{
	UPROPERTY()
	FQuat QuatValue;

	/**
	 * Observe that the property defaults to the identity-like state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the value is 0,0,0,1
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatWriteDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(QuatValue.X, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Y, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Z, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(QuatValue.W, 1.0);
	}

	/**
	 * Observe that script-side component writes all stick.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four components written from script
	 * @Return true when all four components read back
	 * @Boundary component writes
	 */
	UFUNCTION()
	bool FQuatWriteScriptComponentBoundary()
	{
		QuatValue.X = 0.1;
		QuatValue.Y = 0.2;
		QuatValue.Z = 0.3;
		QuatValue.W = 0.9;

		if (!Math::IsNearlyEqual(QuatValue.X, 0.1))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Y, 0.2))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Z, 0.3))
		{
			return false;
		}

		return Math::IsNearlyEqual(QuatValue.W, 0.9);
	}
}
/** @end */
/**
 * @begin geometric-struct-reflection-properties-and-containers
 * @summary Geometric structs under reflection: FBox and FPlane as UPROPERTY defaults, and both inside TArray and TMap containers filled during BeginPlay.
 * @topic Reflection
 */
UCLASS()
class ACoverageMathGeometricStructActor : AActor
{
	UPROPERTY()
	FBox BoxValue = FBox(FVector(-1, -2, -3), FVector(4, 5, 6));

	UPROPERTY()
	FPlane PlaneValue = FPlane(FVector(0, 0, 10), FVector(0, 0, 1));

	UPROPERTY()
	TArray<FBox> BoxArray;

	UPROPERTY()
	TArray<FPlane> PlaneArray;

	UPROPERTY()
	TMap<int, FBox> BoxMap;

	/**
	 * Fills every geometric container.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the arrays and map receive their oracle values
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BoxArray.Add(FBox(FVector(1, 2, 3), FVector(4, 5, 6)));
		BoxArray.Add(FBox(FVector(-10, -20, -30), FVector(-1, -2, -3)));

		PlaneArray.Add(FPlane(FVector(0, 0, 8), FVector(0, 0, 1)));
		PlaneArray.Add(FPlane(FVector(2, 0, 0), FVector(1, 0, 0)));

		BoxMap.Add(7, FBox(FVector(10, 20, 30), FVector(40, 50, 60)));
		BoxMap.Add(8, FBox(FVector(-4, -5, -6), FVector(-1, -2, -3)));
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GeometricStructDefaultEmptyContainers()
	{
		if (BoxArray.Num() != 0)
		{
			return false;
		}

		if (PlaneArray.Num() != 0)
		{
			return false;
		}

		return BoxMap.Num() == 0;
	}

	/**
	 * Observe that the box default survived reflection.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the BoxValue default
	 * @Return true when Min and Max equal their declared corners
	 */
	UFUNCTION()
	bool GeometricStructBoxDefault()
	{
		if (!BoxValue.Min.Equals(FVector(-1, -2, -3), 0.001))
		{
			return false;
		}

		return BoxValue.Max.Equals(FVector(4, 5, 6), 0.001);
	}

	/**
	 * Observe the container counts after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then all three containers
	 * @Return true when all three counts are 2
	 */
	UFUNCTION()
	bool GeometricStructAfterBeginPlay()
	{
		BeginPlay();

		if (BoxArray.Num() != 2)
		{
			return false;
		}

		if (PlaneArray.Num() != 2)
		{
			return false;
		}

		return BoxMap.Num() == 2;
	}
}
/** @end */
/**
 * @begin int-container-edge-cases
 * @summary Empty, single-element, modified, overwritten and deduplicated int containers: an array trimmed by RemoveAt, a map whose key is overwritten, and a set that ignores a duplicate add.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntContainerEdgeActor : AActor
{
	UPROPERTY()
	TArray<int> EmptyArray;

	UPROPERTY()
	TArray<int> SingleElementArray;

	UPROPERTY()
	TArray<int> ModifiedArray;

	UPROPERTY()
	TMap<int, int> EmptyMap;

	UPROPERTY()
	TMap<int, int> SingleEntryMap;

	UPROPERTY()
	TMap<int, int> OverwriteMap;

	UPROPERTY()
	TSet<int> EmptySet;

	UPROPERTY()
	TSet<int> SingleElementSet;

	UPROPERTY()
	TSet<int> DuplicateSet;

	/**
	 * Populates the single, modified, overwritten and deduplicated containers.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the containers hold their edge-case shapes
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Empty containers - no action

		// Single element
		SingleElementArray.Add(42);
		SingleEntryMap.Add(1, 100);
		SingleElementSet.Add(99);

		// Modified array - add then remove
		ModifiedArray.Add(1);
		ModifiedArray.Add(2);
		ModifiedArray.Add(3);
		ModifiedArray.RemoveAt(1);  // Remove middle element

		// Map overwrite
		OverwriteMap.Add(10, 100);
		OverwriteMap.Add(10, 200);  // Overwrite existing key

		// Set with duplicates
		DuplicateSet.Add(5);
		DuplicateSet.Add(10);
		DuplicateSet.Add(5);  // Duplicate - should be ignored
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all nine containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainerEdgeDefaultEmpty()
	{
		if (EmptyArray.Num() != 0)
		{
			return false;
		}

		if (SingleElementArray.Num() != 0)
		{
			return false;
		}

		if (ModifiedArray.Num() != 0)
		{
			return false;
		}

		if (EmptyMap.Num() != 0)
		{
			return false;
		}

		if (SingleEntryMap.Num() != 0)
		{
			return false;
		}

		if (OverwriteMap.Num() != 0)
		{
			return false;
		}

		if (EmptySet.Num() != 0)
		{
			return false;
		}

		if (SingleElementSet.Num() != 0)
		{
			return false;
		}

		return DuplicateSet.Num() == 0;
	}

	/**
	 * Observe the edge-case shapes after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then every container
	 * @Return true when every edge-case shape matches
	 */
	UFUNCTION()
	bool IntContainerEdgeShapesAfterBeginPlay()
	{
		BeginPlay();

		if (EmptyArray.Num() != 0)
		{
			return false;
		}

		if (SingleElementArray.Num() != 1)
		{
			return false;
		}

		if (SingleElementArray[0] != 42)
		{
			return false;
		}

		if (ModifiedArray.Num() != 2)
		{
			return false;
		}

		if (ModifiedArray[0] != 1)
		{
			return false;
		}

		if (EmptyMap.Num() != 0)
		{
			return false;
		}

		if (SingleEntryMap[1] != 100)
		{
			return false;
		}

		if (OverwriteMap[10] != 200)
		{
			return false;
		}

		if (EmptySet.Num() != 0)
		{
			return false;
		}

		if (!SingleElementSet.Contains(99))
		{
			return false;
		}

		if (DuplicateSet.Num() != 2)
		{
			return false;
		}

		if (!DuplicateSet.Contains(5))
		{
			return false;
		}

		return DuplicateSet.Contains(10);
	}
}
/** @end */
/**
 * @begin int-container-properties
 * @summary Int-family members inside TArray and TMap containers, filled during BeginPlay: three int lanes, an int64 lane, a byte lane, and two maps keyed by int.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntContainerActor : AActor
{
	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	TArray<int64> Int64Array;

	UPROPERTY()
	TArray<uint8> ByteArray;

	UPROPERTY()
	TMap<int, int> IntToIntMap;

	UPROPERTY()
	TMap<int, FString> IntToStringMap;

	/**
	 * Fills every container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all five containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		IntArray.Add(10);
		IntArray.Add(20);
		IntArray.Add(30);

		Int64Array.Add(1000000000000);
		Int64Array.Add(2000000000000);

		ByteArray.Add(1);
		ByteArray.Add(255);

		IntToIntMap.Add(1, 100);
		IntToIntMap.Add(2, 200);

		IntToStringMap.Add(7, "Seven");
		IntToStringMap.Add(9, "Nine");
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all five containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainersDefaultToEmpty()
	{
		if (IntArray.Num() != 0)
		{
			return false;
		}

		if (Int64Array.Num() != 0)
		{
			return false;
		}

		if (ByteArray.Num() != 0)
		{
			return false;
		}

		if (IntToIntMap.Num() != 0)
		{
			return false;
		}

		return IntToStringMap.Num() == 0;
	}

	/**
	 * Observe the populated state after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then every container
	 * @Return true when every count and element matches
	 */
	UFUNCTION()
	bool IntContainersPopulatedAfterBeginPlay()
	{
		BeginPlay();

		if (IntArray.Num() != 3)
		{
			return false;
		}

		if (IntArray[0] != 10)
		{
			return false;
		}

		if (IntArray[2] != 30)
		{
			return false;
		}

		if (Int64Array[1] != 2000000000000)
		{
			return false;
		}

		if (ByteArray[1] != 255)
		{
			return false;
		}

		if (IntToIntMap.Num() != 2)
		{
			return false;
		}

		if (IntToIntMap[2] != 200)
		{
			return false;
		}

		return IntToStringMap[9] == "Nine";
	}
}
/** @end */
/**
 * @begin int-container-properties-extended
 * @summary The remaining int widths inside arrays, maps and sets: int8 through uint64, signed and unsigned, including extreme values like 127 and 65535.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntContainerExtActor : AActor
{
	UPROPERTY()
	TArray<int8> Int8Array;

	UPROPERTY()
	TArray<int16> Int16Array;

	UPROPERTY()
	TArray<uint16> UInt16Array;

	UPROPERTY()
	TArray<uint> UIntArray;

	UPROPERTY()
	TArray<uint64> UInt64Array;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	UPROPERTY()
	TMap<int8, FString> Int8ToStringMap;

	UPROPERTY()
	TMap<int64, FString> Int64ToStringMap;

	UPROPERTY()
	TMap<uint, FString> UIntToStringMap;

	UPROPERTY()
	TSet<int> IntSet;

	UPROPERTY()
	TSet<int8> Int8Set;

	UPROPERTY()
	TSet<int64> Int64Set;

	UPROPERTY()
	TSet<uint> UIntSet;

	/**
	 * Fills every remaining-width container with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all thirteen containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Int8Array.Add(-42);
		Int8Array.Add(127);

		Int16Array.Add(-12345);
		Int16Array.Add(30000);

		UInt16Array.Add(60000);
		UInt16Array.Add(65535);

		UIntArray.Add(3000000000);
		UIntArray.Add(4000000000);

		UInt64Array.Add(10000000000000000000);

		StringToIntMap.Add("Alpha", 100);
		StringToIntMap.Add("Beta", 200);

		Int8ToStringMap.Add(-10, "NegTen");
		Int8ToStringMap.Add(127, "MaxInt8");

		Int64ToStringMap.Add(9000000000, "Billion");
		Int64ToStringMap.Add(-9000000000, "NegBillion");

		UIntToStringMap.Add(3000000000, "Three");
		UIntToStringMap.Add(4000000000, "Four");

		IntSet.Add(5);
		IntSet.Add(10);
		IntSet.Add(15);

		Int8Set.Add(-42);
		Int8Set.Add(0);
		Int8Set.Add(127);

		Int64Set.Add(1000000000000);
		Int64Set.Add(2000000000000);

		UIntSet.Add(3000000000);
		UIntSet.Add(4000000000);
	}

	/**
	 * Observe that a locally constructed actor leaves the containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the sampled containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainerExtDefaultEmpty()
	{
		if (Int8Array.Num() != 0)
		{
			return false;
		}

		if (StringToIntMap.Num() != 0)
		{
			return false;
		}

		return IntSet.Num() == 0;
	}

	/**
	 * Observe the populated state after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the sampled containers
	 * @Return true when every sampled element matches
	 */
	UFUNCTION()
	bool IntContainerExtPopulatedAfterBeginPlay()
	{
		BeginPlay();

		if (Int8Array[0] != -42)
		{
			return false;
		}

		if (Int8Array[1] != 127)
		{
			return false;
		}

		if (Int16Array[0] != -12345)
		{
			return false;
		}

		if (Int16Array[1] != 30000)
		{
			return false;
		}

		if (UInt16Array[0] != 60000)
		{
			return false;
		}

		if (UInt16Array[1] != 65535)
		{
			return false;
		}

		if (UIntArray[0] != 3000000000)
		{
			return false;
		}

		if (UIntArray[1] != 4000000000)
		{
			return false;
		}

		if (StringToIntMap["Alpha"] != 100)
		{
			return false;
		}

		if (Int8ToStringMap[127] != "MaxInt8")
		{
			return false;
		}

		if (!IntSet.Contains(10))
		{
			return false;
		}

		return Int8Set.Contains(0);
	}
}
/** @end */
/**
 * @begin int-container-width-completion
 * @summary Width completion for TMap and TSet: every int width not covered by the other container themes, both as map value, map key and set element.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntContainerWidthsActor : AActor
{
	UPROPERTY()
	TMap<FString, int8> StringToInt8Map;

	UPROPERTY()
	TMap<FString, int16> StringToInt16Map;

	UPROPERTY()
	TMap<FString, int64> StringToInt64Map;

	UPROPERTY()
	TMap<FString, uint8> StringToUInt8Map;

	UPROPERTY()
	TMap<FString, uint16> StringToUInt16Map;

	UPROPERTY()
	TMap<FString, uint> StringToUIntMap;

	UPROPERTY()
	TMap<FString, uint64> StringToUInt64Map;

	UPROPERTY()
	TMap<int16, FString> Int16ToStringMap;

	UPROPERTY()
	TMap<uint8, FString> UInt8ToStringMap;

	UPROPERTY()
	TMap<uint16, FString> UInt16ToStringMap;

	UPROPERTY()
	TMap<uint64, FString> UInt64ToStringMap;

	UPROPERTY()
	TSet<int16> Int16Set;

	UPROPERTY()
	TSet<uint8> UInt8Set;

	UPROPERTY()
	TSet<uint16> UInt16Set;

	UPROPERTY()
	TSet<uint64> UInt64Set;

	/**
	 * Fills every width-completion map and set with its oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all sixteen containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringToInt8Map.Add("Int8", -12);
		StringToInt16Map.Add("Int16", -1234);
		StringToInt64Map.Add("Int64", -9000000000);
		StringToUInt8Map.Add("UInt8", 250);
		StringToUInt16Map.Add("UInt16", 60000);
		StringToUIntMap.Add("UInt", 3000000000);
		StringToUInt64Map.Add("UInt64", 12000000000000000000);

		Int16ToStringMap.Add(-1234, "Int16Key");
		UInt8ToStringMap.Add(250, "UInt8Key");
		UInt16ToStringMap.Add(60000, "UInt16Key");
		UInt64ToStringMap.Add(12000000000000000000, "UInt64Key");

		Int16Set.Add(-1234);
		Int16Set.Add(30000);
		UInt8Set.Add(1);
		UInt8Set.Add(250);
		UInt16Set.Add(60000);
		UInt16Set.Add(65535);
		UInt64Set.Add(10000000000000000000);
		UInt64Set.Add(12000000000000000000);
	}

	/**
	 * Observe that a locally constructed actor leaves the maps and sets empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the sampled containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainerWidthsDefaultEmpty()
	{
		if (StringToInt8Map.Num() != 0)
		{
			return false;
		}

		if (Int16Set.Num() != 0)
		{
			return false;
		}

		return UInt64Set.Num() == 0;
	}

	/**
	 * Observe the populated state after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the sampled containers
	 * @Return true when every sampled entry matches
	 */
	UFUNCTION()
	bool IntContainerWidthsPopulatedAfterBeginPlay()
	{
		BeginPlay();

		if (StringToInt8Map["Int8"] != -12)
		{
			return false;
		}

		if (StringToInt16Map["Int16"] != -1234)
		{
			return false;
		}

		if (StringToInt64Map["Int64"] != -9000000000)
		{
			return false;
		}

		if (StringToUInt8Map["UInt8"] != 250)
		{
			return false;
		}

		if (Int16ToStringMap[-1234] != "Int16Key")
		{
			return false;
		}

		return UInt8Set.Contains(250);
	}
}
/** @end */
/**
 * @begin int-family-boundary-values
 * @summary The int family's numeric min and max values surviving reflection: every signed width's minimum, then every width's maximum, on eight UPROPERTYs.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntBoundaryActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	/**
	 * Writes each signed width's minimum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their minima
	 */
	UFUNCTION()
	void WriteSignedMins()
	{
		Int8Value = -128;
		Int16Value = -32768;
		IntValue = -2147483647 - 1;
		Int64Value = int64(-9223372036854775807) - 1;
	}

	/**
	 * Writes each signed width's maximum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their maxima
	 */
	UFUNCTION()
	void WriteSignedMaxes()
	{
		Int8Value = 127;
		Int16Value = 32767;
		IntValue = 2147483647;
		Int64Value = 9223372036854775807;
	}

	/**
	 * Writes each unsigned width's maximum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four unsigned UPROPERTYs hold their maxima
	 */
	UFUNCTION()
	void WriteUnsignedMaxes()
	{
		UInt8Value = 255;
		UInt16Value = 65535;
		UInt32Value = 4294967295;
		UInt64Value = 18446744073709551615;
	}

	/**
	 * Observe that a locally constructed actor holds the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the first and last properties are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyBoundaryDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		return UInt64Value == 0;
	}

	/**
	 * Observe that the signed minima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteSignedMins() then the signed properties
	 * @Return true when all three lower widths hold their minima
	 * @Boundary signed minima
	 */
	UFUNCTION()
	bool IntFamilyBoundarySignedMins()
	{
		WriteSignedMins();

		if (Int8Value != -128)
		{
			return false;
		}

		if (Int16Value != -32768)
		{
			return false;
		}

		return IntValue == -2147483647 - 1;
	}

	/**
	 * Observe that the unsigned maxima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteUnsignedMaxes() then the unsigned properties
	 * @Return true when all three lower widths hold their maxima
	 * @Boundary unsigned maxima
	 */
	UFUNCTION()
	bool IntFamilyBoundaryUnsignedMaxes()
	{
		WriteUnsignedMaxes();

		if (UInt8Value != 255)
		{
			return false;
		}

		if (UInt16Value != 65535)
		{
			return false;
		}

		return UInt32Value == 4294967295;
	}
}
/** @end */
/**
 * @begin int-family-declaration-defaults
 * @summary The int family's UPROPERTY declaration defaults across all eight widths, read from the CDO without running BeginPlay.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntDefaultsActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 100;

	UPROPERTY()
	int16 Int16Value = 30000;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = 10000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UInt32Value = 123456;

	UPROPERTY()
	uint64 UInt64Value = 123456;

	/**
	 * Observe that all eight declaration defaults are readable without BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight widths hold their declared defaults
	 */
	UFUNCTION()
	bool IntFamilyDeclarationDefaultsNominal()
	{
		if (Int8Value != 100)
		{
			return false;
		}

		if (Int16Value != 30000)
		{
			return false;
		}

		if (IntValue != 123456)
		{
			return false;
		}

		if (Int64Value != 10000000000)
		{
			return false;
		}

		if (UInt8Value != 250)
		{
			return false;
		}

		if (UInt16Value != 60000)
		{
			return false;
		}

		if (UInt32Value != 123456)
		{
			return false;
		}

		return UInt64Value == 123456;
	}
}
/** @end */
/**
 * @begin int-family-implicit-and-explicit-zero-defaults
 * @summary Implicit zero defaults beside explicit ones: eight UPROPERTYs with no initializer, plus an explicit zero, a negative, and two large defaults.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntZeroDefaultsActor : AActor
{
	UPROPERTY()
	int8 NoDefaultInt8;

	UPROPERTY()
	int16 NoDefaultInt16;

	UPROPERTY()
	int NoDefaultInt;

	UPROPERTY()
	int64 NoDefaultInt64;

	UPROPERTY()
	uint8 NoDefaultUInt8;

	UPROPERTY()
	uint16 NoDefaultUInt16;

	UPROPERTY()
	uint NoDefaultUInt;

	UPROPERTY()
	uint64 NoDefaultUInt64;

	UPROPERTY()
	int ExplicitZero = 0;

	UPROPERTY()
	int8 NegativeDefault = -100;

	UPROPERTY()
	int LargeDefault = 2147483647;

	UPROPERTY()
	uint64 LargeUnsignedDefault = 18000000000000000000;

	/**
	 * Observe that every uninitialized property reads as zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight NoDefault fields and the explicit zero read 0
	 * @Boundary implicit zero
	 */
	UFUNCTION()
	bool IntFamilyZeroDefaultsImplicitEmpty()
	{
		if (NoDefaultInt8 != 0)
		{
			return false;
		}

		if (NoDefaultInt16 != 0)
		{
			return false;
		}

		if (NoDefaultInt != 0)
		{
			return false;
		}

		if (NoDefaultInt64 != 0)
		{
			return false;
		}

		if (NoDefaultUInt8 != 0)
		{
			return false;
		}

		if (NoDefaultUInt16 != 0)
		{
			return false;
		}

		if (NoDefaultUInt != 0)
		{
			return false;
		}

		if (NoDefaultUInt64 != 0)
		{
			return false;
		}

		return ExplicitZero == 0;
	}

	/**
	 * Observe that the explicit defaults read back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the negative and both large defaults match
	 * @Boundary explicit defaults
	 */
	UFUNCTION()
	bool IntFamilyZeroDefaultsExplicitBoundary()
	{
		if (NegativeDefault != -100)
		{
			return false;
		}

		if (LargeDefault != 2147483647)
		{
			return false;
		}

		return LargeUnsignedDefault == 18000000000000000000;
	}
}
/** @end */
/**
 * @begin int-family-near-boundary-values
 * @summary Near-boundary values one step above each signed minimum: min+1 for each width, written through a script helper rather than reflection.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntNearBoundaryActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	/**
	 * Writes each signed width's minimum plus one.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the four signed UPROPERTYs hold their near-minima
	 */
	UFUNCTION()
	void WriteNearMins()
	{
		Int8Value = -127;
		Int16Value = -32767;
		IntValue = -2147483647;
		Int64Value = -9223372036854775807;
	}

	/**
	 * Observe that a locally constructed actor holds zeros.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the sampled properties are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyNearBoundaryDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		if (IntValue != 0)
		{
			return false;
		}

		return UInt8Value == 0;
	}

	/**
	 * Observe that the near-minima survive a write and read.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteNearMins() then the signed properties
	 * @Return true when all three lower widths hold min+1
	 * @Boundary near-minima
	 */
	UFUNCTION()
	bool IntFamilyNearBoundaryNominal()
	{
		WriteNearMins();

		if (Int8Value != -127)
		{
			return false;
		}

		if (Int16Value != -32767)
		{
			return false;
		}

		return IntValue == -2147483647;
	}
}
/** @end */
/**
 * @begin int-family-write-round-trip
 * @summary A write-and-read round trip across all eight int widths, with mixed signs and magnitudes, driven by a script helper.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntRoundTripActor : AActor
{
	UPROPERTY()
	int8 Int8Value = 0;

	UPROPERTY()
	int16 Int16Value = 0;

	UPROPERTY()
	int IntValue = 0;

	UPROPERTY()
	int64 Int64Value = 0;

	UPROPERTY()
	uint8 UInt8Value = 0;

	UPROPERTY()
	uint16 UInt16Value = 0;

	UPROPERTY()
	uint UInt32Value = 0;

	UPROPERTY()
	uint64 UInt64Value = 0;

	/**
	 * Writes every width's round-trip value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all eight UPROPERTYs hold their round-trip values
	 */
	UFUNCTION()
	void WriteRoundTripValues()
	{
		Int8Value = -42;
		Int16Value = -12345;
		IntValue = -987654;
		Int64Value = -9000000000;
		UInt8Value = 200;
		UInt16Value = 54321;
		UInt32Value = 3000000000;
		UInt64Value = 12000000000000000000;
	}

	/**
	 * Observe that a locally constructed actor holds the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight fields read 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntFamilyWriteRoundTripDefaultEmpty()
	{
		if (Int8Value != 0)
		{
			return false;
		}

		if (Int16Value != 0)
		{
			return false;
		}

		if (IntValue != 0)
		{
			return false;
		}

		if (Int64Value != 0)
		{
			return false;
		}

		if (UInt8Value != 0)
		{
			return false;
		}

		if (UInt16Value != 0)
		{
			return false;
		}

		if (UInt32Value != 0)
		{
			return false;
		}

		return UInt64Value == 0;
	}

	/**
	 * Observe the values after the write round trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteRoundTripValues() then all eight fields
	 * @Return true when all eight values match
	 */
	UFUNCTION()
	bool IntFamilyWriteRoundTripNominal()
	{
		WriteRoundTripValues();

		if (Int8Value != -42)
		{
			return false;
		}

		if (Int16Value != -12345)
		{
			return false;
		}

		if (IntValue != -987654)
		{
			return false;
		}

		if (Int64Value != -9000000000)
		{
			return false;
		}

		if (UInt8Value != 200)
		{
			return false;
		}

		if (UInt16Value != 54321)
		{
			return false;
		}

		if (UInt32Value != 3000000000)
		{
			return false;
		}

		return UInt64Value == 12000000000000000000;
	}
}
/** @end */
/**
 * @begin int-property-script-read-write-api-surface
 * @summary The script-facing read/write API surface for int-family UPROPERTYs: a reader that sums all eight widths and a rewriter that replaces every value in place then sums again.
 * @topic Reflection
 */
UCLASS()
class ACoverageIntScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	int8 Int8Value = -1;

	UPROPERTY()
	int16 Int16Value = -2;

	UPROPERTY()
	int IntValue = -3;

	UPROPERTY()
	int64 Int64Value = -4;

	UPROPERTY()
	uint8 UInt8Value = 5;

	UPROPERTY()
	uint16 UInt16Value = 6;

	UPROPERTY()
	uint UIntValue = 7;

	UPROPERTY()
	uint64 UInt64Value = 8;

	/**
	 * Sums all eight widths as int.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs all eight UPROPERTYs
	 * @Return the widened sum of every value
	 */
	UFUNCTION()
	int ReadCurrentSum()
	{
		return int(Int8Value) + int(Int16Value) + IntValue + int(Int64Value)
			+ int(UInt8Value) + int(UInt16Value) + int(UIntValue) + int(UInt64Value);
	}

	/**
	 * Rewrites every width in place and returns the new sum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 0 once the eight new values cancel out
	 */
	UFUNCTION()
	int RewriteAndReadCurrentSum()
	{
		Int8Value = -8;
		Int16Value = -16;
		IntValue = -32;
		Int64Value = -64;
		UInt8Value = 8;
		UInt16Value = 16;
		UIntValue = 32;
		UInt64Value = 64;
		return ReadCurrentSum();
	}

	/**
	 * Observe the default sum without any rewrite.
	 *
	 * @Kind Observe
	 * @Inputs a freshly constructed actor
	 * @Return 16
	 * @Boundary default values
	 */
	UFUNCTION()
	int IntPropertyScriptApiDefaultSum()
	{
		return ReadCurrentSum();
	}

	/**
	 * Observe the rewritten state.
	 *
	 * @Kind Observe
	 * @Inputs RewriteAndReadCurrentSum() then the sampled properties
	 * @Return true when the sum is 0 and both sampled ends hold their new values
	 */
	UFUNCTION()
	bool IntPropertyScriptApiRewrite()
	{
		int After = RewriteAndReadCurrentSum();

		if (After != 0)
		{
			return false;
		}

		if (Int8Value != -8)
		{
			return false;
		}

		return UInt64Value == 64;
	}
}
/** @end */
/**
 * @begin int-struct-deep-nested-property-paths
 * @summary A three-level chain of nested USTRUCTs carrying integers, so reflection must walk Root.Middle.Inner to reach the deepest properties.
 * @topic Reflection
 */
/**
 * The innermost struct of the nested chain.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared inner struct with two widths
 */
USTRUCT()
struct FCoverageIntPropertyDeepInner
{
	UPROPERTY()
	int8 Int8Value = 7;

	UPROPERTY()
	uint64 UInt64Value = 999999999;
}

/**
 * The middle struct embedding the inner one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared middle struct embedding Inner
 */
USTRUCT()
struct FCoverageIntPropertyDeepMiddle
{
	UPROPERTY()
	FCoverageIntPropertyDeepInner Inner;

	UPROPERTY()
	int16 Int16Value = 777;
}

/**
 * The root struct embedding the middle one.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared root struct embedding Middle
 */
USTRUCT()
struct FCoverageIntPropertyDeepRoot
{
	UPROPERTY()
	FCoverageIntPropertyDeepMiddle Middle;

	UPROPERTY()
	int IntValue = 12345;
}

UCLASS()
class ACoverageIntStructDeepPathsActor : AActor
{
	UPROPERTY()
	FCoverageIntPropertyDeepRoot Root;

	/**
	 * Observe that the deepest defaults are readable through the chain.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four nested defaults match
	 */
	UFUNCTION()
	bool IntStructDeepPathsNominal()
	{
		if (Root.Middle.Inner.Int8Value != 7)
		{
			return false;
		}

		if (Root.Middle.Inner.UInt64Value != 999999999)
		{
			return false;
		}

		if (Root.Middle.Int16Value != 777)
		{
			return false;
		}

		return Root.IntValue == 12345;
	}

	/**
	 * Observe that mutating a copied inner struct leaves the chain intact.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copy of the innermost struct
	 * @Return true when the original keeps 7 and the copy holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntStructDeepPathsCopyIndependence()
	{
		FCoverageIntPropertyDeepInner Copy = Root.Middle.Inner;
		Copy.Int8Value = 0;

		if (Root.Middle.Inner.Int8Value != 7)
		{
			return false;
		}

		return Copy.Int8Value == 0;
	}
}
/** @end */
/**
 * @begin int-struct-nested-property-widths
 * @summary A USTRUCT nested inside an actor, holding all eight int widths with non-trivial defaults that reflection must preserve.
 * @topic Reflection
 */
/**
 * The nested struct holding every int width.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return a declared struct with eight defaulted widths
 */
USTRUCT()
struct FCoverageIntNestedWidths
{
	UPROPERTY()
	int8 Int8Value = -12;

	UPROPERTY()
	int16 Int16Value = -1234;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = -9000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UIntValue = 3000000000;

	UPROPERTY()
	uint64 UInt64Value = 12000000000000000000;
}

UCLASS()
class ACoverageIntStructNestedWidthsActor : AActor
{
	UPROPERTY()
	FCoverageIntNestedWidths Stats;

	/**
	 * Observe that all eight nested defaults are readable without BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all eight nested defaults match
	 */
	UFUNCTION()
	bool IntStructNestedWidthsNominal()
	{
		if (Stats.Int8Value != -12)
		{
			return false;
		}

		if (Stats.Int16Value != -1234)
		{
			return false;
		}

		if (Stats.IntValue != 123456)
		{
			return false;
		}

		if (Stats.Int64Value != -9000000000)
		{
			return false;
		}

		if (Stats.UInt8Value != 250)
		{
			return false;
		}

		if (Stats.UInt16Value != 60000)
		{
			return false;
		}

		if (Stats.UIntValue != 3000000000)
		{
			return false;
		}

		return Stats.UInt64Value == 12000000000000000000;
	}

	/**
	 * Observe that mutating a copy leaves the nested original intact.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a copy of the Stats struct
	 * @Return true when the original keeps 123456 and the copy holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntStructNestedWidthsCopyIndependence()
	{
		FCoverageIntNestedWidths Copy = Stats;
		Copy.IntValue = 0;

		if (Stats.IntValue != 123456)
		{
			return false;
		}

		return Copy.IntValue == 0;
	}
}
/** @end */
/**
 * @begin mixed-container-parameters
 * @summary One function receiving all three container kinds by const reference, plus a converter from TSet to TArray. The recorded result is the sum of all three element counts.
 * @topic Reflection
 */
UCLASS()
class ACoverageContainerParamMixedActor : AActor
{
	UPROPERTY()
	int ResultSize;

	/**
	 * Sums the element counts of all three container kinds.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs one array, one map and one set
	 * @Return the sum of all three counts
	 * @Param Arr the array parameter
	 * @Param Map the map parameter
	 * @Param Set the set parameter
	 */
	int ProcessMultipleContainers(
		const TArray<int>&in Arr,
		const TMap<int, FString>&in Map,
		const TSet<int>&in Set)
	{
		Print("=== ProcessMultipleContainers ===");
		Print("Array size: " + Arr.Num());
		Print("Map size: " + Map.Num());
		Print("Set size: " + Set.Num());
		return Arr.Num() + Map.Num() + Set.Num();
	}

	/**
	 * Converts a set's elements into an array.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the set to convert
	 * @Return an array holding every set element
	 * @Param InputSet the set to convert
	 */
	TArray<int> SetToArray(const TSet<int>&in InputSet)
	{
		Print("=== SetToArray ===");
		TArray<int> Result;
		for (int Val : InputSet)
		{
			Result.Add(Val);
		}
		Print("Converted " + InputSet.Num() + " elements to array");
		return Result;
	}

	/**
	 * Exercises both helpers with populated containers.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; ResultSize records the summed counts
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Mixed Container Parameters Test ===");

		TArray<int> MyArray;
		MyArray.Add(1);
		MyArray.Add(2);

		TMap<int, FString> MyMap;
		MyMap.Add(1, "One");
		MyMap.Add(2, "Two");
		MyMap.Add(3, "Three");

		TSet<int> MySet;
		MySet.Add(10);
		MySet.Add(20);

		ResultSize = ProcessMultipleContainers(MyArray, MyMap, MySet);

		// Test conversion
		TSet<int> ConvertSet;
		ConvertSet.Add(100);
		ConvertSet.Add(200);
		TArray<int> ConvertedArray = SetToArray(ConvertSet);
		Print("Converted array size: " + ConvertedArray.Num());
	}

	/**
	 * Observe that a locally constructed actor leaves the result unset.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when ResultSize is 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool MixedContainersDefaultEmpty()
	{
		return ResultSize == 0;
	}

	/**
	 * Observe the summed counts after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then ResultSize
	 * @Return true when the result is 7
	 */
	UFUNCTION()
	bool MixedContainersNominal()
	{
		BeginPlay();
		return ResultSize == 7;
	}

	/**
	 * Observe the empty-container boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs three empty containers and the converter
	 * @Return true when the sum is 0 and the converted array is empty
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool MixedContainersEmptyBoundary()
	{
		TArray<int> EmptyArr;
		TMap<int, FString> EmptyMap;
		TSet<int> EmptySet;
		TArray<int> Converted = SetToArray(EmptySet);

		if (ProcessMultipleContainers(EmptyArr, EmptyMap, EmptySet) != 0)
		{
			return false;
		}

		return Converted.Num() == 0;
	}
}
/** @end */
/**
 * @begin property-defaults-compile
 * @summary CDO default overrides: a `default` statement replacing an inline initializer, and another filling a Tags array. The CDO values must survive into fresh instances and stay independent across them.
 * @topic Reflection
 */
UCLASS()
class UCompilerDefaultsCarrier : UObject
{
	UPROPERTY()
	int Score = 7;

	UPROPERTY()
	TArray<FName> Tags;

	/**
	 * Overrides the inline initializer with 21.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the CDO Score becomes 21
	 */
	default Score = 21;

	/**
	 * Fills the CDO Tags array with one entry.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the CDO Tags gain n"Alpha"
	 */
	default Tags.Add(n"Alpha");

	/**
	 * Observe the CDO default overrides.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when Score is 21 and Tags holds Alpha
	 */
	UFUNCTION()
	bool PropertyDefaultsNominal()
	{
		if (Score != 21)
		{
			return false;
		}

		if (!Tags.Contains(n"Alpha"))
		{
			return false;
		}

		return Tags.Num() >= 1;
	}

	/**
	 * Observe that instances do not share the defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier mutated, compared against a second carrier
	 * @Return true when the mutation is local and the other keeps defaults
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool PropertyDefaultsSecondInstanceIndependent()
	{
		UCompilerDefaultsCarrier Second =
			Cast<UCompilerDefaultsCarrier>(
				NewObject(GetTransientPackage(), UCompilerDefaultsCarrier::StaticClass(), n"CompilerDefaultsCarrierSecond"));
		if (Second == nullptr)
		{
			throw("Test_PropertyDefaultsCompile setup: NewObject returned null");
		}

		Score = 0;
		Tags.Empty();

		if (Score != 0)
		{
			return false;
		}

		if (Tags.Num() != 0)
		{
			return false;
		}

		if (Second.Score != 21)
		{
			return false;
		}

		return Second.Tags.Contains(n"Alpha");
	}
}
/** @end */
/**
 * @begin u-class-property-defaults
 * @summary A UCLASS carrying a UPROPERTY with an explicit zero initializer. The property must start at zero, accept writes, and stay independent across instances.
 * @topic Reflection
 */
UCLASS()
class AClassUCLASSActor : AActor
{
	UPROPERTY()
	int X = 0;

	/**
	 * Observe the initialized property default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return the X value
	 */
	UFUNCTION()
	int UClassPropertyDefaultValue()
	{
		return X;
	}

	/**
	 * Observe that a write lands on the property.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs X set to 1
	 * @Return the X value
	 */
	UFUNCTION()
	int UClassPropertyWriteBoundary()
	{
		X = 1;
		return X;
	}

	/**
	 * Observe that writing this actor leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 7 and the other holds 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool UClassPropertyIsIndependentAcrossInstances()
	{
		AClassUCLASSActor Other;
		X = 7;
		Other.X = 0;

		if (X != 7)
		{
			return false;
		}

		return Other.X == 0;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassUCLASSActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int UClassActorDefaultsToNull()
	{
		AClassUCLASSActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
/**
 * @begin vector4-int-point-int-vector-reflection
 * @summary FVector4, FIntPoint and FIntVector under reflection: scalar UPROPERTY defaults beside TArrays of each type, filled during BeginPlay.
 * @topic Reflection
 */
UCLASS()
class ACoverageMathVector4IntStructActor : AActor
{
	UPROPERTY()
	FVector4 Vector4Value = FVector4(1, 2, 3, 4);

	UPROPERTY()
	FIntPoint IntPointValue = FIntPoint(5, 6);

	UPROPERTY()
	FIntVector IntVectorValue = FIntVector(7, 8, 9);

	UPROPERTY()
	TArray<FVector4> Vector4Array;

	UPROPERTY()
	TArray<FIntPoint> IntPointArray;

	UPROPERTY()
	TArray<FIntVector> IntVectorArray;

	/**
	 * Adds one element to each array.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three arrays gain one element
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Vector4Array.Add(FVector4(10, 11, 12, 13));
		IntPointArray.Add(FIntPoint(14, 15));
		IntVectorArray.Add(FIntVector(16, 17, 18));
	}

	/**
	 * Observe that a locally constructed actor leaves the arrays empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three arrays report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool Vector4IntStructDefaultEmptyArrays()
	{
		if (Vector4Array.Num() != 0)
		{
			return false;
		}

		if (IntPointArray.Num() != 0)
		{
			return false;
		}

		return IntVectorArray.Num() == 0;
	}

	/**
	 * Observe the scalar struct defaults.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all sampled components match
	 */
	UFUNCTION()
	bool Vector4IntStructNominalDefaults()
	{
		if (!Math::IsNearlyEqual(Vector4Value.X, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(Vector4Value.W, 4.0))
		{
			return false;
		}

		if (IntPointValue.X != 5)
		{
			return false;
		}

		if (IntPointValue.Y != 6)
		{
			return false;
		}

		return IntVectorValue.X == 7;
	}

	/**
	 * Observe the array contents after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the three arrays
	 * @Return true when each array holds its element
	 */
	UFUNCTION()
	bool Vector4IntStructAfterBeginPlay()
	{
		BeginPlay();

		if (Vector4Array.Num() != 1)
		{
			return false;
		}

		if (IntPointArray[0].X != 14)
		{
			return false;
		}

		return IntVectorArray[0].X == 16;
	}
}
/** @end */
/**
 * @begin container-reference-return
 * @summary A member TArray returned by reference. Writing through the returned reference must reach the member itself, which BeginPlay verifies by adding through the reference and then reading the member's size and first element.
 * @topic Reflection
 */
UCLASS()
class ACoverageContainerReferenceReturnActor : AActor
{
	UPROPERTY()
	TArray<int> Values;

	UPROPERTY()
	int RefSize = 0;

	UPROPERTY()
	int FirstValue = 0;

	/**
	 * Returns the member array by reference so callers can mutate it.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs the member TArray Values
	 * @Return a mutable reference to Values
	 */
	TArray<int>& GetValuesRef()
	{
		return Values;
	}

	/**
	 * Populates the array, then adds once more through the returned reference.
	 *
	 * @Covers Syntax.Reference
	 * @Inputs none
	 * @Return nothing; RefSize and FirstValue record the result
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(10);
		Values.Add(20);

		TArray<int>& Ref = GetValuesRef();
		Ref.Add(30);

		RefSize = Values.Num();
		FirstValue = Ref[0];
	}

	/**
	 * Observe the state of a locally constructed actor before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Reference
	 * @Inputs a locally constructed actor
	 * @Return true when the array is empty and both counters are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool ContainerReferenceDefaultsToEmpty()
	{
		if (RefSize != 0)
		{
			return false;
		}

		if (FirstValue != 0)
		{
			return false;
		}

		return Values.Num() == 0;
	}
}
/** @end */
