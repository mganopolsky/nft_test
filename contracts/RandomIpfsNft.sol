// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable i_vrfCoordinator;
    bytes32 public immutable i_gasLane;
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callBackGasLimit;

    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;
    uint256 public constant MAX_CHANCE_VALUE = 100;

    mapping(uint256 => address) public s_requestIdToSender;
    string[3] public s_dogTokenURIs;

    uint256 s_tokenCounter;

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callBackGasLimit,
        string[3] memory dogTokenUris
    )
        ERC721("Marina's Ransom IPFS", "RIN")
        VRFConsumerBaseV2(vrfCoordinatorV2)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;
        s_tokenCounter = 0;
        s_dogTokenURIs = dogTokenUris;
        // 0 - St. Bernard
        // 1 - Pug
        // 2 - Shiba
    }

    //mint a random puppy
    function requestDoggie() public returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address dogOwner = s_requestIdToSender[requestId];
        //assign this NFT a tokenID
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        // did we get a random dog?
        // is the st. bernard super random?
        // 35394587349587345 % 100
        // get the breed?
        // 0-99
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        uint256 breed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);
        // set the tokenURI
        _setTokenURI(newTokenId, s_dogTokenURIs[breed]);
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        // 0 - 9 = st. bernard
        // 10-29 = pug
        // 30-99 shiba inu
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getBreedFromModdedRng(uint256 moddedRng)
        private
        pure
        returns (uint256)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory changeArray = getChanceArray();
        for (uint256 i = 0; i < changeArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + changeArray[i]
            ) {
                // 0 - St. Bernard
                // 1 - Pug
                // 2 - Shiba
                return i;
            }
            cumulativeSum = cumulativeSum + changeArray[i];
        }
    }
}
