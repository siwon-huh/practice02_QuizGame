// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    mapping(address => uint256) public new_bet;
    uint public vault_balance;
    mapping(uint => Quiz_item) public quiz_list;
    uint private quiz_num;
    mapping(address => uint256) public better_balance;
    // storage variable: ?
    address public owner;

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);
        quiz_list[q.id] = q;
        quiz_num += 1;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        require(msg.sender == owner);
        return quiz_list[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory quiz =  quiz_list[quizId];
        quiz.answer = "";
        return quiz;
    }

    function getQuizNum() public view returns (uint){
        return quiz_num;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory quiz = quiz_list[quizId];
        uint256 bet_value = msg.value;
        uint bet_quiz_id = quizId - 1;
        address better = msg.sender;
        require(quiz.min_bet <= bet_value, "set more value");
        require(bet_value <= quiz.max_bet, "set less value");
        new_bet[better] = bet_value;
        bets.push();
        bets[bet_quiz_id][better] += bet_value;
        
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory quiz = quiz_list[quizId];
        uint bet_quiz_id = quizId - 1;

        if(keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(quiz.answer))){
            better_balance[msg.sender] += bets[bet_quiz_id][msg.sender] * 2;
            return true;
        } else {
            vault_balance += bets[bet_quiz_id][msg.sender];
            bets[bet_quiz_id][msg.sender] = 0;
            return false;
        }
    }

    function claim() public {
        uint256 amount = better_balance[msg.sender];
        better_balance[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    receive() external payable{
    }
}
