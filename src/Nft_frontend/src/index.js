import { Nft_backend } from "../../declarations/Nft_backend";
import { Principal } from "@dfinity/principal";


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
document.getElementById("balanceButton").addEventListener("click", async () => {
  const user = document.getElementById("userAddress").value;
  const balance = await Nft_backend.balanceOfDip721(user);
  document.getElementById("balanceDisplay").innerText = `Balance: ${balance}`;
});

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

    reader.onloadend = async function() {
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

    reader.onerror = function(error) {
        console.error("Error reading file:", error);
        alert("Error reading file: " + error.message);
    };

    reader.readAsArrayBuffer(imageFile);
});


// Transfer an NFT
document
  .getElementById("transferButton")
  .addEventListener("click", async () => {
    const from = document.getElementById("fromAddress").value;
    const to = document.getElementById("toAddress").value;
    const tokenId = document.getElementById("tokenId").value;
    const receipt = await Nft_backend.transferFromDip721(from, to, tokenId);
    console.log(receipt);
  });

// Get the owner of a specific NFT
document.getElementById("ownerButton").addEventListener("click", async () => {
  const tokenId = document.getElementById("tokenId").value;
  const owner = await Nft_backend.ownerOfDip721(tokenId);
  document.getElementById("ownerDisplay").innerText = `Owner: ${owner}`;
});

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
    const tokenId = document.getElementById("tokenIdMetadata").value;
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