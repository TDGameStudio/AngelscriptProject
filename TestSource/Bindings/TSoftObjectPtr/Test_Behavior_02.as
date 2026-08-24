// Purpose: Observe TSoftClassPtr copy construction and construction from
// TSubclassOf.
// AS-facing API: TSoftClassPtr<T> Value(const TSoftClassPtr<T>& Other);
// TSoftClassPtr<T> Value(const TSubclassOf<T>& Other);
// Inputs: Other class ptr from AActor::StaticClass(), TSubclassOf<AActor>,
// and an empty TSubclassOf as the empty state.
// Expected observations: Copy construction preserves AActor class identity.
// Construction from TSubclassOf Get() matches StaticClass. Empty TSubclassOf
// produces a null class ptr.
// Boundary/ownership: Construction copies the class path and does not spawn
// an actor. Empty TSubclassOf yields IsNull rather than a pending path.

namespace TS_TSoftObjectPtr_Behavior_02
{
	bool Observe_Value_Nominal()
	{
		TSoftClassPtr<AActor> Other = AActor::StaticClass();
		TSoftClassPtr<AActor> Copied(Other);
		TSubclassOf<AActor> Subclass = AActor::StaticClass();
		TSoftClassPtr<AActor> FromSubclass(Subclass);
		TSubclassOf<AActor> EmptySubclass;
		TSoftClassPtr<AActor> FromEmpty(EmptySubclass);
		return Copied.Get().Get() == AActor::StaticClass() &&
			Copied == Other &&
			FromSubclass.Get().Get() == AActor::StaticClass() &&
			FromSubclass == Subclass &&
			FromEmpty.IsNull() &&
			!FromEmpty.Get().IsValid();
	}
}
