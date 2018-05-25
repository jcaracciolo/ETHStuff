    pragma solidity ^0.4.18;

    contract RankingProblem {
        
        function generateNewProblem(uint participants, uint seed) public;
        function getEntranceFee() public view returns (uint fee);
        function checkSolution(string posibleSolution) public view returns (bool isSolution);
        function getProblemData() public view returns (string problemData);
    }

    contract Ownable {
      address public owner;

      //WTF WHY DO I DO THIS PUBLIC?
      function Ownable() public {
        owner = msg.sender;
      }

      modifier onlyOwner() {
        require(msg.sender == owner);
        _;
      }

      function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner != address(0)) {
          owner = newOwner;
        }
      }

    }

    contract ETHBuenosAiresRanking is Ownable {
        
        RankingProblem problem = RankingProblem(address(0));

        bool isRunning;    
        address[] participants;
        uint participantsSize;
        
        modifier isParticipant() {
            uint i = 0;
            bool found = false;
            while(i<participantsSize && !found) {
                found = participants[i] == msg.sender;
                i++;
            }
            require(found);
            _;
        }

        modifier isNotParticipant() {
            uint i = 0;
            bool found = false;
            while(i<participantsSize && !found) {
                found = participants[i] == msg.sender;
                i++;
            }
            require(!found);
            _;
        }
        
        modifier notYetStarted() {
            require(!isRunning);
            _;
        }
        
        modifier hasStarted() {
            require(isRunning);
            _;
        }

        function getParticipants() view external returns (address[]) {
            return participants;
        }

        function amIParticipant() view external returns (bool) {
            uint i = 0;
            bool found = false;
            while(i<participantsSize && !found) {
                found = (participants[i] == msg.sender);
                i++;
            }
            return found;
        }

        function competitionHasStarted() view external returns (bool) {
            return isRunning;
        }

        function setUpProblemGenerator(address problemGenerator) external onlyOwner {
            require(problem == address(0));
            RankingProblem rankingProblem = RankingProblem(problemGenerator);
            problem = rankingProblem;
        }

        function addParticipant() private {
            if(participantsSize == participants.length) {
                participants.length += 1;
            }
            participants[participantsSize++] = msg.sender;
        }

        function resetParticipants() private {
            participantsSize = 0;
        }

        function signUp() external payable isNotParticipant notYetStarted {
            require(msg.value == problem.getEntranceFee());
            addParticipant();
        }

        function submit(string posibleSolution) external isParticipant hasStarted returns (bool) {
            if(problem.checkSolution(posibleSolution)) {
                endCompetition();
                msg.sender.transfer(this.balance);
                return true;
            }

            return false;
        }

        function releaseNewCompetition() external onlyOwner notYetStarted {
            require(participantsSize>1);
            problem.generateNewProblem(participantsSize, generateRandom());
            isRunning = true;
        }

        function endCompetition() private hasStarted {
            problem = RankingProblem(address(0));
            isRunning = false;
            resetParticipants();
        }
        
        function generateRandom() private view returns (uint rand) {
            return uint(keccak256(now));
        }
    }

    contract ETHBuenosAiresTrivialProblem is RankingProblem {

        uint problem;

        function getProblemNumber() external view returns (uint problemNumber) {
            return problem;
        }

        function compareStrings (string a, string b) private pure returns (bool comparison){
           return keccak256(a) == keccak256(b);
        }

        function checkSolution(string posibleSolution) public view returns (bool) {
            return compareStrings(posibleSolution, "A");
        }

        function getProblemData() public view returns (string data) {
            return "A";
        }


        function generateNewProblem(uint participants, uint seed) public {
            problem++;
            participants = participants;
            seed = seed;
        }

        function getEntranceFee() public view returns (uint fee) {
            return 0;
        }

    }