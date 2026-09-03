/**
 * The FQualifiedFrameTime.AsSeconds mixin binding compiles and links. C++
 * expects AsSeconds_Compiles() to return 1. The observers cover the default
 * zero seconds and the independence of two default times.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.AsSecondsMixinCompiles
 * @Harness Function
 * @Tag Feature.Mixin.AsSecondsMixinCompiles
 * @Namespace MixinTest
 * @Provenance Theme: Feature.Mixin. Positive FQualifiedFrameTime.AsSeconds mixin binding.
 * @Provenance C++: AngelscriptFrameTimeFunctionLibraryTests.cpp::AsSecondsMixinCompiles
 * @Provenance ExpectGlobalInt AsSeconds_Compiles() == 1.
 * @Provenance Extra: default AsSeconds is 0.0; two default times match.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace MixinTest
{
	/**
	 * Call AsSeconds on a default FQualifiedFrameTime so the mixin binding
	 * compiles and links.
	 *
	 * @Kind Observe
	 * @Covers Mixin.AsSecondsMixinCompiles
	 * @Inputs a default-constructed FQualifiedFrameTime
	 * @Return 1 after AsSeconds() is called
	 */
	UFUNCTION()
	int AsSeconds_Compiles()
	{
		FQualifiedFrameTime DefaultTime;
		DefaultTime.AsSeconds();
		return 1;
	}

	/**
	 * Observe that a default FQualifiedFrameTime reports zero seconds.
	 *
	 * @Kind Observe
	 * @Covers Mixin.AsSecondsMixinCompiles
	 * @Inputs a default-constructed FQualifiedFrameTime
	 * @Return 0.0
	 * @Boundary default AsSeconds
	 */
	UFUNCTION()
	double DefaultAsSecondsIsZero()
	{
		FQualifiedFrameTime DefaultTime;
		return DefaultTime.AsSeconds();
	}

	/**
	 * Observe that two default times both report zero seconds.
	 *
	 * @Kind Observe
	 * @Covers Mixin.AsSecondsMixinCompiles
	 * @Inputs two default-constructed FQualifiedFrameTime values
	 * @Return true when both AsSeconds() results are 0.0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoDefaultTimesMatch()
	{
		FQualifiedFrameTime First;
		FQualifiedFrameTime Second;
		if (First.AsSeconds() != 0.0)
		{
			return false;
		}
		return Second.AsSeconds() == 0.0;
	}
}
