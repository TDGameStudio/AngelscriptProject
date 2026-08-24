// Theme: Feature.Delegates. Positive: delegate vs event metadata on a UObject carrier.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateDeclarationMetadata
// Compile + reflection oracle: single-cast delegates, multicast events, named members.
// Extra: default-constructed object is non-null; nullptr assignment is the null boundary.
// DefaultSafe.

delegate void FCoverageDynamicNoParam();
delegate void FCoverageDynamicValue(int Value);
delegate bool FCoverageDynamicBoolResult();
event void FCoverageDynamicEvent();
event void FCoverageDynamicValueEvent(int NewValue);

UCLASS()
class UCoverageDynamicDelegateMetadataObject : UObject
{
	UPROPERTY()
	FCoverageDynamicNoParam SingleNoParam;

	UPROPERTY()
	FCoverageDynamicValue SingleValue;

	UPROPERTY()
	FCoverageDynamicBoolResult SingleBoolResult;

	UPROPERTY()
	FCoverageDynamicEvent AssignableEvent;

	UPROPERTY()
	FCoverageDynamicValueEvent CallableValueEvent;
}

bool Observe_MetadataObject_DefaultNonNull()
{
	UCoverageDynamicDelegateMetadataObject Obj;
	return Obj != nullptr;
}

bool Observe_MetadataObject_NullBoundary()
{
	UCoverageDynamicDelegateMetadataObject Obj = nullptr;
	return Obj == nullptr;
}
