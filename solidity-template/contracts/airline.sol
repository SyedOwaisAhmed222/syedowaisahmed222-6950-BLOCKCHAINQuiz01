// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.10 and less than 0.9.0
pragma solidity >=0.5.0 <0.9.0;

//Plz read comments for better understanding
//below i am copy pasting Ownable Contract 
contract Ownable {
    address private _owner;

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor()  {
        _owner = msg.sender;
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

}


contract AirlineManager is Ownable {


    //to select from 3 predefined ticket classes
    enum ticketClass {
        first_class,
         business,
         economy
    }
        uint first_class_price=0.01 ether;
        uint business_price=0.007 ether;
        uint economy_price=0.005 ether;

    //User struct with all his required attributes.   
    struct User {
            string name ;
            string destination;
            address passport_ID;
            ticketClass classChoice;
            bool isDeleted;
            bool flag; 
            /*this attribute is relating to task 5, since it is
             not possible to delete an element from mapping from solidity,
              i've just created a attrubute so that i made IsDeleted True to assume that 
             User is deleted from mapping.*/
        }

        mapping (address => User ) public usersMapping;//so this may be called WhiteList
        // or allowed list of addresses

    //so actually i made this modifire to make check that user can transfer
    // ether for only 1 time for 1 ticket
    modifier checkForEtherTransfer() {
        require(usersMapping[msg.sender].flag==true);
        _;
    }
    
    //this function is checking that user is in white list or not
    // (i am using it to check in transferEther function)
    function checkUser() public view returns(bool){
        if(bytes(usersMapping[msg.sender]).length>0){
            return true;
        }
        else{
            return false;
        }
    }
    

    //this function is trnsfering ethers to confirm his booking in his asked class of ticket
    function transferEther(address payable admin) public view checkForEtherTransfer() returns(bool) {
        require(checkUser==true);

        if (usersMapping[msg.sender].classChoice == ticketClass.economy) {
         admin.transfer(economy_price); //admin is address of owner (define in Factory contract in last)

        } 
        else if (usersMapping[msg.sender].classChoice==ticketClass.business) {
            admin.transfer(business_price);

        } 
        else if (usersMapping[msg.sender].classChoice==ticketClass.first_class) {
         admin.transfer(first_class_price);

        }
    
        usersMapping[msg.sender].flag=false;//making flag false so that not ether could be sent again for one user 

    }

    //this function is just creating new User.
    function storeUser(string  memory _name, string memory _destination , ticketClass _class) public {
        User storage newUser;
        newUser.name=_name;
        newUser.destination=_destination;
        newUser.passport_ID=msg.sender;
        newUser.classChoice = _class;
        newUser.flag=true;
        usersMapping[msg.sender]= newUser;
         
    }

    //This function is also creating New User but this time it's created by owner itself.
    //It's same like Airline staff complete foramalities for any old man, old woman who is alone traveling.
    function add_by_owmer(string  memory _name, string memory _destination , address _passport_ID , string memory _class) onlyOwner {
        User storage newUser;
        newUser.name=_name;
        newUser.destination=_destination;
        newUser.passport_ID = _passport_ID;
        newUser.classChoice = _class;
        usersMapping[_passport_ID]= newUser;
        bool flag=true;
    } 

    //removing a User from whitelist (mapping)
     function remove_by_owner(address _passport_ID) onlyOwner {
         usersMapping[_passport_ID].isDeleted=true;

     }
}


contract AirlineManagerFactory is Ownable{
    AirlineManager am_instance;
    address  admin;
    constructor(){
    admin = msg.sender;
    }

    //creating new Instance of AirlineManager contract.
    function createAirlineManager() onlyOwner {
        am_instance = new AirlineManagerFactory();

    }
}