module rebel.handle;

/**
	Returns $(D s) rounded up to the nearest power of 2.
	From: http://dpldocs.info/experimental-docs/source/std.experimental.allocator.common.d.html#L216
	License: Boost
*/

@safe @nogc nothrow pure private size_t roundUpToPowerOf2(size_t s) {
	import std.meta : AliasSeq;

	assert(s <= (size_t.max >> 1) + 1);
	--s;
	static if (size_t.sizeof == 4)
		alias Shifts = AliasSeq!(1, 2, 4, 8, 16);
	else
		alias Shifts = AliasSeq!(1, 2, 4, 8, 16, 32);
	foreach (i; Shifts)
		s |= s >> i;
	return s + 1;
}

struct Handle(Type_, size_t MaxCount_) {
	import std.bitmanip : bitfields;
	import std.math : log2, ceil;

	alias Ref = HandleRefData!(typeof(this), Type_);

	private alias Type = Type_;
	private enum size_t MaxCount = MaxCount_;

	private enum BitSize = cast(size_t)MaxCount.log2.ceil + 4 + 1 + 2;
	private enum BitSizeRound = BitSize.roundUpToPowerOf2;

	// dfmt off
	mixin(bitfields!(
		size_t, "id", cast(size_t)MaxCount.log2.ceil,
		ubyte, "magic", 4,
		bool, "inUse", 1,
		ubyte, "refGotten", 2,
		ulong, "", BitSizeRound - BitSize
	));
	// dfmt on

	@property bool isValid() const {
		return inUse && id < MaxCount;
	}

	// I could dream
	/*invariant {
		assert(isValid());
	}*/
}

struct HandleRefData(HandleType_, Type) if (is(HandleType_ : Handle!(Type, MaxCount), Type, size_t MaxCount)) {
	alias HandleType = HandleType_;

	@disable this(this);

	~this() {
		if (_handle)
			_handle.refGotten = cast(ubyte)(_handle.refGotten - 1);
	}

	@property T* get(T = Type)() if (is(T == Type) || is(typeof(T.tupleof[0]) == Type)) {
		return cast(T*)_data;
	}

	/*alias get this;

	auto opCast(T)() if (is(T.HandleType == HandleType)) {
		return T(_handle, cast(typeof(T._data))_data);
	}

	alias to = opCast;*/

	static if (!is(Type == HandleType.Type)) {
		auto toBase() {
			return HandleRefData!(HandleType, HandleType.Type)(_handle, cast(HandleType.Type*)_data);
		}

		alias toBase this;
	}

private:
	this(HandleType* handle, Type* data) {
		_handle = handle;
		_handle.refGotten = cast(ubyte)(_handle.refGotten + 1);
		_data = data;
	}

	HandleType* _handle;
	Type* _data;
}

struct HandleStorage(HandleType, Type = HandleType.Type) if (is(HandleType : Handle!(Type, MaxCount), Type, size_t MaxCount)) {
	private enum size_t MaxCount = HandleType.MaxCount;

	@disable this(this);

	HandleType[MaxCount] handles = () {
		HandleType[MaxCount] output;
		foreach (i, ref hdl; output) {
			hdl.id = i;
		}
		return output;
	}();
	Type[MaxCount] data;

	scope HandleRefData!(HandleType, Type) get(HandleType h) {
		import std.format : format;

		assert(h.isValid, format!"Handle is invalid! inUse: %s, id %s < %s"(h.inUse, h.id, h.MaxCount));
		assert(handles[h.id].magic == h.magic, "Old handle - Magic is wrong");
		assert(handles[h.id].inUse, "Old handle - Not in use");
		assert(!handles[h.id].refGotten, "Someone is already holding a ref of this handle");

		return HandleRefData!(HandleType, Type)(&handles[h.id], cast(Type*)&data[h.id]);
	}

	HandleType create(Args...)(Args args) {
		import std.algorithm : find;
		import std.range : front, empty;
		import std.conv : emplace;

		auto handlePtr = find!"a.inUse == b"(handles[], false);
		assert(!handlePtr.empty, "Out of handles!");
		HandleType* handle = &handlePtr.front;
		handle.inUse = true;

		handle.magic = cast(ubyte)(handle.magic + 1);

		emplace(&data[handle.id], args);

		return *handle;
	}

	void remove(HandleType h) {
		assert(h.isValid, "Handle is invalid");
		assert(handles[h.id].magic == h.magic, "Old handle - Magic is wrong");
		assert(handles[h.id].inUse, "Old handle - Not in use");
		assert(!handles[h.id].refGotten, "Someone is holding a ref of this handle");

		data[h.id].destroy;
		handles[h.id].inUse = false;
	}

	void clear() {
		foreach (ref h; handles) {
			if (!h.inUse)
				continue;
			data[h.id].destroy;
			h.inUse = false;
		}
	}

	int opApply(int delegate(ref Type data) dg) {
		foreach (h; handles) {
			if (!h.inUse)
				continue;
			if (auto _ = dg(data[h.id]))
				return _;
		}
		return 0;
	}

	int opApply(int delegate(size_t idx, ref Type data) dg) {
		foreach (h; handles) {
			if (!h.inUse)
				continue;
			if (auto _ = dg(h.id, data[h.id]))
				return _;
		}
		return 0;
	}

}
