import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

module {


  public type Dip721NonFungibleToken = {
    logo: LogoResult;
    name: Text;
    symbol: Text;
    maxLimit : Nat16;
  };

  public type LogoResult = {
    logo_type: Text;
    data: Text;
  };
  public type ApiError = {
    #Unauthorized;
    #InvalidTokenId;
    #ZeroAddress;
    #Other;
    #AutionNotCreated;
    #BuyerHasNotBoughtNft
  };
  public type TxReceipt = Result<Nat, ApiError>;
  public type MintReceipt = Result<MintReceiptPart, ApiError>;


  public type OwnerResult = Result<Principal, ApiError>;
  
  public type TransactionId = Nat;
  public type TokenId = Nat64;

  public type Nft = {
    owner: Principal;
    id: TokenId;
    metadata: MetadataDesc;
  };
  public type InterfaceId = {
    #Approval;
    #TransactionHistory;
    #Mint;
    #Burn;
    #TransferNotification;
  };

   public type DaoInterface = actor {
    _burn: shared(caller:Principal,amount:Nat) -> async () ;
    hasBalanceDecreased: shared(user:Principal,to:Principal,expectedDecrease:Nat) -> async Result<Bool,Text> ;
  };

  public type ExtendedMetadataResult = Result<{
    metadata_desc: MetadataDesc;
    token_id: TokenId;
  }, ApiError>;

  public type MetadataResult = Result<MetadataDesc, ApiError>;
  public type Result<S, E> = {
    #Ok : S;
    #Err : E;
  };

  public type MetadataDesc =  MetadataPart;

  public type MetadataPart = {
    purpose: MetadataPurpose;
    des_val_data:Text ;
    image: Blob;
  };

  public type MetadataPurpose = {
    #Private;
    #Rendered;
  };

  

  public type MintReceiptPart = {
    token_id: TokenId;
    id: Nat;
  };
};
