// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC1155
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./libs/NFT100Common.sol";
import "./libs/LockInfoMap1155.sol";

contract NFT100Pair1155 is
    ERC1155ReceiverUpgradeable,
    NFT100Common
{

    using LockInfoMap1155 for LockInfoMap1155.Map;
    LockInfoMap1155.Map private lockInfoMap;

    using SubLockInfoMap1155 for LockMap;

    // create new token
    constructor() {}

    function init(
        string memory _name,
        string memory _symbol,
        address _nftAddress
    ) external payable {
        __NFT100Common_init_(_name, _symbol, _nftAddress, 1155);
    }

    //return: (id[], LockInfo[])
    function getLockInfos() external view returns (LockInfo1155[] memory){
        return lockInfoMap.entries();
    }

    function getAmountById(uint id) private view returns (uint){
        return IERC1155(nftAddress).balanceOf(address(this), id);
    }

    // withdraw nft and burn tokens
    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external override {
        require(_tokenIds.length == amounts.length, "ID != AM in length");
        uint256 qty = 0;
        for(uint i = 0; i < _tokenIds.length; i++){
            LockMap storage lm = lockInfoMap.get(_tokenIds[i]);
            (address[] memory lockers, SubLockInfo[] memory subLockInfos) = lm.entries();
            uint lockedAmount = 0;
            for(uint j = 0; j < subLockInfos.length; j++){
                if(subLockInfos[j].blockNum > block.number && lockers[j] != _msgSender()){
                    lockedAmount += subLockInfos[j].amount;
                }else if(subLockInfos[j].blockNum > 0){
                    lm.remove(lockers[j]);
                }
            }
            require(amounts[i] <= (getAmountById(_tokenIds[i]) - lockedAmount), "amount not enough");
            qty = qty + amounts[i];
        }

        // burn tokens
        _burn(_msgSender(), nftValue * qty);

        IERC1155(nftAddress).safeBatchTransferFrom(
            address(this),
            recipient,
            _tokenIds,
            amounts,
            "0x0"
        );

        emit Withdraw(_tokenIds, amounts);
    }

    function onERC1155Received(
        address operator,
        address,
        uint256 id,
        uint256 value,
        bytes memory data
    ) external virtual override returns (bytes4) {
        require(nftAddress == _msgSender(), "forbidden");
        if (keccak256(data) != keccak256("INTERNAL")) {
            whiteListCheck(id);
            uint256 fee = IFactory(factory).fee();
            address feeTo = IFactory(factory).feeTo();

            (address referral, address recipient, uint24[] memory unlockBlocks) = decodeParams(
                data,
                operator
            );

            uint256 lockFee = 0;
            if(unlockBlocks.length > 0){
                lockFee = setLockBlock1155(operator, id, value, unlockBlocks[0]);
            }

            uint256 refFee = IFactory(factory).getReferralFee(referral);
            // If referral exist, give refFee to referral
            if (refFee > 0) {
                _mint(referral, (nftValue * value * refFee) / 100);
                _mint(feeTo, (nftValue * value * (fee - refFee)) / 100 + lockFee);
            } else {
                _mint(feeTo, (nftValue * value * fee) / 100 + lockFee);
            }

            _mint(
                recipient,
                (((nftValue * value) * (uint256(100) - fee)) / 100) - lockFee
            );
        }
        return this.onERC1155Received.selector;
    }

    function setLockBlock1155(address operator,
        uint256 id,
        uint256 amount,
        uint24 _unlockBlock) private returns (uint256){
        LockMap storage lm = lockInfoMap.get(id);
        SubLockInfo storage subLockInfo = lm.get(operator);
        require(subLockInfo.blockNum <= block.number, "1155 id still locked");
        uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
        subLockInfo.blockNum = _unlockBlock;
        subLockInfo.amount = amount;
        lockInfoMap.set(id, operator, subLockInfo);
        return nftValue * amount * feePerBlock * (_unlockBlock - block.number) / 10000000000;
    }

    /* param data: default is "0x0". 
        format:
        let data = ethers.utils.solidityPack(["address", "address", "uint24","uint24"...], ["referral address", "recipient address", unlockBlockNumber1, unlockBlockNumber2...])

        note: The order of UnlockBlockNumber must correspond to IndexID of the ids

        e.g.
        let data = ethers.utils.solidityPack(["address", "address", "uint24","uint24"], ["0xFB83a67784F110dC658B19515308A7a95c2bA33A", "0xFB83a67784F110dC658B19515308A7a95c2bA33A", 11011286, 11011286])
        ethers.utils.defaultAbiCoder.encode(["address", "address", "uint256[]", "uint256[]", "bytes"], ["0xFB83a67784F110dC658B19515308A7a95c2bA33A", "0xFB83a67784F110dC658B19515308A7a95c2bA33A", [100, 101], [1, 100], data]);
    */
    function onERC1155BatchReceived(
        address operator,
        address,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) external override returns (bytes4) {
        require(nftAddress == _msgSender(), "forbidden");
        if (keccak256(data) != keccak256("INTERNAL")) {
            uint256 qty = 0;

            require(ids.length == values.length, "ID != VA");
            for (uint256 i = 0; i < ids.length; i++) {
                whiteListCheck(ids[i]);
                qty = qty + values[i];
            }
            uint256 fee = IFactory(factory).fee();
            address feeTo = IFactory(factory).feeTo();

            (address referral, address recipient, uint24[] memory unlockBlocks) = decodeParams(
                data,
                operator
            );

            uint256 lockFee = 0;
            if(unlockBlocks.length > 0){
                lockFee = setLockBlocks1155(operator, ids, values, unlockBlocks);
            }

            uint256 refFee = IFactory(factory).getReferralFee(referral);
            // If referral exist, give refFee to referral
            if (refFee > 0) {
                _mint(referral, (nftValue * qty * refFee) / 100);
                _mint(feeTo, (nftValue * qty * (fee - refFee)) / 100 + lockFee);
            } else {
                _mint(feeTo, (nftValue * qty * fee) / 100 + lockFee);
            }

            _mint(
                recipient,
                ((nftValue * qty) * (uint256(100) - (fee))) / 100 - lockFee
            );
        }
        return this.onERC1155BatchReceived.selector;
    }

    function setLockBlocks1155(address operator,
        uint256[] memory ids,
        uint256[] memory amounts,
        uint24[] memory unlockBlocks) private returns (uint256){
        uint256 lockFee = 0;
        require(ids.length == unlockBlocks.length, "UB.length != ids.length");
        uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
        for(uint i = 0; i < ids.length; i++){
            LockMap storage lm = lockInfoMap.get(ids[i]);
            SubLockInfo storage subLockInfo = lm.get(operator);
            require(subLockInfo.blockNum <= block.number, "1155 ids still locked");
            lockFee += nftValue * amounts[i] * feePerBlock * (unlockBlocks[i] - block.number) / 10000000000;
            subLockInfo.blockNum = unlockBlocks[i];
            subLockInfo.amount = amounts[i];
            lockInfoMap.set(ids[i], operator, subLockInfo);
        }
        return lockFee;
    }
}
