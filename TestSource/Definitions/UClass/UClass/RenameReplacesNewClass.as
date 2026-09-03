/**
 * Rename pair AFTER replacement. ATestScriptClassRenameNew Version=2 on the
 * renamed CDO. Keep Version.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.RenameReplacesNewClass
 * @Harness UClass
 * @Tag Definitions.UClass.RenameReplacesNewClass
 * @Provenance Theme: Definitions.UClass. WorldStory rename pair AFTER replacement.
 * @Provenance C++: AngelscriptScriptClassCreationTests.cpp::RenameReplacesOldClass block 2
 * @Provenance Oracle: ATestScriptClassRenameNew Version=2 on the renamed CDO. Old name is replaced.
 * @Provenance Extra: nullptr actor is the empty handle; mutating First does not write Second.
 * @Provenance FixtureIsolated. Pair with RenameReplacesOldClass.as. Keep Version.
 */

UCLASS()
class ATestScriptClassRenameNew : AActor
{
	UPROPERTY()
	int Version = 2;

	/**
	 * Observe the new-class Version default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Inputs a freshly constructed actor
	 * @Return true when Version is 2
	 */
	UFUNCTION()
	bool VersionDefault()
	{
		return Version == 2;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Inputs ATestScriptClassRenameNew Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestScriptClassRenameNew Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Rename
	 * @Param Second Other actor expected to stay at 2
	 * @Inputs this.Version set to 0
	 * @Return true when Second.Version is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassRenameNew Second)
	{
		if (Second is null)
		{
			throw("RenameReplacesNewClass setup: required Second is null");
		}
		Version = 0;
		return Second.Version == 2;
	}
}
