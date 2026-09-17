/**
 * @version v1
 * @summary Observe UDataTable row-name listing, wildcard row copy, and row/category handle resolution.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UDataTable row-name listing, wildcard row copy, and row/category handle resolution.
 * @topic Baseline
 */
// Runner owns the Table fixture, including RowStruct matching FTSDataTableRow.
// Null Table is setup failure.
// AS-facing API: TArray<FName> Names = DataTable.GetRowNames() const;
// bool bFound = DataTable.FindRow(FName RowName, ?&out OutRow) const;
// DataTable.GetAllRows(?& OutArray) const;
// bool bNull = RowHandle.IsNull() const;
// bool bFound = RowHandle.GetRow(?&out OutRow) const;
// bool bNull = CategoryHandle.IsNull() const;
// TArray<FName> Names = CategoryHandle.GetRowNames() const;
// bool bFound = CategoryHandle.GetRow(FName RowName, ?&out OutRow) const;
// CategoryHandle.GetRows(?& OutArray) const;
// Inputs: Runner-owned UDataTable, FTSDataTableRow Alpha with Category n"Enemy",
// empty table state, n"Alpha" vs n"Missing", default-null handles, and
// TArray<FVector> as the type-mismatch diagnostic.
// Expected observations: Empty GetRowNames is empty. FindRow of a missing
// name returns false and leaves OutRow unchanged. Null handles report IsNull
// true and GetRow false. Category GetRowNames of a null handle is empty.
// FindRow of n"Alpha" after AddRow writes Count 2 and Label "Alpha".
// Boundary/ownership: OutRow/OutArray are caller-owned writebacks whose
// element type must match RowStruct. GetAllRows with TArray<FVector> is the
// type-mismatch diagnostic path. SetupOwner=Runner.

USTRUCT()
struct FTSDataTableRow
{
	UPROPERTY()
	FName Category = NAME_None;

	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

namespace TS_UDataTable_Queries_01
{
	bool Observe_GetRowNames_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		Table.EmptyTable();
		TArray<FName> EmptyNames = Table.GetRowNames();

		FTSDataTableRow Alpha;
		Alpha.Category = n"Enemy";
		Alpha.Count = 2;
		Alpha.Label = "Alpha";
		Table.AddRow(n"Alpha", Alpha);
		TArray<FName> Names = Table.GetRowNames();

		FDataTableCategoryHandle NullCategoryHandle;
		TArray<FName> NullCategoryNames = NullCategoryHandle.GetRowNames();
		FDataTableCategoryHandle CategoryHandle;
		CategoryHandle.DataTable = Table;
		CategoryHandle.ColumnName = n"Category";
		CategoryHandle.RowContents = n"Enemy";
		TArray<FName> CategoryNames = CategoryHandle.GetRowNames();

		return EmptyNames.Num() == 0 &&
			Names.Contains(n"Alpha") &&
			NullCategoryNames.Num() == 0 &&
			CategoryNames.Contains(n"Alpha");
	}

	bool Observe_FindRow_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		Table.EmptyTable();
		FTSDataTableRow Alpha;
		Alpha.Category = n"Enemy";
		Alpha.Count = 2;
		Alpha.Label = "Alpha";
		Table.AddRow(n"Alpha", Alpha);

		FTSDataTableRow Found;
		Found.Category = n"Sentinel";
		Found.Count = -99;
		Found.Label = "Sentinel";
		bool bFound = Table.FindRow(n"Alpha", Found);

		FTSDataTableRow Missing;
		Missing.Category = n"Sentinel";
		Missing.Count = -99;
		Missing.Label = "Sentinel";
		bool bMissing = Table.FindRow(n"Missing", Missing);

		return bFound &&
			Found.Category == n"Enemy" &&
			Found.Count == 2 &&
			Found.Label == "Alpha" &&
			!bMissing &&
			Missing.Count == -99 &&
			Missing.Label == "Sentinel";
	}

	bool Observe_GetAllRows_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		Table.EmptyTable();
		FTSDataTableRow Alpha;
		Alpha.Category = n"Enemy";
		Alpha.Count = 2;
		Alpha.Label = "Alpha";
		Table.AddRow(n"Alpha", Alpha);

		TArray<FTSDataTableRow> OutArray;
		FTSDataTableRow Sentinel;
		Sentinel.Category = n"Sentinel";
		Sentinel.Count = -99;
		Sentinel.Label = "Sentinel";
		OutArray.Add(Sentinel);
		int32 Before = OutArray.Num();
		Table.GetAllRows(OutArray);
		return Before == 1 &&
			OutArray.Num() == 2 &&
			OutArray[0].Label == "Sentinel" &&
			OutArray[1].Label == "Alpha" &&
			OutArray[1].Count == 2;
	}

	bool Observe_IsNull_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		FDataTableRowHandle RowHandle;
		bool bDefaultRowNull = RowHandle.IsNull();
		RowHandle.DataTable = Table;
		RowHandle.RowName = n"Alpha";
		bool bFilledRowNull = RowHandle.IsNull();

		FDataTableCategoryHandle CategoryHandle;
		bool bDefaultCategoryNull = CategoryHandle.IsNull();
		CategoryHandle.DataTable = Table;
		CategoryHandle.ColumnName = n"Category";
		CategoryHandle.RowContents = n"Enemy";
		bool bFilledCategoryNull = CategoryHandle.IsNull();

		return bDefaultRowNull && !bFilledRowNull && bDefaultCategoryNull && !bFilledCategoryNull;
	}

	bool Observe_GetRow_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		Table.EmptyTable();
		FTSDataTableRow Alpha;
		Alpha.Category = n"Enemy";
		Alpha.Count = 2;
		Alpha.Label = "Alpha";
		Table.AddRow(n"Alpha", Alpha);

		FDataTableRowHandle RowHandle;
		FTSDataTableRow NullHandleOut;
		NullHandleOut.Count = -99;
		NullHandleOut.Label = "Sentinel";
		bool bNullHandleFound = RowHandle.GetRow(NullHandleOut);

		RowHandle.DataTable = Table;
		RowHandle.RowName = n"Alpha";
		FTSDataTableRow FromHandle;
		bool bHandleFound = RowHandle.GetRow(FromHandle);

		FDataTableCategoryHandle CategoryHandle;
		FTSDataTableRow NullCategoryOut;
		NullCategoryOut.Count = -99;
		bool bNullCategoryFound = CategoryHandle.GetRow(n"Alpha", NullCategoryOut);
		CategoryHandle.DataTable = Table;
		CategoryHandle.ColumnName = n"Category";
		CategoryHandle.RowContents = n"Enemy";
		FTSDataTableRow FromCategory;
		bool bCategoryFound = CategoryHandle.GetRow(n"Alpha", FromCategory);
		bool bCategoryMissing = CategoryHandle.GetRow(n"Missing", FromCategory);

		return !bNullHandleFound &&
			NullHandleOut.Count == -99 &&
			!bNullCategoryFound &&
			bHandleFound &&
			FromHandle.Label == "Alpha" &&
			bCategoryFound &&
			FromCategory.Count == 2 &&
			!bCategoryMissing;
	}

	bool Observe_GetRows_Nominal(UDataTable Table)
	{
		if (Table is null)
		{
			throw("TS_UDataTable_Queries_01 setup: required Table is null");
		}
		Table.EmptyTable();
		FTSDataTableRow Alpha;
		Alpha.Category = n"Enemy";
		Alpha.Count = 2;
		Alpha.Label = "Alpha";
		Table.AddRow(n"Alpha", Alpha);

		FDataTableCategoryHandle NullHandle;
		TArray<FTSDataTableRow> NullRows;
		FTSDataTableRow Sentinel;
		Sentinel.Label = "Sentinel";
		NullRows.Add(Sentinel);
		NullHandle.GetRows(NullRows);

		FDataTableCategoryHandle CategoryHandle;
		CategoryHandle.DataTable = Table;
		CategoryHandle.ColumnName = n"Category";
		CategoryHandle.RowContents = n"Enemy";
		TArray<FTSDataTableRow> OutArray;
		OutArray.Add(Sentinel);
		CategoryHandle.GetRows(OutArray);

		return NullRows.Num() == 1 &&
			NullRows[0].Label == "Sentinel" &&
			OutArray.Num() == 2 &&
			OutArray[0].Label == "Sentinel" &&
			OutArray[1].Label == "Alpha";
	}

	void ExerciseExpectedFailure()
	{
		UDataTable Table = Cast<UDataTable>(
			NewObject(GetTransientPackage(), UDataTable::StaticClass(), n"TSDataTableWrongArray", true));
		TArray<FVector> WrongRows;
		FVector Seed;
		Seed.X = 1.0;
		Seed.Y = 2.0;
		Seed.Z = 3.0;
		WrongRows.Add(Seed);
		Table.GetAllRows(WrongRows);
	}
}
/** @end */
