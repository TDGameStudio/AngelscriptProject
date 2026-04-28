#include "AngelscriptUhtCoverageTestTypes.h"

int32 UAngelscriptUhtCoverageTestLibrary::InternalCallableWithOverride(UAngelscriptUhtCoverageTestObject* Target)
{
	return Target != nullptr ? Target->StoredValue : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::InternalCallableWithoutOverride(UAngelscriptUhtCoverageTestObject* Target)
{
	return Target != nullptr ? Target->StoredValue : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::GetCoverageValue(const UObject* Target)
{
	const UAngelscriptUhtCoverageTestObject* TypedTarget = Cast<UAngelscriptUhtCoverageTestObject>(Target);
	return TypedTarget != nullptr ? TypedTarget->StoredValue : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::RequiresWorldContext(UObject* WorldContextObject, int32 Value)
{
	return WorldContextObject != nullptr ? Value : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::CallableWithoutWorldContext(UObject* WorldContextObject, int32 Value)
{
	return WorldContextObject != nullptr ? Value : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::GetTemporaryThisValue(const UObject* Target)
{
	const UAngelscriptUhtCoverageTestObject* TypedTarget = Cast<UAngelscriptUhtCoverageTestObject>(Target);
	return TypedTarget != nullptr ? TypedTarget->StoredValue : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::UnsafeDuringConstruction(UObject* Target)
{
	return Target != nullptr ? 1 : INDEX_NONE;
}

int32 UAngelscriptUhtCoverageTestLibrary::SafeDuringConstruction(UObject* Target)
{
	return Target != nullptr ? 1 : INDEX_NONE;
}
