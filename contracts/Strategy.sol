// SPDX-License-Identifier: AGPL-3.0

// Feel free to change this version of Solidity. We support >=0.6.0 <0.7.0;
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// These are the core Yearn libraries
import {
    BaseStrategy
} from "@yearnvaults/contracts/BaseStrategy.sol";
import "@openzeppelin/contracts/math/Math.sol";
import {
    SafeERC20,
    SafeMath,
    IERC20,
    Address,
} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

// Import interfaces for many popular DeFi projects, or add your own!


import "../interfaces/tokemak/ILiquidityEthPool.sol";
import "../interfaces/tokemak/IRewards.sol";

contract Strategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    ILiquidityEthPool internal constant tokemakEthPool =
        ILiquidityEthPool(0xD3D13a578a53685B4ac36A1Bab31912D2B2A2F36);

    // From Tokemak docs: tABC tokens represent your underlying claim to the assets
    // you deposited into the token reactor, available to be redeemed 1:1 at any time IManager internal constant tokemakManager = IManager(0xA86e412109f77c45a3BC1c5870b880492Fb86A14);


    IERC20 internal constant tWETH =
        IERC20(0xD3D13a578a53685B4ac36A1Bab31912D2B2A2F36);

    // Removing for now: IRewards internal constant tokemakRewards = IRewards(0x79dD22579112d8a5F7347c5ED7E609e60da713C5);

    // Removing for now: IERC20 internal constant tokeToken = IERC20(0x2e9d63788249371f1DFC918a52f8d799F4a38C94);

     // Removing for now: bool internal isOriginal = true;

    // Removing for now:  address public tradeFactory = address(0);

    constructor(address _vault)BaseStrategy(_vault) public {
        // You can set these parameters on deployment to whatever you want
        // maxReportDelay = 6300;
        // profitFactor = 100;
        // debtThreshold = 0;
    }

    // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

    function name() external view override returns (string memory) {
        // Adding Strategy name
        return "StrategyTokemakwETH2";

    }

    // TODO: add together the wETH (want) and tWETH balance and return the cumulative estimated value
    function estimatedTotalAssets() public view override returns (uint256) {
        return twethBalance().add(wantBalance());
    }

    // TODO: Build a more accurate estimate using the value of all positions in terms of `want`
        return want.balanceOf(address(this));
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {

    // TODO: Do stuff here to free up any returns back into `want`
    // NOTE: Return `_profit` which is value generated by all positions, priced in `want`
    // NOTE: Should try to free up at least `_debtOutstanding` of underlying position
    }

    // TODO: as long as there is not too much _debtOutstanding, invest excess want into tokemak liquidity
    function adjustPosition(uint256 _debtOutstanding) internal override {
        // TODO: Do something to invest excess `want` tokens (from the Vault) into your positions
        // NOTE: Try to adjust positions so that `_debtOutstanding` can be freed up on *next* harvest (not immediately)
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        // TODO: Do stuff here to free up to `_amountNeeded` from all positions back into `want`
        // NOTE: Maintain invariant `want.balanceOf(this) >= _liquidatedAmount`
        // NOTE: Maintain invariant `_liquidatedAmount + _loss <= _amountNeeded`

        uint256 totalAssets = want.balanceOf(address(this));
        if (_amountNeeded > totalAssets) {
            _liquidatedAmount = totalAssets;
            _loss = _amountNeeded.sub(totalAssets);
        } else {
            _liquidatedAmount = _amountNeeded;
        }
    }

    function liquidateAllPositions() internal override returns (uint256) {
        // TODO: Liquidate all positions and return the amount freed.
        return want.balanceOf(address(this));
    }

    // NOTE: Can override `tendTrigger` and `harvestTrigger` if necessary

    function prepareMigration(address _newStrategy) internal override {
        // TODO: Transfer any non-`want` tokens to the new strategy
        // NOTE: `migrate` will automatically forward all `want` in this strategy to the new one
    }

    // Override this to add all tokens/tokenized positions this contract manages
    // on a *persistent* basis (e.g. not just for swapping back to want ephemerally)
    // NOTE: Do *not* include `want`, already included in `sweep` below
    //
    // Example:
    //
    //    function protectedTokens() internal override view returns (address[] memory) {
    //      address[] memory protected = new address[](3);
    //      protected[0] = tokenA;
    //      protected[1] = tokenB;
    //      protected[2] = tokenC;
    //      return protected;
    //    }
    function protectedTokens() internal override view 

        returns
        (address [] memory) {
            address[] memory protected = new address[] (3);
            protected[0] = tWETH
            return protected;
    }

    /**
     * @notice
     *  Provide an accurate conversion from `_amtInWei` (denominated in wei)
     *  to `want` (using the native decimal characteristics of `want`).
     * @dev
     *  Care must be taken when working with decimals to assure that the conversion
     *  is compatible. As an example:
     *
     *      given 1e17 wei (0.1 ETH) as input, and want is USDC (6 decimals),
     *      with USDC/ETH = 1800, this should give back 1800000000 (180 USDC)
     *
     * @param _amtInWei The amount (in wei/1e-18 ETH) to convert to `want`
     * @return The amount in `want` of `_amtInEth` converted to `want`
     **/

    function ethToWant(uint256 _amtInWei)
        public
        view
        virtual
        override
        returns (uint256)
    {
        // TODO create an accurate price oracle
        return _amtInWei;
    }

    // View functions to check health and status of Strategy

    function tokeTokenBalance()
        public view
        returns (uint256)
    {
        return tokeToken.balanceOf(address(this));
    }

    function wantBalance()
        public view
        returns (uint256)
    {
        return want.balanceOf(address(this));
    }

    function twethBalance()
        public view
        returns (uint256)
    {
        return tWETH.balanceOf(address(this));
    }

    function _checkAllowance(
        address _contract,
        address _token,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _contract) < _amount) {
            IERC20(_token).safeApprove(_contract, 0);
            IERC20(_token).safeApprove(_contract, _amount);
        }
    }
}