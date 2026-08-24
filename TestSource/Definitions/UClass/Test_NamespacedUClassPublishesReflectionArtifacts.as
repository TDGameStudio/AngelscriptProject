// Theme: Definitions.UClass. Positive namespaced UObject publishes StoredValue and GetStoredValue.
// C++: AngelscriptScriptClassStructureTests.cpp::NamespacedUClassPublishesReflectionArtifacts
// Oracle: StoredValue CDO default 29; GetStoredValue returns 29.
// Extra: nullptr handle is the empty vector; mutating First does not write Second.
// DefaultSafe. Keep StoredValue.

namespace ScriptClassNamespace
{
	UCLASS()
	class UNamespacedScriptClass : UObject
	{
		UPROPERTY()
		int StoredValue = 29;

		UFUNCTION()
		int GetStoredValue()
		{
			return StoredValue;
		}
	}
}

bool Observe_NamespacedStored_Nominal(ScriptClassNamespace::UNamespacedScriptClass Object)
{
	return Object.GetStoredValue() == 29 && Object.StoredValue == 29;
}

bool Observe_NamespacedStored_NullDefault()
{
	ScriptClassNamespace::UNamespacedScriptClass Object = nullptr;
	return Object == nullptr;
}

bool Observe_NamespacedStored_CopyIndependent(
	ScriptClassNamespace::UNamespacedScriptClass First,
	ScriptClassNamespace::UNamespacedScriptClass Second)
{
	First.StoredValue = 0;
	return Second.StoredValue == 29 && Second.GetStoredValue() == 29;
}
