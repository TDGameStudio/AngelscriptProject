/**
 * Streaming-level access through a UWorld: the level count, their order, and
 * each level's editor visibility. The check is reported as a bitmask rather
 * than a single boolean, so a caller can tell which expectation failed —
 * bit 1 is the count, bits 2 and 4 are the ordered identities, and bits 8 and
 * 16 are the two visibility flags. The World and ULevelStreaming handles are
 * runner-owned: the fixture inserts two levels, the first visible and the
 * second hidden, and injects both along with the baseline values.
 *
 * @Theme World.Streaming
 * @Subject Streaming.WorldStreamingAccess
 * @Harness UClass
 * @Tag World.Streaming.WorldStreamingAccess
 * @Namespace StreamingTest
 * @Provenance C++: AngelscriptWorldFunctionLibraryTests.cpp::WorldStreamingAccess
 * @Provenance Substitutions $EXPECTED_COUNT$ / $EXPECTED_FIRST_VISIBLE$ / $EXPECTED_SECOND_VISIBLE$
 * @Provenance become runner parameters (fixture inserts two levels; first visible, second hidden).
 * @Provenance Oracle: mismatch mask 0 when World matches ExpectedCount and ordered identities.
 * @Provenance Extra: ExpectedCount 0 is the empty vector (bit 1); swapped order sets bits 2|4.
 * @Provenance DefaultSafe. World and ULevelStreaming handles are runner-owned.
 */

namespace AccessTest
{
	/**
	 * Compare the world's streaming levels against the injected baselines and
	 * report each mismatch as its own bit.
	 *
	 * @Covers Access.WorldStreaming
	 * @Param World Runner-owned world whose streaming levels are inspected
	 * @Param FirstLevel Level expected at index 0
	 * @Param SecondLevel Level expected at index 1
	 * @Param LevelCount Expected number of streaming levels
	 * @Param FirstVisible Expected editor visibility of the first level
	 * @Param SecondVisible Expected editor visibility of the second level
	 * @Inputs A world with two streaming levels plus the baseline values
	 * @Return 0 when every expectation holds; otherwise the mismatch bitmask
	 */
	int VerifyWorldStreamingAccess(
		UWorld World,
		ULevelStreaming FirstLevel,
		ULevelStreaming SecondLevel,
		int LevelCount,
		bool FirstVisible,
		bool SecondVisible)
	{
		int MismatchMask = 0;

		if (World.GetStreamingLevels().Num() != LevelCount)
		{
			MismatchMask |= 1;
		}
		if (World.GetStreamingLevels().Num() <= 0 || World.GetStreamingLevels()[0] != FirstLevel)
		{
			MismatchMask |= 2;
		}
		if (World.GetStreamingLevels().Num() <= 1 || World.GetStreamingLevels()[1] != SecondLevel)
		{
			MismatchMask |= 4;
		}
		if (FirstLevel.GetShouldBeVisibleInEditor() != FirstVisible)
		{
			MismatchMask |= 8;
		}
		if (SecondLevel.GetShouldBeVisibleInEditor() != SecondVisible)
		{
			MismatchMask |= 16;
		}

		return MismatchMask;
	}

	/**
	 * Observe the nominal case: count, order, and both visibility flags all
	 * match the injected baselines.
	 *
	 * @Kind WorldStory
	 * @Covers Access.WorldStreaming
	 * @Param World Runner-owned world whose streaming levels are inspected
	 * @Param FirstLevel Level expected at index 0
	 * @Param SecondLevel Level expected at index 1
	 * @Param LevelCount Expected number of streaming levels
	 * @Param FirstVisible Expected editor visibility of the first level
	 * @Param SecondVisible Expected editor visibility of the second level
	 * @Inputs A world with two streaming levels in the expected order
	 * @Return 0 when every expectation holds
	 */
	UFUNCTION()
	int WorldStreamingAccessMatchesBaselines(
		UWorld World,
		ULevelStreaming FirstLevel,
		ULevelStreaming SecondLevel,
		int LevelCount,
		bool FirstVisible,
		bool SecondVisible)
	{
		if (World == nullptr || FirstLevel == nullptr || SecondLevel == nullptr)
		{
			throw("TS-LANG-0293 setup: required World or streaming levels are null");
		}
		return VerifyWorldStreamingAccess(World, FirstLevel, SecondLevel, LevelCount, FirstVisible, SecondVisible);
	}

	/**
	 * Observe the empty-count boundary: expecting zero levels makes the count
	 * check fail against a world that has two.
	 *
	 * @Kind WorldStory
	 * @Covers Access.WorldStreaming
	 * @Param World Runner-owned world whose streaming levels are inspected
	 * @Param FirstLevel Level expected at index 0
	 * @Param SecondLevel Level expected at index 1
	 * @Param FirstVisible Expected editor visibility of the first level
	 * @Param SecondVisible Expected editor visibility of the second level
	 * @Inputs A world with two streaming levels, but a baseline count of zero
	 * @Return bit 1 set when the count does not match
	 * @Boundary empty count
	 */
	UFUNCTION()
	int WorldStreamingAccessEmptyCount(
		UWorld World,
		ULevelStreaming FirstLevel,
		ULevelStreaming SecondLevel,
		bool FirstVisible,
		bool SecondVisible)
	{
		if (World == nullptr || FirstLevel == nullptr || SecondLevel == nullptr)
		{
			throw("TS-LANG-0293 setup: required World or streaming levels are null");
		}
		return VerifyWorldStreamingAccess(World, FirstLevel, SecondLevel, 0, FirstVisible, SecondVisible);
	}

	/**
	 * Observe the swapped-order boundary: passing the two levels in reverse
	 * makes both identity checks fail.
	 *
	 * @Kind WorldStory
	 * @Covers Access.WorldStreaming
	 * @Param World Runner-owned world whose streaming levels are inspected
	 * @Param FirstLevel Level expected at index 0
	 * @Param SecondLevel Level expected at index 1
	 * @Param LevelCount Expected number of streaming levels
	 * @Param FirstVisible Expected editor visibility of the first level
	 * @Param SecondVisible Expected editor visibility of the second level
	 * @Inputs A world with two streaming levels, with the expected order reversed
	 * @Return bits 2 and 4 set when neither identity matches
	 * @Boundary swapped order
	 */
	UFUNCTION()
	int WorldStreamingAccessSwappedOrder(
		UWorld World,
		ULevelStreaming FirstLevel,
		ULevelStreaming SecondLevel,
		int LevelCount,
		bool FirstVisible,
		bool SecondVisible)
	{
		if (World == nullptr || FirstLevel == nullptr || SecondLevel == nullptr)
		{
			throw("TS-LANG-0293 setup: required World or streaming levels are null");
		}
		return VerifyWorldStreamingAccess(World, SecondLevel, FirstLevel, LevelCount, SecondVisible, FirstVisible);
	}
}
