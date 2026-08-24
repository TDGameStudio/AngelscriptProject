// Purpose: Observe FStatID and FScopeCycleCounter value-type declaration and
// copy assignment of constructed stats. Each function returns that scoped
// work completed after copy.
// AS-facing API: struct FStatID; struct FScopeCycleCounter;
// Inputs: A named FStatID, a copied FStatID, and a scope constructed from the
// copy. Default/empty is the NAME_None identifier.
// Expected observations: Copying a FStatID still constructs a usable scope.
// A second scope from the same identifier completes independently.
// Boundary/ownership: FStatID native lifetime is managed automatically.
// FScopeCycleCounter begins on construction and ends when the value leaves
// scope. Copies do not stop the original scope.

namespace TS_Stats_ConstructionAndAssignment_01
{
	// Copying FStatID still constructs a usable FScopeCycleCounter.
	bool Observe_Surface001_Nominal()
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

	// Copying FScopeCycleCounter still completes independently of the source.
	bool Observe_Surface002_Nominal()
	{
		FStatID Stat(n"TestSource.Stats.ScopeHandle");
		int Work = 0;
		FScopeCycleCounter First(Stat);
		FScopeCycleCounter Second = First;
		Work = 1;
		return Work == 1;
	}
}
