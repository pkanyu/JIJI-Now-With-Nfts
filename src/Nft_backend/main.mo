/// Import the necessary libraries:

import Principal "mo:base/Principal";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Types "./Types";

actor class Nfts(){
  //Auctioning an Nft
  // Define an item for the auction: 
  type Item = {
    /// Define a title for the auction:
    title :Preview ;
    /// Define a description for the auction:
    description : Text;
    /// Define an image used as an icon for the auction:
    image : Blob;
  };

type Preview ={
  #Private;
  #Rendered;
};

  /// Define the auction's bid:
  type Bid = {
    /// Define the price for the bid using ICP as the currency:
    price : Nat;
    /// Define the time the bid was placed, measured as the time remaining in the auction: 
    time : Nat;
    /// Define the authenticated user ID of the bid:
    originator : Principal.Principal;
  };

  /// Define an auction ID to uniquely identify the auction:
  type AuctionId = Nat;

  /// Define an auction overview:
  type AuctionOverview = {
    id : AuctionId;
    /// Define the auction sold at the item:
    item : Item;
  };

  /// Define the details of the auction:
  type AuctionDetails = {
    /// Item sold in the auction:
    item : Item;
    /// Bids submitted in the auction:
    bidHistory : [Bid];
    /// Time remaining in the auction:
    /// the auction winner.
    remainingTime : Nat;
  };

  /// Define an internal, non-shared type for storing info about the auction:
  type Auction = {
    id : AuctionId;
    item : Item;
    var bidHistory : List.List<Bid>;
    var remainingTime : Nat;
  };

  /// Create a stable variable to store the auctions:
  stable var auctions = List.nil<Auction>();
  /// Define a counter for generating new auction IDs.
  stable var idCounter = 0;

  /// Define a timer that occurs every second, used to define the time remaining in the open auction:
  func tick() : async () {
    for (auction in List.toIter(auctions)) {
      if (auction.remainingTime > 0) {
        auction.remainingTime -= 1;
      };
    };
  };

  /// Install a timer: 
  let timer = Timer.recurringTimer(#seconds 1, tick);

  /// Define a function to generating a new auction:
  func newAuctionId() : AuctionId {
    let id = idCounter;
    idCounter += 1;
    id;
  };

  /// Define a function to register a new auction that is open for the defined duration:
  func _newAuction(item : Item, duration : Nat) : async () {
    let id = newAuctionId();
    let bidHistory = List.nil<Bid>();
    let newAuction = { id; item; var bidHistory; var remainingTime = duration };
    auctions := List.push(newAuction, auctions);
  };

  /// Define a function to retrieve all auctions: 
  /// Specific auctions can be separately retrieved by `getAuctionDetail`:
  public query func getOverviewList() : async [AuctionOverview] {
    func getOverview(auction : Auction) : AuctionOverview = {
      id = auction.id;
      item = auction.item;
    };
    let overviewList = List.map<Auction, AuctionOverview>(auctions, getOverview);
    List.toArray(List.reverse(overviewList));
  };

  /// Define an internal helper function to retrieve auctions by ID: 
  func findAuction(auctionId : AuctionId) : Auction {
    let result = List.find<Auction>(auctions, func auction = auction.id == auctionId);
    switch (result) {
      case null Debug.trap("Inexistent id");
      case (?auction) auction;
    };
  };

  /// Define a function to retrieve detailed info about an auction using its ID: 
  public query func getAuctionDetails(auctionId : AuctionId) : async AuctionDetails {
    let auction = findAuction(auctionId);
    let bidHistory = List.toArray(List.reverse(auction.bidHistory));
    { item = auction.item; bidHistory; remainingTime = auction.remainingTime };
  };

  /// Define an internal helper function to retrieve the minimum price for an auction's next bid; the next bid must be one unit of currency larger than the last bid: 
  func minimumPrice(auction : Auction) : Nat {
    switch (auction.bidHistory) {
      case null 1;
      case (?(lastBid, _)) lastBid.price + 1;
    };
  };

  /// Make a new bid for a specific auction specified by the ID:
  /// Checks that:
  /// * The user (`message.caller`) is authenticated.
  /// * The price is valid, higher than the last bid, if existing.
  /// * The auction is still open.
  /// If valid, the bid is appended to the bid history.
  /// Otherwise, traps with an error.
  public shared (message) func makeBid(auctionId : AuctionId, price : Nat) : async () {
    let originator = message.caller;
    if (Principal.isAnonymous(originator)) {
      Debug.trap("Anonymous caller");
    };
    let auction = findAuction(auctionId);
    if (price < minimumPrice(auction)) {
      Debug.trap("Price too low");
    };
    let time = auction.remainingTime;
    if (time == 0) {
      Debug.trap("Auction closed");
    };
    let newBid = { price; time; originator };
    auction.bidHistory := List.push(newBid, auction.bidHistory);
  };


  //nfts Auctioning

public func createAuctionForNFT(nftId: Types.TokenId, duration: Nat) : async Text {
    let nftMetadataResult = await getMetadataDip721(nftId);
    
    switch (nftMetadataResult) {
        case (#Ok(nftMetadata)) {
            // Convert NFT metadata to Item type
            let item : Item = {
                title = nftMetadata.purpose;
                description = nftMetadata.des_val_data;
                image = nftMetadata.image; // Assuming image is stored as a Blob
            };
            // Create a new auction with this item
            await _newAuction(item, duration);
            return "Auction created successfully!";
        };
        case (#Err(error)) {
            "Error creating auction: " # debug_show(error);
        };
    };
};


















































































    //Nfts
    // Define stable variables to store the custodian and init values
     var custodian: ?Principal = null;
     var init: ?Types.Dip721NonFungibleToken = null;

    // Function to initialize the custodian and initConfig
    public shared({ caller }) func initialize(custodianArg: Principal, initArg: Types.Dip721NonFungibleToken) : async Text {
        if (custodian == null and init == null) {
            custodian := ?custodianArg;
            init := ?initArg;
            return "Initialized successfully!"
        } else {
            // Handle the error or ignore if already initialized
            return "Already initialized!"
        }
    };
  let burnTokens:Types.DaoInterface = actor("br5f7-7uaaa-aaaaa-qaaca-cai");

   // / Define a shared actor class called 'Dip721NFT' that takes a 'Principal' ID as the custodian value and is initialized with the types for the Dip721NonFungibleToken.
///This actor class also defines several stable variables.
   var transactionId: Types.TransactionId = 0;
   var nfts = List.nil<Types.Nft>();
// Dynamic retrieval of custodians
func  getCustodians() : List.List<Principal> {
    switch (custodian) {
        case (null) { return List.nil<Principal>(); };
        case (?custodianValue) { 

          return List.make<Principal>(custodianValue); };
    };
};



   var maxLimit : Nat16 = switch (init) {
  case (null) { 50};
  case (?i) { i.maxLimit };
};

  // Define a 'null_address' variable. Check out the forum post for a detailed explanation:
  let null_address : Principal = Principal.fromText("aaaaa-aa");

  // Define a public function called 'balanceOfDip721' that returns the current balance of NFTs for the current user: 
  public query func balanceOfDip721(user: Principal) : async Nat64 {
    return Nat64.fromNat(
      List.size(
        List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == user })
      )
    );
  };

  // Define a public function called 'ownerOfDip721' that returns the principal that owns an NFT: 
  public query func ownerOfDip721(token_id: Types.TokenId) : async Types.OwnerResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case (null) {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok(token.owner);
      };
    };
  };

  // Define a shared function called 'safeTransferFromDip721' that provides functionality for transferring NFTs and checks if the transfer is from the 'null_address', and errors if it is:
public shared({ caller }) func safeTransferFromDip721(from: Principal, to: Principal, token_id: Types.TokenId, amount: Nat) : async Types.TxReceipt {  
    if (to == null_address) {
        return #Err(#ZeroAddress);
    } else {
        let balanceCheck = await burnTokens.hasBalanceDecreased(to, from, amount);
        switch(balanceCheck) {
            case (#Ok(balanceDecreased)) {
                if (balanceDecreased) {
                    // Balance has decreased, proceed with the transfer
                    return await transferFrom(from, to, token_id, caller);
                } else {
                    // Balance has not decreased as expected
                    return #Err(#BuyerHasNotBoughtNft);
                }
            };
            case (#Err(_)) {
                // Handle the error case
                return #Err(#Other); // Adjust this based on your error mapping strategy
            };
        };
    };
};





  func transferFrom(from: Principal, to: Principal, token_id: Types.TokenId, caller: Principal) :async Types.TxReceipt {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        if (
          caller != token.owner and
          not List.some(getCustodians(), func (custodian : Principal) : Bool { custodian == caller })
        ) {
          return #Err(#Unauthorized);
        } else if (Principal.notEqual(from, token.owner)) {
          return #Err(#Other);
        } else {
          await burnTokens._burn(caller,1);
          nfts := List.map(nfts, func (item : Types.Nft) : Types.Nft {
            if (item.id == token.id) {
              let update : Types.Nft = {
                owner = to;
                id = item.id;
                metadata = token.metadata;
              };
              return update;
            } else {
              return item;
            };
          });
          transactionId += 1;
          return #Ok(transactionId);   
        };
      };
    };
  };


  // Define a public function that queries and returns the supported interfaces:
  public query func supportedInterfacesDip721() : async [Types.InterfaceId] {
    return [#TransferNotification, #Burn, #Mint];
  };

 // Define a public function that queries and returns the NFT's logo:
  public query func logoDip721() : async Types.LogoResult {
        switch (init) {
        case (null) { return { logo_type = "default_logo_type"; data = "default_data" }; };
        case (?i) { return i.logo; };
    };
  };

 // Define a public function that queries and returns the NFT's name:
public query func nameDip721() : async Text {
    switch (init) {
        case (null) { return "Default Name"; }; // Replace with your default name
        case (?i) { return i.name; };
    };
};

// Define a public function that queries and returns the NFT's symbol:
public query func symbolDip721() : async Text {
    switch (init) {
        case (null) { return "Default Symbol"; }; // Replace with your default symbol
        case (?i) { return i.symbol; };
    };
};

//Dao update functions;
    // Function to update the NFT's logo
    public func updateLogo(newLogo: Types.LogoResult) : async () {
        switch (init) {
            case (null) { /* Handle error: actor not initialized */ };
            case (?i) { init := ?{ i with logo = newLogo }; };
        };
    };

    // Function to update the NFT's name
      // Function to update the name
    public func updateName(newName: Text) : async () {
        switch (init) {
            case (null) { /* Handle error: actor not initialized */ };
            case (?i) { init := ?{ i with name = newName }; };
        };
    };


    // Function to update the NFT's symbol
    // Function to update the symbol
    public func updateSymbol(newSymbol: Text) : async () {
        switch (init) {
            case (null) { /* Handle error: actor not initialized */ };
            case (?i) { init := ?{ i with symbol = newSymbol }; };
        };
    };

  // Define a public function that queries and returns the NFT's total supply value:
  public query func totalSupplyDip721() : async Nat64 {
    return Nat64.fromNat(
      List.size(nfts)
    );
  };

  // Define a public function that queries and returns the NFT's metadata:
  public query func getMetadataDip721(token_id: Types.TokenId) : async Types.MetadataResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.id == token_id });
    switch (item) {
      case null {
        return #Err(#InvalidTokenId);
      };
      case (?token) {
        return #Ok(token.metadata);
      }
    };
  };

  // Define a public function that queries and returns the NFT's max limit value:
  public query func getMaxLimitDip721() : async Nat16 {
    return maxLimit;
  };

  // Define a public function that returns the NFT's metadata for the current user:
  public func getMetadataForUserDip721(user: Principal) : async Types.ExtendedMetadataResult {
    let item = List.find(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    switch (item) {
      case null {
        return #Err(#Other);
      };
      case (?token) {
        return #Ok({
          metadata_desc = token.metadata;
          token_id = token.id;
        });
      }
    };
  };

  // Define a public function that queries and returns the token IDs owned by the current user:
  public query func getTokenIdsForUserDip721(user: Principal) : async [Types.TokenId] {
    let items = List.filter(nfts, func(token: Types.Nft) : Bool { token.owner == user });
    let tokenIds = List.map(items, func (item : Types.Nft) : Types.TokenId { item.id });
    return List.toArray(tokenIds);
  };

  // Define a public function that mints the NFT token:
  public shared({ caller }) func mintDip721(to: Principal, metadata: Types.MetadataDesc) : async Types.MintReceipt {
     if (not List.some(getCustodians(), func (c : Principal) : Bool { c == caller })) {
      Debug.print("Caller: " # debug_show(caller));

      return #Err(#Unauthorized);
    };
    await burnTokens._burn(caller,1);
    let newId = Nat64.fromNat(List.size(nfts));
    let nft : Types.Nft = {
      owner = to;
      id = newId;
      metadata = metadata;
    };

    nfts := List.push(nft, nfts);

    transactionId += 1;

    return #Ok({
      token_id = newId;
      id = transactionId;
    });
  };

};