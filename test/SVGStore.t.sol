// SPDX-License-Identifier: Unlicense
pragma solidity >= 0.8.15;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {LibString} from "solady/utils/LibString.sol";
import {Base64} from "solady/utils/Base64.sol";

import {SVGStore} from "../src/SVGStore.sol";

contract SVGStoreTest is Test {
    using stdJson for string;

    SVGStore svgstore;
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
            if (LibString.endsWith(next, ".svg")) {
                filenames[_dir].push(next);
            }
            next = vm.readLine(temptxt);
        }
        vm.removeFile(temptxt);
    }

    /*///////////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////////*/

    function setUp() public {
        svgstore = new SVGStore(address(this));
    }

    /*///////////////////////////////////////////////////////////////////
                                TEST HELPERS
    //////////////////////////////////////////////////////////////////*/

    /**
     * read svg, store in contract, retrieve URI from contract, decode, parse, and assert.
     * tests that inputs to contract == URI output
     */
    function assertSvg(address _actor, string memory _filename, string memory _dir) public {
        string memory tempjson = string.concat(tempdir, "/", _dir, ".json");

        // make path
        string memory path = string.concat(assetsdir, "/", _dir, "/", _filename);

        // read file
        string memory contents = vm.readFile(path);

        // store in contract
        vm.prank(_actor);
        svgstore.store(_filename, path, contents);

        // get uri from contract
        string memory uri = svgstore.uris(_actor);
        
        // slice and decode uri
        string memory cutUri = LibString.slice(uri, 29);
        string memory decodedUri = string(Base64.decode(cutUri));
        
        // write decoded metadata to json
        vm.writeJson(decodedUri, tempjson);

        // read json
        string memory json = vm.readFile(tempjson);
        
        // decode json
        string memory dname = abi.decode(json.parseRaw(".name"), (string));
        string memory ddescription = abi.decode(json.parseRaw(".description"), (string));
        string memory dcontent = abi.decode(json.parseRaw(".image"), (string));

        // slice and decode content
        string memory cutContent = LibString.slice(dcontent, 26);
        string memory decodedContent = string(Base64.decode(cutContent));

        assertEq(_filename, dname);
        assertEq(path, ddescription);
        assertEq(contents, decodedContent);

        vm.removeFile(tempjson);
    }

    function assertSvgs(string memory _dir) public {
        address[] memory actors = getActors(filenames[_dir].length);
        for (uint256 i; i < filenames[_dir].length; i++) {
            assertSvg(actors[i], filenames[_dir][i], _dir);
        }
    }

    function assertSvgs(string memory _dir, uint256 index) public {
        address actor = address(uint160(4444));
        assertSvg(actor, filenames[_dir][index], _dir);
    }

    /*///////////////////////////////////////////////////////////////////
                                TESTS
    //////////////////////////////////////////////////////////////////*/

    // function testSingle() public {
    //     string memory dir = "embedded";
    //     setFiles(dir);
    //     assertSvgs(dir, 0);
    // }

    function testAnimations() public {
        string memory dir = "animations";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testEmbedded() public {
        string memory dir = "embedded";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport() public {
        string memory dir = "import";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport2() public {
        string memory dir = "import2";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport3() public {
        string memory dir = "import3";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport4() public {
        string memory dir = "import4";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testInteract() public {
        string memory dir = "interact";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testLinking() public {
        string memory dir = "linking";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPainting() public {
        string memory dir = "painting";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPath() public {
        string memory dir = "path";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPservers() public {
        string memory dir = "pservers";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testRender() public {
        string memory dir = "render";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testRendering() public {
        string memory dir = "rendering";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testScripted() public {
        string memory dir = "scripted";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testShapes() public {
        string memory dir = "shapes";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testStruct() public {
        string memory dir = "struct";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testStyling() public {
        string memory dir = "styling";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testText() public {
        string memory dir = "text";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testTypes() public {
        string memory dir = "types";
        setFiles(dir);
        assertSvgs(dir);
    }
}
