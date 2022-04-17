pragma solidity >=0.5.0 <0.6.0;
import "./ZombieFactory.sol";

// Create KittyInterface here since zombies feed on kitties
contract KittyInterface {
    function getKitty(uint256 _id)
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

contract ZombieFeeding is ZombieFactory {
    //crypto kitty contract address
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // Initialize kittyContract here using `ckAddress` from above
    KittyInterface kittyContract = KittyInterface(ckAddress);

    function feedAndMultiply(
        uint256 _zombieId,
        uint256 _targetDna,
        string memory _species
    ) public {
        //check if the sender is the owner of the zombie to feed
        require(msg.sender == zombieToOwner[_zombieId]);
        //storage variable to hold the zombie object from the Zombie array
        Zombie storage myZombie = zombies[_zombieId];

        // make sure target dna isnt longer than 16 digits
        _targetDna = _targetDna % dnaModulus;

        uint256 newDna = (myZombie.dna + _targetDna) / 2;

        //modify dna to indicate that zombie was a kitty by add 99 to dna
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie("NoName", newDna);
    }

    //funtion to feed zombie a kitty
    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
