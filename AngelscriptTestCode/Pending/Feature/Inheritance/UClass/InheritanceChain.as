/**
 * @version v1
 * @summary Super:: chain on RunChain. C++ verifies after ExecuteDeepChain: CallChain==1234 and BaseValue==1, while MidValue/DerivedValue/DeepValue stay 0 (documented deep-inheritance initializer boundary). ExecuteChain on derived.
 * @topic Feature
 */
/**
 * @version root
 * @summary Super:: chain on RunChain. C++ verifies after ExecuteDeepChain: CallChain==1234 and BaseValue==1, while MidValue/DerivedValue/DeepValue stay 0 (documented deep-inheritance initializer boundary). ExecuteChain on derived.
 * @topic Baseline
 */
UCLASS()
class ACoverageClassFeaturesInheritanceBase : AActor
{
	UPROPERTY()
	int BaseValue = 1;

	UPROPERTY()
	int CallChain = 0;

	/**
	 * Base RunChain step that appends digit 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs none
	 * @Return CallChain = CallChain * 10 + 1
	 */
	void RunChain()
	{
		CallChain = CallChain * 10 + 1;
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceMid : ACoverageClassFeaturesInheritanceBase
{
	UPROPERTY()
	int MidValue = 2;

	/**
	 * Mid RunChain step that Super-calls then appends digit 2.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs Super::RunChain()
	 * @Return CallChain = CallChain * 10 + 2 after Super
	 */
	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 2;
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceDerived : ACoverageClassFeaturesInheritanceMid
{
	UPROPERTY()
	int DerivedValue = 3;

	/**
	 * Derived RunChain step that Super-calls then appends digit 3.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs Super::RunChain()
	 * @Return CallChain = CallChain * 10 + 3 after Super
	 */
	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 3;
	}

	/**
	 * Execute the Super chain through derived RunChain.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs RunChain()
	 * @Return CallChain, expected to be 123
	 */
	UFUNCTION()
	void ExecuteChain()
	{
		RunChain();
	}

	/**
	 * Observe ExecuteChain writing CallChain 123.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs ExecuteChain()
	 * @Return CallChain, expected to be 123
	 */
	UFUNCTION()
	int DerivedExecute()
	{
		ExecuteChain();
		return CallChain;
	}
}

UCLASS()
class ACoverageClassFeaturesInheritanceDeep : ACoverageClassFeaturesInheritanceDerived
{
	UPROPERTY()
	int DeepValue = 4;

	/**
	 * Deep RunChain step that Super-calls then appends digit 4.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs Super::RunChain()
	 * @Return CallChain = CallChain * 10 + 4 after Super
	 */
	void RunChain()
	{
		Super::RunChain();
		CallChain = CallChain * 10 + 4;
	}

	/**
	 * Execute the Super chain through deep RunChain.
	 *
	 * @Kind Action
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs RunChain()
	 * @Return CallChain, expected to be 1234
	 */
	UFUNCTION()
	void ExecuteDeepChain()
	{
		RunChain();
	}

	/**
	 * Observe that a locally constructed deep actor has CallChain 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs an actor that has not executed the chain
	 * @Return CallChain, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultEmpty()
	{
		return CallChain;
	}

	/**
	 * Observe ExecuteDeepChain writing CallChain 1234.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs ExecuteDeepChain()
	 * @Return CallChain, expected to be 1234
	 */
	UFUNCTION()
	int DeepExecute()
	{
		ExecuteDeepChain();
		return CallChain;
	}

	/**
	 * Observe BaseValue on the deep actor.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs a freshly constructed deep actor
	 * @Return BaseValue, expected to be 1
	 */
	UFUNCTION()
	int ObservedBaseValue()
	{
		return BaseValue;
	}

	/**
	 * Observe that executing this instance leaves another deep actor at CallChain 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritanceChain
	 * @Inputs this actor plus a second actor
	 * @Return true when this is 1234 and the other stays 0
	 * @Param Second the other actor, expected to stay at CallChain 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageClassFeaturesInheritanceDeep Second)
	{
		if (Second == nullptr)
		{
			throw("InheritanceChain setup: required Second is null");
		}
		ExecuteDeepChain();
		if (CallChain != 1234)
		{
			return false;
		}
		return Second.CallChain == 0;
	}
}
/** @end */
