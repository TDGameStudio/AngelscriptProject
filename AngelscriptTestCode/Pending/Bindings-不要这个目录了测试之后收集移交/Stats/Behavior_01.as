/**
 * @version v1
 * @summary Observe FStatID and FScopeCycleCounter constructors, including object-attributed scopes. Each function returns that scoped work completed.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FStatID and FScopeCycleCounter constructors, including object-attributed scopes. Each function returns that scoped work completed.
 * @topic Baseline
 */
// FScopeCycleCounter Scope(const FStatID& Stat);
// FScopeCycleCounter Scope(const UObject Object);
// Inputs: Name n"TestSource.Stats.Nominal", NAME_None, a live actor CDO, and
// a null UObject as the empty object boundary.
// Expected observations: Named and NAME_None stats both construct. A scope
// from a FStatID and a scope from a UObject both complete. Null object scope
// is the empty-handle boundary.
// Boundary/ownership: The stat identifier's native lifetime is automatic.
// The cycle counter does not own the UObject; it only attributes the scope.

namespace TS_Stats_Behavior_01
{
	bool Observe_Stat_Nominal()
	{
		FName NamedId = n"TestSource.Stats.Nominal";
		FStatID Named(NamedId);
		FStatID Empty(NAME_None);
		return NamedId == n"TestSource.Stats.Nominal";
	}

	bool Observe_Scope_Nominal()
	{
		FStatID Stat(n"TestSource.Stats.Scope");
		int NamedWork = 0;
		{
			FScopeCycleCounter FromStat(Stat);
			NamedWork = 1;
		}
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_Stats_Behavior_01 setup: required Actor CDO is null");
		}
		int ObjectWork = 0;
		{
			FScopeCycleCounter FromObject(LiveCdo);
			ObjectWork = 2;
		}
		UObject NullObject = nullptr;
		int NullWork = 0;
		{
			FScopeCycleCounter FromNull(NullObject);
			NullWork = 3;
		}
		return NamedWork == 1 && ObjectWork == 2 && NullWork == 3;
	}
}
/** @end */
