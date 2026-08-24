// Purpose: Observe EmptyTable, RemoveRow, and AddRow mutations on UDataTable.
// Runner owns the Table fixture, including RowStruct matching
// FTSDataTableMutationRow. Null Table is setup failure.
// AS-facing API: DataTable.EmptyTable(); DataTable.RemoveRow(FName RowName);
// DataTable.AddRow(FName RowName, const ?&in InRow);
// Inputs: Runner-owned UDataTable, FTSDataTableMutationRow Alpha/Beta, n"Alpha"
// as the add/remove key, a repeated AddRow of the same name, RemoveRow of a
// missing name, and EmptyTable as cleanup.
// Expected observations: AddRow makes GetRowNames contain n"Alpha". Repeating
// AddRow of the same key replaces rather than duplicating the name. RemoveRow
// drops that name. EmptyTable leaves zero names while keeping the table
// object alive.
// Boundary/ownership: InRow is copied into the table. The caller keeps the
// struct value. RowName is interned FName identity. SetupOwner=Runner.

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

namespace TS_UDataTable_MutationAndLifecycle_01
{
	bool Observe_EmptyTable_Nominal(UDataTable Table)
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

	bool Observe_RemoveRow_Nominal(UDataTable Table)
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

	bool Observe_AddRow_Nominal(UDataTable Table)
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
}
