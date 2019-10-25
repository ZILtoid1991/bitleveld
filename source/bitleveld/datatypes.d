/*
 * bitleveld - datatypes.d
 * by Laszlo Szeremi
 *
 * Copyright under Boost Software License.
 */

module bitleveld.datatypes;

import std.bitmanip;

/**
 * Used for template initialization.
 * Reverses the order of data elements whithin a byte if false.
 */
public enum ByteEndianness : bool {
	normal	= 	true,
	reverse	=	false,
}
/**
 * Implements a 4bit nibble array.
 */
public struct NibbleArrayTemplt (bool Endianness = ByteEndianness.normal) {
	private ubyte[]	src;
	private size_t	_length;

	public const size_t length() @nogc nothrow @safe pure @property {
		return _length;
	}
	public size_t length(size_t val) nothrow @safe pure @property {
		src.length = val>>>1 + (val & 1);
		return _length = val;
	}
	public size_t reserve(size_t val) nothrow @safe pure {
		return src.reserve(val>>>1)<<1;
	}
	ubyte opIndex (size_t i) @nogc nothrow @safe pure {
		static if (Endianness) {
			if (i & 1) {
				return src[i>>>1]>>>4;
			} else {
				return src[i>>>1] & 0x0F;
			}
		} else {
			if (i & 1) {
				return src[i>>>1] & 0x0F;
			} else {
				return src[i>>>1]>>>4;
			}
		}
	}
	ubyte opIndexAssign (ubyte val, size_t i) @nogc nothrow @safe pure {
		val &= 0x0F;
		static if (Endianness) {
			if (i & 1) {
				src[i>>>1] |= val<<4;
			} else {
				src[i>>>1] |= val & 0x0F;
			}
		} else {
			if (i & 1) {
				src[i>>>1] |= val & 0x0F;
			} else {
				src[i>>>1] |= val<<4;
			}
		}
		return opIndex(i);
	}
}
alias NibbleArray = NibbleArrayTemplt!(ByteEndianness.normal);
alias NibbleArrayR = NibbleArrayTemplt!(ByteEndianness.reverse);
/**
 * Implements a 2bit quad array.
 */
public struct QuadArrayTemplt (bool Endianness = ByteEndianness.normal) {
	private ubyte[] src;
	private size_t	_length;
	public const size_t length() @nogc nothrow @safe pure @property {
		return _length;
	}
	public size_t length(size_t val) nothrow @safe pure @property {
		src.length = val>>>2 + ((val & 1) | (val>>>1 & 1));
		return _length = val;
	}
	public size_t reserve(size_t val) nothrow @safe pure {
		return src.reserve(val>>>1)<<1;
	}
	ubyte opIndex (size_t i) @nogc nothrow @safe pure {
		static if (Endianness) {
			switch (i & 3) {
				case 1:
					return (src[i>>>2] & 0b0000_1100)>>>2;
				case 2:
					return (src[i>>>2] & 0b0011_0000)>>>4;
				case 3:
					return src[i>>>2]>>>6;
				default:
					return src[i>>>2] & 0b0000_0011;
			}
		} else {
			switch (i & 3) {
				case 1:
					return (src[i>>>2] & 0b0011_0000)>>>4;
				case 2:
					return (src[i>>>2] & 0b0000_1100)>>>2;
				case 3:
					return src[i>>>2] & 0b0000_0011;
				default:
					return src[i>>>2]>>>6;
			}
		}
	}
	ubyte opIndexAssign (ubyte val, size_t i) @nogc nothrow @safe pure {
		val &= 0b0000_0011;
		static if (Endianness) {
			switch (i & 3) {
				case 1:
					src[i>>>2] |= val<<2;
					break;
				case 2:
					src[i>>>2] |= val<<4;
					break;
				case 3:
					src[i>>>2] |= val<<6;
					break;
				default:
					src[i>>>2] |= val;
					break;
			}
		} else {
			switch (i & 3) {
				case 1:
					src[i>>>2] |= val<<4;
					break;
				case 2:
					src[i>>>2] |= val<<2;
					break;
				case 3:
					src[i>>>2] |= val;
					break;
				default:
					src[i>>>2] |= val<<6;
					break;
			}
		}
		return opIndex(i);
	}
}
alias QuadArray = QuadArrayTemplt!(ByteEndianness.normal);
alias QuadArrayR = QuadArrayTemplt!(ByteEndianness.reverse);

unittest {
	import std.conv : to;
	ubyte[] test = [0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef];
	ubyte[] output;
	NibbleArray na = NibbleArray(test, 16);
	for (int i ; i < na.length ; i++) {
		output ~= na[i];
	}
	assert(output == [1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14], "Error in result : " ~ to!string(output));
	output.length = 0;
	NibbleArrayR nar = NibbleArrayR(test, 16);
	for (int i ; i < nar.length ; i++) {
		output ~= nar[i];
	}
	assert(output == [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], "Error in result : " ~ to!string(output));
	output.length = 0;
	QuadArray qa = QuadArray(test, 32);
	for (int i ; i < qa.length ; i++) {
		output ~= qa[i];
	}
	assert(output == [1,0, 0,0, 3,0, 2,0, 1,1, 0,1, 3,1, 2,1, 1,2, 0,2, 3,2, 2,2, 1,3, 0,3, 3,3, 2,3], "Error in result : "
			~ to!string(output));
	output.length = 0;
	QuadArrayR qar = QuadArrayR(test, 32);
	for (int i ; i < qar.length ; i++) {
		output ~= qar[i];
	}
	assert(output == [0,0, 0,1, 0,2, 0,3, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 2,2, 2,3, 3,0, 3,1, 3,2, 3,3], "Error in result : "
			~ to!string(output));
}

/**
 * Implements a bitplane reader/writer, that reads/writes multiple bitplanes at once.
 * Between 1-8 planes, ubyte is used as the return/input type, between 9-16 it's ushort.
 */
public struct Bitplane (int NOfBitplanes) 
		if (NOfBitplanes <= 16 && NOfBitplanes > 0) {
	private BitArray[NOfBitplanes]		src;
	private	size_t						_length;
	public const size_t length () @property @nogc nothrow @safe pure {
		return length;
	}
	public size_t length (size_t val) @property nothrow @trusted pure {
		for (int i ; i < NOfBitplanes ; i++) {
			src[i].length = val;
		}
		return length = val;
	}
	static if (NOfBitplanes <= 8) {
		ubyte opIndex(size_t i) {
			ubyte result;
			for (int b ; b < NOfBitplanes ; b++){
				result>>>=1;
				result |= src[b][i] ? 1 : 0;
			}
			return result;
		}
		ubyte opIndexAssign(ubyte val, size_t i) {
			for (int b ; b < NOfBitplanes ; b++){
				src[b][i] = (val&1) == 1;
				val>>>=1;
			}
			return opIndex(i);
		}
	} else {
		ushort opIndex(size_t i) {
			ushort result;
			for (int b ; b < NOfBitplanes ; b++){
				result>>>=1;
				result |= src[b][i] ? 1 : 0;
			}
			return result;
		}
		ushort opIndexAssign(ushort val, size_t i) {
			for (int b ; b < NOfBitplanes ; b++){
				src[b][i] = (val&1) == 1;
				val>>>=1;
			}
			return opIndex(i);
		}
	}
}
unittest{
	ubyte[] plane0 = [0x51,0x31,0x05,0x08,0x60,0x00,0x00,0x00];
	ubyte[] plane1 = [0x00,0x05,0x00,0x22,0x60,0x00,0x00,0x00];
	ubyte[] plane2 = [0x00,0x00,0x00,0x00,0x60,0x00,0x00,0x00];
	Bitplane!3 plane = Bitplane!3([BitArray(plane0, 8*8), BitArray(plane1, 8*8), BitArray(plane2, 8*8)], 8*8);
}