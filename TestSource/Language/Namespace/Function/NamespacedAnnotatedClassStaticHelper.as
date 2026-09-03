/**
 * A UCLASS declared inside a namespace is generated with its namespace, and
 * its StaticClass helper is reached through the qualified name. The round
 * trip is: ask for the static class by qualified name, confirm it is
 * non-null, then call a UFUNCTION on it. If the static class were null the
 * entry would yield 0 instead, so the non-null check is what distinguishes a
 * generated class from a missing one.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.AnnotatedClassStaticHelper
 * @Harness UClass
 * @Tag Language.Namespace.NamespacedAnnotatedClassStaticHelper
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCompilerNamespaceTests.cpp::NamespacedAnnotatedClassStaticHelperRoundTrip
 * @Provenance sha256=d7051977e7e5f48fb59c2787b70bcccf7a0f2ec674f522629c8188c286e73757; lines 73-91.
 * @Provenance Oracle: Entry() == 42 when Gameplay::UNamespaceCarrier::StaticClass() is non-null.
 * @Provenance Extra: Entry's ternary yields 0 if StaticClass is null.
 */

namespace Gameplay
{
	UCLASS()
	class UNamespaceCarrier : UObject
	{
		/**
		 * A method on the namespaced class, reached through the generated
		 * class's static helper.
		 */
		UFUNCTION()
		int GetValue()
		{
			return 42;
		}
	}
}

namespace NamespaceTest
{
	/**
	 * Observe the static-helper round trip: the qualified static class is
	 * non-null, and the entry therefore yields 42 rather than 0.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Ask for Gameplay::UNamespaceCarrier::StaticClass(); yield 42 when non-null
	 * @Return 42 when the namespaced static class was generated
	 */
	UFUNCTION()
	int StaticHelperRoundTrip()
	{
		if (Gameplay::UNamespaceCarrier::StaticClass() == nullptr)
		{
			return 0;
		}
		return 42;
	}

	/**
	 * Observe that the generated class carries its UFUNCTION: calling GetValue
	 * on a default object of the namespaced class returns 42.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Get the CDO of the namespaced class and call GetValue on it
	 * @Return true when the CDO is non-null and reports 42
	 */
	UFUNCTION()
	bool NamespacedClassCarriesFunction()
	{
		UClass CarrierClass = Gameplay::UNamespaceCarrier::StaticClass();
		if (CarrierClass == nullptr)
		{
			return false;
		}

		UObject DefaultObject = GetDefaultObject(CarrierClass);
		if (DefaultObject == nullptr)
		{
			return false;
		}

		UGameplayNamespaceCarrier Carrier = Cast<UGameplayNamespaceCarrier>(DefaultObject);
		if (Carrier == nullptr)
		{
			return false;
		}
		return Carrier.GetValue() == 42;
	}

	/**
	 * Observe that the qualified static class is stable across repeated lookups.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Look up the static class twice
	 * @Return true when both lookups return the same non-null class
	 */
	UFUNCTION()
	bool StaticHelperIsStable()
	{
		UClass First = Gameplay::UNamespaceCarrier::StaticClass();
		UClass Second = Gameplay::UNamespaceCarrier::StaticClass();
		if (First == nullptr)
		{
			return false;
		}
		return First == Second;
	}
}
