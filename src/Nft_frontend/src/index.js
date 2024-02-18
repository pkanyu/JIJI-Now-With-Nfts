import { Nft_backend } from "../../declarations/Nft_backend";
import { AuthClient } from "@dfinity/auth-client";
import { Dao } from "../../declarations/Dao";
import { Principal } from "@dfinity/principal";
import { Actor, HttpAgent } from "@dfinity/agent";


const initializeAuth = async () => {
  const authClient = await AuthClient.create();
  const isLocalNetwork = process.env.DFX_NETWORK === "local";
  const identityProviderUrl = isLocalNetwork
    ? `http://127.0.0.1:4943/?canisterId=${process.env.CANISTER_ID_INTERNET_IDENTITY}`
    : "https://identity.ic0.app/";

  const loginButton = document.getElementById("login");

  const login = async () => {
    try {
      await authClient.login({
        identityProvider: identityProviderUrl,
        maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
        onSuccess: async () => {
          loginButton.innerText = "Logout";
          loginButton.removeEventListener("click", login);
          loginButton.addEventListener("click", logout);
        },
        onError: (err) => {
          console.error(err);
        },
      });
    } catch (err) {
      console.error('Error during login:', err);
    }
  };

  const logout = async () => {
    try {
      await authClient.logout();
      loginButton.innerText = "Login";
      loginButton.removeEventListener("click", logout);
      loginButton.addEventListener("click", login);
    } catch (err) {
      console.error('Error during logout:', err);
    }
  };

  loginButton.addEventListener("click", login);

  // Check if user is already logged in
  authClient.isAuthenticated().then((isAuthenticated) => {
    if (isAuthenticated) {
      loginButton.innerText = "Logout";
      loginButton.removeEventListener("click", login);
      loginButton.addEventListener("click", logout);
    }
  });
};

initializeAuth();
document
  .querySelector("#formsubmission")
  .addEventListener("submit", async function (event) {
    event.preventDefault();
    const name = document.getElementById("name").value;
    const age = parseInt(document.getElementById("age").value);
    const Member = {
      name,
      age,
    };
    console.log(Member);
    try {
      await Dao.addMember(Member);
      alert("sucessfully submitted. You are now a member");
    } catch (error) {
      console.log("error", error);
    }
  });


  //Initialize the collection
  
// Initialize the NFT backend with custodian and initial configuration
document.getElementById("initButton").addEventListener("click", async () => {
  try {
    const initialConfig = {
      logo: {
        logo_type: document.getElementById("logoType").value,
        data: document.getElementById("logoData").value,
      },
      name: document.getElementById("name").value,
      symbol: document.getElementById("symbol").value,
      maxLimit: 50,
    };
    const response = await Nft_backend.initialize(initialConfig);
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


//Mint Nft
// Mint a new NFT
document.getElementById("mintButton").addEventListener("click", async () => {
  const metaDesc = document.getElementById("metadataDesc").value;
  const metaPurposeSelect = document.getElementById("metadataPurpose");
  const metaPurpose =
    metaPurposeSelect.options[metaPurposeSelect.selectedIndex].value;
  const metadataFileInput = document.getElementById("metadataImage");

  if (metadataFileInput.files.length === 0) {
    alert("Please select an image file to mint.");
    return;
  }

  const imageFile = metadataFileInput.files[0];
  const reader = new FileReader();

  reader.onloadend = async function () {
    try {
      const arrayBuffer = reader.result;
      const metadataBlob = new Uint8Array(arrayBuffer);

      // Construct the metadata object based on the backend's expected structure
      const metadataDesc = {
        purpose: { [metaPurpose]: null }, // Use the variant tag without value
        des_val_data: metaDesc, // Ensure this is a string
        image: metadataBlob, // Pass the blob here
      };

      // Call the backend's mintDip721 function with the constructed metadata object
      const receipt = await Nft_backend.mintDip721(metadataDesc);
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




document.addEventListener("DOMContentLoaded", (event) => {
  //Transfer an Nft
  document
    .getElementById("transferButton")
    .addEventListener("click", async () => {
      try {
        const fromprincipal = document.getElementById("fromAddress").value;
        const toprincipal = document.getElementById("toAddress").value;
        const tokenId = BigInt(document.getElementById("tokenId").value);

        const frmPrincipal = Principal.fromText(fromprincipal);
        const tPrincipal = Principal.fromText(toprincipal);
        const receipt = await Nft_backend.safeTransferFromDip721(
          frmPrincipal,
          tPrincipal,
          tokenId
        );
        console.log(receipt);
        // Check the response and display an alert accordingly
        if ("Ok" in receipt && receipt.Ok) {
          alert("You have successfully transferred  an Nft  to " + toPrincipal);
        } else if ("Err" in receipt) {
          alert(
            "The Nft amount you want to transfer is greater than your balance"
          );
        } else {
          alert(
            "The Nft amount you want to transfer is greater than your balance"
          );
        }
      } catch (error) {
        console.error("Error during sending:", error);
        alert("Sending error: " + error.message);
      }
    });
});




//Buy an Nft


const hasBalanceDecreased = document.getElementById("checkBalance")

hasBalanceDecreased.addEventListener("submit", async function (event) {
  event.preventDefault()
  const addressFrom = document.getElementById("Addressfrom").value;
  const addressTo = document.getElementById("Addressto").value;
  const ownerAmount = parseInt(document.getElementById("expectedAmountToDecrease").value);
  const principalFrom = Principal.fromText(addressFrom);
  const principalTo = Principal.fromText(addressTo);
  try {
    const receipt = await Dao.hasBalanceDecreased(
      principalFrom,
      principalTo,
      ownerAmount
    );
    console.log("Receipt:", receipt);

 if ("Ok" in receipt && receipt.Ok) {
   alert(
     "You have successfully transferred JiJi coins of amount " + ownerAmount
   );
 } else if ("Err" in receipt) {
   alert("The amount you want to transfer is greater than your balance");
 } else {
   alert("The amount you want to transfer is greater than your balance");
 }

  } catch (error) {
    console.error("Error during transfer:", error);
    alert("Transfer error: " + error.message);
  }
})



// Function to handle creating a proposal
async function createProposal(content) {
    try {
        const createProposalResult = await Dao.createProposal({ content });
        if ('ok' in createProposalResult) {
            console.log('Proposal created successfully with ID:', createProposalResult.ok);
            // Handle successful creation here (e.g., update UI)
        } else {
            console.error('Error creating proposal:', createProposalResult.err);
            // Handle error here (e.g., show error message to user)
        }
    } catch (error) {
        console.error('Exception while creating proposal:', error);
        // Handle exception here (e.g., show error message to user)
    }
}

// Example usage
document.getElementById('createProposalForm').addEventListener('submit', function(event) {
    event.preventDefault();
    const content = document.getElementById('content').value;
    createProposal(content);
});




  