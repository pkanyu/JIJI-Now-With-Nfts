import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Nat64 "mo:base/Nat64";
import Types "types";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Int "mo:base/Int";
actor class DAO() {

    type Member = Types.Member;
    type Result<Ok, Err> = Types.Result<Ok, Err>;
    type HashMap<K, V> = Types.HashMap<K, V>;
    type Proposal = Types.Proposal;
    type ProposalContent = Types.ProposalContent;
    type ProposalId = Types.ProposalId;
    type Vote = Types.Vote;
    type Account = Types.Account;

    /////////////////
    // PART #1 //
    ///////////////
    let goals = Buffer.Buffer<Text>(0);
    let name = "Motoko Bootcamp";
    var manifesto = "Empower the next generation of builders and make the DAO-revolution a reality";

    public shared query func getName() : async Text {
        return name;
    };

    public shared query func getManifesto() : async Text {
        return manifesto;
    };

    public func setManifesto(newManifesto : Text) : async () {
        manifesto := newManifesto;
        return;
    };

    public func addGoal(newGoal : Text) : async () {
        goals.add(newGoal);
        return;
    };

    public shared query func getGoals() : async [Text] {
        Buffer.toArray(goals);
    };

    /////////////////
    // PART #2 //
    ///////////////
    let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(newMember : Member) : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                members.put(caller, newMember);
                ledger.put(caller, 100); 
                return #ok();
            };
            case (?member) {
                return #err("Member already exists");
            };
        };
    };

    public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?mem) {
                members.put(caller, member);
                return #ok();
            };
        };
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        switch (members.get(caller)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?mem) {
                members.delete(caller);
                return #ok();
            };
        };
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        switch (members.get(p)) {
            case (null) {
                return #err("Member does not exist");
            };
            case (?member) {
                return #ok(member);
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        return Iter.toArray(members.vals());
    };

    public query func numberOfMembers() : async Nat {
        return members.size();
    };

    /////////////////
    // PART #3 //
    ///////////////
    let ledger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);

    public query func tokenName() : async Text {
        return "Jiji Coin";
    };

    public query func tokenSymbol() : async Text {
        return "JIJ";
    };

    public func mint(owner : Principal, amount : Nat) : async Result<(), Text> {
        let balance = Option.get(ledger.get(owner), 0);
        ledger.put(owner, balance + amount);
        return #ok();
    };

    public func burn(owner : Principal, amount : Nat) : async Result<(), Text> {
        let balance = Option.get(ledger.get(owner), 0);
        if (balance < amount) {
            return #err("Insufficient balance to burn");
        };
        ledger.put(owner, balance - amount);
        return #ok();
    };

public func hasBalanceDecreased(user: Principal, to: Principal, expectedDecrease: Nat) : async Result<Bool, Text> {
    let previousBalance = Option.get(ledger.get(user), 0);

    // Ensure that expectedDecrease is not greater than previousBalance
    if (expectedDecrease > previousBalance) {
        return #err("Amount you want to transer is more than your balance");
    }else{
    let transferResult = await transfer(user, to, expectedDecrease);
    let decreasedAmount = previousBalance - expectedDecrease;
            return #ok( transferResult<= decreasedAmount);
};
};





    public shared ({ caller }) func transfer(from : Principal, to : Principal, amount : Nat) : async Nat {
        let balanceFrom = Option.get(ledger.get(from), 0);
        let balanceTo = Option.get(ledger.get(to), 0);
        let newBalance= balanceFrom - amount;
        ledger.put(from, newBalance);
        ledger.put(to, balanceTo + amount);
        return newBalance;
    };

    public query func balanceOf(owner : Principal) : async Nat {
        return (Option.get(ledger.get(owner), 0));
    };

    public query func totalSupply() : async Nat {
        var total = 0;
        for (balance in ledger.vals()) {
            total += balance;
        };
        return total;
    };

    //airdrop function
public func airdrop() : async Result<(), Text> {
    for (memberKey in members.keys()) {
        let currentBalance = Option.get(ledger.get(memberKey), 0);
        let newBalance = currentBalance + 100; // Assuming airdrop amount is 100
        ledger.put(memberKey, newBalance);
    };
    return #ok(());
};

    /////////////////
    // PART #4 //
    ///////////////
public type CreateProposalOk = Nat64;

public type CreateProposalErr = {
  #NotADAOMember;
  #NotEnoughTokens;
};

public type CreateProposalResult = Result<CreateProposalOk, CreateProposalErr>;

public type VoteOk = {
  #ProposalAccepted;
  #ProposalRefused;
  #ProposalOpen;
};

public type VoterErr = {
  #ProposalNotFound;
  #AlreadyVoted;
  #ProposalEnded;
  #NotEnoughTokens;
  #NotADAOMember; 
};

public type VoteResult = Result<VoteOk, VoterErr>;
    var nextProposalId :Nat64= 0;
    let proposals = HashMap.HashMap<Nat64, Proposal>(0, Nat64.equal, Nat64.toNat32);

    func _isMember(caller : Principal) : Bool {
        switch (members.get(caller)) {
            case (null) {
                return false;
            };
            case (?member) {
                return true;
            };
        };
    };

    public func _burn (caller : Principal, amount : Nat) : async () {
        let balance = Option.get(ledger.get(caller), 0);
        if (balance < amount) {
            assert(false);
        };
        ledger.put(caller, balance - amount);
    };

    public shared ({ caller }) func createProposal(content : ProposalContent) : async CreateProposalResult {
        if (not _isMember(caller)) {
            return #err(#NotADAOMember);
        };
        let balance = Option.get(ledger.get(caller), 0);
        if (balance < 10) {
            return #err(#NotEnoughTokens);
        };
        let  id = nextProposalId;
        let proposal : Proposal =  {
            id = id;
            content = content;
            creator = caller;
            created = Time.now();
            executed = null;
            votes = [];
            voteScore= 0;
            status = #Open;
           };
           proposals.put(nextProposalId, proposal);
           nextProposalId += 1;
          await  _burn(caller,1);
        return #ok((id));
        };
    


    public query func getProposal(proposalId : ProposalId) : async ?Proposal {
        return proposals.get(proposalId);
    };

    func _computeVote(oldScore: Int, newVote: Bool,caller:Principal) : Int {
        let voterBalance = Option.get(ledger.get(caller), 0);
         if (newVote) {
            return oldScore + voterBalance * 1;
        } else {
            return oldScore + voterBalance * -1;
        };
    };

    public shared ({ caller }) func voteProposal(proposalId : ProposalId, vote:Vote) : async VoteResult {
        if (not _isMember(caller)) {
            return #err(#NotADAOMember);
        };
        let balance = Option.get(ledger.get(caller), 0);
        if (balance < 10) {
            return #err(#NotEnoughTokens);
        };
        switch(proposals.get(proposalId)){
            case(null){
                return #err(#ProposalNotFound)
            };
            case(?proposal){
                if (proposal.status != #Open) {
                    return #err(#ProposalEnded);
                };
                for (vote in proposal.votes.vals()) {
                    if (vote.member == caller) {
                        return #err(#AlreadyVoted);
                    };
                };
                await _burn(caller, 1);
                let newVote = _computeVote(proposal.voteScore, vote.yesOrNo,caller);
                let voterPower = Option.get(ledger.get(caller), 0);
                //Prosposal is rejected
                if(newVote <=-10){
                    let newPropasal :Proposal = {
                        id = proposal.id;
                        content = proposal.content;
                        creator = proposal.creator;
                        created = proposal.created;
                        executed = proposal.executed;
                        votes = Array.append(proposal.votes, [{member = caller;votingPower = voterPower;yesOrNo = vote.yesOrNo;}]);
                        voteScore= newVote;
                        status = #Rejected;
                    };
                    proposals.put(proposalId, newPropasal);
                    return #ok(#ProposalRefused);
                    } else if
                //Prosposal is accepted
                    (newVote >=10){
                     await _executeProposal(proposal.content);
                    let newPropasal = {
                        id = proposal.id;
                        content = proposal.content;
                        creator = proposal.creator;
                        created = proposal.created;
                        executed = ?Time.now();
                        votes = Array.append(proposal.votes, [{member = caller;votingPower = voterPower;yesOrNo = vote.yesOrNo;}]);
                        voteScore= newVote;
                        status = #Accepted;
                    };
                    proposals.put(proposal.id, newPropasal);
                    return #ok(#ProposalAccepted);
                    }else{
                      let newPropasal = {
                        id = proposal.id;
                        content = proposal.content;
                        creator = proposal.creator;
                        created = proposal.created;
                        executed = proposal.executed;
                        votes = Array.append(proposal.votes, [{member = caller;votingPower = voterPower;yesOrNo = vote.yesOrNo;}]);
                        voteScore= newVote;
                        status = #Open;
                    };
                    proposals.put(proposalId, newPropasal);
                    return #ok(#ProposalOpen);
                    };
            };
                };

            };
    let nftChange: Types.NftInterface = actor("bkyz2-fmaaa-aaaaa-qaaaq-cai");
    func _executeProposal(content : ProposalContent) : async () {
        switch (content) {
            case (#ChangeManifesto(newManifesto)) {
                manifesto := newManifesto;
            };
            case (#AddGoal(newGoal)) {
                goals.add(newGoal);
            };
            case(#ChangeNFTLogo(newLogoData)){
               // Construct the LogoResult type
                        let newLogo: Types.LogoResult = {
                            logo_type = "preview_type"; // Set a default or appropriate logo_type
                            data = newLogoData;
                        };
                        await nftChange.updateLogo(newLogo);
        };
            case(#ChangeNFTName(newName)){
               await nftChange.updateName(newName);
            };
            case(#ChangeNFTSymbol(newSymbol)){
             await   nftChange.updateSymbol(newSymbol);
            };
        };
        return ();
    };

    public query func getAllProposals() : async [Proposal] {
        return Iter.toArray(proposals.vals());
    };
        };
    


