// Purpose: Observe TSet explicit iterators and Proceed returning the current
// element for mutable and const iterators.
// AS-facing API: const T& TSetIterator<T>.Proceed();
// const T& TSetConstIterator<T>.Proceed();
// TSetIterator<T> TSet<T>.Iterator();
// TSetConstIterator<T> TSet<T>.Iterator() const;
// Inputs: Empty set, populated {1, 2}, and Proceed until CanProceed is false.
// Expected observations: Empty Iterator CanProceed is false. First Proceed
// returns 1 or 2 and the second returns the remaining element. Const Proceed
// yields the same membership.
// Boundary/ownership: Create starts before the first element; Proceed both
// returns and advances. Proceed past the last element throws.

namespace TS_TSet_IndexAndIteration_01
{
	bool Observe_Proceed_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		TSetIterator<int32> It = Set.Iterator();
		bool bCanEnter = It.CanProceed;
		const int32& First = It.Proceed();
		bool bCanContinue = It.CanProceed;
		const int32& Second = It.Proceed();
		bool bExhausted = !It.CanProceed;

		const TSet<int32> ConstSet = Set;
		TSetConstIterator<int32> ConstIt = ConstSet.Iterator();
		const int32& ConstFirst = ConstIt.Proceed();
		const int32& ConstSecond = ConstIt.Proceed();

		return bCanEnter &&
			(First == 1 || First == 2) &&
			bCanContinue &&
			(Second == 1 || Second == 2) &&
			Second != First &&
			bExhausted &&
			(ConstFirst == 1 || ConstFirst == 2) &&
			(ConstSecond == 1 || ConstSecond == 2) &&
			ConstFirst != ConstSecond;
	}

	bool Observe_Iterator_Nominal()
	{
		TSet<int32> Empty;
		TSetIterator<int32> EmptyIt = Empty.Iterator();

		TSet<int32> Set;
		Set.Add(1);
		TSetIterator<int32> It = Set.Iterator();

		const TSet<int32> ConstSet = Set;
		TSetConstIterator<int32> ConstIt = ConstSet.Iterator();

		TSetIterator<int32> Copied(It);

		return !EmptyIt.CanProceed && It.CanProceed && ConstIt.CanProceed && Copied.CanProceed;
	}
}
