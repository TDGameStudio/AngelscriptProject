/**
 * Macro detection on a script class: the preprocessor records the property
 * macro Mesh and the function macro BeginPlay. The mesh is left at its default,
 * and the empty BeginPlay override is a no-op that does not assign it.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.MacroDetection
 * @Harness UClass
 * @Tag Language.Preprocessor.MacroDetection
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::MacroDetection
 * @Provenance lines 73-84; preprocess records property macro Mesh and function macro BeginPlay.
 * @Provenance sha256=37ad72c168426874b23a1b064d767bf009984f512097a98f984d01bb9a8836ef.
 * @Provenance Oracle: Mesh default is null; empty BeginPlay does not assign Mesh.
 * @Provenance Extra: null Mesh is the empty/default vector; BeginPlay is a no-op override.
 * @Provenance FixtureIsolated. Keep UPROPERTY name Mesh.
 */

class AMacroActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UStaticMesh Mesh;

	/**
	 * An empty lifecycle override that must not assign the mesh.
	 *
	 * @Covers Preprocessor.Macros
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
	}

	/**
	 * Observe that the mesh is left at its null default.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Macros
	 * @Inputs a freshly constructed actor
	 * @Return true when Mesh is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool MeshDefaultsToNull()
	{
		return Mesh is null;
	}

	/**
	 * Observe that running the empty override leaves the mesh null.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Macros
	 * @Inputs BeginPlay() then Mesh
	 * @Return true when Mesh is still null
	 * @Boundary no-op override
	 */
	UFUNCTION()
	bool EmptyBeginPlayLeavesMeshNull()
	{
		BeginPlay();
		return Mesh is null;
	}
}
