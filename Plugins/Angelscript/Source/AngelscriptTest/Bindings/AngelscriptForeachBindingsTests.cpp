// ============================================================================
// AngelscriptForeachBindingsTests.cpp
//
// foreach syntax binding coverage — 9 Automation IDs:
//   - Angelscript.TestModule.Bindings.Container.ArrayForeach
//   - Angelscript.TestModule.Bindings.Container.SetForeach
//   - Angelscript.TestModule.Bindings.Container.SetForeachExactVisit
//   - Angelscript.TestModule.Bindings.Container.MapForeach
//   - Angelscript.TestModule.Bindings.Container.MapForeachKeyValuePairing
//   - Angelscript.TestModule.Bindings.Container.ForeachNestedArrayMap
//   - Angelscript.TestModule.Bindings.Container.ForeachEmptyContainerSkipsBody
//   - Angelscript.TestModule.Bindings.Container.ForeachUObjectArrayCompiles
//   - Angelscript.TestModule.Bindings.Container.ForeachConstRefPreservesOriginal
//
// Refactored from AngelscriptContainerBindingsTests.cpp using the
// Bindings/Shared/ Coverage Section base layer.
// ============================================================================

#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

// ----------------------------------------------------------------------------
// Profile
// ----------------------------------------------------------------------------

static const FBindingsCoverageProfile GForeachProfile{
	TEXT("Foreach"),         // Theme
	TEXT(""),                // Variant
	TEXT("ASForeach"),       // ModulePrefix
	TEXT("Foreach"),         // CasePrefix
	TEXT("ForeachBindings"), // LogCategory
};

// ============================================================================
// Sub-Section runners — one per Automation ID
// ============================================================================

namespace
{
	// -----------------------------------------------------------------------
	// ArrayForeach: foreach(Value,Index:TArray) sum + index sum
	//   Extended: break/continue, modification of accumulator, FString array.
	// -----------------------------------------------------------------------
	bool RunForeachArraySection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Array"), TEXT(R"(
int ForeachArray_ValueSum()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(5);
	int Sum = 0;
	foreach (int Value : Values)
		Sum += Value;
	return Sum;
}

int ForeachArray_IndexSum()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(5);
	int IndexSum = 0;
	foreach (int Value, int Index : Values)
		IndexSum += Index;
	return IndexSum;
}

int ForeachArray_BreakStops()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(5);
	Values.Add(99);
	int Sum = 0;
	foreach (int Value : Values)
	{
		if (Value > 3)
			break;
		Sum += Value;
	}
	return Sum;
}

int ForeachArray_ContinueSkips()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	Values.Add(4);
	int OddSum = 0;
	foreach (int Value : Values)
	{
		if ((Value % 2) == 0)
			continue;
		OddSum += Value;
	}
	return OddSum;
}

int ForeachArray_FStringConcatLen()
{
	TArray<FString> Values;
	Values.Add("Hello");
	Values.Add("World");
	int TotalLen = 0;
	foreach (FString S : Values)
		TotalLen += S.Len();
	return TotalLen;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int ForeachArray_ValueSum()"),         TEXT("TArray foreach value sum should be 8"),                          8 },
			{ TEXT("int ForeachArray_IndexSum()"),         TEXT("TArray foreach index sum should be 3"),                          3 },
			{ TEXT("int ForeachArray_BreakStops()"),       TEXT("TArray foreach break should stop before >3 (sum=1+2=3)"),  3 },
			{ TEXT("int ForeachArray_ContinueSkips()"),    TEXT("TArray foreach continue should skip evens (1+3=4)"),             4 },
			{ TEXT("int ForeachArray_FStringConcatLen()"), TEXT("TArray<FString> foreach length sum should be 10"),              10 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// SetForeach: foreach(Value:TSet) sum + FString sentinel.
	// -----------------------------------------------------------------------
	bool RunForeachSetSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Set"), TEXT(R"(
int ForeachSet_Sum()
{
	TSet<int> Values;
	Values.Add(2);
	Values.Add(5);
	int Sum = 0;
	foreach (int Value : Values)
		Sum += Value;
	return Sum;
}

int ForeachSet_FStringTotalLen()
{
	TSet<FString> Values;
	Values.Add("AA");
	Values.Add("BBBB");
	int TotalLen = 0;
	foreach (FString S : Values)
		TotalLen += S.Len();
	return TotalLen;
}

int ForeachSet_NameSawAlpha()
{
	TSet<FName> Names;
	Names.Add(FName("Alpha"));
	Names.Add(FName("Beta"));
	bool bSawAlpha = false;
	foreach (FName N : Names)
	{
		if (N == FName("Alpha")) bSawAlpha = true;
	}
	return bSawAlpha ? 1 : 0;
}

int ForeachSet_NameSawBeta()
{
	TSet<FName> Names;
	Names.Add(FName("Alpha"));
	Names.Add(FName("Beta"));
	bool bSawBeta = false;
	foreach (FName N : Names)
	{
		if (N == FName("Beta")) bSawBeta = true;
	}
	return bSawBeta ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int ForeachSet_Sum()"),               TEXT("TSet<int> foreach sum should be 7"),                      7 },
			{ TEXT("int ForeachSet_FStringTotalLen()"),   TEXT("TSet<FString> foreach length sum should be 6"),           6 },
			{ TEXT("int ForeachSet_NameSawAlpha()"),      TEXT("TSet<FName> foreach should visit Alpha"),                  1 },
			{ TEXT("int ForeachSet_NameSawBeta()"),       TEXT("TSet<FName> foreach should visit Beta"),                   1 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// SetForeachExactVisit: empty skip + exact visit count + all elements
	// -----------------------------------------------------------------------
	bool RunForeachSetExactVisitSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("SetExactVisit"), TEXT(R"(
int SetForeach_EmptySkip()
{
	TSet<int> EmptyValues;
	int Count = 0;
	foreach (int Value : EmptyValues)
		Count += 1;
	return Count;
}

int SetForeach_VisitCount()
{
	TSet<int> Values;
	Values.Add(2);
	Values.Add(5);
	Values.Add(11);
	int Count = 0;
	foreach (int Value : Values)
		Count += 1;
	return Count;
}

int SetForeach_AllVisited()
{
	TSet<int> Values;
	Values.Add(2);
	Values.Add(5);
	Values.Add(11);
	TSet<int> Visited;
	foreach (int Value : Values)
		Visited.Add(Value);
	return (Visited.Num() == 3 && Visited.Contains(2) && Visited.Contains(5) && Visited.Contains(11)) ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int SetForeach_EmptySkip()"),   TEXT("Empty TSet foreach should skip body"),           0 },
			{ TEXT("int SetForeach_VisitCount()"),  TEXT("TSet foreach should visit 3 elements"),          3 },
			{ TEXT("int SetForeach_AllVisited()"),  TEXT("TSet foreach should visit every element"),       1 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// MapForeach: foreach(Value,Key:TMap) value sum + key count
	//   Extended: TMap<int,FString>, TMap<FName,FVector> diversification.
	// -----------------------------------------------------------------------
	bool RunForeachMapSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Map"), TEXT(R"(
int ForeachMap_ValueSum()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 5);
	int Sum = 0;
	foreach (int Value, FName Key : Values)
		Sum += Value;
	return Sum;
}

int ForeachMap_KeyCount()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 5);
	int KeyCount = 0;
	foreach (int Value, FName Key : Values)
	{
		if (Key == FName("Alpha") || Key == FName("Beta"))
			KeyCount += 1;
	}
	return KeyCount;
}

int ForeachMap_IntStringValueLen()
{
	TMap<int, FString> Values;
	Values.Add(1, "AA");
	Values.Add(2, "BBB");
	Values.Add(3, "C");
	int LenSum = 0;
	foreach (FString V, int K : Values)
		LenSum += V.Len();
	return LenSum;
}

int ForeachMap_VectorValueXSum()
{
	TMap<FName, FVector> Values;
	Values.Add(FName("A"), FVector(1, 0, 0));
	Values.Add(FName("B"), FVector(2, 0, 0));
	Values.Add(FName("C"), FVector(3, 0, 0));
	float XSum = 0.0f;
	foreach (FVector V, FName K : Values)
		XSum += V.X;
	return (XSum > 5.9f && XSum < 6.1f) ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int ForeachMap_ValueSum()"),         TEXT("TMap<FName,int> foreach value sum should be 7"),       7 },
			{ TEXT("int ForeachMap_KeyCount()"),         TEXT("TMap<FName,int> foreach key count should be 2"),       2 },
			{ TEXT("int ForeachMap_IntStringValueLen()"), TEXT("TMap<int,FString> foreach value length sum should be 6"),6 },
			{ TEXT("int ForeachMap_VectorValueXSum()"),   TEXT("TMap<FName,FVector> foreach X sum should be 6"),       1 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// MapForeachKeyValuePairing: empty skip + exact pairing + visit/seen
	// -----------------------------------------------------------------------
	bool RunForeachMapKeyValueSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("MapKeyValue"), TEXT(R"(
int MapForeach_EmptySkip()
{
	TMap<FName, int> Empty;
	int Visits = 0;
	foreach (int Value, FName Key : Empty)
		Visits += 1;
	return Visits;
}

int MapForeach_AlphaValue()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	int AlphaValue = -1;
	foreach (int Value, FName Key : Values)
	{
		if (Key == FName("Alpha"))
			AlphaValue = Value;
	}
	return AlphaValue;
}

int MapForeach_BetaValue()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	int BetaValue = -1;
	foreach (int Value, FName Key : Values)
	{
		if (Key == FName("Beta"))
			BetaValue = Value;
	}
	return BetaValue;
}

int MapForeach_GammaValue()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	int GammaValue = -1;
	foreach (int Value, FName Key : Values)
	{
		if (Key == FName("Gamma"))
			GammaValue = Value;
	}
	return GammaValue;
}

int MapForeach_VisitCount()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	int VisitCount = 0;
	foreach (int Value, FName Key : Values)
		VisitCount += 1;
	return VisitCount;
}

int MapForeach_SeenCount()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	TMap<FName, int> SeenCounts;
	foreach (int Value, FName Key : Values)
	{
		int& Count = SeenCounts.FindOrAdd(Key);
		Count += 1;
	}
	return SeenCounts.Num();
}

int MapForeach_EachSeenOnce()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 2);
	Values.Add(FName("Beta"), 9);
	Values.Add(FName("Gamma"), 17);
	TMap<FName, int> SeenCounts;
	foreach (int Value, FName Key : Values)
	{
		int& Count = SeenCounts.FindOrAdd(Key);
		Count += 1;
	}
	int AlphaCount = 0;
	int BetaCount = 0;
	int GammaCount = 0;
	SeenCounts.Find(FName("Alpha"), AlphaCount);
	SeenCounts.Find(FName("Beta"), BetaCount);
	SeenCounts.Find(FName("Gamma"), GammaCount);
	return (AlphaCount == 1 && BetaCount == 1 && GammaCount == 1) ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int MapForeach_EmptySkip()"),     TEXT("Empty TMap foreach should skip body"),                  0 },
			{ TEXT("int MapForeach_AlphaValue()"),    TEXT("TMap foreach Alpha value should be 2"),                 2 },
			{ TEXT("int MapForeach_BetaValue()"),     TEXT("TMap foreach Beta value should be 9"),                  9 },
			{ TEXT("int MapForeach_GammaValue()"),    TEXT("TMap foreach Gamma value should be 17"),                17 },
			{ TEXT("int MapForeach_VisitCount()"),    TEXT("TMap foreach visit count should be 3"),                 3 },
			{ TEXT("int MapForeach_SeenCount()"),     TEXT("TMap foreach seen count should be 3 keys"),             3 },
			{ TEXT("int MapForeach_EachSeenOnce()"),  TEXT("TMap foreach each key should be seen exactly once"),    1 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// ForeachNestedArrayMap: outer TArray<FName>, inner TMap<FName, int>
	// -----------------------------------------------------------------------
	bool RunForeachNestedSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Nested"), TEXT(R"(
int ForeachNested_Total()
{
	TArray<FName> Keys;
	Keys.Add(n"A");
	Keys.Add(n"B");
	TMap<FName, int> Data;
	Data.Add(n"A", 10);
	Data.Add(n"B", 20);
	int Total = 0;
	foreach (FName Key : Keys)
	{
		foreach (int Value, FName MapKey : Data)
		{
			if (MapKey == Key)
				Total += Value;
		}
	}
	return Total;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		return ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int ForeachNested_Total()"), TEXT("Nested foreach should accumulate 10+20=30"), 30);
	}

	// -----------------------------------------------------------------------
	// ForeachEmptyContainerSkipsBody: empty TArray/TSet/TMap
	// -----------------------------------------------------------------------
	bool RunForeachEmptySection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("Empty"), TEXT(R"(
int ForeachEmpty_Count()
{
	TArray<int> EmptyArray;
	TSet<int> EmptySet;
	TMap<FName, int> EmptyMap;
	int Count = 0;
	foreach (int V : EmptyArray)
		Count += 1;
	foreach (int V : EmptySet)
		Count += 1;
	foreach (int V, FName K : EmptyMap)
		Count += 1;
	return Count;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		return ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int ForeachEmpty_Count()"), TEXT("Empty containers should never enter foreach body"), 0);
	}

	// -----------------------------------------------------------------------
	// ForeachUObjectArrayCompiles: UObject array foreach + FString array
	//   Extended: also iterates TArray<FString> and TArray<FName> to prove
	//   that foreach over heap-managed value types works in this Section.
	// -----------------------------------------------------------------------
	bool RunForeachUObjectSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("UObject"), TEXT(R"(
int ForeachUObject_Count()
{
	TArray<UObject> Objects;
	int Count = 0;
	foreach (UObject Obj : Objects)
		Count += 1;
	return Count;
}

int ForeachUObject_NullEntries()
{
	TArray<UObject> Objects;
	Objects.Add(nullptr);
	Objects.Add(nullptr);
	int Count = 0;
	foreach (UObject Obj : Objects)
		Count += 1;
	return Count;
}

int ForeachFStringArray_LenSum()
{
	TArray<FString> Strings;
	Strings.Add("AB");
	Strings.Add("CDE");
	Strings.Add("F");
	int LenSum = 0;
	foreach (FString S : Strings)
		LenSum += S.Len();
	return LenSum;
}

int ForeachFNameArray_KnownSentinel()
{
	TArray<FName> Names;
	Names.Add(FName("Alpha"));
	Names.Add(FName("Beta"));
	int Hits = 0;
	foreach (FName N : Names)
	{
		if (N == FName("Alpha") || N == FName("Beta"))
			Hits += 1;
	}
	return Hits;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int ForeachUObject_Count()"),         TEXT("Empty UObject array foreach should iterate 0 times"),       0 },
			{ TEXT("int ForeachUObject_NullEntries()"),   TEXT("UObject array with two nulls should iterate twice"),        2 },
			{ TEXT("int ForeachFStringArray_LenSum()"),   TEXT("TArray<FString> foreach length sum should be 6"),           6 },
			{ TEXT("int ForeachFNameArray_KnownSentinel()"),TEXT("TArray<FName> foreach should hit both sentinels"),         2 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// ForeachConstRefPreservesOriginal: FVector array foreach
	//   Extended: TArray<FRotator> + early break preservation.
	// -----------------------------------------------------------------------
	bool RunForeachConstRefSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("ConstRef"), TEXT(R"(
int ForeachConstRef_XSum()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 2, 3));
	Vectors.Add(FVector(4, 5, 6));
	float Sum = 0.0f;
	foreach (FVector V : Vectors)
		Sum += V.X;
	return (Sum > 4.9f && Sum < 5.1f) ? 1 : 0;
}

int ForeachConstRef_PreservesOriginal()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 2, 3));
	Vectors.Add(FVector(4, 5, 6));
	float Sum = 0.0f;
	foreach (FVector V : Vectors)
		Sum += V.X;
	return (Vectors[0].X > 0.9f && Vectors[0].X < 1.1f) ? 1 : 0;
}

int ForeachConstRef_BreakPreservesNum()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 2, 3));
	Vectors.Add(FVector(4, 5, 6));
	Vectors.Add(FVector(7, 8, 9));
	foreach (FVector V : Vectors)
	{
		if (V.X > 3.0f)
			break;
	}
	return Vectors.Num();
}

int ForeachConstRef_BreakPreservesLastElement()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 2, 3));
	Vectors.Add(FVector(4, 5, 6));
	Vectors.Add(FVector(7, 8, 9));
	foreach (FVector V : Vectors)
	{
		if (V.X > 3.0f)
			break;
	}
	float X = Vectors[2].X;
	return (X > 6.9f && X < 7.1f) ? 1 : 0;
}

int ForeachConstRef_RotatorYawSum()
{
	TArray<FRotator> Rots;
	Rots.Add(FRotator(0, 30, 0));
	Rots.Add(FRotator(0, 45, 0));
	Rots.Add(FRotator(0, 25, 0));
	float YawSum = 0.0f;
	foreach (FRotator R : Rots)
		YawSum += R.Yaw;
	// Sum should be 100 (degrees).
	return (YawSum > 99.9f && YawSum < 100.1f) ? 1 : 0;
}

int ForeachConstRef_VectorPartialSumViaContinue()
{
	TArray<FVector> Vectors;
	Vectors.Add(FVector(1, 0, 0));
	Vectors.Add(FVector(2, 0, 0));
	Vectors.Add(FVector(3, 0, 0));
	float Sum = 0.0f;
	foreach (FVector V : Vectors)
	{
		if (V.X > 1.5f && V.X < 2.5f)
			continue; // skip X=2
		Sum += V.X;
	}
	return (Sum > 3.9f && Sum < 4.1f) ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int ForeachConstRef_XSum()"),                       TEXT("FVector foreach X sum should be ~5"),                       1 },
			{ TEXT("int ForeachConstRef_PreservesOriginal()"),          TEXT("foreach should preserve original array unchanged"),         1 },
			{ TEXT("int ForeachConstRef_BreakPreservesNum()"),          TEXT("break inside foreach should leave array Num=3"),            3 },
			{ TEXT("int ForeachConstRef_BreakPreservesLastElement()"),  TEXT("break inside foreach should leave Vectors[2].X intact (~7)"),1 },
			{ TEXT("int ForeachConstRef_RotatorYawSum()"),              TEXT("FRotator foreach Yaw sum should be ~100"),                  1 },
			{ TEXT("int ForeachConstRef_VectorPartialSumViaContinue()"), TEXT("continue inside foreach should skip middle element (1+3=4)"),1 },
		};
		return ExpectGlobalInts(Test, Engine, Module, Profile, Cases);
	}

	// -----------------------------------------------------------------------
	// Section: ForeachReturnType — exercise returning container types that
	// were built using foreach, plus bool/float accumulator returns.
	// -----------------------------------------------------------------------

	bool RunForeachReturnTypeSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("ReturnType"), TEXT(R"(
// Return bool from foreach-based predicate
bool ForeachRet_Bool_AnyGreaterThan3()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(5);
	foreach (int V : Values)
	{
		if (V > 3) return true;
	}
	return false;
}

bool ForeachRet_Bool_AllPositive()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	foreach (int V : Values)
	{
		if (V <= 0) return false;
	}
	return true;
}

// Return float from foreach accumulator
float ForeachRet_Float_Sum()
{
	TArray<float> Values;
	Values.Add(1.5f);
	Values.Add(2.5f);
	Values.Add(3.0f);
	float Sum = 0.0f;
	foreach (float V : Values)
		Sum += V;
	return Sum;
}

// Return TArray built via foreach
TArray<int> ForeachRet_FilteredArray()
{
	TArray<int> Source;
	Source.Add(1);
	Source.Add(2);
	Source.Add(3);
	Source.Add(4);
	Source.Add(5);
	TArray<int> Evens;
	foreach (int V : Source)
	{
		if ((V % 2) == 0)
			Evens.Add(V);
	}
	return Evens;
}
int ForeachRet_VerifyFilteredArray_Num()
{
	TArray<int> Evens = ForeachRet_FilteredArray();
	return Evens.Num();
}
int ForeachRet_VerifyFilteredArray_First()
{
	TArray<int> Evens = ForeachRet_FilteredArray();
	return Evens[0];
}
int ForeachRet_VerifyFilteredArray_Second()
{
	TArray<int> Evens = ForeachRet_FilteredArray();
	return Evens[1];
}

// Return TMap built via foreach
TMap<FName, int> ForeachRet_NameLengthMap()
{
	TArray<FName> Names;
	Names.Add(FName("AB"));
	Names.Add(FName("CDEF"));
	TMap<FName, int> Result;
	foreach (FName N : Names)
	{
		Result.Add(N, N.ToString().Len());
	}
	return Result;
}
int ForeachRet_VerifyMapReturn_Num()
{
	TMap<FName, int> M = ForeachRet_NameLengthMap();
	return M.Num();
}
int ForeachRet_VerifyMapReturn_AB_Len()
{
	TMap<FName, int> M = ForeachRet_NameLengthMap();
	int Out = 0;
	M.Find(FName("AB"), Out);
	return Out;
}
int ForeachRet_VerifyMapReturn_CDEF_Len()
{
	TMap<FName, int> M = ForeachRet_NameLengthMap();
	int Out = 0;
	M.Find(FName("CDEF"), Out);
	return Out;
}

// Return TArray<FVector> built via foreach
TArray<FVector> ForeachRet_ScaledVectors()
{
	TArray<FVector> Source;
	Source.Add(FVector(1, 0, 0));
	Source.Add(FVector(0, 2, 0));
	Source.Add(FVector(0, 0, 3));
	TArray<FVector> Result;
	foreach (FVector V : Source)
		Result.Add(V * 10.0f);
	return Result;
}
int ForeachRet_VerifyScaledVectors_Num()
{
	TArray<FVector> A = ForeachRet_ScaledVectors();
	return A.Num();
}
int ForeachRet_VerifyScaledVectors_FirstX()
{
	TArray<FVector> A = ForeachRet_ScaledVectors();
	return (A[0].X > 9.9f && A[0].X < 10.1f) ? 1 : 0;
}
int ForeachRet_VerifyScaledVectors_LastZ()
{
	TArray<FVector> A = ForeachRet_ScaledVectors();
	return (A[2].Z > 29.9f && A[2].Z < 30.1f) ? 1 : 0;
}

// Return TSet<int> built via foreach dedup
TSet<int> ForeachRet_DedupSet()
{
	TArray<int> Source;
	Source.Add(1);
	Source.Add(2);
	Source.Add(2);
	Source.Add(3);
	Source.Add(1);
	TSet<int> Result;
	foreach (int V : Source)
		Result.Add(V);
	return Result;
}
int ForeachRet_VerifyDedupSet_Num()
{
	TSet<int> S = ForeachRet_DedupSet();
	return S.Num();
}
int ForeachRet_VerifyDedupSet_ContainsThree()
{
	TSet<int> S = ForeachRet_DedupSet();
	return S.Contains(3) ? 1 : 0;
}
)"));
		if (!ModuleScope.IsValid())
		{
			return false;
		}
		asIScriptModule& Module = ModuleScope.GetModule();

		bool bPassed = true;

		// Direct bool returns
		bPassed &= ExpectGlobalReturnBool(Test, Engine, Module, Profile,
			TEXT("bool ForeachRet_Bool_AnyGreaterThan3()"), TEXT("bool return: any>3 in {1,2,5} should be true"), true);
		bPassed &= ExpectGlobalReturnBool(Test, Engine, Module, Profile,
			TEXT("bool ForeachRet_Bool_AllPositive()"), TEXT("bool return: all-positive {1,2,3} should be true"), true);

		// Direct float return
		bPassed &= ExpectGlobalReturnFloat(Test, Engine, Module, Profile,
			TEXT("float ForeachRet_Float_Sum()"), TEXT("float return: sum of {1.5,2.5,3.0} should be 7.0"), 7.0f);

		// Container returns verified via script-side int wrappers
		const FExpectedGlobalInt IntCases[] = {
			{ TEXT("int ForeachRet_VerifyFilteredArray_Num()"),     TEXT("TArray<int> return: filter evens from 1..5 Num=2"),       2 },
			{ TEXT("int ForeachRet_VerifyFilteredArray_First()"),   TEXT("TArray<int> return: first even should be 2"),              2 },
			{ TEXT("int ForeachRet_VerifyFilteredArray_Second()"),  TEXT("TArray<int> return: second even should be 4"),             4 },
			{ TEXT("int ForeachRet_VerifyMapReturn_Num()"),         TEXT("TMap<FName,int> return: Num should be 2"),                 2 },
			{ TEXT("int ForeachRet_VerifyMapReturn_AB_Len()"),      TEXT("TMap<FName,int> return: 'AB' length should be 2"),         2 },
			{ TEXT("int ForeachRet_VerifyMapReturn_CDEF_Len()"),    TEXT("TMap<FName,int> return: 'CDEF' length should be 4"),       4 },
			{ TEXT("int ForeachRet_VerifyScaledVectors_Num()"),     TEXT("TArray<FVector> return: Num should be 3"),                 3 },
			{ TEXT("int ForeachRet_VerifyScaledVectors_FirstX()"),  TEXT("TArray<FVector> return: [0].X should be ~10"),             1 },
			{ TEXT("int ForeachRet_VerifyScaledVectors_LastZ()"),   TEXT("TArray<FVector> return: [2].Z should be ~30"),             1 },
			{ TEXT("int ForeachRet_VerifyDedupSet_Num()"),          TEXT("TSet<int> return from dedup: Num should be 3"),            3 },
			{ TEXT("int ForeachRet_VerifyDedupSet_ContainsThree()"),TEXT("TSet<int> return from dedup: should contain 3"),           1 },
		};
		bPassed &= ExpectGlobalInts(Test, Engine, Module, Profile, IntCases);

		return bPassed;
	}

	// -----------------------------------------------------------------------
	// Section: ForeachLogDiagnostic — Log() containers during foreach.
	// -----------------------------------------------------------------------

	bool RunForeachLogDiagnosticSection(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FBindingsCoverageProfile& Profile)
	{
		FCoverageModuleScope ModuleScope(Test, Engine, Profile, TEXT("LogDiag"), TEXT(R"(
int ForeachLog_Types()
{
	// TArray<int>
	TArray<int> Ints;
	Ints.Add(10); Ints.Add(20); Ints.Add(30);
	foreach (int V : Ints)
		Log("ForeachLog TArray<int>: " + V);

	// TArray<FString>
	TArray<FString> Strs;
	Strs.Add("Hello"); Strs.Add("World");
	foreach (FString S : Strs)
		Log("ForeachLog TArray<FString>: " + S);

	// TArray<FVector>
	TArray<FVector> Vecs;
	Vecs.Add(FVector(1, 2, 3)); Vecs.Add(FVector(4, 5, 6));
	foreach (FVector V : Vecs)
		Log("ForeachLog TArray<FVector>: " + V);

	// TSet<int>
	TSet<int> SInt;
	SInt.Add(7); SInt.Add(8);
	foreach (int V : SInt)
		Log("ForeachLog TSet<int>: " + V);

	// TMap<FName, int>
	TMap<FName, int> MNameInt;
	MNameInt.Add(FName("A"), 100);
	MNameInt.Add(FName("B"), 200);
	foreach (int V, FName K : MNameInt)
		Log("ForeachLog TMap K=" + K + " V=" + V);

	// TMap<int, FVector>
	TMap<int, FVector> MIntVec;
	MIntVec.Add(1, FVector(10, 20, 30));
	foreach (FVector V, int K : MIntVec)
		Log("ForeachLog TMap<int,FVector> K=" + K + " V=" + V);

	return 1;
}
)"));
		if (!ModuleScope.IsValid()) return false;
		asIScriptModule& Module = ModuleScope.GetModule();

		return ExpectGlobalInt(Test, Engine, Module, Profile,
			TEXT("int ForeachLog_Types()"),
			TEXT("Log diagnostic: foreach over various container types should compile and log"), 1);
	}
}

// ============================================================================
// Automation ID registrations (9 IDs)
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptArrayForeachBindingsTest,
	"Angelscript.TestModule.Bindings.Container.ArrayForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSetForeachBindingsTest,
	"Angelscript.TestModule.Bindings.Container.SetForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSetForeachExactVisitBindingsTest,
	"Angelscript.TestModule.Bindings.Container.SetForeachExactVisit",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapForeachBindingsTest,
	"Angelscript.TestModule.Bindings.Container.MapForeach",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptMapForeachKeyValuePairingBindingsTest,
	"Angelscript.TestModule.Bindings.Container.MapForeachKeyValuePairing",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachNestedArrayMapTest,
	"Angelscript.TestModule.Bindings.Container.ForeachNestedArrayMap",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachEmptyContainerTest,
	"Angelscript.TestModule.Bindings.Container.ForeachEmptyContainerSkipsBody",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachUObjectArrayTest,
	"Angelscript.TestModule.Bindings.Container.ForeachUObjectArrayCompiles",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachConstRefPreservesTest,
	"Angelscript.TestModule.Bindings.Container.ForeachConstRefPreservesOriginal",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

// ============================================================================
// RunTest implementations — thin shells calling sub-Section runners
// ============================================================================

bool FAngelscriptArrayForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachArraySection(*this, Engine, GForeachProfile);
	bPassed &= RunForeachReturnTypeSection(*this, Engine, GForeachProfile);
	bPassed &= RunForeachLogDiagnosticSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptSetForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachSetSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptSetForeachExactVisitBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachSetExactVisitSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptMapForeachBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachMapSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptMapForeachKeyValuePairingBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachMapKeyValueSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptForeachNestedArrayMapTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachNestedSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptForeachEmptyContainerTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachEmptySection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptForeachUObjectArrayTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachUObjectSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptForeachConstRefPreservesTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bPassed = true;
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT { ResetSharedCloneEngine(Engine); };
	bPassed &= RunForeachConstRefSection(*this, Engine, GForeachProfile);
	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif // WITH_DEV_AUTOMATION_TESTS
