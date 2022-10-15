// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./sheudoOracle.sol";

contract bnbusd is ERC20 {

  sheudoOracle priceOracle;
  uint constant ONECENT  = 1;

   constructor (address priceOracleContract) ERC20("USD pegged BNB backed stablecoin", "bnbUSD") {
    priceOracle =  PriceOracle(priceOracleContract);
  }

   function decimals() public pure  override returns (uint8) {
        return 2;
    }


  function buybnbUsd() public payable  {
    require((ONECENT <= (msg.value * priceOracle.priceInCents()) / 1 ether), "The minimum purchase is one cent");
    uint amountInCents = (msg.value * priceOracle.priceInCents()) / 1 ether;
     _mint(msg.sender, amountInCents);

  }

  function getPrice() public view returns (uint) {

    return priceOracle.priceInCents();

  }

  function sellbnbUsd(uint amountInCents) public returns (uint amountInWei){
    require(amountInCents <= balanceOf(msg.sender), "Your balance is insufficient");
    amountInWei = (amountInCents * 1 ether) / priceOracle.priceInCents();


    // Dos modalidades a aplicar en el caso de no disponer fondos.


    // 1. REPARTO PROPORCIONAL A LO EXISTENTE

    // Si no tenemos suficiente Éter en el contrato para pagar la cantidad completa
    // pagamos una cantidad proporcional a lo que nos queda.
    // De esta manera el valor neto del usuario nunca caerá a un ritmo más rápido que
    // la propia garantía.

    // Por ejemplo:
    // Un usuario deposita 1 BNB cuando el precio del BNB es de $300
    // el precio entonces cae a $150.
    // Si tenemos suficiente BNB en el contrato cubrimos sus pérdidas
    // y les devolvemos 2 BNB (la misma cantidad en USD).
    // si no tenemos suficiente dinero para devolverles pagamos
    // de forma proporcional a lo que nos queda. En este caso ellos
    // recuperarían su depósito original de 1 BNB.

    //if(address(this).balance <= amountInWei) amountInWei = (amountInWei * address(this).balance * priceOracle.priceInCents()) / (1 ether * totalSupply());

    // 2. NO DAR MAS DE LO DISPONIBLE
    //
    // Si no tenemos suficiente Bnbs para pagar la equivalencia no se paga.
    uint balanceInCentsOfContract = (address(this).balance  * priceOracle.priceInCents()) / 1 ether; 
     require(amountInCents <= balanceInCentsOfContract, "Our balance is insufficient for your amount");


    _burn(msg.sender, amountInCents);
    payable(msg.sender).transfer(amountInWei);
  }

}
