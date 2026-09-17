/**
 * @version v1
 * @summary Set and the implicit UClass constructor throw when the assigned class is not a child of the templated class. The holder is left unset after the throw, so the failure is observable but does not corrupt the holder. This.
 * @topic Containers
 */
/**
 * @version root
 * @summary Set and the implicit UClass constructor throw when the assigned class is not a child of the templated class. The holder is left unset after the throw, so the failure is observable but does not corrupt the holder. This.
 * @topic Baseline
 */
UCLASS()
class UTSubclassOfThrowBase : UObject
{
}

UCLASS()
class UTSubclassOfThrowDerived : UTSubclassOfThrowBase
{
}

/** Unrelated to UTSubclassOfThrowBase, so it can never satisfy the template. */
UCLASS()
class UTSubclassOfThrowUnrelated : UObject
{
}

namespace TSubclassOfTest
{
	/**
	 * Set an unrelated class into a base-class holder throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TSubclassOf.Set
	 * @Inputs TSubclassOf<UTSubclassOfThrowBase>; Set(unrelated class)
	 * @Return does not return; throws "Class set to TSubclassOf<> was not a child of templated class."
	 * @Boundary class not a child of the template parameter
	 */
	UFUNCTION()
	void SetUnrelatedClass()
	{
		TSubclassOf<UTSubclassOfThrowBase> Class;
		Class.Set(UTSubclassOfThrowUnrelated::StaticClass());
	}

	/**
	 * Implicit-construct from an unrelated class throws at construction.
	 *
	 * @Kind RuntimeException
	 * @Covers TSubclassOf.Construct
	 * @Inputs TSubclassOf<UTSubclassOfThrowBase> initialized from an unrelated class
	 * @Return does not return; throws "Class set to TSubclassOf<> was not a child of templated class."
	 * @Boundary implicit constructor validates the hierarchy too
	 */
	UFUNCTION()
	void ImplicitConstructFromUnrelatedClass()
	{
		TSubclassOf<UTSubclassOfThrowBase> Class = UTSubclassOfThrowUnrelated::StaticClass();
	}

	/**
	 * Assign an unrelated class with opAssign throws; the overload routes
	 * through the same validation as Set.
	 *
	 * @Kind RuntimeException
	 * @Covers TSubclassOf.opAssign
	 * @Inputs TSubclassOf<UTSubclassOfThrowBase>; assign an unrelated class
	 * @Return does not return; throws "Class set to TSubclassOf<> was not a child of templated class."
	 * @Boundary opAssign(UClass) validates like Set
	 */
	UFUNCTION()
	void AssignUnrelatedClass()
	{
		TSubclassOf<UTSubclassOfThrowBase> Class;
		Class = UTSubclassOfThrowUnrelated::StaticClass();
	}

	/**
	 * Assigning a sibling class from a different branch throws; being a
	 * UObject subclass is not enough, the class must be under the template.
	 *
	 * @Kind RuntimeException
	 * @Covers TSubclassOf.opAssign
	 * @Inputs TSubclassOf<UTSubclassOfThrowDerived>; assign the base class
	 * @Return does not return; throws "Class set to TSubclassOf<> was not a child of templated class."
	 * @Boundary a base class is not a child of its own derived class
	 */
	UFUNCTION()
	void AssignBaseClassIntoDerivedHolder()
	{
		TSubclassOf<UTSubclassOfThrowDerived> Class;
		Class = UTSubclassOfThrowBase::StaticClass();
	}
}
/** @end */
