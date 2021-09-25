// SPDX-License-Identifier: GPL

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./SubLockInfoMap1155.sol";


struct LockInfo1155 {
    uint id;
    address unlocker;
    uint24 blockNum;
    uint amount;
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
 *     using LockInfoMap1155 for LockInfoMap1155.Map;
 *
 *     // Declare a set state variable
 *     LockInfoMap1155.Map private myMap;
 * }
 * ```
 *
 */
library LockInfoMap1155 {
    using EnumerableSet for EnumerableSet.UintSet;
    using SubLockInfoMap1155 for LockMap;

    struct Map {
        // Storage of keys
        EnumerableSet.UintSet _keys;
        mapping(uint => LockMap) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(
        Map storage map,
        uint key,
        address subKey,
        SubLockInfo storage info
    ) internal returns (bool) {
        LockMap storage lockMap = map._values[key];
        lockMap.set(subKey, info);
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(Map storage map, uint key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(Map storage map, uint key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function length(Map storage map) internal view returns (uint256) {
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
    function at(Map storage map, uint256 index) internal view returns (uint, LockMap storage) {
        uint key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     * todo what will return if key not exist?
     */
    function get(Map storage map, uint key) internal view returns (LockMap storage) {
        return map._values[key];
    }

    function entries(
        Map storage map
    ) internal view returns (LockInfo1155[] memory) {
        uint len = map._keys.length();
        uint[] memory myKeys = map._keys.values();
        uint total = 0;
        for (uint i = 0; i < len; i++){
            LockMap storage lm = map._values[myKeys[i]];
            total += lm.length();
        }
        LockInfo1155[] memory lockInfos = new LockInfo1155[](total);
        uint counter = 0;
        for (uint i = 0; i < len; i++){
            LockMap storage lm = map._values[myKeys[i]];
            (address[] memory lpAddresses, SubLockInfo[] memory lpSubLockInfos) = lm.entries();
            uint lpLength = lpAddresses.length;
            for (uint j = 0; j < lpLength; j++){
                lockInfos[counter] = LockInfo1155(myKeys[i], lpAddresses[j], lpSubLockInfos[j].blockNum, lpSubLockInfos[j].amount);
                counter++;
            }
        }
        return lockInfos;
    }
}