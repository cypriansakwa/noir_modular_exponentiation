// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../CyprianVerifierApp.sol";
import "../Verifier.sol";

contract CyprianVerifierAppTest is Test {
    CyprianVerifierApp public verifierApp;
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](2);

    function setUp() public {
        verifier = new HonkVerifier();
        verifierApp = new CyprianVerifierApp(verifier);

        // Set according to your circuit's expected public output!
        publicInputs[0] = bytes32(uint256(3));
        publicInputs[1] = bytes32(uint256(6));
    }

    function testVerifyProof() public {
        // Make sure this path matches your proof's actual location and extension.
        bytes memory proof = vm.readFileBinary("../circuits/target/proof");
        console.log("Proof length:", proof.length);

        verifierApp.verifyEqual(proof, publicInputs);
    }
}
