// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../interfaces/INFT20Pair.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";


contract NFT20Factory is Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    // keep track of nft address to pair address
    mapping(address => address) public nftToToken;
    mapping(uint256 => address) public indexToNft;

    uint256 public counter;
    uint256 public fee;
    address public feeTo;
    //referral => feeRate
    mapping(address => uint256) private referrals;

    event pairCreated(
        address indexed originalNFT,
        address newPair,
        uint256 _type
    );

    using AddressUpgradeable for address;
    address public logic;

    // new store V5
    bool public flashLoansEnabled;

    constructor() {}

    function nft20Pair(
        string memory name,
        string memory _symbol,
        address _nftOrigin,
        uint256 _nftType
    ) public payable {
        require(nftToToken[_nftOrigin] == address(0));
        bytes memory initData = abi.encodeWithSignature(
            "init(string,string,address,uint256)",
            name,
            _symbol,
            _nftOrigin,
            _nftType
        );

        address instance = address(new BeaconProxy(logic, ""));

        instance.functionCallWithValue(initData, msg.value);

        nftToToken[_nftOrigin] = instance;
        indexToNft[counter] = _nftOrigin;
        counter = counter + 1;
        emit pairCreated(_nftOrigin, instance, _nftType);
    }

    function getPairByIndex(uint256 index)
        public
        view
        returns (
            address _nft20pair,
            address _originalNft,
            uint256 _type,
            string memory _name,
            string memory _symbol,
            uint256 _supply
        )
    {
        _originalNft = indexToNft[index];
        _nft20pair = nftToToken[_originalNft];
        (_type, _name, _symbol, _supply) = INFT20Pair(_nft20pair).getInfos();
    }

    // this is to set value in case we decided to change tokens given to a tokenizing project.
    function setValue(
        address _pair,
        uint256 _nftType,
        string calldata _name,
        string calldata _symbol,
        uint256 _value
    ) external onlyOwner {
        INFT20Pair(_pair).setParams(_nftType, _name, _symbol, _value);
    }

    function setFactorySettings(uint256 _fee, bool _allowFlashLoans, address _feeTo)
        external
        onlyOwner
    {
        fee = _fee;
        flashLoansEnabled = _allowFlashLoans;
        feeTo = _feeTo;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        public
        onlyOwner
    {
        IERC20(tokenAddress).transfer(
            owner(),
            tokenAmount
        );
    }

    function changeLogic(address _newLogic) external onlyOwner {
        logic = _newLogic;
    }

    function setReferralFee(address referral, uint256 _fee) external onlyOwner {
        require(_fee <= fee, "fee too high");
        referrals[referral] = _fee;
    }

    function getReferralFee(address referral) external view returns (uint256) {
        uint256 f = referrals[referral];
        require(f <= fee, "bad fee");
        return f;
    }

    // NEW functions v6
    receive() external payable {} //lol 2 hours
}