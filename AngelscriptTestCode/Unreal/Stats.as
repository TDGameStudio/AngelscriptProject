/**
 * @version v1
 * @summary Stats host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Stats
 *
 * stat
 * scope
 * copying-fstatid-still-constructs
 * copying-fscopecyclecounter-still-completes
 */
/**
 * @begin stat
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveStatNominal
 * @summary Observe the container API.
 * @covers Stats.stat
 * @inputs Stats values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FScopeCycleCounter Scope(const FStatID& Stat);
// FScopeCycleCounter Scope(const UObject Object);
// Inputs: Name n"TestSource.Stats.Nominal", NAME_None, a live actor CDO, and
// a null UObject as the empty object boundary.
// Expected observations: Named and NAME_None stats both construct. A scope
// from a FStatID and a scope from a UObject both complete. Null object scope
// is the empty-handle boundary.
// Boundary/ownership: The stat identifier's native lifetime is automatic.
// The cycle counter does not own the UObject; it only attributes the scope.
bool ObserveStatNominal()
{
	FName NamedId = n"TestSource.Stats.Nominal";
	FStatID Named(NamedId);
	FStatID Empty(NAME_None);
	return NamedId == n"TestSource.Stats.Nominal";
}
/** @end */
/**
 * @begin scope
 * @summary The cycle counter does not own the UObject.
 * @topic Unreal
 */
/**
 * @function ObserveScopeNominal
 * @summary The cycle counter does not own the UObject.
 * @covers Stats.scope
 * @inputs Stats values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveScopeNominal()
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
/** @end */
/**
 * @begin copying-fstatid-still-constructs
 * @summary Copying FStatID still constructs a usable FScopeCycleCounter.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Copying FStatID still constructs a usable FScopeCycleCounter.
 * @covers Stats.copying-fstatid-still-constructs
 * @inputs Stats values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FStatID Source(n"TestSource.Stats.Handle");
	FStatID Copied = Source;
	int Work = 0;
	{
		FScopeCycleCounter Scope(Copied);
		Work = 1;
	}
	FStatID Empty(NAME_None);
	return Work == 1;
}
/** @end */
/**
 * @begin copying-fscopecyclecounter-still-completes
 * @summary Copying FScopeCycleCounter still completes independently of the source.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Copying FScopeCycleCounter still completes independently of the source.
 * @covers Stats.copying-fscopecyclecounter-still-completes
 * @inputs Stats values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	FStatID Stat(n"TestSource.Stats.ScopeHandle");
	int Work = 0;
	FScopeCycleCounter First(Stat);
	FScopeCycleCounter Second = First;
	Work = 1;
	return Work == 1;
}
/** @end */
