// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IMoloch.sol";
import "./IUniswapV2Router02.sol";

contract UniswapMinion {
  // Allow people to make propsals (which sends a proposal command to Moloch DAO)
  string public constant MINION_ACTION_DETAILS = '{"isMinion": true, "title":"MINION", "description":"';
  IMoloch immutable public moloch;
  IUniswapV2Router02 immutable public uniswap;

  constructor (address _moloch, address _uniswap) {
    moloch = IMoloch(_moloch);
    uniswap = IUniswapV2Router02(_uniswap);
  }
}