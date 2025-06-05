// License

// SPDX-License-Identifier: MIT

// Solidity compiler version

pragma solidity 0.8.24;

// Libraries

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Contract 

contract stakingApp is Ownable{

    // Variables

    bool vote = false;
    address public stakingToken;
    uint256 public startVoting;
    uint256 public periodToVote;
    uint256 public fixedStakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public fixedRewardPerPeriod;
    uint256 public communityStakingPeriod;
    uint256 public communityStakingAmount;
    uint256 public communityRewardPerPeriod;
    uint256 public timeElapsedVoting;
    uint256 public mostVotedStakingPeriod;
    uint256 public mostVotedStakingAmount;
    uint256 public votingTime;
    uint256[] public allowedStakingPeriods = [1,2,3,4,5,6,7,8,9,10,11,12];
    uint256[] public allowedStakingAmounts = [5,25,50,100];
    mapping (address => uint256) public userStakingPeriod;
    mapping (address => uint256) public userStakingAmount;
    mapping (address => uint256) public userRewardPerPeriod;
    mapping (address => uint256) public proposalStakingPeriod;
    mapping (address => uint256) public proposalStakingAmount;
    mapping (address => uint256)public userBalance;
    mapping (address => uint256)public startTimeFixedStrategy;
    mapping (address => uint256)public startTimeCommunityStrategy;
    mapping (uint256 => uint256) public voteCountStakingPeriod;
    mapping (uint256 => uint256) public voteCountStakingAmount;
    mapping (address => bool) public votedStakingPeriod;
    mapping (address => bool) public votedStakingAmount;

    // Events

    event e_voteToModifyStakingPeriod(address user, uint256 proposalStakingPeriod);
    event e_voteToModifyStakingAmount(address user, uint256 proposalStakingAmount);
    event e_participateInFixedStrategy(address user, uint256 fixedStakingAmount);
    event e_participateInCommunityStrategy(address user, uint256 communityStakingAmount);
    event e_withdrawTokens(address user_, uint256 withdrawAmount_);
    event e_ethSend(uint256 amount_);
    event e_voting(bool vote, uint256 periodToVote, uint256 startVoting);
    event e_votingEnded(uint256 mostVotedStakingPeriod, uint256 mostVotedStakingAmount, uint256 communityRewardPerPeriod);

    // Modifiers
    modifier timeToVotingStakingPeriod(){
        require(vote == true, "Isn't time to voting");
        require(votedStakingPeriod[msg.sender] == false, "You voted yet");
        require(block.timestamp - startVoting < periodToVote, "The campaign to vote ended");
        _;
    }

        modifier timeToVotingStakingAmount(){
        require(vote == true, "Isn't time to voting");
        require(votedStakingAmount[msg.sender] == false, "You voted yet");
        require(block.timestamp - startVoting < periodToVote, "The campaign to vote ended");
        _;
    }

    // Constructor
    constructor(address stakingToken_, address owner_, uint256 fixedStakingPeriod_, uint256 fixedStakingAmount_, uint256 fixedRewardPerPeriod_) Ownable(owner_) {
        stakingToken = stakingToken_;
        fixedStakingPeriod = fixedStakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        fixedRewardPerPeriod = fixedRewardPerPeriod_;
    }

    // External functions
     function modifyCommunityStaking(bool vote_, uint256 periodToVote_) external onlyOwner {
        vote = vote_;
        periodToVote = periodToVote_;
        startVoting = block.timestamp;
        emit e_voting(vote, periodToVote, startVoting);
    }

    function voteToModifyStakingPeriod(uint256 proposalStakingPeriod_) external timeToVotingStakingPeriod {
        bool status = false;
        for (uint256 i=0; i < allowedStakingPeriods.length; i++){
            if(allowedStakingPeriods[i] == proposalStakingPeriod_){status = true;}
        }
        require(status, "Propose a correct value between 1 and 12 (months)");
        proposalStakingPeriod[msg.sender] = proposalStakingPeriod_;
        uint256 proposalPeriod =  proposalStakingPeriod[msg.sender]; 
        uint256 voteCount =  voteCountStakingPeriod[proposalPeriod];
        voteCount++;
        voteCountStakingPeriod[proposalPeriod] = voteCount;
        votedStakingPeriod[msg.sender] = true;
        emit e_voteToModifyStakingPeriod(msg.sender, proposalStakingPeriod[msg.sender]);
    }

    function voteToModifyStakingAmount(uint256 proposalStakingAmount_) external timeToVotingStakingAmount {
        bool status = false;
        for (uint256 i=0; i < allowedStakingAmounts.length; i++){
            if(allowedStakingAmounts[i] == proposalStakingAmount_){status = true;}
        }
        require(status, "Propose a correct value between 5, 25, 50 or 100 (ether)");
        proposalStakingAmount[msg.sender] = proposalStakingAmount_;
        uint256 proposalAmount = proposalStakingAmount[msg.sender];
        uint256 voteCount = voteCountStakingAmount[proposalAmount];
        voteCount++;
        voteCountStakingAmount[proposalAmount] = voteCount;
        votedStakingAmount[msg.sender] = true;
        emit e_voteToModifyStakingAmount(msg.sender, proposalStakingAmount[msg.sender]);
    }

    function finalizedVoting(bool vote_) external onlyOwner{
        votingTime = block.timestamp - startVoting;
        require(votingTime > periodToVote, "Voting time is not over");
        vote = vote_;
        uint256 highestVotesPeriods = 0;
        for (uint256 i = 0; i < allowedStakingPeriods.length; i++){
            uint256 value = allowedStakingPeriods[i];
            uint256 count = voteCountStakingPeriod[value]; 
            if (count > highestVotesPeriods){
                highestVotesPeriods = count;
                mostVotedStakingPeriod = value;
            }
        }
        uint256 highestVotesAmount = 0;
        for (uint256 i = 0; i < allowedStakingAmounts.length; i++){
            uint256 value = allowedStakingAmounts[i];
            uint256 count = voteCountStakingAmount[value]; 
            if (count > highestVotesAmount){
                highestVotesAmount = count;
                mostVotedStakingAmount = value;
            }
        }
        communityStakingPeriod = mostVotedStakingPeriod * 2592000;
        communityStakingAmount = mostVotedStakingAmount * 10e18;
        communityRewardPerPeriod = ((mostVotedStakingAmount / 10) * mostVotedStakingPeriod) * 10e18;
        emit e_votingEnded(mostVotedStakingPeriod, mostVotedStakingAmount, communityRewardPerPeriod);
        
    }

    function viewStrategiesValues()external view returns(uint256, uint256, uint256, uint256, uint256, uint256 ){
        return (fixedStakingPeriod, fixedStakingAmount, fixedRewardPerPeriod, communityStakingPeriod, communityStakingAmount, communityRewardPerPeriod);
    }

    function participateInFixedStrategy(bool participate) external{
        require (participate, "Put True if you want participate in the fixed strategy");
        require(userBalance[msg.sender] == 0, "User is staking");
        IERC20(stakingToken).transferFrom(msg.sender, address (this), fixedStakingAmount);
        userBalance[msg.sender] += fixedStakingAmount;
        startTimeFixedStrategy[msg.sender] = block.timestamp;
        userStakingAmount[msg.sender] = fixedStakingAmount;
        userStakingPeriod[msg.sender] = fixedStakingPeriod;
        userRewardPerPeriod [msg.sender] = fixedRewardPerPeriod;
         emit e_participateInFixedStrategy(msg.sender, fixedStakingAmount);
    }

    function participateInCommunityStrategy(bool participate) external{
        require (participate, "Put True if you want participate in the community strategy");
        require(userBalance[msg.sender] == 0, "User is staking");
        IERC20(stakingToken).transferFrom(msg.sender, address (this), communityStakingAmount);
        userBalance[msg.sender] += communityStakingAmount;
        startTimeCommunityStrategy[msg.sender] = block.timestamp;
        userStakingAmount[msg.sender] = communityStakingAmount;
        userStakingPeriod[msg.sender] = communityStakingPeriod;
        userRewardPerPeriod[msg.sender] = communityRewardPerPeriod;
        emit e_participateInCommunityStrategy(msg.sender, communityStakingAmount);
    }   

    function withdrawTokens()external{
        uint256 userBalance_ = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, userBalance_);
        emit e_withdrawTokens(msg.sender, userBalance_);
    }

    function claimRewardsFixedStrategy()external{
      require(userBalance[msg.sender] == fixedStakingAmount, "Not staking");
      uint256 elapsedPeriodFixedStrategy_ = block.timestamp - startTimeFixedStrategy[msg.sender]; 
      require(elapsedPeriodFixedStrategy_ >= userStakingPeriod[msg.sender], "Need to wait");
      startTimeFixedStrategy[msg.sender] = block.timestamp;
      (bool success,) = msg.sender.call{value: userRewardPerPeriod[msg.sender]}("");
      require(success,"Transfer failed");
    }

    function claimRewardsCommunityStrategy()external{
      require(userBalance[msg.sender] == communityStakingAmount, "Not staking");
      uint256 elapsedPeriodCommunityStrategy_ = block.timestamp - startTimeCommunityStrategy[msg.sender]; 
      require(elapsedPeriodCommunityStrategy_ >= userStakingPeriod[msg.sender], "Need to wait");
      startTimeCommunityStrategy[msg.sender] = block.timestamp;
      (bool success,) = msg.sender.call{value: userRewardPerPeriod[msg.sender]}("");
      require(success,"Transfer failed");
    }

    receive()external payable onlyOwner{
        emit e_ethSend(msg.value);
    }

}