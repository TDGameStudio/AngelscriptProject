/**
 * @version v1
 * @summary Observe default/copy construction of eligible structs and reflected property access.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe default/copy construction of eligible structs and reflected property access.
 * @topic Baseline
 */
// <PropertyType> Value.<ScriptPropertyName>;
// Inputs: Default FVector and FTSBindStructBehaviorPayload, Other FVector
// (1,2,3) and payload Count 11 / Label "Copied", and property writes to
// Count/Label/X.
// Expected observations: Default FVector is the zero vector. Copy
// construction preserves (1,2,3) independently of later Other mutation.
// Default payload Count is 4. Copied payload Count is 11. Property writes
// are visible on later reads.
// Boundary/ownership: Copy construction copies struct bytes. Property access
// uses the reflected offset; it does not own a separate object.

USTRUCT()
struct FTSBindStructBehaviorPayload
{
	UPROPERTY()
	int Count = 4;

	UPROPERTY()
	FString Label = "Payload";
}

namespace TS_UStruct_Behavior_01
{
	// Default/copy construct FVector and FTSBindStructBehaviorPayload; copies stay independent.
	bool Observe_Value_Nominal()
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

	// Reflected Count/Label/X writes are visible on later reads.
	bool Observe_Surface004_Nominal()
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
}
/** @end */
