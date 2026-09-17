/**
 * @version v1
 * @summary opIndex throws "Array index out of bounds." when the index is not in [0, Num).
 * @topic Containers
 */
/**
 * @version root
 * @summary Read [1] on a one-element array throws "Array index out of bounds."
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Read [1] on a one-element array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> with Add(10); read [1]
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary index == Num()
	 */
	UFUNCTION()
	int ReadPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		return Values[1];
	}
}
/** @end */
/**
 * @version empty-index
 * @parent root
 * @summary Read [0] on an empty array throws "Array index out of bounds."
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Read [0] on an empty array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.opIndex
	 * @Inputs Empty TArray<int>; read [0]
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary index == Num() when Num() == 0
	 */
	UFUNCTION()
	int ReadEmpty()
	{
		TArray<int> Values;
		return Values[0];
	}
}
/** @end */
/**
 * @version write-past-end
 * @parent root
 * @summary Write [1] on a one-element array throws "Array index out of bounds."
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Write [1] on a one-element array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> with Add(10); write [1] = 20
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary index == Num()
	 */
	UFUNCTION()
	void WritePastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		Values[1] = 20;
	}
}
/** @end */
/**
 * @version negative-index
 * @parent root
 * @summary Read [-1] throws "Array index out of bounds."
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Read [-1] throws; IsValidIndex uses unsigned compare.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> with Add(10); read [-1]
	 * @Return does not return; throws "Array index out of bounds."
	 * @Boundary Index < 0
	 */
	UFUNCTION()
	int ReadNegativeIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		return Values[-1];
	}
}
/** @end */
/**
 * @version write-negative-index
 * @parent root
 * @summary Write [-1] throws "Array index out of bounds."
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Write [-1] throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.opIndex
	 * @Inputs TArray<int> with Add(10); write [-1] = 20
	 * @Return void; throws "Array index out of bounds."
	 * @Boundary Index < 0
	 */
	UFUNCTION()
	void WriteNegativeIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values[-1] = 20;
	}
}
/** @end */
