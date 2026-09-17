/**
 * @version v1
 * @summary Script methods remain on a Blueprint child. C++ verifies GetInterfaceValue()==42, GetLabel()=="InterfaceActor" and InterfaceResult==42. Zeroing InterfaceResult is copy-independent.
 * @topic Feature
 */
/**
 * @version root
 * @summary Script methods remain on a Blueprint child. C++ verifies GetInterfaceValue()==42, GetLabel()=="InterfaceActor" and InterfaceResult==42. Zeroing InterfaceResult is copy-independent.
 * @topic Baseline
 */
UCLASS()
class ATestBPChildScriptInterfaceActor : AActor
{
	UPROPERTY()
	int InterfaceResult = 42;

	/**
	 * Return the script interface value a Blueprint child must still see.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInterfaceInheritance
	 * @Inputs none
	 * @Return InterfaceResult, expected to be 42
	 */
	UFUNCTION()
	int GetInterfaceValue()
	{
		return InterfaceResult;
	}

	/**
	 * Return the script label a Blueprint child must still see.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInterfaceInheritance
	 * @Inputs none
	 * @Return "InterfaceActor"
	 */
	UFUNCTION()
	FString GetLabel()
	{
		return "InterfaceActor";
	}

	/**
	 * Observe GetInterfaceValue after InterfaceResult is zeroed.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInterfaceInheritance
	 * @Inputs InterfaceResult = 0
	 * @Return GetInterfaceValue(), expected to be 0
	 * @Boundary zero result
	 */
	UFUNCTION()
	int ZeroResultBoundary()
	{
		InterfaceResult = 0;
		return GetInterfaceValue();
	}

	/**
	 * Observe that writing InterfaceResult on this instance leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ScriptInterfaceInheritance
	 * @Inputs this actor plus a second actor
	 * @Return true when this is 0 and the other stays 42
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestBPChildScriptInterfaceActor Second)
	{
		if (Second == nullptr)
		{
			throw("ScriptInterfaceInheritance setup: required Second is null");
		}
		InterfaceResult = 0;
		if (Second.GetInterfaceValue() != 42)
		{
			return false;
		}
		return GetInterfaceValue() == 0;
	}
}
/** @end */
