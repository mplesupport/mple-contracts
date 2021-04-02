// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "./ISTAKING.sol";

contract MPLE is ERC20, ERC20Burnable {
    /** security for math*/
    using SafeMath for uint256;
    /** security for address*/
    using Address for address;
    /** inital supply*/
    uint256 public INITAL_SUPPLY = 1000000000*(10**18);
    /** staking contract */
    ISTAKING public stakingContract;
    bool private _paused;
    address private _owner;
    /** staking activation config */
    bool public stakingFinished = true;
    bool public stakingLocked = true;

    /** List of agents allowed to manage staking */
    mapping (address => bool) public stakingManagers;
    /**
    * @dev Check if staking is possible.
    */
    modifier canStaking() {
        require(!stakingFinished, "[Validation] The staking did not open.");
        _;
    }

    /**
    * @dev Check if staking is possible.
    */
    modifier canWithdraw() {
        require(!stakingLocked, "[Validation] The staking did not open.");
        _;
    }

    /**
    * @dev Check if you are a staking manager.
    */
    modifier onlyManagers() {
        require(stakingManagers[msg.sender], "[Validation] sender is not a staking manager.");
        _;
    }

    /**
    * @dev Check if it is a smart contract.
    */
    modifier onlyContract(address account)
    {
        require(account.isContract(), "[Validation] The address does not contain a contract");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    constructor() ERC20("MPLE", "MPLE")
    {
        _mint((msg.sender), INITAL_SUPPLY);

        _paused = false;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

    }

    /**
     * @dev _beforeTokenTransfer overide
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        ERC20._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() public whenNotPaused onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() public whenPaused onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }

   /**
   * @dev setup staking manager
   */
    function setManager(address addr, bool state) public onlyOwner {
        stakingManagers[addr] = state;
        emit ManagerChanged(addr, state);
    }
   /**
   * @dev set staking Contract
   */
    function setStakingContract(address contractAddr) public onlyOwner onlyContract(contractAddr)
    {
        stakingContract = ISTAKING(contractAddr);
        emit StakingContractChanged(contractAddr);
    }


    /**
    * @dev Make staking possible.
    */
    function openStaking() public onlyManagers {
        stakingFinished = false;
        emit StakingOpened();
    }

    /**
    * @dev stop staking
    */
    function closeStaking() public onlyManagers {
        stakingFinished = true;
        emit StakingFinished();
    }

    /**
     * @dev Staking for mining.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Staking} event.
     */
    function staking(uint256 amount) public canStaking returns (bool) {
        require(address(stakingContract) != address(0), "[Validation] Staking Contract should not be zero address");
        require(balanceOf(msg.sender) >= amount, "[Validation] The balance is insufficient.");
        _transfer(msg.sender, address(stakingContract), amount);
        return stakingContract.staking(msg.sender, amount);
    }
     /**
     * @dev This function withdraws the staked MPLE and reward tokens for mining.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Withdraw} event.
     */
    function withdraw(uint256 amount) public canWithdraw returns (bool) {
        return stakingContract.withdraw(msg.sender, amount);
    }

    /**
     * @dev This is a function for withdrawal of erc20 tokens.
     *
     * Emits a {Withdraw} event.
     */
    function withdrawErc20(address _tokenAddr, address _to, uint _value) public onlyOwner {
        ERC20 erc20 = ERC20(_tokenAddr);
        erc20.transfer(_to, _value);
        emit WithdrawErc20Token(_tokenAddr, _to, _value);
    }

    /**
     * @dev This is a function for mint.
     *
     * Emits a {Withdraw} event.
     */
    function mint(address account, uint256 amount) public onlyOwner {
        require(INITAL_SUPPLY >= totalSupply().add(amount), "[Validation] Total supply cannot exceed the initial supply.");
        _mint(account, amount);
    }

    /** events */
    event StakingOpened();
    event StakingFinished();
    event StakingContractChanged(address indexed stakingContract);
    event ManagerChanged(address indexed manager, bool state);
    event WithdrawErc20Token (address indexed erc20, address indexed wallet, uint value);
    event Paused(address account);
    event Unpaused(address account);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
