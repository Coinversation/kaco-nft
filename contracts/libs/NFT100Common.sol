// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC721
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// ERC1155
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../ERC20Upgradeable.sol";
import "../../interfaces/IFactory.sol";
import "../../interfaces/IFlashLoanReceiver.sol";

abstract contract NFT100Common is ERC20Upgradeable
{
    address public factory;
    address public nftAddress;
    uint256 public nftType;
    uint256 public nftValue;

    event Withdraw(uint256[] indexed _tokenIds, uint256[] indexed amounts);

    // create new token
    constructor() {}

    function __NFT100Common_init_(
        string memory _name,
        string memory _symbol,
        address _nftAddress,
        uint256 _nftType
    ) public payable {
        require(factory == address(0), "factory should be zero");
        __ERC20_init(_name, _symbol);
        factory = msg.sender;
        nftType = _nftType;
        nftAddress = _nftAddress;
        nftValue = 100 * 10**18;
    }

    modifier flashloansEnabled() {
        require(
            IFactory(factory).flashLoansEnabled(),
            "flashloans not allowed"
        );
        _;
    }

    function getInfos()
        public
        view
        returns (
            uint256 _type,
            string memory _name,
            string memory _symbol,
            uint256 _supply
        )
    {
        _type = nftType;
        _name = name();
        _symbol = symbol();
        _supply = totalSupply() / nftValue;
    }

    // withdraw nft and burn tokens
    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external virtual;

    // set new params
    function setParams(
        uint256 _nftType,
        string calldata _name,
        string calldata _symbol,
        uint256 _nftValue
    ) external {
        require(msg.sender == factory, "unauthorized");
        nftType = _nftType;
        setName(_name);
        setSymbol(_symbol);
        nftValue = _nftValue;
    }

    function toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    function toUnlockNumbers(bytes memory _bytes, uint256 _start)
        internal
        view
        returns (uint24[] memory)
    {
        uint256 count = (_bytes.length - _start) / 3;
        uint24[] memory unlockNumbers = new uint24[](count);
        uint24 num;
        for (uint256 i = 0; i < count; i++) {
            assembly {
                num := div(
                    mload(add(add(_bytes, 0x20), add(_start, mul(i, 3)))),
                    0x10000000000000000000000000000000000000000000000000000000000
                )
            }
            require(num < block.number + 864000, "NFTPair: blockNumber too big");
            require(num > block.number, "NFTPair: blockNumber too small");
            unlockNumbers[i] = num;
        }

        return unlockNumbers;
    }

    function decodeParams(bytes memory data, address defaultRecipient)
        public
        view
        returns (
            address,
            address,
            uint24[] memory
        )
    {
        uint256 n = data.length;
        address referal = IFactory(factory).feeTo();
        address recipient = defaultRecipient;
        uint24[] memory unlockBlocks = new uint24[] (0);

        if (n >= 20) {
            referal = toAddress(data, 0);
        }
        if (n >= 40) {
            recipient = toAddress(data, 20);
        }
        if (n >= 43) {
            unlockBlocks = toUnlockNumbers(data, 40);
        }
        return (referal, recipient, unlockBlocks);
    }

    function flashLoan(
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        address _operator,
        bytes calldata _params
    ) external virtual;
}
