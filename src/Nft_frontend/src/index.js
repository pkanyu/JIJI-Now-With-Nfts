import { Nft_backend } from "../../declarations/Nft_backend";
import { Dao } from "../../declarations/Dao";
import { Principal } from "@dfinity/principal";
document.querySelector("#formsubmission").addEventListener("submit", async function (event) {
  event.preventDefault()
  const name = document.getElementById("name").value;
  const age = parseInt(document.getElementById("age").value)
  const Member = {
    name,
    age
  }
  console.log(Member)
  try {
    await Dao.addMember(Member)
    console.log("sucessfully submitted")
  } catch (error) {
    console.log("error", error)
  }
})



//updating member function
document.querySelector("#updateForm").addEventListener("submit", async function (event) {
  event.preventDefault()
  const name = document.getElementById("newname").value;
  const age = parseInt(document.getElementById("newage").value)
  const Member = {
    name,
    age
  }
  console.log(Member)
  try {
    await Dao.updateMember(Member)
    console.log("sucessfully submitted")
  } catch (error) {
    console.log("error", error)
  }
})


const deleteButton = document.getElementById("deleteBtn")
deleteButton.addEventListener('click', async function () {
  await Dao.removeMember();
  console.log("user successfully removed")
})


const checkprofile = document.getElementById("identity");
checkprofile.addEventListener('submit', async function (event) {
  event.preventDefault()
  const user = document.getElementById("principal").value;
  const pricipal = Principal.fromText(user);
  try {
    const result = await Dao.getMember(pricipal);
    console.log(result)
  } catch (error) {
    console.log(error);
  }
})


//get allusers
async function allUsers() {
  const users = await Dao.getAllMembers()
  return console.log(users);
}

allUsers()

//part for the Dao code

const minting = document.getElementById("minting");
minting.addEventListener("submit", async function (event) {
  event.preventDefault()
  const usermintingprincipal = document.getElementById("mintingprincipal").value;
  const mintingAmount = parseInt(document.getElementById("amount").value);
  const principal = Principal.fromText(usermintingprincipal)
  try {
    await Dao.mint(principal, mintingAmount)
    console.log("successfully minted")

  }
  catch (error) {
    console.log("error", error);
  }
})



const burn = document.getElementById("burn")
burn.addEventListener("submit", async function (event) {
  event.preventDefault()
  const usermintingprincipal = document.getElementById("burnprincipal").value;
  const ownerAmount = parseInt(document.getElementById("owneramount").value);
  const principal = Principal.fromText(usermintingprincipal)
  try {
    const result = await Dao.burn(principal, ownerAmount)
    console.log(result)
  }
  catch (error) {
    console.log("error", error);
  }
})



//loading the user balance


const hasBalanceDecreased = document.getElementById("checkBalance")

hasBalanceDecreased.addEventListener("submit", async function (event) {
  event.preventDefault()
  const checkbalanceprincipal = document.getElementById("balanceprincipal").value;
  const ownerAmount = parseInt(document.getElementById("expectedAmountToDecrease").value);
  const principal = Principal.fromText(checkbalanceprincipal)
  try {
    const result = await Dao.hasBalanceDecreased(principal, principal, ownerAmount)
    console.log(result)
  }
  catch (error) {
    console.log("error", error);
  }
})

const transfer = document.getElementById("transferprocess");
transfer.addEventListener("submit", async function (event) {
  event.preventDefault()
  const checkbalanceprincipal = document.getElementById("transferprincipal").value;
  const amountTransfer = parseInt(document.getElementById("AmountToTransfer").value);
  const principal = Principal.fromText(checkbalanceprincipal)
  try {
    const result = await Dao.transfer(principal, principal, amountTransfer)
    console.log(result)
  }
  catch (error) {
    console.log("error", error);
  }
})


//const query user balace

const askforbalance = document.getElementById("checkuserbalance")

askforbalance.addEventListener("submit", async function (event) {
  event.preventDefault();
  const userPrincipal = document.getElementById("checkbalanceprincipal").value;
  const principalforbalance = Principal.fromText(userPrincipal);
  try {
    const result = await Dao.balanceOf(principalforbalance)
    console.log(result)
  }
  catch (error) {
    console.log("error", error);
  }
})


async function airdrop() {
  const result = await Dao.airdrop()
  return console.log(result)
}

airdrop()



//part44
const ismember = document.getElementById("ismember")


ismember.addEventListener("submit", async function (event) {
  event.preventDefault()
  try {
    const principal = document.getElemenBy("memberprincipal").value;
    const principalId = Principal.fromText(principal);
    const result = await Dao._isMember(principalId);
    return result; // Either true or false
  } catch (error) {
    console.error("Error checking membership:", error);
    // Handle error gracefully (e.g., display error message to user)
    return undefined; // Or default value if appropriate
  }
})
const isBurn = document.getElementById("isBurn")
isBurn.addEventListener("submit", async function (event) {
  event.preventDefault()
  try {
    const principal = document.getElemenBy("isbunprincipal").value;
    const principalId = Principal.fromText(principal);
    const result = await Dao._burn(principalId);
    return result; // Either true or false
  } catch (error) {
    console.error("Error checking membership:", error);
    // Handle error gracefully (e.g., display error message to user)
    return undefined; // Or default value if appropriate
  }
})


const submitProposal = document.getElementById("submitProposalForm");

submitProposal.addEventListener("submit", async function (e) {
  e.preventDefault();
  try {
    const proposal = document.getElementById("propasalCategory").value;
    await Dao.shared(proposal)
    console.log("succesfully submitted your proposal")
  } catch (error) {
    console.error("error checking propasol", error)
  }
})


const voteproposalSubmission = document.getElementById("voteProp")



const userSubmission = document.getElementById("userbalanceSubmission");
userSubmission.addEventListener("submit", async function (event) {
  event.preventDefault();
  try {
    const token = document.getElementById("tokenSubmitted").value;
    console.log("token submitted", token)
    const tokenId = BigInt(token)
    console.log("token id", tokenId)
    const owner = await Nft_backend.ownerOfDip721(tokenId);
    console.log("success fully submitted")
    document.getElementById("ownerDisplay").innerText = `Owner: ${owner}`;
  }
  catch (error) {
    console.log("error", error)
  }
})





// Initialize the NFT backend with custodian and initial configuration
document.getElementById("initButton").addEventListener("click", async () => {
  const custodianText = document.getElementById("custodian").value;
  try {
    const custodian = Principal.fromText(custodianText);
    console.log("Custodian Principal ID: ", custodian);
    const initialConfig = {
      name: document.getElementById("name").value,
      symbol: document.getElementById("symbol").value,
      maxLimit: parseInt(document.getElementById("maxLimit").value, 10),
      logo: {
        logo_type: document.getElementById("logoType").value,
        data: document.getElementById("logoData").value,
      },
    };
    const response = await Nft_backend.initialize(custodian, initialConfig);
    console.log(response);
    // Check the response and display an alert accordingly
    if (response === "Initialized successfully!") {
      alert("Initialization successful!");
    } else if (response === "Already initialized!") {
      alert("The system has already been initialized.");
    } else {
      alert("Initialization failed: " + response);
    }
  } catch (error) {
    console.error("Error converting principal:", error);
    alert("Initialization error: " + error.message);
  }
});



// Get the balance of NFTs for a specific user

const balanceQuery = document.getElementById("balanceQuery");

balanceQuery.addEventListener("submit", async function (event) {
  event.preventDefault()
  try {
    const userPrincipal = document.getElementById("userprincipal").value;
    const principal = Principal.fromText(userPrincipal);
    const balance = await Nft_backend.balanceOfDip721(principal);
    console.log(balance);
  } catch (error) {
    console.log("error", error)
  }
})

// Mint a new NFT
document.getElementById("mintButton").addEventListener("click", async () => {
  const recipientText = document.getElementById("recipientAddress").value;
  const metadataFileInput = document.getElementById("metadataImage");

  if (metadataFileInput.files.length === 0) {
    alert("Please select an image file to mint.");
    return;
  }

  const imageFile = metadataFileInput.files[0];
  const reader = new FileReader();

  reader.onloadend = async function () {
    try {
      const recipient = Principal.fromText(recipientText);
      const arrayBuffer = reader.result;
      const metadataBlob = new Uint8Array(arrayBuffer);

      const receipt = await Nft_backend.mintDip721(recipient, metadataBlob);
      console.log(receipt);

      // Handle the receipt response here
      if (receipt.Ok) {
        alert("Minting successful! Transaction ID: " + receipt.Ok.id);
      } else {
        alert("Minting failed: " + JSON.stringify(receipt.Err));
      }
    } catch (error) {
      console.error("Error during minting:", error);
      alert("Minting error: " + error.message);
    }
  };

  reader.onerror = function (error) {
    console.error("Error reading file:", error);
    alert("Error reading file: " + error.message);
  };

  reader.readAsArrayBuffer(imageFile);
});


// Transfer an NFT

const tranferNft = document.getElementById("transferprocess");

tranferNft.addEventListener("submit", async function (event) {
  event.preventDefault()
  const principalID = document.getElementById("fromAddress").value;
  const receiverPrincipalID = document.getElementById("toAddress").value;
  const tokenId = document.getElementById("tokenId").value;
  const amount = document.getElementById("amount").value;
  try {
    const senderPrincipalId = Principal.fromText(principalID);
    const receiverPrincipalId = Principal.fromText(receiverPrincipalID)
    const senderTokenId = BigInt(tokenId);
    console.log(senderTokenId)
    await Nft_backend.safeTransferFromDip721(senderPrincipalId, receiverPrincipalId, senderTokenId, amount)
    console.log("success fully submitted")
  } catch (error) {
    console.log("tranfer error", error)
  }
})

// Additional functionalities (e.g., getTotalSupply, getMetadataOfNFT) can be added similarly.
document
  .getElementById("totalSupplyButton")
  .addEventListener("click", async () => {
    const totalSupply = await Nft_backend.totalSupplyDip721();
    document.getElementById(
      "totalSupplyDisplay"
    ).innerText = `Total Supply: ${totalSupply}`;
  });

// Get metadata of a specific NFT
document
  .getElementById("metadataButton")
  .addEventListener("click", async () => {
    const token = document.getElementById("tokenIdMetadata").value;
    const tokenId = BigInt(token)
    console.log(tokenId)
    const metadata = await Nft_backend.getMetadataDip721(tokenId);
    document.getElementById(
      "metadataDisplay"
    ).innerText = `Metadata: ${JSON.stringify(metadata)}`;
  });
document
  .getElementById("userMetadataButton")
  .addEventListener("click", async () => {
    const user = document.getElementById("userAddressMetadata").value;
    const metadata = await Nft_backend.getMetadataForUserDip721(user);
    document.getElementById(
      "userMetadataDisplay"
    ).innerText = `User Metadata: ${JSON.stringify(metadata)}`;
  });

// Get token IDs for a user's NFTs
document
  .getElementById("userTokenIdsButton")
  .addEventListener("click", async () => {
    const user = document.getElementById("userAddressTokenIds").value;
    const tokenIds = await Nft_backend.getTokenIdsForUserDip721(user);
    document.getElementById(
      "userTokenIdsDisplay"
    ).innerText = `User Token IDs: ${tokenIds.join(", ")}`;
  });