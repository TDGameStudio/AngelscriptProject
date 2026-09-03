/**
 * A plain script struct is not BlueprintType by default. C++ compiles
 * FScopeConstructStruct and checks that UScriptStruct BlueprintType metadata
 * is false.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ScopeConstructStruct
 * @Harness Function
 * @Tag Definitions.UStruct.ScopeConstructStruct
 * @Namespace UStructTest
 * @Provenance Theme: Definitions.UStruct. Positive: plain script struct is not BlueprintType by default.
 * @Provenance C++: AngelscriptStructCppOpsTests.cpp::NotBlueprintTypeByDefault
 * @Provenance Compile FScopeConstructStruct; UScriptStruct BlueprintType metadata is false.
 * @Provenance Extra: default Value==7; zero assignment; copy independence.
 * @Provenance DefaultSafe.
 */

struct FScopeConstructStruct
{
	int Value = 7;
}

namespace UStructTest
{
	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScopeConstructStruct
	 * @Inputs a default-constructed FScopeConstructStruct
	 * @Return 7
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		FScopeConstructStruct Scope;
		return Scope.Value;
	}

	/**
	 * Observe the zero write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScopeConstructStruct
	 * @Inputs a struct whose Value was set to 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		FScopeConstructStruct Scope;
		Scope.Value = 0;
		return Scope.Value;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ScopeConstructStruct
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 7 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FScopeConstructStruct Original;
		FScopeConstructStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 7)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
