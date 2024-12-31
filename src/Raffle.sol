// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle contract
 * @author David Onwuka
 * @notice This contract is for creating a raffle
 * @dev This implements the Chainlink VRF Version 2
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /** Errors */
    error Raffle__SendNMoreToEnterRaffle();

    /** State Variables */
    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    address payable[] private S_players;

    /** Events */
    event RaffleEntered(address indexed player);

    /** Constructor */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrf Coordinator, 
    ) VRFConsumerBaseV2Plus( vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendNMoreToEnterRaffle();
        }
        S_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        // check to see if enough time has passed
        if (block.timestamp - s_lastTimeStamp < i_interval) revert();

        // Get our randon number from Chainlink VRF

          VRFV2PlusClient.RandomWordsRequest request = VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
       uint256 requestId = s_vrfCoordinator.requestRandomWords(
          request
        );
    }

    /** Getter Function */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
