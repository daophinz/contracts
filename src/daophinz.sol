import "./Efficient.sol";

pragma solidity ^0.8.0;


contract Daophin is ERC721Enumerable, Ownable, nonReentrant {

	uint256 public mintPrice = 0;		// 0.0 ETH
	
    uint256 public immutable MAX_SUPPLY = 100;	// 100 supply
	
	bool public saleActive = false;
	
	uint256 public maxSaleMint = 1;
	
	mapping(address => AddressInfo) public addressInfo;
		
	constructor() ERC721("Daophinz", "PHINZ") {}

	// PUBLIC FUNCTIONS
	
	function mint(uint256 _mintAmount) public payable reentryLock {
		require(saleActive, "public sale is not active");
		require(msg.sender == tx.origin, "no proxy transactions allowed");
		
		uint256 supply = totalSupply();
		require(_mintAmount < maxSaleMint + 1, "max mint amount per session exceeded");
		require(supply + _mintAmount < MAX_SUPPLY + 1, "max NFT limit exceeded");
		
		_safeMint(msg.sender, supply + 1);
	}
	
    function isApprovedForAll(address _owner, address operator) public view override returns (bool) {
        MarketplaceProxyRegistry proxyRegistry = MarketplaceProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == operator || addressInfo[operator].projectProxy) return true;
        return super.isApprovedForAll(_owner, operator);
    }


	// ONLY OWNER FUNCTIONS

	function setBaseURI(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
    }
	
    function flipSaleState() public onlyOwner {
        saleActive = !saleActive;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
		(bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed.");
    }
}