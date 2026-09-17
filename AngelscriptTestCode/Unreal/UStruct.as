/**
 * @version v1
 * @summary UStruct host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UStruct
 *
 * copy-construct-fvector-ftsbindstructbehaviorpayload
 * reflected-count-label-x
 * assignment
 */
/**
 * @begin copy-construct-fvector-ftsbindstructbehaviorpayload
 * @summary Default/copy construct FVector and FTSBindStructBehaviorPayload.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Default/copy construct FVector and FTSBindStructBehaviorPayload.
 * @covers UStruct.copy-construct-fvector-ftsbindstructbehaviorpayload
 * @inputs UStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveValueNominal()
{
	FVector DefaultVector;
	FVector ConstructedVector = FVector();
	FVector Other(1.0, 2.0, 3.0);
	FVector CopiedVector(Other);
	Other.X = 9.0;

	FTSBindStructBehaviorPayload DefaultPayload;
	FTSBindStructBehaviorPayload ConstructedPayload = FTSBindStructBehaviorPayload();
	FTSBindStructBehaviorPayload Source;
	Source.Count = 11;
	Source.Label = "Copied";
	FTSBindStructBehaviorPayload CopiedPayload(Source);
	Source.Count = 0;

	return DefaultVector.X == 0.0 && ConstructedVector.Y == 0.0 && CopiedVector.X == 1.0 && CopiedVector.Y == 2.0 && CopiedVector.Z == 3.0 && DefaultPayload.Count == 4 && ConstructedPayload.Label == "Payload" && CopiedPayload.Count == 11 && CopiedPayload.Label == "Copied";
}
/** @end */
/**
 * @begin reflected-count-label-x
 * @summary Reflected Count/Label/X writes are visible on later reads.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary Reflected Count/Label/X writes are visible on later reads.
 * @covers UStruct.reflected-count-label-x
 * @inputs UStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface004Nominal()
{
	FTSBindStructBehaviorPayload Value;
	int Before = Value.Count;
	FString BeforeLabel = Value.Label;
	Value.Count = 11;
	Value.Label = "Written";
	int After = Value.Count;
	FString AfterLabel = Value.Label;

	FVector Vector;
	bool bDefaultXZero = Vector.X == 0.0;
	Vector.X = 3.0;
	return Before == 4 && BeforeLabel == "Payload" && After == 11 && AfterLabel == "Written" && bDefaultXZero && Vector.X == 3.0;
}
/** @end */
/**
 * @begin assignment
 * @summary the reflective fallback.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary the reflective fallback.
 * @covers UStruct.assignment
 * @inputs UStruct values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Assigned FVector equals Other

bool ObserveAssignmentNominal()
{
	FVector Value;
	FVector Other(1.0, 2.0, 3.0);
	Value = Other;
	Other.X = 9.0;

	FTSBindStructPayload Payload;
	FTSBindStructPayload Source;
	Source.Count = 4;
	Source.Label = "Payload";
	Payload = Source;
	Source.Count = -1;
	Source.Label = "Changed";

	FTSBindStructPayload Empty;
	Empty = FTSBindStructPayload();

	return Value.X == 1.0 && Value.Y == 2.0 && Value.Z == 3.0 && Other.X == 9.0 && Payload.Count == 4 && Payload.Label == "Payload" && Empty.Count == 4 && Empty.Label == "Payload";
}
/** @end */
