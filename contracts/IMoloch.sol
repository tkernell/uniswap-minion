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
}