// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC721
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./libs/NFT100Common.sol";
import "./libs/LockInfoMap.sol";

contract NFT100Pair721 is
    IERC721ReceiverUpgradeable,
    NFT100Common
{
    using LockInfoMap for LockInfoMap.Map;
    // id => blockNumber, the block number when this id could be unlocked.
    LockInfoMap.Map private lockInfos;
    
    // create new token
    constructor() {}

    function init(
        string memory _name,
        string memory _symbol,
        address _nftAddress
    ) public payable {
        __NFT100Common_init_(_name, _symbol, _nftAddress, 721);
    }

    //return: (id[], LockInfo[])
    function getLockInfos() external view returns (uint256[] memory, LockInfo[] memory){
        return lockInfos.entries();
    }
    
    // withdraw nft and burn tokens
    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external override{
        _burn(_msgSender(), nftValue * _tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            checkLock(_tokenIds[i], _msgSender());
            _withdraw721(address(this), recipient, _tokenIds[i]);
        }
        emit Withdraw(_tokenIds, amounts);
    }

    function checkLock(uint id, address operator) private {
        LockInfo storage info = lockInfos.get(id);
        if (info.blockNum > block.number && info.unlocker != operator){
            revert("721 locked");
        } else if (info.blockNum > 0){
            lockInfos.remove(id);
        }
    }

    function _withdraw721(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        IERC721(nftAddress).safeTransferFrom(_from, _to, _tokenId);
    }

    function swap721(
        uint256 _in,
        uint256 _out,
        address _receipient
    ) external {
        checkLock(_out, _msgSender());
        IERC721(nftAddress).transferFrom(_msgSender(), address(this), _in);
        IERC721(nftAddress).safeTransferFrom(address(this), _receipient, _out);
    }


    //param _referral: 3rd party fee receival address
    function multi721Deposit(
        uint256[] memory _ids,
        bytes memory data
    ) external {
        uint256 fee = IFactory(factory).fee();
        address feeTo = IFactory(factory).feeTo();

        (address _referral, address _receipient, uint24[] memory unlockBlocks) = decodeParams(data, _msgSender());

        for (uint256 i = 0; i < _ids.length; i++) {
            IERC721(nftAddress).transferFrom(
                _msgSender(),
                address(this),
                _ids[i]
            );
        }

        uint256 refFee = IFactory(factory).getReferralFee(_referral);
        // If referral exist, give refFee to referral
        if (refFee > 0) {
            _mint(_referral, ((nftValue * _ids.length) * refFee) / 100);
            _mint(feeTo, ((nftValue * _ids.length) * (fee - refFee)) / 100);
        } else {
            _mint(feeTo, ((nftValue * _ids.length) * fee) / 100);
        }

        uint256 lockFee = 0;
        if(unlockBlocks.length > 0){
            lockFee = setLockBlocks(_msgSender(), _ids, unlockBlocks);
            _mint(feeTo, lockFee);
        }

        _mint(
            _receipient,
            ((nftValue * _ids.length) * (uint256(100) - fee)) / 100 - lockFee
        );
    }

    function setLockBlocks(address operator,
        uint256[] memory ids,
        uint24[] memory unlockBlocks) private returns (uint256){
        uint256 lockFee = 0;
        require(ids.length == unlockBlocks.length, "UB ID length not equal");
        uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
        for(uint i = 0; i < ids.length; i++){
            LockInfo storage info = lockInfos.get(ids[i]);
            require(info.blockNum <= block.number, "721 ids still locked");
            lockFee += nftValue * feePerBlock * (unlockBlocks[i] - block.number) / 10000000000;
            info.blockNum = unlockBlocks[i];
            info.unlocker = operator;
        }
        return lockFee;
    }

    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes memory data
    ) external virtual override returns (bytes4) {
        require(nftAddress == _msgSender(), "forbidden");
        uint256 fee = IFactory(factory).fee();
        address feeTo = IFactory(factory).feeTo();

        (address referral, address recipient, uint24[] memory unlockBlocks) = decodeParams(data, operator);

        uint256 refFee = IFactory(factory).getReferralFee(referral);
        // If referral exist, give refFee to referral
        if (refFee > 0) {
            _mint(referral, (nftValue * refFee) / 100);
            _mint(feeTo, (nftValue * (fee - refFee)) / 100);
        } else {
            _mint(feeTo, (nftValue * fee) / 100);
        }

        uint256 lockFee = 0;
        if(unlockBlocks.length > 0){
            LockInfo storage info = lockInfos.get(tokenId);
            require(info.blockNum <= block.number, "721 still locked");
            uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
            lockFee = nftValue * feePerBlock * (unlockBlocks[0] - block.number) / 10000000000;
            _mint(feeTo, lockFee);
            info.blockNum = unlockBlocks[0];
            info.unlocker = operator;
        }

        _mint(recipient, ((nftValue * (uint256(100) - fee)) / 100) - lockFee);
        return this.onERC721Received.selector;
    }

    // function flashLoan(
    //     uint256[] calldata _ids,
    //     uint256[] calldata _amounts,
    //     address _operator,
    //     bytes calldata _params
    // ) external override flashloansEnabled {
    //     require(_ids.length < 80, "To many NFTs");

    //     for (uint8 index; index < _ids.length; index++) {
    //         IERC721(nftAddress).safeTransferFrom(
    //             address(this),
    //             _operator,
    //             _ids[index]
    //         );
    //     }
        
    //     require(
    //         IFlashLoanReceiver(_operator).executeOperation(
    //             _ids,
    //             _amounts,
    //             _msgSender(),
    //             _params
    //         ),
    //         "Execution Failed"
    //     );

    //     for (uint8 index; index < _ids.length; index++) {
    //         IERC721(nftAddress).transferFrom(
    //             _operator,
    //             address(this),
    //             _ids[index]
    //         );
    //     }
        
    // }
}
