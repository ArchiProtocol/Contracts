pragma solidity ^0.5.16;

import "./CToken.sol";
import "./PriceOracle.sol";

contract UnitrollerAdminStorage {
    /**
    * @notice Administrator for this contract
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Unitroller
    */
    address public comptrollerImplementation;

    /**
    * @notice Pending brains of Unitroller
    */
    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {

    /**
     * @notice Oracle which gives the price of any given asset
     */
    PriceOracle public oracle;

    /**
     * @notice Multiplier used to calculate the maximum repayAmount when liquidating a borrow
     */
    uint public closeFactorMantissa;

    /**
     * @notice Multiplier representing the discount on collateral that a liquidator receives
     */
    uint public liquidationIncentiveMantissa;

    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets
     */
    mapping(address => CToken[]) public accountAssets;

}

contract ComptrollerV2Storage is ComptrollerV1Storage {
    struct Market {
        /// @notice Whether or not this market is listed
        bool isListed;

        /**
         * @notice Multiplier representing the most one can borrow against their collateral in this market.
         *  For instance, 0.9 to allow borrowing 90% of collateral value.
         *  Must be between 0 and 1, and stored as a mantissa.
         */
        uint collateralFactorMantissa;

        /// @notice Per-market mapping of "accounts in this asset"
        mapping(address => bool) accountMembership;

        /// @notice Whether or not this market receives Acmd
        bool isAcmded;
    }

    /**
     * @notice Official mapping of cTokens -> Market metadata
     * @dev Used e.g. to determine if a market is supported
     */
    mapping(address => Market) public markets;


    /**
     * @notice The Pause Guardian can pause certain actions as a safety mechanism.
     *  Actions which allow users to remove their own assets cannot be paused.
     *  Liquidation / seizing / transfer can only be paused globally, not by market.
     */
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
}

contract ComptrollerV3Storage is ComptrollerV2Storage {
    struct AcmdMarketState {
        /// @notice The market's last updated AcmdBorrowIndex or AcmdSupplyIndex
        uint224 index;

        /// @notice The block number the index was last updated at
        uint32 block;
    }

    /// @notice A list of all markets
    CToken[] public allMarkets;

    /// @notice The rate at which the flywheel distributes Acmd, per block
    uint public acmdRate;

    /// @notice The portion of acmdRate that each market currently receives
    mapping(address => uint) public acmdSpeeds;

    /// @notice The Acmd market supply state for each market
    mapping(address => AcmdMarketState) public acmdSupplyState;

    /// @notice The Acmd market borrow state for each market
    mapping(address => AcmdMarketState) public acmdBorrowState;

    /// @notice The Acmd borrow index for each market for each supplier as of the last time they accrued Acmd
    mapping(address => mapping(address => uint)) public acmdSupplierIndex;

    /// @notice The Acmd borrow index for each market for each borrower as of the last time they accrued Acmd
    mapping(address => mapping(address => uint)) public acmdBorrowerIndex;

    /// @notice The Acmd accrued but not yet transferred to each user
    mapping(address => uint) public acmdAccrued;

    /// @notice The utilization rate balance point which acmd speeds equals from lenders and borrowers
    uint public balanceUtiRate;

    /// @notice The credit limits of protocols.
    mapping(address => uint) public creditLimits;

}
