// Theme: Definitions.UStruct. Positive: plain script struct is not BlueprintType by default.
// C++: AngelscriptStructCppOpsTests.cpp::NotBlueprintTypeByDefault
// Compile FScopeConstructStruct; UScriptStruct BlueprintType metadata is false.
// Extra: default Value==7; zero assignment; copy independence.
// DefaultSafe.

struct FScopeConstructStruct
{
	int Value = 7;
}

int Observe_ScopeConstruct_DefaultValue()
{
	FScopeConstructStruct Scope;
	return Scope.Value;
}

int Observe_ScopeConstruct_ZeroBoundary()
{
	FScopeConstructStruct Scope;
	Scope.Value = 0;
	return Scope.Value;
}

bool Observe_ScopeConstruct_CopyIndependence()
{
	FScopeConstructStruct Original;
	FScopeConstructStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 7 && Copy.Value == 0;
}
