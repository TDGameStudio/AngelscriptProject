/**
 * @version v1
 * @summary Observe Tell, Seek, and Skip cursor movement, including the empty buffer and a skip of zero.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Tell, Seek, and Skip cursor movement, including the empty buffer and a skip of zero.
 * @topic Baseline
 */
// void Reader.Skip(int Count);
// Inputs: The 12-byte fixture, initial Tell 0, Seek(4), Skip(2), Skip(0),
// and Seek(0) restoration.
// Expected observations: Fresh Tell is 0. Seek(4) then Skip(2) yields Tell 6.
// Skip(0) leaves Tell unchanged. Seek(0) restores the start.
// Boundary/ownership: Seek/Skip mutate only the reader cursor, not Data.
// Seeking or skipping past TotalSize is the out-of-bounds diagnostic path.

namespace TS_FMemoryReader_Behavior_01
{
	TArray<uint8> MakeCursorProbeData()
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

	bool Observe_Tell_Nominal()
	{
		TArray<uint8> Data = MakeCursorProbeData();
		FMemoryReader Reader(Data);
		int FreshTell = Reader.Tell();
		Reader.ReadUInt8();
		int AfterReadTell = Reader.Tell();
		TArray<uint8> Empty;
		FMemoryReader EmptyReader(Empty);
		int EmptyTell = EmptyReader.Tell();
		return FreshTell == 0 && AfterReadTell == 1 && EmptyTell == 0;
	}

	bool Observe_Seek_Nominal()
	{
		TArray<uint8> Data = MakeCursorProbeData();
		FMemoryReader Reader(Data);
		int Before = Reader.Tell();
		Reader.Seek(4);
		int AfterSeek = Reader.Tell();
		Reader.Seek(4);
		int AfterRepeat = Reader.Tell();
		Reader.Seek(0);
		int Restored = Reader.Tell();
		return Before == 0 && AfterSeek == 4 && AfterRepeat == 4 && Restored == 0;
	}

	bool Observe_Skip_Nominal()
	{
		TArray<uint8> Data = MakeCursorProbeData();
		FMemoryReader Reader(Data);
		Reader.Seek(2);
		int BeforeSkip = Reader.Tell();
		Reader.Skip(2);
		int AfterSkip = Reader.Tell();
		Reader.Skip(0);
		int AfterZeroSkip = Reader.Tell();
		return BeforeSkip == 2 && AfterSkip == 4 && AfterZeroSkip == 4;
	}
}
/** @end */
