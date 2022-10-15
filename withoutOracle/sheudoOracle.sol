
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract sheudoOracle  {

    uint public priceInCents;

    function setPrice(uint _priceInCents) public {
      priceInCents = _priceInCents;
    }

}
