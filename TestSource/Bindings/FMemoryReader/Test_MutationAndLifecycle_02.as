// Purpose: Observe double, raw-byte, and ANSI-string reads, including empty
// Count and sequential ordering of remaining bytes.
// AS-facing API: float64 Reader.ReadDouble();
// TArray<uint8> Reader.ReadBytes(int Count);
// FString Reader.ReadAnsiString(int Count);
// Inputs: A 12-byte buffer matching the existing ReadOperations fixture,
// Count 4 for the tail, Count 0 as the empty result, and a double-width
// prefix for ReadDouble.
// Expected observations: ReadBytes(4) returns four values in order.
// ReadBytes(0) is empty. ReadAnsiString(4) at offset 8 equals "CDEF".
// ReadDouble advances Tell by 8.
// Boundary/ownership: Returned TArray/FString copies are independent of the
// reader cursor. Count past the remaining bytes is a diagnostic boundary
// observed by later Seek/Skip tests.

namespace TS_FMemoryReader_MutationAndLifecycle_02
{
	TArray<uint8> MakeTailProbeData()
	{
		TArray<uint8> Data;
		Data.Add(0x41);
		Data.Add(0x42);
		Data.Add(0x10);
		Data.Add(0x00);
		Data.Add(0x78);
		Data.Add(0x56);
		Data.Add(0x34);
		Data.Add(0x12);
		Data.Add(0x43);
		Data.Add(0x44);
		Data.Add(0x45);
		Data.Add(0x46);
		return Data;
	}

	bool Observe_ReadDouble_Nominal()
	{
		TArray<uint8> Data = MakeTailProbeData();
		FMemoryReader Reader(Data);
		float64 Value = Reader.ReadDouble();
		return Reader.Tell() == 8 && Reader.TotalSize() == 12 && Math::IsFinite(Value);
	}

	bool Observe_ReadBytes_Nominal()
	{
		TArray<uint8> Data = MakeTailProbeData();
		FMemoryReader Reader(Data);
		Reader.Seek(8);
		TArray<uint8> TailBytes = Reader.ReadBytes(4);
		bool bCountMatches = TailBytes.Num() == 4;
		bool bOrderMatches = bCountMatches && TailBytes[0] == 0x43 && TailBytes[1] == 0x44 && TailBytes[2] == 0x45 && TailBytes[3] == 0x46;
		bool bCursorAtEnd = Reader.Tell() == 12;

		FMemoryReader EmptyReader(Data);
		TArray<uint8> EmptyBytes = EmptyReader.ReadBytes(0);
		return bCountMatches && bOrderMatches && bCursorAtEnd && EmptyBytes.Num() == 0;
	}

	bool Observe_ReadAnsiString_Nominal()
	{
		TArray<uint8> Data = MakeTailProbeData();
		FMemoryReader Reader(Data);
		Reader.Seek(8);
		FString Text = Reader.ReadAnsiString(4);
		bool bAnsiMatches = Text == "CDEF" && Reader.Tell() == 12;
		FMemoryReader EmptyReader(Data);
		FString EmptyText = EmptyReader.ReadAnsiString(0);
		return bAnsiMatches && EmptyText.IsEmpty();
	}
}
