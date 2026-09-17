/**
 * @version v1
 * @summary Rename pair AFTER replacement. ATestScriptClassRenameNew Version=2 on the renamed CDO. Keep Version.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Rename pair AFTER replacement. ATestScriptClassRenameNew Version=2 on the renamed CDO. Keep Version.
 * @topic Baseline
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
/** @end */
