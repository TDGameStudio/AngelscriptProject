/**
 * @version v1
 * @summary Observe FMemoryReader construction and primitive integer/float reads from a seeded byte array, including a byte-swapped constructor.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FMemoryReader construction and primitive integer/float reads from a seeded byte array, including a byte-swapped constructor.
 * @topic Baseline
 */
// int8 Reader.ReadInt8(); uint8 Reader.ReadUInt8(); int16 Reader.ReadInt16();
// uint16 Reader.ReadUInt16(); int32 Reader.ReadInt32(); uint32 Reader.ReadUInt32();
// int64 Reader.ReadInt64(); uint64 Reader.ReadUInt64(); float32 Reader.ReadFloat();
// Inputs: A 16-byte little-endian buffer starting 0x01, 0x02, 0x03, 0x04,
// 0x78,0x56,0x34,0x12 then zeros, default ForceByteSwapping=false, and a
// second reader constructed with ForceByteSwapping=true.
// Expected observations: Each Read* consumes the next width and advances Tell.
// Default construction does not swap. Repeated ReadUInt8 yields sequential bytes.
// Boundary/ownership: The reader borrows the byte array for its lifetime and
// does not take ownership of Data.

namespace TS_FMemoryReader_MutationAndLifecycle_01
{
	TArray<uint8> MakeIntegerProbeData()
	{
		TArray<uint8> Data;
		Data.Add(0x01);
		Data.Add(0x02);
		Data.Add(0x03);
		Data.Add(0x04);
		Data.Add(0x78);
		Data.Add(0x56);
		Data.Add(0x34);
		Data.Add(0x12);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x00);
		return Data;
	}

	bool Observe_Reader_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader DefaultReader(Data);
		int DefaultSize = DefaultReader.TotalSize();
		FMemoryReader SwappedReader(Data, true);
		int SwappedSize = SwappedReader.TotalSize();
		return DefaultSize == 16 && SwappedSize == 16;
	}

	bool Observe_ReadInt8_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		int8 Value = Reader.ReadInt8();
		return Value == 0x01 && Reader.Tell() == 1;
	}

	bool Observe_ReadUInt8_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		uint8 First = Reader.ReadUInt8();
		uint8 Second = Reader.ReadUInt8();
		return First == 0x01 && Second == 0x02 && Reader.Tell() == 2;
	}

	bool Observe_ReadInt16_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		int16 Value = Reader.ReadInt16();
		return Value == 0x0201 && Reader.Tell() == 2;
	}

	bool Observe_ReadUInt16_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		Reader.ReadUInt8();
		uint16 Value = Reader.ReadUInt16();
		return Value == 0x0302 && Reader.Tell() == 3;
	}

	bool Observe_ReadInt32_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		Reader.Seek(4);
		int32 Value = Reader.ReadInt32();
		return Value == 0x12345678 && Reader.Tell() == 8;
	}

	bool Observe_ReadUInt32_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		Reader.Seek(4);
		uint32 Value = Reader.ReadUInt32();
		return Value == 0x12345678 && Reader.Tell() == 8;
	}

	bool Observe_ReadInt64_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		int64 Value = Reader.ReadInt64();
		int64 Expected = (int64(0x12345678) << 32) | int64(0x04030201);
		return Reader.Tell() == 8 && Value == Expected;
	}

	bool Observe_ReadUInt64_Nominal()
	{
		TArray<uint8> Data = MakeIntegerProbeData();
		FMemoryReader Reader(Data);
		uint64 Value = Reader.ReadUInt64();
		uint64 Expected = (uint64(0x12345678) << 32) | uint64(0x04030201);
		return Reader.Tell() == 8 && Value == Expected;
	}

	bool Observe_ReadFloat_Nominal()
	{
		TArray<uint8> Data;
		Data.Add(0x00);
		Data.Add(0x00);
		Data.Add(0x80);
		Data.Add(0x3f);
		FMemoryReader Reader(Data);
		float32 Value = Reader.ReadFloat();
		return Reader.Tell() == 4 && Value == 1.0;
	}
}
/** @end */
