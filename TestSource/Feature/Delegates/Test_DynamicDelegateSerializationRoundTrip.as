// Theme: Feature.Delegates. Positive serialize bound single and multicast delegates.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateSerializationRoundTrip
// Oracle: BindDelegates binds Single and Multi to Handler; serialized bytes restore bindings.
// Extra: empty object is null. DefaultSafe.

delegate void FCoverageSerializedSingle();
event void FCoverageSerializedEvent();

UCLASS()
class UCoverageDynamicDelegateSerializationObject : UObject
{
	UPROPERTY()
	FCoverageSerializedSingle Single;

	UPROPERTY()
	FCoverageSerializedEvent Multi;

	UFUNCTION()
	void Handler()
	{
	}

	UFUNCTION()
	void BindDelegates()
	{
		Single.BindUFunction(this, n"Handler");
		Multi.AddUFunction(this, n"Handler");
	}
}

bool Observe_SerializedDelegates_EmptyDefaultIsNull()
{
	UCoverageDynamicDelegateSerializationObject Obj;
	return Obj == nullptr;
}
