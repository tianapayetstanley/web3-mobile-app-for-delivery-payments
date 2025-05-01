import React, { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardHeader,
  CardTitle,
  CardContent,
} from "@/components/ui/card";
import { Link, useNavigate } from "react-router-dom";
import contractAbi from "@/assets/GeoLogix.json";
import { ethers } from "ethers";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function App() {
  const navigate = useNavigate();

  // MetaMask wallet state
  const [walletAddress, setWalletAddress] = useState(null);
  const [stateType, setStateType] = useState(); // 'Created' | 'In-Transit' | 'Delivered'
  const [isLoading, setIsLoading] = useState(false);

  // Contract addresses
  const contractAddress = "0x3D07934564C66C0f619041E6e16466796328d1";
  const companyAddress = "0x86Af90deC474618DFcB911e2617B74773c3b1b39";

  // Connect to MetaMask
  const connectWallet = async () => {
    if (!window.ethereum) {
      return toast.error("MetaMask not installed.");
    }
    try {
      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setWalletAddress(accounts[0]);
      toast.success("Connected to MetaMask!");
      await fetchState(); // refresh on-chain state once connected
    } catch (err) {
      console.error(err);
      toast.error("Failed to connect wallet.");
    }
  };

  // Read on-chain delivery state
  const fetchState = async () => {
    if (!walletAddress) return;
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(
        contractAddress,
        contractAbi,
        provider
      );
      const onChainState = await contract.state(); // returns 0/1/2
      const labels = ["Created", "In-Transit", "Delivered"];
      setStateType(labels[onChainState]);
    } catch (err) {
      console.error("state fetch failed", err);
      toast.error("Could not read state.");
    }
  };

  // Reset everything on-chain
  const handleResetEverything = async () => {
    if (!walletAddress) return toast.error("Connect wallet first");
    setIsLoading(true);
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        contractAddress,
        contractAbi,
        signer
      );
      const tx = await contract.resetEverything();
      await tx.wait();
      toast.success("Reset successful");
      fetchState();
    } catch (err) {
      console.error(err);
      toast.error("Reset failed");
    } finally {
      setIsLoading(false);
    }
  };

  // Complete delivery on-chain
  const handleCompleteDelivery = async () => {
    if (!walletAddress) return toast.error("Connect wallet first");
    setIsLoading(true);
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        contractAddress,
        contractAbi,
        signer
      );
      const tx = await contract.complete({ value: 0 }); // payable if needed
      await tx.wait();
      toast.success("Delivery marked complete");
      fetchState();
    } catch (err) {
      console.error(err);
      toast.error("Complete delivery failed");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (walletAddress) {
      fetchState();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [walletAddress]);

  return (
    <div className="min-h-screen p-6 bg-gradient-to-r from-green-400 to-blue-500">
      <nav className="flex justify-between items-center mb-6">
        <h1 className="text-white text-xl font-bold">GeoLogix DApp</h1>
        <div className="space-x-4">
          <Link className="text-white hover:underline" to="/about">
            About
          </Link>
          <a
            className="text-white hover:underline"
            href="https://github.com/abdimussa87/web3-mobile-app-for-delivery-payments"
            target="_blank"
            rel="noopener noreferrer"
          >
            GitHub
          </a>
          {!walletAddress && (
            <Button variant="default" onClick={connectWallet}>
              Connect Wallet
            </Button>
          )}
          {walletAddress && (
            <span className="text-white font-mono">
              {walletAddress.slice(0, 6)}…{walletAddress.slice(-4)}
            </span>
          )}
        </div>
      </nav>

      <div className="max-w-4xl mx-auto bg-white rounded-lg shadow p-6">
        <Card>
          <CardHeader className="flex justify-between items-center">
            <CardTitle>Admin Dashboard</CardTitle>
            <div className="space-x-2">
              <Button variant="outline" onClick={() => navigate("/addCheckpoint")}>
                Add a checkpoint
              </Button>
              <Button variant="destructive" onClick={handleResetEverything}>
                {isLoading ? "Resetting…" : "Reset everything"}
              </Button>
            </div>
          </CardHeader>

          <CardContent>
            {stateType === "Created" && (
              <div>
                <div className="font-semibold">Contract Created</div>
                <div className="text-gray-600">Contract has been created</div>
              </div>
            )}
            {stateType === "In-Transit" && (
              <div>
                <div className="font-semibold">In Transit</div>
                <div className="text-gray-600">Your package is on the way</div>
              </div>
            )}
            {stateType === "Delivered" && (
              <div>
                <div className="font-semibold">Delivered</div>
                <div className="text-gray-600">Your package has been delivered</div>
              </div>
            )}
            {!stateType && <div>Loading…</div>}
          </CardContent>
        </Card>

        <div className="mt-6 text-center">
          <Button
            variant="solid"
            className="bg-green-600"
            onClick={handleCompleteDelivery}
            disabled={stateType === "Delivered" || isLoading}
          >
            {isLoading ? "Processing…" : "Complete Delivery"}
          </Button>
        </div>
      </div>

      <ToastContainer position="top-right" />
    </div>
  );
}
