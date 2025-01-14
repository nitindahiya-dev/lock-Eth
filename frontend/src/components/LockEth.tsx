import { useState } from "react";
import { ethers } from "ethers";

const CONTRACT_ADDRESS = "0xB37B2D41E46cDc47b4d33EebBf027c9405453f64"; // Replace with your contract address
const ABI = [
  {
    inputs: [],
    name: "stake",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "getContractBalance",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "user", type: "address" }],
    name: "getStakeDetails",
    outputs: [
      { internalType: "uint256", name: "amount", type: "uint256" },
      { internalType: "uint256", name: "unlockTime", type: "uint256" },
    ],
    stateMutability: "view",
    type: "function",
  },
];

const LockEthApp = () => {
  const [stakeAmount, setStakeAmount] = useState("");
  // Explicitly define the type for stakeDetails
  const [stakeDetails, setStakeDetails] = useState<{
    amount: string;
    unlockTime: string;
  } | null>(null); // Type is either an object or null
  const [contractBalance, setContractBalance] = useState("");
  const [loading, setLoading] = useState(false);

  const getProviderAndSigner = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    return { provider, signer };
  };

  const handleStake = async () => {
    try {
      setLoading(true);
      const { signer } = await getProviderAndSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      const tx = await contract.stake({
        value: ethers.utils.parseEther(stakeAmount),
      });
      await tx.wait();

      alert("Stake successful!");
      setStakeAmount("");
    } catch (error) {
      console.error(error);
      alert("Stake failed.");
    } finally {
      setLoading(false);
    }
  };

  const handleWithdraw = async () => {
    try {
      setLoading(true);
      const { signer } = await getProviderAndSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      const tx = await contract.withdraw();
      await tx.wait();

      alert("Withdraw successful!");
    } catch (error) {
      console.error(error);
      alert("Withdraw failed.");
    } finally {
      setLoading(false);
    }
  };

  const fetchContractBalance = async () => {
    try {
      const { provider } = await getProviderAndSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, provider);

      const balance = await contract.getContractBalance();
      setContractBalance(ethers.utils.formatEther(balance) + " ETH");
    } catch (error) {
      console.error(error);
      alert("Failed to fetch contract balance.");
    }
  };

  const fetchStakeDetails = async () => {
    try {
      const { signer } = await getProviderAndSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      const address = await signer.getAddress();
      const [amount, unlockTime] = await contract.getStakeDetails(address);

      setStakeDetails({
        amount: ethers.utils.formatEther(amount) + " ETH",
        unlockTime: new Date(unlockTime.toNumber() * 1000).toLocaleString(),
      });
    } catch (error) {
      console.error(error);
      alert("Failed to fetch stake details.");
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <h1 className="text-2xl font-bold text-center mb-8">Ethereum Staking</h1>
      <div className="max-w-lg mx-auto bg-white p-6 rounded shadow">
        {/* Stake ETH */}
        <div className="mb-4">
          <input
            type="number"
            value={stakeAmount}
            onChange={(e) => setStakeAmount(e.target.value)}
            placeholder="Enter ETH amount"
            className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={handleStake}
            disabled={loading}
            className="mt-2 w-full px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:bg-gray-400"
          >
            {loading ? "Staking..." : "Stake ETH"}
          </button>
        </div>

        {/* Withdraw ETH */}
        <div className="mb-4">
          <button
            onClick={handleWithdraw}
            disabled={loading}
            className="w-full px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 disabled:bg-gray-400"
          >
            {loading ? "Withdrawing..." : "Withdraw ETH"}
          </button>
        </div>

        {/* Fetch Contract Balance */}
        <div className="mb-4">
          <button
            onClick={fetchContractBalance}
            disabled={loading}
            className="w-full px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400"
          >
            {loading ? "Fetching..." : "Get Contract Balance"}
          </button>
          {contractBalance && (
            <div className="mt-2 text-center text-gray-700">
              Contract Balance: {contractBalance}
            </div>
          )}
        </div>

        {/* Fetch Stake Details */}
        <div>
          <button
            onClick={fetchStakeDetails}
            disabled={loading}
            className="w-full px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600 disabled:bg-gray-400"
          >
            {loading ? "Fetching..." : "Get Stake Details"}
          </button>
          {stakeDetails && (
            <div className="mt-2 text-gray-700">
              <p>Amount: {stakeDetails.amount}</p>
              <p>Unlock Time: {stakeDetails.unlockTime}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default LockEthApp;
