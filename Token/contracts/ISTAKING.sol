
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ISTAKING
 */
interface ISTAKING {

    /**
     * @dev Returns the name of reward tokens.
     */
    function asset() external view returns (string memory);

    /**
     * @dev Returns the address of reward tokens.
     */
    function assetAddr() external view returns (address[] memory);

    /**
     * @dev Returns the total amount of staking.
     */
    function totalBalance() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Stake for mining.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Staking} event.
     */
    function staking(address beneficiary, uint256 amount) external returns (bool);

    /**
     * @dev This function withdraws the staked MPLE and reward tokens for mining.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Withdraw} event.
     */
    function withdraw(address beneficiary, uint256 amount) external returns (bool);


    /**
     * @dev Returns whether reward has been confirmed.

     *
     */
    function isconfirm() external returns (bool);


    /**
     * @dev Return the rewards you can receive. Returns 0 if the reward has not been confirmed.
     */
    function reward(address account) external view returns (uint256);

    

    /**
     * @dev Returns the past time since deposit.
     */
    function term(address account) external view returns (uint256);

    /**
     * @dev Returns the staking open date
     */
    function beginAt() external view returns (uint256);

    /**
     * @dev Returns the staking close date.
     */
    function endAt() external view returns (uint256);

    /**
     * @dev Returns the staking regist time.
     */
    function registAt(address account) external view returns (uint256);

    /**
     * @dev Returns the staking exit time.
     */
    function exitAt(address account) external view returns (uint256);

    /**
     * @dev Emitted when the token stakes.
     */
    event Staking(address indexed from, uint256 value);

    /**
     * @dev Emitted when the owner makes a withdrawal.
     */
    event Withdraw(address indexed owner, uint256 value);
}
