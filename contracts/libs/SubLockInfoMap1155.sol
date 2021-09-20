// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


struct SubLockInfo {
    uint24 blockNum;
    uint amount;
}

struct LockMap {
    // Storage of keys
    EnumerableSet.AddressSet _keys;
    mapping(address => SubLockInfo) _values;
}

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using SubLockInfoMap1155 for LockMap;
 *
 *     // Declare a set state variable
 *     LockMap private myMap;
 * }
 * ```
 *
 */
library SubLockInfoMap1155 {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        LockMap storage map,
        address key,
        SubLockInfo storage value
    ) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(LockMap storage map, address key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(LockMap storage map, address key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(LockMap storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    /**
     * @dev Returns the key-value pair stored at position `index` in the map. O(1).
     *
     * Note that there are no guarantees on the ordering of entries inside the
     * array, and it may change when more entries are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(LockMap storage map, uint256 index) internal view returns (address, SubLockInfo storage) {
        address key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     * todo what will return if key not exist?
     */
    function get(LockMap storage map, address key) internal view returns (SubLockInfo storage) {
        return map._values[key];
    }

    function entries(
        LockMap storage map
    ) internal view returns (address[] memory, SubLockInfo[] memory) {
        uint len = map._keys.length();
        address[] memory myKeys = map._keys.values();
        SubLockInfo[] memory myValues = new SubLockInfo[](len);
        for (uint i = 0; i < len; i++){
            myValues[i] = map._values[myKeys[i]];
        }
        return (myKeys, myValues);
    }
}