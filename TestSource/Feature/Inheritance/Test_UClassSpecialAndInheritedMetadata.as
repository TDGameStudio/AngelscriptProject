// Theme: Feature.Inheritance. Positive UCLASS metadata plus empty child inherit.
// C++: AngelscriptCoverageUClassTests.cpp::UClassSpecialAndInheritedMetadata
// sha256=86adb90b15799889a4eff8d37bc37f64390882b839cf4e0ff1820d39673242c2; lines 798-808.
// Oracle: both classes generate; ComponentWrapperClass/ConversionRoot/HideFunctions/
// SparseClassDataTypes/AutoExpandCategories/CollapseCategories/DontCollapseCategories metadata.
// Extra: local construct of base and child; two child locals independent. DefaultSafe.

UCLASS(ComponentWrapperClass, meta=(ConversionRoot, HideFunctions="CoverageHiddenFunction", SparseClassDataTypes="CoverageSparseData", AutoExpandCategories="CoverageExpanded", CollapseCategories, DontCollapseCategories))
class UCoverageUClassSpecialMetadataBaseObject : UObject
{
}

UCLASS()
class UCoverageUClassInheritedMetadataObject : UCoverageUClassSpecialMetadataBaseObject
{
}

void Observe_SpecialMetadata_LocalConstruct()
{
	UCoverageUClassSpecialMetadataBaseObject Base;
	UCoverageUClassInheritedMetadataObject Child;
}

bool Observe_SpecialMetadata_TwoChildLocalsIndependent()
{
	UCoverageUClassInheritedMetadataObject First;
	UCoverageUClassInheritedMetadataObject Second;
	return First != nullptr && Second != nullptr && First != Second;
}
