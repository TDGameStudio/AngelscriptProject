/**
 * Meta ClampMin/ClampMax on Health compiles. The observers cover Health 50, the
 * ClampMin 0 write, and the ClampMax 100 write.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.MetaClampMinMax
 * @Harness UClass
 * @Tag Definitions.UProperty.MetaClampMinMax
 * @Provenance Theme: Definitions.UProperty. WorldStory: Meta ClampMin/ClampMax on Health.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles
 * @Provenance UPropSP_Meta; lines 163-169;
 * @Provenance sha256=3ebef64627d00943e1367c5093ba0e2d5e9b7b42a5c9e11b40062794b194f52f.
 * @Provenance Oracle: Health default is 50 on the spawned actor.
 * @Provenance Extra: 0 is ClampMin empty/default; 100 is ClampMax boundary.
 * @Provenance FixtureIsolated.
 */

class AUPropMetaActor : AActor
{
	UPROPERTY(Meta = (ClampMin = 0, ClampMax = 100))
	int Health = 50;

	/**
	 * Observe the default Health of 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs none
	 * @Return true when Health is 50
	 */
	UFUNCTION()
	bool HealthDefault()
	{
		return Health == 50;
	}

	/**
	 * Observe a ClampMin 0 write that restores 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs Health written to 0 then restored
	 * @Return true when the min write lands and the saved default is 50
	 * @Boundary ClampMin
	 */
	UFUNCTION()
	bool HealthClampMinEmpty()
	{
		int Saved = Health;
		Health = 0;
		bool bMin = Health == 0;
		Health = Saved;
		if (!bMin)
		{
			return false;
		}
		return Saved == 50;
	}

	/**
	 * Observe a ClampMax 100 write that restores 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs Health written to 100 then restored
	 * @Return true when the max write lands and the saved default is 50
	 * @Boundary ClampMax
	 */
	UFUNCTION()
	bool HealthClampMaxBoundary()
	{
		int Saved = Health;
		Health = 100;
		bool bMax = Health == 100;
		Health = Saved;
		if (!bMax)
		{
			return false;
		}
		return Saved == 50;
	}
}
