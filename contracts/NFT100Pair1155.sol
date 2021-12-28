// SPDX-License-Identifier: GPL
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

    function getLockInfos(uint start) external view returns (LockInfo1155[] memory){
        return lockInfoMap.entries(start);
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

            uint unlockAmount;
            for(uint j = 0; j < subLockInfos.length; j++){
                if(lockers[j] != address(0) && (subLockInfos[j].blockNum < block.number || lockers[j] == _msgSender())){
                    unlockAmount += subLockInfos[j].amount;
                    lm.remove(lockers[j]);
                }
            }
            SubLockInfo storage freeNft = lm.get(address(0));
            uint freeAmount = freeNft.amount + unlockAmount - amounts[i];
            if(freeAmount == 0){
                lm.remove(address(0));
                if(lm.length() == 0){
                    lockInfoMap.remove(_tokenIds[i]);
                }
            }else{
                freeNft.amount = freeAmount;
                lm.set(address(0), freeNft);
            }
            
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
        }else{
            lockFee = setLockBlock1155(operator, id, value, 0);
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
        return this.onERC1155Received.selector;
    }

    function setLockBlock1155(address operator,
        uint256 id,
        uint256 amount,
        uint24 _unlockBlock) private returns (uint256){
        LockMap storage lm = lockInfoMap.get(id);
        SubLockInfo storage subLockInfo;
        if(_unlockBlock == 0){
            subLockInfo = lm.get(address(0));
            subLockInfo.amount += amount;
            lockInfoMap.set(id, address(0), subLockInfo);
            return 0;
        }else{
            subLockInfo = lm.get(operator);
            if(subLockInfo.blockNum > block.number){
                revert("still locked");
            }else if(subLockInfo.blockNum > 0){ //could delete this logic
                SubLockInfo storage freeNft = lm.get(address(0));
                freeNft.amount += subLockInfo.amount;
                lockInfoMap.set(id, address(0), freeNft);
            }
            subLockInfo.blockNum = _unlockBlock;
            subLockInfo.amount = amount;

            lockInfoMap.set(id, operator, subLockInfo);
            uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
            return nftValue * amount * feePerBlock * (_unlockBlock - block.number) / 10000000000;
        }
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
            require(ids.length == unlockBlocks.length, "UB!=ID");
            for(uint i = 0; i < ids.length; i++){
                lockFee += setLockBlock1155(operator, ids[i], values[i], unlockBlocks[i]);
            }
        }else{
            for(uint i = 0; i < ids.length; i++){
                setLockBlock1155(operator, ids[i], values[i], 0);
            }
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
        return this.onERC1155BatchReceived.selector;
    }
}
