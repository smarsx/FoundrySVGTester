// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.15;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";

import {MetaStore} from "../src/MetaStore.sol";
import {NFTMeta} from "../src/libraries/NFTMeta.sol";

contract MetaTest is Test {
    using stdJson for string;

    MetaStore metaStore;
    mapping(string => string[]) public filenames;

    string tempdir = string.concat(vm.projectRoot(), "/temp");
    string assetsdir = string.concat(vm.projectRoot(), "/assets");
    string assetsOut = string.concat(assetsdir, "/out");

    /*///////////////////////////////////////////////////////////////////
                                UTILS
    //////////////////////////////////////////////////////////////////*/

    function getActors(uint256 _n) public pure returns (address[] memory) {
        address[] memory actors = new address[](_n);
        for (uint256 i; i < _n; i++) {
            actors[i] = address(uint160(i));
        }
        return actors;
    }

    function ls(string memory _file) public returns (string memory) {
        string[] memory inputs = new string[](3);
        inputs[0] = "ls";
        inputs[1] = "-A"; // exclude implied . ..
        inputs[2] = _file;
        return string(vm.ffi(inputs));
    }

    /**
     * populate filenames map for _dir
     */
    function setFiles(string memory _dir) public {
        if (filenames[_dir].length > 0) return;

        string memory temptxt = string.concat(tempdir, "/", _dir, ".txt");
        string memory dir = string.concat(assetsdir, "/", _dir);
        string memory files = ls(dir);
        vm.writeFile(temptxt, files);
        string memory next = vm.readLine(temptxt);

        while (bytes(next).length > 0) {
            filenames[_dir].push(next);
            next = vm.readLine(temptxt);
        }
        vm.removeFile(temptxt);
    }

    /*///////////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////////*/

    function setUp() public {
        metaStore = new MetaStore(address(this));
    }

    /*///////////////////////////////////////////////////////////////////
                                TEST HELPERS
    //////////////////////////////////////////////////////////////////*/

    /**
     * read metadata, store in contract, retrieve URI from contract, decode, parse, and assert.
     * tests that inputs to contract == URI output
     */
    function assertMeta(
        NFTMeta.TypeURI _typeUri,
        address _actor,
        string memory _filename,
        string memory _dir
    ) public {
        string memory tempjson = string.concat(tempdir, "/", _filename, ".json");
        string memory contentkey = _typeUri == NFTMeta.TypeURI.SVG ? ".image" : ".animation_url";
        uint256 contentidx = _typeUri == NFTMeta.TypeURI.SVG ? 26 : 22;

        // make path
        string memory path = string.concat(assetsdir, "/", _dir, "/", _filename);

        // read file
        string memory contents = vm.readFile(path);
        
        // store in contract
        vm.prank(_actor);
        metaStore.store(_typeUri, _filename, path, contents);
        string memory uri = metaStore.uris(_actor);

        // slice and decode uri
        string memory decodedUri = string(Base64.decode(LibString.slice(uri, 29)));
        
        // write decoded metadata to json
        vm.writeJson(decodedUri, tempjson);
        // read json
        string memory json = vm.readFile(tempjson);

        assertEq(_filename, abi.decode(json.parseRaw(".name"), (string)));
        assertEq(path, abi.decode(json.parseRaw(".description"), (string)));
        assertEq(contents, string(Base64.decode(LibString.slice(abi.decode(json.parseRaw(contentkey), (string)), contentidx))));

        vm.removeFile(tempjson);
    }

    function assertFiles(NFTMeta.TypeURI _turi, string memory _dir) public {
        address[] memory actors = getActors(filenames[_dir].length);
        for (uint256 i; i < filenames[_dir].length; i++) {
            assertMeta(_turi, actors[i], filenames[_dir][i], _dir);
        }
    }

    function assertFile(
        NFTMeta.TypeURI _turi,
        string memory _dir,
        uint256 index
    ) public {
        address actor = address(uint160(4444));
        assertMeta(_turi, actor, filenames[_dir][index], _dir);
    }

    /*///////////////////////////////////////////////////////////////////
                                TESTS
    //////////////////////////////////////////////////////////////////*/

    function testSvgs() public {
        string memory dir = "meta-svg";
        setFiles(dir);
        assertFiles(NFTMeta.TypeURI.SVG, dir);
    }

    function testHtml() public {
        string memory dir = "meta-html";
        setFiles(dir);
        assertFiles(NFTMeta.TypeURI.HTML, dir);
    }
}
