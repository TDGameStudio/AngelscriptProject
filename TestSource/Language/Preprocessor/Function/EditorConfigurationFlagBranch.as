/**
 * The EDITOR flag is a configuration flag, so code may be guarded with it. With
 * EDITOR true the #if branch survives and the #else branch is stripped.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.EditorConfigurationFlagBranch
 * @Harness Function
 * @Tag Language.Preprocessor.EditorConfigurationFlagBranch
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::EditorConfigurationFlagBranch
 * @Provenance lines 219-228; preprocess flags EDITOR=true.
 * @Provenance sha256=74ccb2a9729b80b8fd23e46e1d4ed9e677ee57ac4f742e7890413c4c54349e39.
 * @Provenance Oracle: Entry() == 11. The #else return -11 is stripped.
 * @Provenance Extra: EDITOR false is the -11 boundary, not the C++ run.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * Returns a different value from each EDITOR branch.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the configuration flag EDITOR
	 * @Return 11 when EDITOR is set, otherwise -11
	 */
	int Entry()
	{
#if EDITOR
		return 11;
#else
		return -11;
#endif
	}

	/**
	 * Observe the branch selected with EDITOR set true.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs EDITOR=true
	 * @Return true when the surviving branch returns 11
	 */
	UFUNCTION()
	bool EditorFlagBranchSelected()
	{
		return Entry() == 11;
	}
}
