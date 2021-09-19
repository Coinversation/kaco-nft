// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC721
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./libs/NFT100Common.sol";

contract NFT100Pair721 is
    IERC721ReceiverUpgradeable,
    NFT100Common
{

    //the block number when this id could be unlocked.
    mapping(uint256 => uint24) public unlockBlock;
    //the address who can unlock this locked id.
    mapping(uint256 => address) public unlocker;

    // create new token
    constructor() {}

    function init(
        string memory _name,
        string memory _symbol,
        address _nftAddress
    ) public payable {
        __NFT100Common_init_(_name, _symbol, _nftAddress, 721);
    }
    
    // withdraw nft and burn tokens
    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external override{
        _burn(msg.sender, nftValue * _tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _withdraw721(address(this), recipient, _tokenIds[i]);
        }
        emit Withdraw(_tokenIds, amounts);
    }

    function _withdraw721(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        IERC721(nftAddress).safeTransferFrom(_from, _to, _tokenId);
    }


    //param _referral: 3rd party fee receival address
    function multi721Deposit(
        uint256[] memory _ids,
        bytes memory data
    ) public {
        uint256 fee = IFactory(factory).fee();
        address feeTo = IFactory(factory).feeTo();

        (address _referral, address _receipient, uint24[] memory unlockBlocks) = decodeParams(data, msg.sender);

        for (uint256 i = 0; i < _ids.length; i++) {
            IERC721(nftAddress).transferFrom(
                msg.sender,
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
            lockFee = setLockBlocks(msg.sender, _ids, unlockBlocks);
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
        require(ids.length == unlockBlocks.length, "unlockBlocks.length != ids.length");
        uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
        for(uint i = 0; i < ids.length; i++){
            require(unlockBlock[ids[i]] <= block.number, "721 ids still locked");
            lockFee += nftValue * feePerBlock * (unlockBlocks[i] - block.number) / 10000000000;
            unlocker[ids[i]] = operator;
            unlockBlock[ids[i]] = unlockBlocks[i];
        }
        return lockFee;
    }

    function swap721(
        uint256 _in,
        uint256 _out,
        address _receipient
    ) external {
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _in);
        IERC721(nftAddress).safeTransferFrom(address(this), _receipient, _out);
    }

    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes memory data
    ) public virtual override returns (bytes4) {
        require(nftAddress == msg.sender, "forbidden");
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
            require(unlockBlock[tokenId] <= block.number, "721 still locked");
            uint256 feePerBlock = IFactory(factory).lockFeePerBlock();
            lockFee = nftValue * feePerBlock * (unlockBlocks[0] - block.number) / 10000000000;
            _mint(feeTo, lockFee);
            unlocker[tokenId] = operator;
            unlockBlock[tokenId] = unlockBlocks[0];
        }

        _mint(recipient, ((nftValue * (uint256(100) - fee)) / 100) - lockFee);
        return this.onERC721Received.selector;
    }

    function flashLoan(
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        address _operator,
        bytes calldata _params
    ) external override flashloansEnabled {
        require(_ids.length < 80, "To many NFTs");

        for (uint8 index; index < _ids.length; index++) {
            IERC721(nftAddress).safeTransferFrom(
                address(this),
                _operator,
                _ids[index]
            );
        }
        
        require(
            IFlashLoanReceiver(_operator).executeOperation(
                _ids,
                _amounts,
                msg.sender,
                _params
            ),
            "Execution Failed"
        );

        for (uint8 index; index < _ids.length; index++) {
            IERC721(nftAddress).transferFrom(
                _operator,
                address(this),
                _ids[index]
            );
        }
        
    }
}
