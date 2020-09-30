pragma solidity ^0.6.6;
// Import Aave flashloans code.  By importing you are saving resources from having to write out this code
import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/FlashLoanReceiverBase.sol";
import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/ILendingPoolAddressesProvider.sol";
import "https://github.com/aave/flashloan-box/blob/Remix/contracts/aave/ILendingPool.sol";

contract Flashloan is FlashLoanReceiverBase {

/**
This construction method is run when you create this flashloans smart contract.
Make sure to specify the lendingpooladdress provider from Aave. This argument is different  based on the environment you are working in.  Visit Aave docs to get this address.
*/
    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) public {}

    /**
        This function is called by Aave to the flashloans contract after the contract has received the flash loaned amount
     */
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
        external
        override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        //
        // Your logic goes here.
        // !! Ensure that *this contract* has enough of `_reserve` funds to payback the `_fee` !!
        //

        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    /**
       Call this function when you want to execute a flashloan.  
       The parameter `_asset` is the address of the token you want to borrow in the flash loan. 
       In our example the token we will borrow is DAI.
     */
    function flashloan(address _asset) public onlyOwner {
        bytes memory data = "";
        uint amount = 1 ether;

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), _asset, amount, data);
    }
}
