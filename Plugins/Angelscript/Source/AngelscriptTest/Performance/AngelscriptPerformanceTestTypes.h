#pragma once

#include "CoreMinimal.h"
#include "UObject/Object.h"

#include "AngelscriptPerformanceTestTypes.generated.h"

UENUM(BlueprintType)
enum class EAngelscriptPerformanceTestEnum : uint8
{
	Zero,
	One,
};

USTRUCT(BlueprintType)
struct ANGELSCRIPTTEST_API FAngelscriptPerformanceTestStruct
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int32 Value = 0;

	bool operator==(const FAngelscriptPerformanceTestStruct& Other) const
	{
		return Value == Other.Value;
	}
};

UCLASS(BlueprintType)
class ANGELSCRIPTTEST_API UAngelscriptPerformanceTestTargetObject : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	bool BoolValue = false;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	int32 Int32Value = 0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	double DoubleValue = 0.0;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FName NameValue = NAME_None;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FText TextValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FString StringValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	EAngelscriptPerformanceTestEnum EnumValue = EAngelscriptPerformanceTestEnum::Zero;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FAngelscriptPerformanceTestStruct StructValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TObjectPtr<UObject> ObjectValue = nullptr;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TObjectPtr<UClass> ClassValue = nullptr;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<int32> ArrayValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSet<int32> SetValue;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TMap<FName, int32> MapValue;

	UFUNCTION(BlueprintCallable)
	static void StaticNoOp();

	UFUNCTION(BlueprintCallable)
	static int32 StaticAdd(int32 A, int32 B);

	UFUNCTION(BlueprintCallable)
	static int32 StaticSubtract(int32 A, int32 B);

	UFUNCTION(BlueprintCallable)
	static int32 StaticMultiply(int32 A, int32 B);

	UFUNCTION(BlueprintCallable)
	static int32 StaticDivide(int32 A, int32 B);

	UFUNCTION(BlueprintCallable)
	void MemberNoOp() const;

	UFUNCTION(BlueprintCallable)
	void SetBoolValueFunction(bool InValue);

	UFUNCTION(BlueprintCallable)
	bool GetBoolValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetInt32ValueFunction(int32 InValue);

	UFUNCTION(BlueprintCallable)
	int32 GetInt32ValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetDoubleValueFunction(double InValue);

	UFUNCTION(BlueprintCallable)
	double GetDoubleValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetNameValueFunction(FName InValue);

	UFUNCTION(BlueprintCallable)
	FName GetNameValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetTextValueFunction(const FText& InValue);

	UFUNCTION(BlueprintCallable)
	FText GetTextValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetStringValueFunction(const FString& InValue);

	UFUNCTION(BlueprintCallable)
	FString GetStringValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetEnumValueFunction(EAngelscriptPerformanceTestEnum InValue);

	UFUNCTION(BlueprintCallable)
	EAngelscriptPerformanceTestEnum GetEnumValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetStructValueFunction(const FAngelscriptPerformanceTestStruct& InValue);

	UFUNCTION(BlueprintCallable)
	FAngelscriptPerformanceTestStruct GetStructValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetObjectValueFunction(UObject* InValue);

	UFUNCTION(BlueprintCallable)
	UObject* GetObjectValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetClassValueFunction(UClass* InValue);

	UFUNCTION(BlueprintCallable)
	UClass* GetClassValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetArrayValueFunction(const TArray<int32>& InValue);

	UFUNCTION(BlueprintCallable)
	TArray<int32> GetArrayValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetSetValueFunction(const TSet<int32>& InValue);

	UFUNCTION(BlueprintCallable)
	TSet<int32> GetSetValueFunction() const;

	UFUNCTION(BlueprintCallable)
	void SetMapValueFunction(const TMap<FName, int32>& InValue);

	UFUNCTION(BlueprintCallable)
	TMap<FName, int32> GetMapValueFunction() const;

	void ResetValues();
	int32 RunNativeScalarPropertyLoop(int32 Iterations);
	int32 RunNativeContainerPropertyLoop(int32 Iterations);
	int32 RunNativeScalarFunctionLoop(int32 Iterations);
	int32 RunNativeContainerFunctionLoop(int32 Iterations);
};
