// License
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libreries
import "forge-std/Test.sol";
import "../src/stakingToken.sol";
import "../src/stakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract stakingAppTest is Test{

    stakingToken stakingTokenTesting;
    stakingApp stakingAppTesting;

    // Staking Token Parameters

    string name = "Red Linuxera";
    string symbol = "RLX";

    // Staking App Parameters

    address owner = vm.addr(1);
    address randomUser1 = vm.addr(2);
    address randomUser2 = vm.addr(3);
    address randomUser3 = vm.addr(4);
    address randomUser4 = vm.addr(5);
    address randomUser5 = vm.addr(6);
    uint256 fixedStakingPeriod = 5000000;
    uint256 fixedStakingAmount = 10 ether;
    uint256 fixedRewardPeriod = 2 ether;
    mapping (address => bool) public votedStakingPeriod;
    mapping (address => bool) public votedStakingAmount;
    
    // Testing Funtions

    function setUp() external{
        stakingTokenTesting = new stakingToken(name, symbol);
        stakingAppTesting = new stakingApp(address(stakingTokenTesting), owner, fixedRewardPeriod, fixedStakingAmount, fixedRewardPeriod);
    }

    function testStakingTokenCorrectlyDeployed() external view{
        assert(address(stakingTokenTesting) != address(0));
    }

    function testStakingAppCorrectlyDeployed() external view{
        assert(address(stakingAppTesting) != address(0));
    }

    function testShouldRevertIfNotOwner() external{
        bool vote = true;
        uint256 periodToVote = 100000000000;
        vm.expectRevert();
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
    }

    function testShouldCanVoteToModifyStakingPeriod() external{
        
        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();
        
        vm.startPrank(randomUser1);
        uint256 proposalStakingPeriod = 7;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod);
        vm.stopPrank();

    }

        function testShouldRevertIfStakingPeriodProposalIsIncorrect() external{
        
        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();
        
        vm.startPrank(randomUser1);
        uint256 proposalStakingPeriod = 13;
        votedStakingPeriod[randomUser1] = false;
        vm.expectRevert();
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod);
        vm.stopPrank();

    }

        function testShouldCanVoteToModifyStakingAmount() external{
        
        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();
        
        vm.startPrank(randomUser1);
        uint256 proposalStakingAmount = 25;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount);
        vm.stopPrank();

    }

    function testShouldRevertIfStakingAmountProposalIsIncorrect() external{
        
        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();
        
        vm.startPrank(randomUser1);
        uint256 proposalStakingAmount = 500;
        votedStakingAmount[randomUser1] = false;
        vm.expectRevert();
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount);
        vm.stopPrank();

    }

    function testVotingToModifyStakingPeriodFinalizeCorrectly() external{

        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();

        vm.startPrank(randomUser1);
        uint256 proposalStakingPeriod1 = 7;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        uint256 proposalStakingPeriod2 = 1;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod2);
        vm.stopPrank();

        vm.startPrank(randomUser3);
        uint256 proposalStakingPeriod3 = 7;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod3);
        vm.stopPrank();

        vm.startPrank(randomUser4);
        uint256 proposalStakingPeriod4 = 12;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod4);
        vm.stopPrank();

        vm.startPrank(randomUser5);
        uint256 proposalStakingPeriod5 = 7;
        votedStakingPeriod[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingPeriod(proposalStakingPeriod5);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.warp(block.timestamp + 999999999999999999);
        stakingAppTesting.finalizedVoting(vote);
        uint256 communityStakingPeriod = stakingAppTesting.mostVotedStakingPeriod();
        assert( communityStakingPeriod == 7);
        vm.stopPrank();

    }

     function testVotingToModifyStakingAmountFinalizeCorrectly() external{

        vm.startPrank(owner);
        bool vote = true;
        uint256 periodToVote = 100000000;
        stakingAppTesting.modifyCommunityStaking(vote, periodToVote);
        uint256 startVoting = block.timestamp;
        vm.stopPrank();

        vm.startPrank(randomUser1);
        uint256 proposalStakingAmount1 = 5;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        uint256 proposalStakingAmount2 = 25;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount2);
        vm.stopPrank();

        vm.startPrank(randomUser3);
        uint256 proposalStakingAmount3 = 50;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount3);
        vm.stopPrank();

        vm.startPrank(randomUser4);
        uint256 proposalStakingAmount4 = 100;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount4);
        vm.stopPrank();

        vm.startPrank(randomUser5);
        uint256 proposalStakingAmount5 = 100;
        votedStakingAmount[randomUser1] = false;
        stakingAppTesting.voteToModifyStakingAmount(proposalStakingAmount5);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.warp(block.timestamp + 999999999999999999);
        stakingAppTesting.finalizedVoting(vote);
        uint256 communityStakingAmount = stakingAppTesting.mostVotedStakingAmount();
        assert( communityStakingAmount == 100);
        vm.stopPrank();

    }

    function testContractReceivesEthCorrectly() external{
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
        uint256 etherValue = 1 ether;
        uint256 balanceBefore_ = address(stakingAppTesting).balance;
        (bool success,) = address(stakingAppTesting).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingAppTesting).balance;
        require(success, "Transfer failed");
        assert(balanceAfter - balanceBefore_ == etherValue);
        vm.stopPrank();
    }    

    function testParticipatedFixedStrategyCorrectly() external{
        vm.startPrank(randomUser1);
        bool participate = true;
        uint256 tokenAmount = stakingAppTesting.fixedStakingAmount();
        stakingTokenTesting.mint(tokenAmount);
        uint256 userBalanceBefore = stakingAppTesting.userBalance(randomUser1);
        uint256 elapsePeriodBefore = stakingAppTesting.startTimeFixedStrategy(randomUser1);
        IERC20(stakingTokenTesting).approve(address(stakingAppTesting), tokenAmount);
        stakingAppTesting.participateInFixedStrategy(participate);
        uint256 userBalanceAfter = stakingAppTesting.userBalance(randomUser1);
        uint256 elapsePeriodAfter = stakingAppTesting.startTimeFixedStrategy(randomUser1);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();
    }    

    function testParticipatedCommunityStrategyCorrectly() external{
        vm.startPrank(randomUser1);
        bool participate = true;
        uint256 tokenAmount = stakingAppTesting.communityStakingAmount();
        stakingTokenTesting.mint(tokenAmount);
        uint256 userBalanceBefore = stakingAppTesting.userBalance(randomUser1);
        uint256 elapsePeriodBefore = stakingAppTesting.startTimeCommunityStrategy(randomUser1);
        IERC20(stakingTokenTesting).approve(address(stakingAppTesting), tokenAmount);
        stakingAppTesting.participateInCommunityStrategy(participate);
        uint256 userBalanceAfter = stakingAppTesting.userBalance(randomUser1);
        uint256 elapsePeriodAfter = stakingAppTesting.startTimeCommunityStrategy(randomUser1);
        assert(userBalanceAfter - userBalanceBefore == tokenAmount);  
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();
    }   

}