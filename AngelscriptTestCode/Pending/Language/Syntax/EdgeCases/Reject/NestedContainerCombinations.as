/**
 * @version v1
 * @summary Nesting one container type inside another, here a TMap inside a TArray, is rejected. This file is the illegal program itself; do not unwrap the map into a flat structure, since the nesting is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Nesting one container type inside another, here a TMap inside a TArray, is rejected. This file is the illegal program itself; do not unwrap the map into a flat structure, since the nesting is the point.
 * @topic Negative
 */
/**
 * The actor whose property nests a map inside an array.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
UCLASS()
class ACoverageContainerArrayOfMapsActor : AActor
{
	/**
	 * The nested container property whose declaration is illegal.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return does not compile in this file
	 */
	UPROPERTY()
	TArray<TMap<int, FString>> ArrayOfMaps;
}
/** @end */
