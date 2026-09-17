/**
 * @version v1
 * @summary Observe ULevelStreaming editor visibility, FRuntimeFloatCurve key count, and URuntimeFloatCurveMixinLibrary::GetTimeRange out writeback.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ULevelStreaming editor visibility, FRuntimeFloatCurve key count, and URuntimeFloatCurveMixinLibrary::GetTimeRange out writeback.
 * @topic Baseline
 */
// int FRuntimeFloatCurve.GetNumKeys() const;
// void URuntimeFloatCurveMixinLibrary::GetTimeRange(const FRuntimeFloatCurve& Target, float32&out MinTime, float32&out MaxTime);
// Inputs: A transient ULevelStreamingDynamic, an empty FRuntimeFloatCurve,
// the same curve after AddDefaultKey at 0.5/1.25 and 3.0/9.5, and a null
// ULevelStreaming receiver as the diagnostic path.
// Expected observations: Two newly constructed streaming levels report the
// same editor visibility request. Empty GetNumKeys is 0; seeded GetNumKeys
// is 2. GetTimeRange writes 0,0 for empty and 0.5,3.0 after keys. Out values
// are recorded before and after each call.
// Boundary/ownership: GetTimeRange writes through out parameters; it does not
// own the curve. GetShouldBeVisibleInEditor on a null handle is Null pointer
// access and lives in ExerciseExpectedFailure.

namespace TS_FunctionLibraryMixins_Queries_01
{
	bool Observe_GetShouldBeVisibleInEditor_Nominal()
	{
		ULevelStreamingDynamic First = Cast<ULevelStreamingDynamic>(
			NewObject(GetTransientPackage(), ULevelStreamingDynamic::StaticClass(), n"TSFunctionLibraryMixinsStreamingLevelA", true));
		ULevelStreamingDynamic Second = Cast<ULevelStreamingDynamic>(
			NewObject(GetTransientPackage(), ULevelStreamingDynamic::StaticClass(), n"TSFunctionLibraryMixinsStreamingLevelB", true));
		if (First is null || Second is null)
		{
			throw("TS_FunctionLibraryMixins_Queries_01 setup: required LevelStreaming is null");
		}
		return First.GetShouldBeVisibleInEditor() == Second.GetShouldBeVisibleInEditor();
	}

	bool Observe_GetNumKeys_Nominal()
	{
		FRuntimeFloatCurve Empty;
		FRuntimeFloatCurve Seeded;
		Seeded.AddDefaultKey(0.5f, 1.25f);
		Seeded.AddDefaultKey(3.0f, 9.5f);
		return Empty.GetNumKeys() == 0 && Seeded.GetNumKeys() == 2;
	}

	bool Observe_GetTimeRange_Nominal()
	{
		FRuntimeFloatCurve Empty;
		float32 EmptyMinBefore = -1.0f;
		float32 EmptyMaxBefore = -1.0f;
		float32 EmptyMin = EmptyMinBefore;
		float32 EmptyMax = EmptyMaxBefore;
		URuntimeFloatCurveMixinLibrary::GetTimeRange(Empty, EmptyMin, EmptyMax);

		FRuntimeFloatCurve Seeded;
		Seeded.AddDefaultKey(0.5f, 1.25f);
		Seeded.AddDefaultKey(3.0f, 9.5f);
		float32 SeededMinBefore = -1.0f;
		float32 SeededMaxBefore = -1.0f;
		float32 SeededMin = SeededMinBefore;
		float32 SeededMax = SeededMaxBefore;
		URuntimeFloatCurveMixinLibrary::GetTimeRange(Seeded, SeededMin, SeededMax);
		return EmptyMin == 0.0f &&
			EmptyMax == 0.0f &&
			EmptyMin != EmptyMinBefore &&
			EmptyMax != EmptyMaxBefore &&
			SeededMin == 0.5f &&
			SeededMax == 3.0f &&
			SeededMin != SeededMinBefore &&
			SeededMax != SeededMaxBefore;
	}

	void ExerciseExpectedFailure()
	{
		ULevelStreaming NullLevel = nullptr;
		bool bNullReceiver = NullLevel.GetShouldBeVisibleInEditor();
	}
}
/** @end */
