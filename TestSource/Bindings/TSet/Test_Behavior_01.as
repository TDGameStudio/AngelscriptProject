// Purpose: Observe TSet/TSetIterator type declarations, copy-constructed
// iterators, CanProceed, and range-for element visitation.
// AS-facing API: template<class T> struct TSet;
// template<class T> struct TSetIterator;
// template<class T> struct TSetConstIterator;
// TSet<T> Set; TSetIterator<T> It(const TSetIterator<T>& Other);
// bool TSetIterator<T>.CanProceed;
// TSetConstIterator<T> It(const TSetConstIterator<T>& Other);
// bool TSetConstIterator<T>.CanProceed;
// for (auto Value : Set) { Use(Value); }
// Inputs: Empty TSet<int32>, populated {1, 2}, TSet<FName>, copied iterators,
// and a range-for over {1, 2}.
// Expected observations: Default Set is empty. Copy-constructed iterators
// preserve CanProceed. Range-for visits both elements exactly once.
// Boundary/ownership: Declared template types own element lifetimes. Range-for
// aliases live elements.

namespace TS_TSet_Behavior_01
{
	// TSet<int32> default construction is an empty value type.
	bool Observe_Surface001_Nominal()
	{
		TSet<int32> Set;
		return Set.IsEmpty();
	}

	// TSetIterator is produced by Iterator() on a populated set and CanProceed.
	bool Observe_Surface002_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		TSetIterator<int32> It = Set.Iterator();
		return It.CanProceed;
	}

	// TSetConstIterator is produced by Iterator() on a const populated set.
	bool Observe_Surface003_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		const TSet<int32> ConstSet = Set;
		TSetConstIterator<int32> It = ConstSet.Iterator();
		return It.CanProceed;
	}

	// Default TSet<int32>, TSet<FName>, and TSet<FString> are empty.
	bool Observe_Surface004_Nominal()
	{
		TSet<int32> Set;
		TSet<FName> Names;
		TSet<FString> Texts;
		return Set.IsEmpty() && Names.IsEmpty() && Texts.IsEmpty();
	}

	// Copy-constructed TSetIterator preserves CanProceed on a populated set.
	bool Observe_It_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		TSetIterator<int32> Other = Set.Iterator();
		TSetIterator<int32> It(Other);
		return It.CanProceed && Other.CanProceed;
	}

	// Empty iterator CanProceed is false; populated iterator CanProceed is true.
	bool Observe_Surface018_Nominal()
	{
		TSet<int32> Empty;
		TSetIterator<int32> EmptyIt = Empty.Iterator();
		TSet<int32> Set;
		Set.Add(1);
		TSetIterator<int32> It = Set.Iterator();
		return !EmptyIt.CanProceed && It.CanProceed;
	}

	// Copy-constructed TSetConstIterator CanProceed; empty const iterator does not.
	bool Observe_Surface022_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		const TSet<int32> ConstSet = Set;
		TSetConstIterator<int32> Other = ConstSet.Iterator();
		TSetConstIterator<int32> It(Other);
		TSet<int32> Empty;
		const TSet<int32> ConstEmpty = Empty;
		TSetConstIterator<int32> EmptyIt = ConstEmpty.Iterator();
		return It.CanProceed && !EmptyIt.CanProceed;
	}

	// Range-for visits {1, 2} exactly once with sum 3.
	bool Observe_for_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		int32 VisitCount = 0;
		int32 Sum = 0;
		for (int32 Value : Set)
		{
			VisitCount += 1;
			Sum += Value;
		}
		return VisitCount == 2 && Sum == 3;
	}
}
