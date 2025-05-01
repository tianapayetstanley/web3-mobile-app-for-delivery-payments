// src/App.jsx
import React, { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { CardTitle, CardHeader, CardContent, Card } from "@/components/ui/card";
import contractAbi from "@/assets/GeoLogix.json";//changed form - import contractJson from "@/assets/GeoLogix.json";
import { ethers } from "ethers";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function App() {
  const navigate = useNavigate();
  const [walletAddress, setWalletAddress] = useState(null);
  const [contract, setContract]           = useState(null);
  const [stateType, setStateType]         = useState("");
  const [isLoading, setIsLoading]         = useState(false);

  const connectWallet = async () => {
    if (!window.ethereum) {
      toast.error("Please install MetaMask!");
      return;
    }
  
    try {
      // Force the accounts-permissions UI:
      console.log("▶️ Requesting wallet_requestPermissions…");
      const perms = await window.ethereum.request({
        method: "wallet_requestPermissions",
        params: [{ eth_accounts: {} }],
      });
      console.log("✅ Permissions response:", perms);
  
      // Now ask for the accounts themselves:
      console.log("▶️ Requesting eth_requestAccounts…");
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log("✅ Accounts returned:", accounts);
  
      if (!accounts || accounts.length === 0) {
        throw new Error("No accounts selected");
      }
  
      setWalletAddress(accounts[0]);
      toast.success("Connected: " + accounts[0]);
  
      // …then your provider / signer / contract setup…
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer   = provider.getSigner();
      const geo      = new ethers.Contract(contractAddress, contractAbi, signer);
  
    } catch (err) {
      console.error("🔴 connectWallet error:", err);
      // show the actual error message if it's our “No accounts” throw,
      // or MetaMask’s own error code 4001 (user rejected)
      if (err.code === 4001) {
        toast.error("User rejected the request");
      } else {
        toast.error(err.message || "Connection failed");
      }
    }
  };
  

  const handleReset = async () => { /* ... */ };
  const handleComplete = async () => { /* ... */ };

  return (
    <div className="min-h-screen bg-gradient-to-r from-green-400 to-blue-500 text-white">
      {/* HEADER */}
      <header className="flex items-center justify-between p-4">
        <h1 className="text-2xl font-bold">GeoLogix DApp</h1>
        <nav className="space-x-4">
          <Link to="/about" className="hover:underline">
            About
          </Link>
          <a
            href="https://github.com/abdimussa87/web3-mobile-app-for-delivery-payments"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:underline"
          >
            GitHub
          </a>
          {!walletAddress && (
            <Button onClick={connectWallet} variant="default">
              Connect Wallet
            </Button>
          )}
          {walletAddress && (
            <span className="font-mono text-sm">
              {walletAddress.slice(0, 6)}…{walletAddress.slice(-4)}
            </span>
          )}
        </nav>
      </header>

      {/* MAIN CARD */}
      <main className="p-6 max-w-4xl mx-auto bg-white rounded-md text-black">
        <Card>
          <CardHeader className="flex justify-between items-center">
            <CardTitle>Admin Dashboard</CardTitle>
            <div className="flex space-x-2">
              <Button variant="outline" onClick={() => navigate("/addCheckpoint")}>
                Add a checkpoint
              </Button>
              <Button
                variant="destructive"
                onClick={async () => {
                  setIsLoading(true);
                  /* await handleResetEverything() */;
                  setIsLoading(false);
                }}
              >
                {isLoading ? "Resetting..." : "Reset everything"}
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="mb-4">
              <div className="font-semibold">{stateType}</div>
              <div className="text-sm text-gray-600">
                {stateType === "Created"
                  ? "Contract has been created"
                  : stateType === "In-Transit"
                  ? "Your package is on the way"
                  : "Your package has been delivered"}
              </div>
            </div>
            {/* Render your checkpoints/compliances tables here */}
          </CardContent>
        </Card>

        <div className="mt-6 flex justify-center">
          <Button
            variant="default"
            className="bg-green-600"
            onClick={async () => {
              setIsLoading(true);
              /* await handleCompleteDelivery() */;
              setIsLoading(false);
            }}
          >
            {isLoading ? "Completing..." : "Complete Delivery"}
          </Button>
        </div>
      </main>

      <ToastContainer position="top-right" />
    </div>
  );
}