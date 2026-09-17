/**
 * @version v1
 * @summary A script actor compiles to a generated UClass. Spawned SpawnMarker is 7 and the class is AActor-derived. Keep SpawnMarker for VerifyByPath.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A script actor compiles to a generated UClass. Spawned SpawnMarker is 7 and the class is AActor-derived. Keep SpawnMarker for VerifyByPath.
 * @topic Baseline
 */
UCLASS()
class ATestScriptClassCompilesToUClass : AActor
{
	UPROPERTY()
	int SpawnMarker = 7;

	UPROPERTY()
	int EmptyMarker = 0;

	/**
	 * Observe the SpawnMarker default.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Inputs a freshly constructed actor
	 * @Return SpawnMarker
	 */
	UFUNCTION()
	int SpawnMarkerDefault()
	{
		return SpawnMarker;
	}

	/**
	 * Observe the EmptyMarker default.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Inputs a freshly constructed actor
	 * @Return EmptyMarker
	 * @Boundary empty/default vector
	 */
	UFUNCTION()
	int EmptyMarkerDefault()
	{
		return EmptyMarker;
	}

	/**
	 * Observe that the generated class is an AActor child.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Inputs ATestScriptClassCompilesToUClass::StaticClass()
	 * @Return true when IsChildOf(AActor::StaticClass())
	 */
	UFUNCTION()
	bool IsActorChild()
	{
		return ATestScriptClassCompilesToUClass::StaticClass().IsChildOf(AActor::StaticClass());
	}

	/**
	 * Observe that writing this actor leaves another at SpawnMarker 7.
	 *
	 * @Kind Observe
	 * @Covers UClass.GeneratedClass
	 * @Param Second Other actor expected to stay at 7
	 * @Inputs this.SpawnMarker set to 1
	 * @Return true when Second.SpawnMarker is 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptClassCompilesToUClass Second)
	{
		if (Second is null)
		{
			throw("CompilesToUClass setup: required Second is null");
		}
		SpawnMarker = 1;
		return Second.SpawnMarker == 7;
	}
}
/** @end */
