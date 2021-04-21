// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMoloch {
  function submitProposal(
      address applicant,
      uint256 sharesRequested,
      uint256 lootRequested,
      uint256 tributeOffered,
      address tributeToken,
      uint256 paymentRequested,
      address paymentToken,
      string memory details
  ) external returns (uint256 proposalId);

  // Returns [sponsored, processed, didPass, cancelled, whitelist, guildkick]
  function getProposalFlags(uint256 proposalId) external view returns (bool[6] memory);

  function getUserTokenBalance(address user, address token) external view returns (uint256);
  function withdrawBalance(address token, uint256 amount) external;
}