/**
 * @version v1
 * @summary A namespaced UObject publishes StoredValue and GetStoredValue. StoredValue CDO default is 29. Keep StoredValue.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A namespaced UObject publishes StoredValue and GetStoredValue. StoredValue CDO default is 29. Keep StoredValue.
 * @topic Baseline
 */
namespace ScriptClassNamespace
{
	UCLASS()
	class UNamespacedScriptClass : UObject
	{
		UPROPERTY()
		int StoredValue = 29;

		/**
		 * Observe GetStoredValue: it returns StoredValue.
		 *
		 * @Kind Observe
		 * @Covers UClass.Namespace
		 * @Inputs StoredValue
		 * @Return StoredValue
		 */
		UFUNCTION()
		int GetStoredValue()
		{
			return StoredValue;
		}

		/**
		 * Observe the CDO StoredValue default through the getter and the field.
		 *
		 * @Kind Observe
		 * @Covers UClass.Namespace
		 * @Inputs GetStoredValue and StoredValue
		 * @Return true when both read 29
		 */
		UFUNCTION()
		bool StoredDefault()
		{
			if (GetStoredValue() != 29)
			{
				return false;
			}
			return StoredValue == 29;
		}

		/**
		 * Observe that a nullptr handle is null.
		 *
		 * @Kind Observe
		 * @Covers UClass.Namespace
		 * @Inputs ScriptClassNamespace::UNamespacedScriptClass Object = nullptr
		 * @Return true when the handle is null
		 * @Boundary default null
		 */
		UFUNCTION()
		bool NullDefault()
		{
			UNamespacedScriptClass Object = nullptr;
			return Object == nullptr;
		}

		/**
		 * Observe that writing this object leaves another at 29.
		 *
		 * @Kind Observe
		 * @Covers UClass.Namespace
		 * @Param Second Other object expected to stay at 29
		 * @Inputs this.StoredValue set to 0
		 * @Return true when Second.StoredValue and GetStoredValue stay 29
		 * @Boundary copy independence
		 */
		UFUNCTION()
		bool CopyIndependence(UNamespacedScriptClass Second)
		{
			if (Second is null)
			{
				throw("NamespacedUClassPublishesReflectionArtifacts setup: required Second is null");
			}
			StoredValue = 0;
			if (Second.StoredValue != 29)
			{
				return false;
			}
			return Second.GetStoredValue() == 29;
		}
	}
}
/** @end */
