/**
 * A differently named struct whose custom GUID must not collide with
 * FStableGuidStruct. C++ compares the two published GUIDs.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.DifferentGuidStruct
 * @Harness Function
 * @Tag Definitions.UStruct.DifferentGuidStruct
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. Different-name struct; GUID must not collide with FStableGuidStruct.
 * @Provenance C++: AngelscriptScriptStructHotReloadTests.cpp::CustomGuidStableAcrossSameNameReload block 3
 * @Provenance Oracle: FDifferentGuidStruct publishes a valid GUID unequal to the stable struct GUID.
 * @Provenance Extra: default Value==7; zero; copy independence.
 * @Provenance DefaultSafe.
 */

USTRUCT()
struct FDifferentGuidStruct
{
	UPROPERTY()
	int Value = 7;
};

namespace UStructTest
{
	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.DifferentGuidStruct
	 * @Inputs a default-constructed FDifferentGuidStruct
	 * @Return 7
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		FDifferentGuidStruct Other;
		return Other.Value;
	}

	/**
	 * Observe the zero write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.DifferentGuidStruct
	 * @Inputs a struct whose Value was set to 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		FDifferentGuidStruct Other;
		Other.Value = 0;
		return Other.Value;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.DifferentGuidStruct
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 7 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FDifferentGuidStruct Original;
		FDifferentGuidStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 7)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
