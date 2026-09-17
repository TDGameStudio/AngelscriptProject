/**
 * @version v1
 * @summary opIndex throws when the key is not present. This module compiles; each entry is a RuntimeException trigger, not a bool Observe. Find / Contains / FindOrAdd cover the non-throwing miss path.
 * @topic Containers
 */
/**
 * @version root
 * @summary opIndex throws when the key is not present. This module compiles; each entry is a RuntimeException trigger, not a bool Observe. Find / Contains / FindOrAdd cover the non-throwing miss path.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Read [] of a missing key throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, int> with Add(10, 100); read [99]
	 * @Return does not return; throws "Could not find key in map for index operator."
	 * @Boundary missing key
	 */
	UFUNCTION()
	int ReadMissingKey()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		return Values[99];
	}

	/**
	 * Write [] of a missing key throws; it does not insert.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.opIndex
	 * @Inputs TMap<int, int> with Add(10, 100); write [99] = 7
	 * @Return void; throws "Could not find key in map for index operator."
	 * @Boundary missing key
	 */
	UFUNCTION()
	void WriteMissingKey()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values[99] = 7;
	}

	/**
	 * Read [] on an empty map throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.opIndex
	 * @Inputs Empty TMap<int, int>; read [0]
	 * @Return does not return; throws "Could not find key in map for index operator."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	int ReadEmpty()
	{
		TMap<int, int> Values;
		return Values[0];
	}

	/**
	 * Read [] of a key that was removed throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.opIndex
	 * @Inputs Add(10, 100); Remove(10); read [10]
	 * @Return does not return; throws "Could not find key in map for index operator."
	 * @Boundary removed key
	 */
	UFUNCTION()
	int ReadRemovedKey()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Remove(10);
		return Values[10];
	}
}
/** @end */
