pragma solidity >=0.5.0 <0.6.0;
import "./Ownable.sol";

contract ZombieFactory is Ownable {
    //event emitted when new zombie is created
    event NewZombie(uint256 zombieId, string name, uint256 dna);

    //public variables to store the length of zombie dna and dna modulus
    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;
    uint256 cooldownTime = 1 days;

    //zombie interface
    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
    }

    //array of zombie structs
    Zombie[] public zombies;

    //mapping of zombie id to user address to track zombie ownership
    mapping(uint256 => address) public zombieToOwner;
    //mapping of zombie ownership count
    mapping(address => uint256) ownerZombieCount;

    //function to create new zombie
    function _createZombie(string memory _name, uint256 _dna) internal {
        //push new zombie to zombies arrays and retrieve its ID
        uint256 id = zombies.push(
            Zombie(_name, _dna, 1, uint32(now + cooldownTime))
        ) - 1;
        //add id of the zombie to the owner's address
        zombieToOwner[id] = msg.sender;
        //increment zombie count for the owner
        ownerZombieCount[msg.sender]++;

        //emit new zombie event
        emit NewZombie(id, _name, _dna);
    }

    //funtion to generate random numbers using the keccak256 function
    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        //return 16 digits of random number
        return rand % dnaModulus;
    }

    // public function that is called to create zombie
    function createRandomZombie(string memory _name) public {
        //check zombie does not exist for sender
        require(ownerZombieCount[msg.sender] == 0);
        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
