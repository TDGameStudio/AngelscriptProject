/**
 * Serialize bound single and multicast delegates. BindDelegates binds Single
 * and Multi to Handler; serialized bytes restore those bindings.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateSerializationRoundTrip
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateSerializationRoundTrip
 * @Provenance Theme: Feature.Delegates. Positive serialize bound single and multicast delegates.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateSerializationRoundTrip
 * @Provenance Oracle: BindDelegates binds Single and Multi to Handler; serialized bytes restore bindings.
 * @Provenance Extra: empty object is null. DefaultSafe.
 */

/**
 * A parameterless void unicast that is serialized.
 *
 * @Covers Delegates.Serialization
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageSerializedSingle();

/**
 * A parameterless multicast that is serialized.
 *
 * @Covers Delegates.Serialization
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageSerializedEvent();

UCLASS()
class UCoverageDynamicDelegateSerializationObject : UObject
{
	UPROPERTY()
	FCoverageSerializedSingle Single;

	UPROPERTY()
	FCoverageSerializedEvent Multi;

	/**
	 * The named handler both delegates bind.
	 *
	 * @Covers Delegates.Serialization
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void Handler()
	{
	}

	/**
	 * Binds Single and Multi to Handler.
	 *
	 * @Covers Delegates.Serialization
	 * @Inputs none
	 * @Return nothing; both delegates become bound
	 */
	UFUNCTION()
	void BindDelegates()
	{
		Single.BindUFunction(this, n"Handler");
		Multi.AddUFunction(this, n"Handler");
	}

	/**
	 * Observe that a default-constructed handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Serialization
	 * @Inputs a local UCoverageDynamicDelegateSerializationObject
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCoverageDynamicDelegateSerializationObject Obj;
		return Obj == nullptr;
	}
}
