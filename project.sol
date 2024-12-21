// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HackathonReward {

    struct Hackathon {
        string name;
        uint startDate;
        uint endDate;
        uint rewardPool;
        bool isActive;
    }

    struct Submission {
        address participant;
        string title;
        string description;
        uint score;
        bool evaluated;
    }

    mapping(uint => Hackathon) public hackathons;
    mapping(uint => Submission[]) public submissions;
    mapping(address => uint) public rewards;
    
    uint public hackathonCount;

    modifier isActiveHackathon(uint hackathonId) {
        require(hackathons[hackathonId].isActive, "Hackathon is not active.");
        _;
    }

    // Create a new Hackathon
    function createHackathon(string memory _name, uint _startDate, uint _endDate, uint _rewardPool) public {
        hackathonCount++;
        hackathons[hackathonCount] = Hackathon({
            name: _name,
            startDate: _startDate,
            endDate: _endDate,
            rewardPool: _rewardPool,
            isActive: true
        });
    }

    // Submit a project for a specific Hackathon
    function submitProject(uint hackathonId, string memory _title, string memory _description) public isActiveHackathon(hackathonId) {
        submissions[hackathonId].push(Submission({
            participant: msg.sender,
            title: _title,
            description: _description,
            score: 0,
            evaluated: false
        }));
    }

    // Evaluate a project submission
    function evaluateProject(uint hackathonId, uint submissionIndex, uint _score) public isActiveHackathon(hackathonId) {
        Submission storage submission = submissions[hackathonId][submissionIndex];
        require(!submission.evaluated, "Project already evaluated.");
        submission.score = _score;
        submission.evaluated = true;
    }

    // Calculate and distribute rewards based on scores
    function distributeRewards(uint hackathonId) public isActiveHackathon(hackathonId) {
        uint totalScore = 0;
        uint participantCount = submissions[hackathonId].length;

        for (uint i = 0; i < participantCount; i++) {
            Submission storage submission = submissions[hackathonId][i];
            require(submission.evaluated, "Not all projects have been evaluated.");
            totalScore += submission.score;
        }

        for (uint i = 0; i < participantCount; i++) {
            Submission storage submission = submissions[hackathonId][i];
            uint reward = (submission.score * hackathons[hackathonId].rewardPool) / totalScore;
            rewards[submission.participant] += reward;
        }

        hackathons[hackathonId].isActive = false;  // Deactivate hackathon once rewards are distributed
    }

    // Withdraw rewards
    function withdrawRewards() public {
        uint reward = rewards[msg.sender];
        require(reward > 0, "No rewards available.");
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
    }

    // Funding a hackathon's reward pool
    function fundHackathon(uint hackathonId) public payable {
        hackathons[hackathonId].rewardPool += msg.value;
    }
}
