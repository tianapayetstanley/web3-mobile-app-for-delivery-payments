import React, { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { CardTitle, CardHeader, CardContent, Card } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";
import contractAbi from "@/assets/GeoLogix.json";
import { ethers } from "ethers";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function App() {
  const navigate = useNavigate();

  // [CN6035 EDIT] MetaMask wallet connection state
  const [walletAddress, setWalletAddress] = useState(null);
  const [checkpoints, setCheckpoints] = useState([]);
  const [compliances, setCompliances] = useState([]);
  const [nonCompliances, setNonCompliances] = useState([]);
  const [stateType, setStateType] = useState();
  const [isLoading, setIsLoading] = useState(false);

  // [CN6035 EDIT] Connect Wallet button logic
  const connectWallet = async () => {
    if (typeof window.ethereum !== "undefined") {
      try {
        const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
        setWalletAddress(accounts[0]);
        toast.success("Connected to MetaMask!");
      } catch (err) {
        console.error(err);
        toast.error("Failed to connect wallet.");
      }
    } else {
      toast.error("MetaMask not installed.");
    }
  };

  // existing data‐fetching functions (fetchCheckpoints, fetchCompliances, fetchNonCompliances, fetchState, etc.)
  const fetchCheckpoints = async () => { /* ... */ };
  const fetchCompliances = async () => { /* ... */ };
  const fetchNonCompliances = async () => { /* ... */ };
  const fetchState = async () => { /* ... */ };
  const handleResetEverything = async (e) => { /* ... */ };
  const handleCompleteDelivery = async (e) => { /* ... */ };

  useEffect(() => {
    fetchCheckpoints();
    fetchState();
    fetchCompliances();
    fetchNonCompliances();
  }, []);
  
  // At the top, under your useState declarations:    whar???
const contractAddress = "0x3D07934564C66C0f619041E6e16466796328d1"; 
const companyAddress  = "0x86Af90deC474618DFcB911e2617B74773c3b1b39";  // your deployer address


  return (
    <div className="min-h-screen p-20 text-white bg-gradient-to-r from-green-400 to-blue-500">
      <div className="max-w-4xl m-auto bg-white rounded-md">

        {/* [CN6035 EDIT] Connect Wallet Button */}
        {!walletAddress && (
          <div className="flex justify-end p-4">
            <Button variant="default" onClick={connectWallet}>
              Connect Wallet
            </Button>
          </div>
        )}

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <CardTitle>Admin Dashboard</CardTitle>
            <div className="flex items-center gap-2">
              <Button variant="outline" onClick={() => navigate('/addCheckpoint')}>Add a checkpoint</Button>
              <Button variant="destructive" onClick={handleResetEverything}>
                {isLoading ? 'Resetting...' : 'Reset everything'}
              </Button>
            </div>
          </CardHeader>

          <CardContent className="flex items-center gap-4">
            {/* shipment status content */}
            <div>
              <div className="font-semibold">{stateType}</div>
              <div className="text-sm text-gray-500">
                {stateType === 'Created'
                  ? 'Contract has been created'
                  : stateType === 'In-Transit'
                  ? 'Your package is on the way'
                  : 'Your package has been delivered'}
              </div>
            </div>
          </CardContent>

          {/* checkpoints, compliances, non‐compliances sections... */}

        </Card>

        <div className="flex justify-center mt-10">
          <Button onClick={handleCompleteDelivery} className="bg-green-600">
            {isLoading ? 'Completing...' : 'Complete Delivery'}
          </Button>
        </div>
      </div>

      <ToastContainer />
    </div>
  );
}
