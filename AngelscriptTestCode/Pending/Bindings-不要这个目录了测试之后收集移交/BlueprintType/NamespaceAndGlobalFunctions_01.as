/**
 * @version v1
 * @summary Observe StaticClass publication and static reflected functions expanded under the class namespace.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe StaticClass publication and static reflected functions expanded under the class namespace.
 * @topic Baseline
 */
// <ReturnType> <TypeName>::<FunctionName>(<Parameters>);
// Inputs: AActor and UObject as valid class handles, plus a null comparison
// against the returned UClass. Static function arguments use AActor's
// published namespace overloads where present; default omission is used only
// when the reflected static function publishes defaults.
// Expected observations: AActor::StaticClass() is non-null and distinct from
// UObject::StaticClass(). Repeated StaticClass calls return the same identity.
// Boundary/ownership: StaticClass returns the reflected UClass without
// transferring ownership. Namespace static functions target the class default
// object, not a newly constructed instance.

namespace TS_BlueprintType_NamespaceAndGlobalFunctions_01
{
	// UClass <TypeName>::StaticClass() publishes the reflected class identity.
	// Inputs: AActor and UObject StaticClass, plus a repeated Actor call.
	// Oracle: Actor class is live, differs from UObject, and is stable.
	// Ownership: borrowed UClass; no instance is created.
	bool Observe_StaticClass_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		UClass ObjectClass = UObject::StaticClass();
		UClass ActorClassAgain = AActor::StaticClass();
		return ActorClass != nullptr && ActorClass != ObjectClass && ActorClass == ActorClassAgain;
	}

	// <ReturnType> <TypeName>::<FunctionName> static namespace surface via GetName.
	// Inputs: AActor::StaticClass() then GetName().
	// Oracle: class name is "Actor".
	// Ownership: GetName returns a new FString; UClass is borrowed.
	bool Observe_Surface006_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		if (ActorClass is null)
		{
			throw("TS_BlueprintType_NamespaceAndGlobalFunctions_01 setup: required ActorClass is null");
		}
		FString ClassName = ActorClass.GetName();
		return ClassName == "Actor";
	}
}
/** @end */
