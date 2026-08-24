// Theme: Language.Namespace. Positive: namespaced UCLASS StaticClass helper round-trip.
// C++: AngelscriptCompilerNamespaceTests.cpp::NamespacedAnnotatedClassStaticHelperRoundTrip
// sha256=d7051977e7e5f48fb59c2787b70bcccf7a0f2ec674f522629c8188c286e73757; lines 73-91.
// Oracle: Entry() == 42 when Gameplay::UNamespaceCarrier::StaticClass() is non-null;
// GetValue() returns 42 on the generated class.
// Extra: Entry's ternary yields 0 if StaticClass is null.
// DefaultSafe.

namespace Gameplay
{
	UCLASS()
	class UNamespaceCarrier : UObject
	{
		UFUNCTION()
		int GetValue()
		{
			return 42;
		}
	}
}

int Entry()
{
	return Gameplay::UNamespaceCarrier::StaticClass() != nullptr ? 42 : 0;
}

int Observe_Entry_Nominal()
{
	return Entry();
}
