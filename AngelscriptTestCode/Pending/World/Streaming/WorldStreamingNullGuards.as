/**
 * @version v1
 * @summary World streaming getters compiled for both valid and null receivers: the C++ runner passes a valid world and level to the observers and separately exercises the null path, which throws at runtime rather than failing to.
 * @topic World
 */
/**
 * @version root
 * @summary World streaming getters compiled for both valid and null receivers: the C++ runner passes a valid world and level to the observers and separately exercises the null path, which throws at runtime rather than failing to.
 * @topic Baseline
 */
namespace StreamingTest
{
	/**
	 * Counts a world's streaming levels.
	 *
	 * @Covers Streaming.WorldStreamingNullGuards
	 * @Inputs a world instance
	 * @Return the streaming level count
	 * @Param World the world to query
	 */
	int GetStreamingLevelCount(UWorld World)
	{
		return World.GetStreamingLevels().Num();
	}

	/**
	 * Reports a level's editor visibility.
	 *
	 * @Covers Streaming.WorldStreamingNullGuards
	 * @Inputs a streaming level
	 * @Return the level's editor visibility
	 * @Param Level the streaming level to query
	 */
	bool GetLevelVisibleInEditor(ULevelStreaming Level)
	{
		return Level.GetShouldBeVisibleInEditor();
	}

	/**
	 * Observe the streaming count on a valid world.
	 *
	 * @Kind Observe
	 * @Covers Streaming.WorldStreamingNullGuards
	 * @Inputs a valid world
	 * @Return the streaming level count
	 * @Param World the world to query
	 */
	UFUNCTION()
	int GetStreamingLevelCountValid(UWorld World)
	{
		return GetStreamingLevelCount(World);
	}

	/**
	 * Observe the editor visibility on a valid level.
	 *
	 * @Kind Observe
	 * @Covers Streaming.WorldStreamingNullGuards
	 * @Inputs a valid streaming level
	 * @Return the level's editor visibility
	 * @Param Level the streaming level to query
	 */
	UFUNCTION()
	bool GetLevelVisibleInEditorValid(ULevelStreaming Level)
	{
		return GetLevelVisibleInEditor(Level);
	}
}
/** @end */
