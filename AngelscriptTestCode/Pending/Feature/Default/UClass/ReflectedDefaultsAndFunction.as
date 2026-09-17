/**
 * @version v1
 * @summary A UObject whose reflected defaults plus a helper UFUNCTION are observed. Counter starts at 9, ObjectLabel at "FunctionalObject", and ComputeMarker() returns Counter + 5. Keep Counter and ObjectLabel.
 * @topic Feature
 */
/**
 * @version root
 * @summary A UObject whose reflected defaults plus a helper UFUNCTION are observed. Counter starts at 9, ObjectLabel at "FunctionalObject", and ComputeMarker() returns Counter + 5. Keep Counter and ObjectLabel.
 * @topic Baseline
 */
UCLASS()
class UObjectReflectedDefaultsAndFunction : UObject
{
	UPROPERTY()
	int Counter = 9;

	UPROPERTY()
	FString ObjectLabel = "FunctionalObject";

	/**
	 * Returns Counter plus 5.
	 *
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs none
	 * @Return Counter + 5
	 */
	UFUNCTION()
	int ComputeMarker()
	{
		return Counter + 5;
	}

	/**
	 * Observe that an unset handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs a freshly declared handle
	 * @Return true when the unset handle is null
	 * @Boundary unset handle
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UObjectReflectedDefaultsAndFunction Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe that the helper uses the default Counter.
	 *
	 * @Kind Observe
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs a freshly constructed object
	 * @Return 14
	 */
	UFUNCTION()
	int ComputeMarkerNominal()
	{
		return ComputeMarker();
	}

	/**
	 * Observe the zero boundary of Counter through the helper.
	 *
	 * @Kind Observe
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs Counter set to 0
	 * @Return 5
	 * @Boundary zero Counter
	 */
	UFUNCTION()
	int ComputeMarkerZeroBoundary()
	{
		Counter = 0;
		return ComputeMarker();
	}

	/**
	 * Observe the empty-string boundary of ObjectLabel.
	 *
	 * @Kind Observe
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs ObjectLabel set to ""
	 * @Return the empty string
	 * @Boundary empty label
	 */
	UFUNCTION()
	FString EmptyLabelBoundary()
	{
		ObjectLabel = "";
		return ObjectLabel;
	}

	/**
	 * Observe that writing this object leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Default.ReflectedDefaultsAndFunction
	 * @Inputs this object written to, compared against a second object
	 * @Return true when the other still holds 9 and FunctionalObject
	 * @Param Second the other object
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependent(UObjectReflectedDefaultsAndFunction Second)
	{
		if (Second == nullptr)
		{
			throw("ReflectedDefaultsAndFunction setup: required Second is null");
		}
		Counter = 0;
		ObjectLabel = "";
		if (Second.Counter != 9)
		{
			return false;
		}
		return Second.ObjectLabel == "FunctionalObject";
	}
}
/** @end */
