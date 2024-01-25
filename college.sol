// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract HiveToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Hive", "HIVE") {
        _mint(msg.sender, initialSupply);
    }
}

contract College{
    address public adminAddress;
    constructor(){
        adminAddress = msg.sender;
    }
    enum Stream{
        CS,
        Mechanical,
        EC
    }

    struct StudentInfo{
        string name;
        uint8 age;
        uint8 prevMarks;
        Stream course;
        bool isApproved;
        uint fees;
        bool paidFees;
    }

    string[] public studentList;

    mapping (string => StudentInfo) public students;
    mapping (string => bool) public isStudentIdExists;

    event StudentAdded(string _studentId, string _name, uint8 _age, uint8 _prevMarks, Stream _course);
    event StudentApproved(string _studentId);
    event FeesPaid(string _studentId, uint _amount);
    
    modifier onlyAdmin(){
        require(msg.sender == adminAddress, "Only Admin can access this Function");
        _;
    }


    // HERE WE CONSIDERED STUDENT ID as EXCLUSIVE, assuming student can't have multiple IDs (ex. aadhar card)
    function addStudent(string memory _studentId, string memory _name, uint8 _age, uint8 _prevMarks, Stream _course) public{
        require(!isStudentIdExists[_studentId], "StudentId is already Registered!");
        students[_studentId] = StudentInfo(_name, _age, _prevMarks, _course, false ,0, false);
        isStudentIdExists[_studentId] = true;
        emit StudentAdded(_studentId, _name, _age, _prevMarks, _course);
    }

    function approveStudent(string memory _studentId, uint _fees) onlyAdmin public{
        require(isStudentIdExists[_studentId], "Student doesn't exist!");
        require(!students[_studentId].isApproved, "Student is Already Approved!");
        if(students[_studentId].course == Stream.CS && students[_studentId].prevMarks >= 65 ||
           students[_studentId].course == Stream.Mechanical && students[_studentId].prevMarks >= 70 ||
           students[_studentId].course == Stream.EC && students[_studentId].prevMarks >= 75)
        {
            studentList.push(_studentId);
            students[_studentId].isApproved = true;
            students[_studentId].fees = _fees;
        }
        else{
            delete students[_studentId];
            revert("Student is not eligible for the Admission (;");
        }
        emit StudentApproved(_studentId);
    }

    function payFees(string memory _studentId) payable public {

        require(students[_studentId].isApproved, "Pending Admin Approval!");
        require(!students[_studentId].paidFees, "Fees already paid!");
        require(msg.value == students[_studentId].fees, "Incorrect amount sent!");

        payable(adminAddress).transfer(msg.value);

        students[_studentId].paidFees = true;

        emit FeesPaid(_studentId, msg.value);
    }

    function getUnpaidFeesStudentList() view public onlyAdmin returns(string memory) {
        
        string memory result = "";

        

        for(uint i=0; i < studentList.length; i++){
            StudentInfo memory info = students[studentList[i]];
            if(!students[studentList[i]].paidFees){
                result = string(
                    abi.encodePacked(result, "\n",
                        "Student ID: ", studentList[i], "\n",
                        "Student Name:", info.name, "\n",
                        "Stream:", streamToString(info.course), "\n",
                        "Fees Remaining:", uintToString(info.fees), "\n"));
            }

        }
        return result;

    }

    function streamToString(Stream _stream) internal pure returns (string memory) {
        if (_stream == Stream.CS) {
            return "CS";
        } else if (_stream == Stream.Mechanical) {
            return "Mechanical";
        } else if (_stream == Stream.EC) {
            return "EC";
        } else {
            return "Unknown";
        }
    }

    function uintToString(uint value) internal pure returns (string memory) {
        
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits = digits - 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

}