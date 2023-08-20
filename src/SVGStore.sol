// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "solady/auth/Ownable.sol";
import "./libraries/NFTSVG.sol";

contract SVGStore is Ownable {
    mapping(address => string) public uris; // public getter

    constructor(address owner) {}

    function store(string calldata _name, string calldata _description, string calldata _svg) public {
        uris[msg.sender] = NFTSVG.constructTokenURI(
            NFTSVG.SVGParams({name: _name, description: _description, svg: _svg})
        );
    }
}
