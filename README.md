# bitleveld
Bit-level utilities for D by László Szerémi (laszloszeremi@outlook.com, https://twitter.com/ziltoid1991, https://www.patreon.com/ShapeshiftingLizard, https://ko-fi.com/D1D45NEN).

# Functionalities

* Nibble (4bit) and Quad (2bit) arrays.
* Bitplane reader/writer.
* Safe type-array reinterpretator functions.

# Note on pointer casting

The functions of bitleveld.reinterpret are capable of casting pointers and structs that contain paointers. Exploiting this behavior is unsafe and might result in memory leakage issues. A future version will feature an option to test for such things with static asserts.