// Theme: Language.Access. Positive streaming-level count, order, and editor visibility.
// C++: AngelscriptWorldFunctionLibraryTests.cpp::WorldStreamingAccess
// Substitutions $EXPECTED_COUNT$ / $EXPECTED_FIRST_VISIBLE$ / $EXPECTED_SECOND_VISIBLE$
// become runner parameters (fixture inserts two levels; first visible, second hidden).
// Oracle: mismatch mask 0 when World matches ExpectedCount and ordered identities.
// Extra: ExpectedCount 0 is the empty vector (bit 1); swapped order sets bits 2|4.
// DefaultSafe. World and ULevelStreaming handles are runner-owned.

int VerifyWorldStreamingAccess(UWorld World, ULevelStreaming ExpectedFirst, ULevelStreaming ExpectedSecond, int ExpectedCount, bool ExpectedFirstVisible, bool ExpectedSecondVisible)
{
	int MismatchMask = 0;

	if (World.GetStreamingLevels().Num() != ExpectedCount)
	{
		MismatchMask |= 1;
	}
	if (World.GetStreamingLevels().Num() <= 0 || World.GetStreamingLevels()[0] != ExpectedFirst)
	{
		MismatchMask |= 2;
	}
	if (World.GetStreamingLevels().Num() <= 1 || World.GetStreamingLevels()[1] != ExpectedSecond)
	{
		MismatchMask |= 4;
	}
	if (ExpectedFirst.GetShouldBeVisibleInEditor() != ExpectedFirstVisible)
	{
		MismatchMask |= 8;
	}
	if (ExpectedSecond.GetShouldBeVisibleInEditor() != ExpectedSecondVisible)
	{
		MismatchMask |= 16;
	}

	return MismatchMask;
}

int Observe_WorldStreamingAccess_Nominal(UWorld World, ULevelStreaming ExpectedFirst, ULevelStreaming ExpectedSecond, int ExpectedCount, bool ExpectedFirstVisible, bool ExpectedSecondVisible)
{
	if (World == nullptr || ExpectedFirst == nullptr || ExpectedSecond == nullptr)
	{
		throw("TS-LANG-0293 setup: required World or streaming levels are null");
	}
	return VerifyWorldStreamingAccess(World, ExpectedFirst, ExpectedSecond, ExpectedCount, ExpectedFirstVisible, ExpectedSecondVisible);
}

int Observe_WorldStreamingAccess_EmptyCount(UWorld World, ULevelStreaming ExpectedFirst, ULevelStreaming ExpectedSecond, bool ExpectedFirstVisible, bool ExpectedSecondVisible)
{
	if (World == nullptr || ExpectedFirst == nullptr || ExpectedSecond == nullptr)
	{
		throw("TS-LANG-0293 setup: required World or streaming levels are null");
	}
	return VerifyWorldStreamingAccess(World, ExpectedFirst, ExpectedSecond, 0, ExpectedFirstVisible, ExpectedSecondVisible);
}

int Observe_WorldStreamingAccess_SwappedOrder(UWorld World, ULevelStreaming ExpectedFirst, ULevelStreaming ExpectedSecond, int ExpectedCount, bool ExpectedFirstVisible, bool ExpectedSecondVisible)
{
	if (World == nullptr || ExpectedFirst == nullptr || ExpectedSecond == nullptr)
	{
		throw("TS-LANG-0293 setup: required World or streaming levels are null");
	}
	return VerifyWorldStreamingAccess(World, ExpectedSecond, ExpectedFirst, ExpectedCount, ExpectedSecondVisible, ExpectedFirstVisible);
}
