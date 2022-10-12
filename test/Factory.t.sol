// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {GovernorBravoDelegateInterface} from "../src/interfaces/GovernorBravoDelegateInterface.sol";

import {AthensFactory} from "../src/AthensFactory.sol";
import {AthensVoter} from "../src/AthensVoter.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

interface IComp {
    function getPriorVotes(address, uint256) external view returns (uint96);
    function getCurrentVotes(address) external view returns (uint96);
    function balanceOf(address) external view returns (uint256);
    function delegate(address) external;
    function transfer(address, uint256) external;
    function approve(address, uint256) external;
}

contract AthensFactoryTest is Test {
    using stdStorage for StdStorage;

    // Test Contract
    AthensFactory factory;

    // Mainnet compound controller addresses
    address user = address(0xBeef);
    address govBravo = address(0xc0Da02939E1441F497fd74F78cE7Decb17B66529);
    address compToken = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    address compResevior = address(0x2775b1c75658Be0F640272CCb8c72ac986009e38);

    uint256 forkId;

    function setUp() external {
        forkId = vm.createFork(vm.envString("RPC_URL"));
        vm.selectFork(forkId);

        factory = new AthensFactory();
        vm.makePersistent(address(factory));
    }

    function setUpProposal() internal returns (uint96) {
        forkId = vm.createFork(vm.envString("RPC_URL"));
        vm.selectFork(forkId);

        factory = new AthensFactory();
        vm.makePersistent(address(factory));
        // Grant the sender x compound tokens
        // Update the total supply slot of the token
        // Send tokens from the comp reseviour to test account
        vm.rollFork(block.number - 15);

        // Send comp tokens to the user so they can create a proposal
        // deal(address(compToken), user, 10000000);
        // transfer from a big account to make the checkpoints change
        // uint256 proposalThreshold

        vm.prank(compResevior);
        IComp(compToken).transfer(user, 100000e18);
        vm.prank(user);
        IComp(compToken).delegate(user);

        // vm.prank()
        // IComp(compToken).delegate(user);

        vm.makePersistent(compToken);
        assert(vm.isPersistent(address(compToken)));

        // vm.rollFork(block.number + 1);
        vm.rollFork(block.number + 5);

        // Create a proposal as beef
        vm.prank(user);

        IComp(compToken).balanceOf(user);
        IComp(compToken).getPriorVotes(user, block.number - 1);
        IComp(compToken).getCurrentVotes(user);

        vm.prank(user);
        bytes memory cd =
            hex"da95691a00000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000003e0000000000000000000000000000000000000000000000000000000000000092000000000000000000000000000000000000000000000000000000000000000040000000000000000000000003d9819210a31b4961b30ef54be2aed79b9c9cd3b000000000000000000000000316f9708bb98af7da9c68c1c3b5e79039cd336e30000000000000000000000001ec63b5883c3481134fd50d5daebc83ecd2e87790000000000000000000000003d9819210a31b4961b30ef54be2aed79b9c9cd3b000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000002d5f736574436f6d7053706565647328616464726573735b5d2c75696e743235365b5d2c75696e743235365b5d2900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a73657442617365547261636b696e67426f72726f77537065656428616464726573732c75696e743634290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000236465706c6f79416e6455706772616465546f28616464726573732c61646472657373290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001b5f6772616e74436f6d7028616464726573732c75696e74323536290000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000004c0000000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000026000000000000000000000000000000000000000000000000000000000000000070000000000000000000000004ddc2d193948926d02f9b1fe9e1daa0718270ed50000000000000000000000006c8c6b02e7b2be14d4fa6022dfd6d75921d90e4e00000000000000000000000070e36f6bf80a52b3b46b3af8e106cc0ed743e8e4000000000000000000000000face851a4921ce59e912d19329929ce6da6eb0c700000000000000000000000035a18000230da775cac24873d00ff85bccded550000000000000000000000000ccf4429db6322d5c611ee964527d42e5d685dd6a000000000000000000000000b3319f5d18bc0d84dd1b4825dcde5d5f7266d407000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000131888b5aaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000c3d688b66703497daa19211eedff47f25384cdc3000000000000000000000000000000000000000000000000000001b2fe95ce6d0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000316f9708bb98af7da9c68c1c3b5e79039cd336e3000000000000000000000000c3d688b66703497daa19211eedff47f25384cdc300000000000000000000000000000000000000000000000000000000000000400000000000000000000000001b0e765f6224c21223aea2af16c1c46e38885a4000000000000000000000000000000000000000000000054b40b1f852bda0000000000000000000000000000000000000000000000000000000000000000004342320496e697469616c697a6520436f6d706f756e642049494920434f4d5020446973747269627574696f6e0a546869732070726f706f73616c20696e636c7564657320436f6d706f756e642049494920757365727320696e20746865205b434f4d5020446973747269627574696f6e5d2868747470733a2f2f636f6d706f756e642e66696e616e63652f676f7665726e616e63652f636f6d70292c207768696368206973206163636f6d706c69736865642062792072652d616c6c6f636174696e67203136312e343220434f4d502070657220646179202831342e313725206f662074686520746f74616c292066726f6d207632206d61726b6574732e2054686520746f74616c20434f4d5020446973747269627574696f6e20697320756e6368616e67656420627920746869732070726f706f73616c2e0a0a2d2045544820626f72726f776572733a202d33352e33310a2d205742544320737570706c6965727320616e6420626f72726f776572733a202d37302e36330a2d204c494e4b20737570706c6965727320616e6420626f72726f776572733a202d392e36300a2d20554e4920737570706c6965727320616e6420626f72726f776572733a202d392e36300a2d20434f4d5020737570706c696572733a202d31362e34320a2d2042415420737570706c6965727320616e6420626f72726f776572733a202d392e36300a2d205a525820737570706c6965727320616e6420626f72726f776572733a202d392e36300a2d20436f6d706f756e642049494920555344433a202b3136312e34320a0a4c6173746c792c2032352c30303020434f4d5020617265207472616e736665727265642066726f6d2074686520436f6d7074726f6c6c657220746f2074686520436f6d706f756e6420494949205265776172647320636f6e74726163742e204261736564206f6e2074686520706172616d657465727320736574206561726c6965722c207468697320657175616c73203135342064617973206f6620646973747269627574696f6e206265666f726520676f7665726e616e636520776f756c64206e65656420746f207265706c656e697368206f72206d6f646966792074686520646973747269627574696f6e20746f20436f6d706f756e64204949492075736572732e0a0a4966207375636365737366756c2c20746869732070726f706f73616c2077696c6c2074616b65206566666563742061667465722050726f706f73616c203131392063757265732074686520436f6d706f756e6420763220707269636520666565642c20616e64207072696f7220746f20746865204d657267652e0a0a5b46756c6c2070726f706f73616c20616e6420666f72756d2064697363757373696f6e5d2868747470733a2f2f7777772e636f6d702e78797a2f742f696e697469616c697a652d636f6d706f756e642d6969692d757364632d6f6e2d657468657265756d2f333439392f35290a000000000000000000000000";
        (bool success, bytes memory data) = address(govBravo).call(cd);

        assert(success);
        return uint96(uint256(bytes32(data)));
    }

    // function testDeployFactory() external {
    //     // slither-disable-next-line reentrancy-events,reentrancy-benign
    // }

    function testCreateVoterProxy() external {
        // slither-disable-next-line reentrancy-events,reentrancy-benign
        // uint96 proposalId = setUpProposal();

        factory = new AthensFactory();
        vm.makePersistent(address(factory));
        uint96 proposalId = 6;
        uint8 vote = 1;
        address underlyingToken = compToken;
        address govContract = govBravo;

        AthensVoter proxy = factory.createVoterProxy(underlyingToken, govContract, proposalId, vote);
        // assert clone parameters
        assertEq(proxy.govAddress(), govContract);
        assertEq(proxy.tokenAddress(), underlyingToken);
        assertEq(proxy.vote(), vote);
        assertEq(proxy.proposalId(), proposalId);
    }

    function testAllocateVote() external {
        // Create voter contract
        uint256 proposalId = 101;
        address underlyingToken = compToken;
        address govContract = govBravo;

        AthensVoter proxy = factory.createVoterProxy(underlyingToken, govContract, proposalId, 1);

        // Allocate the vote
        address rollup = address(0xdead);
        uint256 numTokens = 1e19;

        // Give the bridge comp tokens
        deal(address(compToken), rollup, numTokens);
        vm.prank(rollup);
        IComp(compToken).approve(address(factory), numTokens);

        // Set the bridge as permissioned to be able to make calls
        factory.setBridge(rollup);

        vm.prank(rollup);
        factory.allocateVote(0, numTokens);

        // assert the balance of the proxy
        assertEq(IComp(compToken).balanceOf(address(proxy)), numTokens);

        // check i have a balance of synthetic tokens
        address syntheticAddress = address(factory.zkVoterTokens(compToken));
        uint256 balance = IComp(syntheticAddress).balanceOf(rollup);
        assertEq(balance, numTokens);
    }

    function testCanRedeemRollupTokens() external {
        // Create voter contract
        uint256 proposalId = 101;
        address underlyingToken = compToken;
        address govContract = govBravo;

        AthensVoter proxy = factory.createVoterProxy(underlyingToken, govContract, proposalId, 1);

        // Allocate vote
        address rollup = address(0xdead);
        uint256 numTokens = 1e19;
        // Give the bridge comp tokens
        deal(address(compToken), rollup, numTokens);
        vm.prank(rollup);
        IComp(compToken).approve(address(factory), numTokens);

        // Set the bridge as permissioned to be able to make calls
        factory.setBridge(rollup);

        vm.prank(rollup);
        factory.allocateVote(0, numTokens);

        // check i have a balance of synthetic tokens
        address zkVoteToken = address(factory.zkVoterTokens(compToken));
        uint256 balance = IComp(zkVoteToken).balanceOf(rollup);
        // Attempt to redeem tokens as the bridge
        vm.prank(rollup);
        factory.redeemVotingTokens(0, numTokens);

        // assert synthetic tokens destroyed
        assertEq(IComp(zkVoteToken).balanceOf(rollup), 0);

        // assert rollup receives tokens back
        assertEq(IComp(compToken).balanceOf(rollup), numTokens);
    }
}
