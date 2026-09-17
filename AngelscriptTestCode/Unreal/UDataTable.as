/**
 * @version v1
 * @summary UDataTable host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UDataTable
 *
 * to-debug-string
 * empty-table
 * remove-row
 * add-row
 * equality
 * get-row-names
 * find-row
 * get-all-rows
 * is-null
 * get-row
 * get-rows
 */
/**
 * @begin to-debug-string
 * @summary selects whether the table's object path is included.
 * @topic Unreal
 */
/**
 * @function ObserveToDebugStringNominal
 * @summary selects whether the table's object path is included.
 * @covers UDataTable.to-debug-string
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToDebugStringNominal()
{
	FDataTableRowHandle RowHandle;
	FString DefaultText = RowHandle.ToDebugString();
	FString DefaultFull = RowHandle.ToDebugString(true);
	FString DefaultShort = RowHandle.ToDebugString(false);

	UDataTable Table = Cast<UDataTable>(
		NewObject(GetTransientPackage(), UDataTable::StaticClass(), n"TSDataTableDebug", true));
	if (Table is null)
	{
		throw("TS_UDataTable_ConversionAndFormatting_01 setup: required Table is null");
	}
	RowHandle.DataTable = Table;
	RowHandle.RowName = n"Alpha";
	FString FilledShort = RowHandle.ToDebugString(false);
	FString FilledFull = RowHandle.ToDebugString(true);

	return DefaultText.Len() > 0 &&
		DefaultFull.Len() > 0 &&
		DefaultShort.Len() > 0 &&
		FilledShort.Len() > 0 &&
		FilledFull.Len() > 0 &&
		FilledShort != DefaultShort;
}
/** @end */
/**
 * @begin empty-table
 * @summary struct value.
 * @topic Unreal
 */
/**
 * @function ObserveEmptyTableNominal
 * @summary struct value.
 * @covers UDataTable.empty-table
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSDataTableMutationRow
{
	UPROPERTY()
	FName Category = NAME_None;

	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

bool ObserveEmptyTableNominal(UDataTable Table)
{
	if (Table is null)
	{
		throw("TS_UDataTable_MutationAndLifecycle_01 setup: required Table is null");
	}
	FTSDataTableMutationRow Alpha;
	Alpha.Category = n"Enemy";
	Alpha.Count = 2;
	Alpha.Label = "Alpha";
	Table.AddRow(n"Alpha", Alpha);
	Table.EmptyTable();
	TArray<FName> AfterEmpty = Table.GetRowNames();
	Table.EmptyTable();
	return AfterEmpty.Num() == 0 && Table.GetRowNames().Num() == 0;
}
/** @end */
/**
 * @begin remove-row
 * @summary struct value.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveRowNominal
 * @summary struct value.
 * @covers UDataTable.remove-row
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSDataTableMutationRow
{
	UPROPERTY()
	FName Category = NAME_None;

	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

bool ObserveRemoveRowNominal(UDataTable Table)
{
	if (Table is null)
	{
		throw("TS_UDataTable_MutationAndLifecycle_01 setup: required Table is null");
	}
	Table.EmptyTable();
	FTSDataTableMutationRow Alpha;
	Alpha.Label = "Alpha";
	FTSDataTableMutationRow Beta;
	Beta.Label = "Beta";
	Table.AddRow(n"Alpha", Alpha);
	Table.AddRow(n"Beta", Beta);
	Table.RemoveRow(n"Alpha");
	TArray<FName> AfterRemove = Table.GetRowNames();
	Table.RemoveRow(n"Missing");
	Table.RemoveRow(n"Alpha");
	return !AfterRemove.Contains(n"Alpha") && AfterRemove.Contains(n"Beta");
}
/** @end */
/**
 * @begin add-row
 * @summary struct value.
 * @topic Unreal
 */
/**
 * @function ObserveAddRowNominal
 * @summary struct value.
 * @covers UDataTable.add-row
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
USTRUCT()
struct FTSDataTableMutationRow
{
	UPROPERTY()
	FName Category = NAME_None;

	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

bool ObserveAddRowNominal(UDataTable Table)
{
	if (Table is null)
	{
		throw("TS_UDataTable_MutationAndLifecycle_01 setup: required Table is null");
	}
	Table.EmptyTable();
	FTSDataTableMutationRow Alpha;
	Alpha.Category = n"Enemy";
	Alpha.Count = 2;
	Alpha.Label = "Alpha";
	Table.AddRow(n"Alpha", Alpha);
	TArray<FName> AfterAdd = Table.GetRowNames();

	Alpha.Count = 9;
	Alpha.Label = "Replaced";
	Table.AddRow(n"Alpha", Alpha);
	TArray<FName> AfterReplace = Table.GetRowNames();
	FTSDataTableMutationRow Found;
	bool bFound = Table.FindRow(n"Alpha", Found);

	return AfterAdd.Contains(n"Alpha") &&
		AfterReplace.Contains(n"Alpha") &&
		AfterReplace.Num() == AfterAdd.Num() &&
		bFound &&
		Found.Count == 9 &&
		Found.Label == "Replaced";
}
/** @end */
/**
 * @begin equality
 * @summary RowName/ColumnName/
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary RowName/ColumnName/
 * @covers UDataTable.equality
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
// RowName/ColumnName/

RowContents differ (n"Alpha" vs n"Beta", n"Category"
// vs n"Other").
// Expected observations: Two defaults compare true. Copy identity is true.
// Changing RowName or category fields makes equality false.
// Boundary/ownership: Comparison uses table, row, and category identity. The
// operators do not mutate either handle.
bool ObserveEqualityNominal()
{
	FDataTableRowHandle LeftRowHandle;
	FDataTableRowHandle RightRowHandle;
	bool bDefaultRowsEqual = LeftRowHandle == RightRowHandle;
	RightRowHandle.RowName = n"Alpha";
	bool bRowNameDifference = LeftRowHandle == RightRowHandle;
	FDataTableRowHandle CopiedRow = LeftRowHandle;
	CopiedRow.RowName = n"Alpha";
	FDataTableRowHandle MatchingRow;
	MatchingRow.RowName = n"Alpha";
	bool bMatchingRowNamesEqual = CopiedRow == MatchingRow;
	MatchingRow.RowName = n"Beta";
	bool bDifferentRowNamesUnequal = CopiedRow == MatchingRow;

	FDataTableCategoryHandle LeftCategoryHandle;
	FDataTableCategoryHandle RightCategoryHandle;
	bool bDefaultCategoriesEqual = LeftCategoryHandle == RightCategoryHandle;
	RightCategoryHandle.ColumnName = n"Category";
	RightCategoryHandle.RowContents = n"Enemy";
	bool bCategoryFieldsDifference = LeftCategoryHandle == RightCategoryHandle;
	FDataTableCategoryHandle MatchingCategory;
	MatchingCategory.ColumnName = n"Category";
	MatchingCategory.RowContents = n"Enemy";
	bool bMatchingCategoriesEqual = RightCategoryHandle == MatchingCategory;
	MatchingCategory.RowContents = n"Item";
	bool bDifferentCategoryContentsUnequal = RightCategoryHandle == MatchingCategory;

	return bDefaultRowsEqual &&
		!bRowNameDifference &&
		bMatchingRowNamesEqual &&
		!bDifferentRowNamesUnequal &&
		bDefaultCategoriesEqual &&
		!bCategoryFieldsDifference &&
		bMatchingCategoriesEqual &&
		!bDifferentCategoryContentsUnequal;
}
/** @end */
/**
 * @begin get-row-names
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetRowNamesNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.get-row-names
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetRowNamesNominal(UDataTable Table)
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
/** @end */
/**
 * @begin find-row
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveFindRowNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.find-row
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveFindRowNominal(UDataTable Table)
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
/** @end */
/**
 * @begin get-all-rows
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllRowsNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.get-all-rows
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetAllRowsNominal(UDataTable Table)
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
/** @end */
/**
 * @begin is-null
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsNullNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.is-null
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveIsNullNominal(UDataTable Table)
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
/** @end */
/**
 * @begin get-row
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetRowNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.get-row
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetRowNominal(UDataTable Table)
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
/** @end */
/**
 * @begin get-rows
 * @summary type-mismatch diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetRowsNominal
 * @summary type-mismatch diagnostic path.
 * @covers UDataTable.get-rows
 * @inputs UDataTable values exercised by this observe
 * @return true when the observe comparison holds
 */
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

bool ObserveGetRowsNominal(UDataTable Table)
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
/** @end */
