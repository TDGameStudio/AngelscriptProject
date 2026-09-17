/**
 * @version v1
 * @summary UCLASS metadata plus an empty child inherit. C++ verifies both classes generate with ComponentWrapperClass, ConversionRoot, HideFunctions, SparseClassDataTypes, AutoExpandCategories, CollapseCategories and.
 * @topic Feature
 */
/**
 * @version root
 * @summary UCLASS metadata plus an empty child inherit. C++ verifies both classes generate with ComponentWrapperClass, ConversionRoot, HideFunctions, SparseClassDataTypes, AutoExpandCategories, CollapseCategories and.
 * @topic Baseline
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
/** @end */
