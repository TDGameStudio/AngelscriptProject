/**
 * Rename pair BEFORE replacement. ATestScriptClassRenameOld Version=1 is the
 * retained-then-replaced class. Keep Version.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.RenameReplacesOldClass
 * @Harness UClass
 * @Tag Definitions.UClass.RenameReplacesOldClass
 * @Provenance Theme: Definitions.UClass. WorldStory rename pair BEFORE replacement.
 * @Provenance C++: AngelscriptScriptClassCreationTests.cpp::RenameReplacesOldClass block 1
 * @Provenance Oracle: ATestScriptClassRenameOld Version=1 is the retained-then-replaced class.
 * @Provenance Extra: nullptr actor is the empty handle; mutating First does not write Second.
 * @Provenance FixtureIsolated. Pair with RenameReplacesNewClass.as. Keep Version.
 */

UCLASS()
class ATestScriptClassRenameOld : AActor
{
	UPROPERTY()
	int Version = 1;

	/**
	 * Observe the old-class Version default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Inputs a freshly constructed actor
	 * @Return true when Version is 1
	 */
	UFUNCTION()
	bool VersionDefault()
	{
		return Version == 1;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Inputs ATestScriptClassRenameOld Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassRenameOld Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Param Second Other actor expected to stay at 1
	 * @Inputs this.Version set to 0
	 * @Return true when Second.Version is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassRenameOld Second)
	{
		if (Second is null)
		{
			throw("RenameReplacesOldClass setup: required Second is null");
		}
		Version = 0;
		return Second.Version == 1;
	}
}
