# Beta Staking Governance
## Overview 🪙
A staking app with two strategies to invert, fixed strategy and community strategy.
## Features 📃
* Create your own token ERC-20.
* Participate in a fixed strategy to invest only the agreed amount.
* Participate in a community strategy to invest in the amount and period agreed upon by the community.
* Deposit your tokens to staking and withdraws it when the period ends.
* Claim rewards for staking.
## Technical details ⚙️
* Framework CLI -> Foundry.
* Forge version -> 1.1.0-stable.
* Solidity compiler version -> 0.8.24.
## Deploying the contract 🛠️
1. Clone the GitHub repository.
2. Open Visual Studio Code (you should already have Foundry installed).
3. Select "File" > "Open Folder", select the cloned repository folder.
4. In the project navigation bar, open the "stakingApp.sol" file located in the "src" folder.
5. In the toolbar above, select "Terminal" > "New Terminal".
6. Select the "Git bash" terminal (previously installed).
7. Run the `forge build` command to compile the script.
8. In the project navigation bar, open the "stakingAppTest.t.sol" file located in the "test" folder.
9. Run the command `forge test --match-test` followed by the name of a test function to test it and verify the smart contract functions are working correctly. For example, run `forge test --match-test testStakingTokenCorrectlyDeployed -vvvv` to test the `testStakingTokenCorrectlyDeployed` function.
10. Run `forge coverage` to generate a code coverage report, which allows you to verify which parts of the "stakingApp.sol" and "stakingToken.sol" scripts code (in the "src" folder) are executed by the tests. This helps identify areas outside the coverage that could be exposed to errors/vulnerabilities.
## Functions (Staking Token) 💻
* `mint()` -> Mints tokens for can stake it.
## Functions (Staking App) 📱
* `modifyCommunityStaking()` -> The owner initiates a vote to modify the period and amount in the community strategy.
* `voteToModifyStakingPeriod()` -> Users can vote to change the staking period value. Only values ​​of 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, and 12 (months) are valid.
* `voteToModifyStakingAmount()` -> Users can vote to change the staking amount. Only 5, 25, 50, and 100 (ether) are valid.
* `finalizedVoting()` -> The owner ends the vote to modify the community strategy values.
* `viewStrategiesValues()` -> Allows you to view the values ​​of fixedStakingPeriod, fixedStakingAmount, fixedRewardPerPeriod, communityStakingPeriod, communityStakingAmount, communityRewardPerPeriod.
* `participateInFixedStrategy()` -> The user enters his ether to perform staking with the values ​​set by the owner.
* `participateInCommunityStrategy()` -> The user enters his ether to perform staking with the values ​​set by the community
* `withdrawTokens()` -> Withdraw all yours tokens in staking.
* `claimRewardsFixedStrategy()` -> Claim your rewards in the fixed staking strategy.
* `claimRewardsCommunityStrategy()` -> Claim your rewards in the community staking strategy.
* `receive()` -> The admin enter to the smart contract the tokens that will be using to rewards the users for staking.
## Testing functions (Unit testing) ⌨️
* `testStakingTokenMintsCorrectly()` ->  Verify that mints the correct quantity of token.
* `testStakingTokenCorrectlyDeployed()` -> Verify that the "Staking Token" contract deployed correctly.
* `testStakingAppCorrectlyDeployed()` -> Verify that the "Staking App" contract deployed correctly.
* `testShouldRevertIfNotOwner()` -> The contract reverts if not owner who modify the staking period.
* `testShouldCanVoteToModifyStakingPeriod()` ->
* `testShouldRevertIfStakingPeriodProposalIsIncorrect()` ->
* `testShouldCanVoteToModifyStakingAmount()` ->
* `testShouldRevertIfStakingAmountProposalIsIncorrect()` ->
* `testVotingToModifyStakingPeriodFinalizeCorrectly()` ->
* `testVotingToModifyStakingAmountFinalizeCorrectly()` -> 
* `testContractReceivesEthCorrectly()` -> Verify that the owner can deposit ETH correctly to this staking smart contract.
* `testParticipatedFixedStrategyCorrectly()` ->
* `testParticipatedCommunityStrategyCorrectly()` ->

CODE IS LAW!

