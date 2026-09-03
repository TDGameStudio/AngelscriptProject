/**
 * Reading an existing native CVar through FConsoleVariable must return the
 * engine's own value, not the script-supplied default, and writes must stick.
 * The observers use the runner-provided native baseline rather than hard-coding
 * the engine default.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ExistingEngineCVarSmokePreservesAndRestoresValues
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ExistingEngineCVarSmokePreservesAndRestoresValues
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ExistingEngineCVarSmokePreservesAndRestoresValues
 * @Provenance sha256=6180652d6ecfb45a45a33100c28567ca9b84cbab73396ca2e058781a8ce3da42; lines 520-533.
 * @Provenance Oracle: ReadExistingMaxFPS returns the native baseline (not script 12.0);
 * @Provenance WriteExistingMaxFPS returns 83.0. Extra: script default 12.0 is not applied
 * @Provenance to an existing native. DefaultSafe (mutates t.MaxFPS until restored).
 */

namespace SyntaxTest
{
	/**
	 * Reads the native t.MaxFPS through a script CVar handle.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the existing t.MaxFPS variable
	 * @Return the native value, not the script default
	 */
	float ReadExistingMaxFPS()
	{
		FConsoleVariable MaxFPS("t.MaxFPS", 12.0f, "Script default should not replace native t.MaxFPS");
		return MaxFPS.GetFloat();
	}

	/**
	 * Writes and reads back the native t.MaxFPS.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the existing t.MaxFPS variable
	 * @Return 83.0 after the write
	 */
	float WriteExistingMaxFPS()
	{
		FConsoleVariable MaxFPS("t.MaxFPS", 12.0f, "Script default should not replace native t.MaxFPS");
		MaxFPS.SetFloat(83.0f);
		return MaxFPS.GetFloat();
	}

	/**
	 * Observe that the native value is not the script default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ReadExistingMaxFPS()
	 * @Return true when the value differs from 12.0
	 * @Boundary script default not applied
	 */
	UFUNCTION()
	bool ExistingMaxFPSReadNotScriptDefault()
	{
		return !Math::IsNearlyEqual(ReadExistingMaxFPS(), 12.0f, 0.001f);
	}

	/**
	 * Observe that a write to the native variable sticks.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteExistingMaxFPS()
	 * @Return true when the value is 83.0
	 */
	UFUNCTION()
	bool ExistingMaxFPSWriteNominal()
	{
		return Math::IsNearlyEqual(WriteExistingMaxFPS(), 83.0f, 0.001f);
	}

	/**
	 * Observe that the read matches the runner's native baseline.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ReadExistingMaxFPS() and the native baseline
	 * @Return true when both agree
	 * @Boundary native baseline
	 * @Param BaselineNative the native value the runner captured beforehand
	 */
	UFUNCTION()
	bool ExistingMaxFPSMatchesNativeBaseline(float32 BaselineNative)
	{
		return Math::IsNearlyEqual(ReadExistingMaxFPS(), BaselineNative, 0.001f);
	}
}
