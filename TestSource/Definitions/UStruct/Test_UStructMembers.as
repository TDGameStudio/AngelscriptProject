// Theme: Definitions.UStruct. WorldStory: mixed USTRUCT member types filled in BeginPlay.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMembers
// lines 3670-3724;
// sha256=e7f4101c9d064b7b54bf251a94a44f2250c695e00620e4e0f2aba2f40dd83ce3.
// Oracle after BeginPlay: Data.IntValue=42, FloatValue=3.14, BoolValue=true,
// StringValue=Hello, NameValue=TestName, VectorValue=(1,2,3), ActorRef=this,
// IntArray[0]=10 [1]=20, StringArray[0]=First [1]=Second.
// Extra: FComplexStruct default zeros/empty/false/null; copy-independence after mutate.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FComplexStruct
{
	UPROPERTY(EditAnywhere)
	int IntValue = 0;

	UPROPERTY(EditAnywhere)
	float FloatValue = 0.0f;

	UPROPERTY(EditAnywhere)
	bool BoolValue = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString StringValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FName NameValue;

	UPROPERTY(EditAnywhere)
	FVector VectorValue;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	TArray<FString> StringArray;
}

UCLASS()
class ACoverageStructMemberActor : AActor
{
	UPROPERTY()
	FComplexStruct Data;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.IntValue = 42;
		Data.FloatValue = 3.14f;
		Data.BoolValue = true;
		Data.StringValue = "Hello";
		Data.NameValue = n"TestName";
		Data.VectorValue = FVector(1.0f, 2.0f, 3.0f);
		Data.ActorRef = this;
		Data.IntArray.Add(10);
		Data.IntArray.Add(20);
		Data.StringArray.Add("First");
		Data.StringArray.Add("Second");
	}
}

bool Observe_Complex_DefaultEmpty()
{
	FComplexStruct Data;
	return Data.IntValue == 0
		&& Data.FloatValue == 0.0f
		&& Data.BoolValue == false
		&& Data.StringValue.IsEmpty()
		&& Data.NameValue == NAME_None
		&& Data.VectorValue.IsNearlyZero()
		&& Data.ActorRef == nullptr
		&& Data.IntArray.Num() == 0
		&& Data.StringArray.Num() == 0;
}

bool Observe_Complex_NominalFill()
{
	FComplexStruct Data;
	Data.IntValue = 42;
	Data.FloatValue = 3.14f;
	Data.BoolValue = true;
	Data.StringValue = "Hello";
	Data.NameValue = n"TestName";
	Data.VectorValue = FVector(1.0f, 2.0f, 3.0f);
	Data.IntArray.Add(10);
	Data.IntArray.Add(20);
	Data.StringArray.Add("First");
	Data.StringArray.Add("Second");
	return Data.IntValue == 42
		&& Data.FloatValue == 3.14f
		&& Data.BoolValue == true
		&& Data.StringValue == "Hello"
		&& Data.NameValue == n"TestName"
		&& Data.VectorValue.Equals(FVector(1.0f, 2.0f, 3.0f))
		&& Data.IntArray[0] == 10 && Data.IntArray[1] == 20
		&& Data.StringArray[0] == "First" && Data.StringArray[1] == "Second";
}

bool Observe_Complex_CopyIndependence()
{
	FComplexStruct Original;
	Original.IntValue = 42;
	Original.IntArray.Add(10);
	FComplexStruct Copy = Original;
	Copy.IntValue = 0;
	Copy.IntArray[0] = 99;
	return Original.IntValue == 42 && Original.IntArray[0] == 10
		&& Copy.IntValue == 0 && Copy.IntArray[0] == 99;
}
