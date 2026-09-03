/**
 * UCLASS metadata plus an empty child inherit. C++ verifies both classes generate
 * with ComponentWrapperClass, ConversionRoot, HideFunctions, SparseClassDataTypes,
 * AutoExpandCategories, CollapseCategories and DontCollapseCategories metadata.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.UClassSpecialAndInheritedMetadata
 * @Harness UClass
 * @Tag Feature.Inheritance.UClassSpecialAndInheritedMetadata
 * @Provenance Theme: Feature.Inheritance. Positive UCLASS metadata plus empty child inherit.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassSpecialAndInheritedMetadata
 * @Provenance sha256=86adb90b15799889a4eff8d37bc37f64390882b839cf4e0ff1820d39673242c2; lines 798-808.
 * @Provenance Oracle: both classes generate; ComponentWrapperClass/ConversionRoot/HideFunctions/
 * @Provenance SparseClassDataTypes/AutoExpandCategories/CollapseCategories/DontCollapseCategories metadata.
 * @Provenance Extra: local construct of base and child; two child locals independent. DefaultSafe.
 */

UCLASS(ComponentWrapperClass, meta=(ConversionRoot, HideFunctions="CoverageHiddenFunction", SparseClassDataTypes="CoverageSparseData", AutoExpandCategories="CoverageExpanded", CollapseCategories, DontCollapseCategories))
class UCoverageUClassSpecialMetadataBaseObject : UObject
{
}

UCLASS()
class UCoverageUClassInheritedMetadataObject : UCoverageUClassSpecialMetadataBaseObject
{
	/**
	 * Observe that locally constructed metadata handles stay null.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassSpecialAndInheritedMetadata
	 * @Inputs local constructs of the base and child
	 * @Return true when both local handles are null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool LocalConstructHandlesAreNull()
	{
		UCoverageUClassSpecialMetadataBaseObject Base;
		UCoverageUClassInheritedMetadataObject Child;
		if (Base != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that two child locals are distinct when both are non-null.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.UClassSpecialAndInheritedMetadata
	 * @Inputs two locally constructed child handles
	 * @Return true when both are non-null and distinct
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoChildLocalsIndependent()
	{
		UCoverageUClassInheritedMetadataObject First;
		UCoverageUClassInheritedMetadataObject Second;
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}
