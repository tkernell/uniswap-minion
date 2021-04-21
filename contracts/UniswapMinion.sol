// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMoloch.sol";
import "./IUniswapV2Router02.sol";
import "./IERC20.sol";

contract UniswapMinion {
  // Allow people to make propsals (which sends a proposal command to Moloch DAO)
  string public constant MINION_ACTION_DETAILS = '{"isMinion": true, "title":"MINION", "description":"';
  IMoloch immutable public moloch;
  IUniswapV2Router02 immutable public uniswap;

  // Mappings
  mapping(uint256 => Swap) public swaps;

  // Structs
  struct Swap {
    uint amountOut_MIN;
    uint amountOut_MAX;
    uint amountIn;
    address[] tokenPath;
    address to;
    uint deadline;
    bool executed;
    address delegator;
  }

  // Events
  event WithdrawToMinion(address targetDao, address token, uint256 amount);
  event ProposeSwapExactTokensForTokens(uint256 proposalId, address proposer, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);
  event SwapExecuted(uint256 propsalId);

  constructor (address _moloch, address _uniswap) {
    moloch = IMoloch(_moloch);
    uniswap = IUniswapV2Router02(_uniswap);
  }

  function doWithdraw (address _targetDao, address _token, uint256 _amount) {
    require(moloch.getUserTokenBalance(address(this), _token) >= _amount, "UniswapMinion: insufficient balance");
    moloch.withdrawBalance(_token, _amount);
    emit WithdrawToMinion(_targetDao, _token, _amount);
  }

  function proposeAction(
      address token,
      uint256 tributeOffered,
      uint256 paymentRequested,
      string memory details
  ) internal returns (uint256 _proposalId) {
      
    //submit proposal to its moloch 
    _proposalId = moloch.submitProposal(
        address(this),
        0,
        0,
        tributeOffered,
        token,
        paymentRequested,
        token,
        details
    );
  }

  function proposeSwapExactTokensForTokens (
    uint _amountIn, 
    uint _amountOut_MIN,
    uint _amountOut_MAX,
    address[] calldata _tokenPath, 
    uint _deadline,
    string calldata _details,
    address _delegator
    ) returns (uint256) {
    address memory finalDelegator = _delegator == address(0) ? msg.sender : _delegator;
    uint256 proposalId = proposeAction(_tokenPath[0], 0, _amountIn, details);
    Swap memory swap = Swap({ amountIn: _amountIn, amountOut_MIN: _amountOut_MIN, amountOut_MAX: _amountOut_MAX, deadline: _deadline, tokenPath: _tokenPath, executed: false, delegator: finalDelegator });
    swaps[proposalId] = swap;

    emit ProposeSwapExactTokensForTokens(proposalId, msg.sender, _amountIn, _amountOut_MIN, _tokenPath[0], _tokenPath[1]);

    return proposalId;
  }

  function executeSwapExactTokensForTokens (uint256 _proposalId, uint newAmountOut) {
    Swap memory swap = swaps[_proposalId];
    require(newAmountOut >= swap.amountOut_MIN && newAmount <= swap.amountOut_MAX, "UniswapMinion: invalid amount out provided");
    require(swap.delegator == msg.sender, "UniswapMinion: unauthorized");
    swap.amountOut = newAmountOut;

    address memory minionAddress = address(this);
    IERC20 inputToken = IERC20(swap.tokenPath[0]);
    bool[6] memory flags = moloch.getProposalFlags(_proposalId);

    require(!swap.executed, "UniswapMinion: swap already executed");
    require(flags[2], "UniswapMinion: proposal not passed");
    require(flags[1], "UniswapMinion: proposal not processed");
    doWithdraw(address(moloch), address(inputToken), swap.amountIn);
    require(inputToken.balanceOf(minionContract) >= swap.amountIn, "UniswapMinion: insufficient funds");

    inputToken.approve(address(uniswap), uint256(-1));
    uniswap.swapExactETHForTokens(swap.amountIn, newAmountOut, swap.tokenPath, address(moloch), swap.deadline);

    swap.executed = true;
    emit SwapExecuted(_propsalId);
  }
}