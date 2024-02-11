import { Button } from "@/components/ui/button";
import { CardTitle, CardHeader, CardContent, Card } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";
import contractAbi from "../src/assets/GeoLogix.json";
import { ethers } from "ethers";
import { useEffect, useState } from "react";

import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

export default function App() {
  const navigate = useNavigate();
  const [checkpoints, setCheckpoints] = useState([]);
  const [compliances, setCompliances] = useState([]);
  const [nonCompliances, setNonCompliances] = useState([]);
  const [stateType, setStateType] = useState();
  const [isLoading, setIsLoading] = useState(false);

  const fetchCheckpoints = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    // const signer = await provider.getSigner();
    const contract = new ethers.Contract(
      "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
      contractAbi,
      provider
    );

    let checkpointIds = await contract.getCheckpointIds();
    const checkpointIdsArray = Object.values(checkpointIds);

    console.log("Checkpoint IDs:", checkpointIdsArray);

    for (let i = 0; i < checkpointIds.length; i++) {
      const checkpointId = checkpointIdsArray[i];
      var result = await contract.checkpointsMap(checkpointId);
      var temp = {
        id: Number(result[0]),
        lat: Number(result[1]) / 100000,
        lng: Number(result[2]) / 100000,
        distance: Number(result[3]),
        timestamp: new Date(Number(result[4])).toISOString().slice(0, 16),
      };
      setCheckpoints((prevList) => [...prevList, temp]);
    }

    console.log(checkpoints);
  };

  const fetchCompliances = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(
      "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
      contractAbi,
      provider
    );

    let complianceIds = await contract.getComplianceIds();
    const complianceIdsArray = Object.values(complianceIds);

    console.log("Compliance IDs:", complianceIdsArray);

    for (let i = 0; i < complianceIdsArray.length; i++) {
      const complianceId = complianceIdsArray[i];
      var result = await contract.compliancesMap(complianceId);
      var temp = {
        id: Number(result[0]),
        lat: Number(result[1]) / 100000,
        lng: Number(result[2]) / 100000,
        distance: Number(result[3]),
        timestamp: Number(result[4]),
      };
      setCompliances((prevList) => [...prevList, temp]);
    }
  };
  const fetchNonCompliances = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(
      "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
      contractAbi,
      provider
    );

    let nonComplianceIds = await contract.getNonComplianceIds();
    const nonComplianceIdsArray = Object.values(nonComplianceIds);

    console.log("Non Compliance IDs:", nonComplianceIdsArray);

    for (let i = 0; i < nonComplianceIdsArray.length; i++) {
      const nonComplianceId = nonComplianceIdsArray[i];
      var result = await contract.nonCompliancesMap(nonComplianceId);
      var temp = {
        id: Number(result[0]),
        lat: Number(result[1]) / 100000,
        lng: Number(result[2]) / 100000,
        distance: Number(result[3]),
        timestamp: Number(result[4]),
      };
      setNonCompliances((prevList) => [...prevList, temp]);
    }
  };

  const fetchState = async () => {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(
      "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
      contractAbi,
      provider
    );
    let state = await contract.state();
    state = Number(state);
    if (state == 0) {
      setStateType("Created");
    } else if (state == 1) {
      setStateType("In-Transit");
    } else {
      setStateType("Completed");
    }
  };

  const handleResetEverything = async (e) => {
    e.preventDefault();
    try {
      setIsLoading(true);

      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();

      const contract = new ethers.Contract(
        "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
        contractAbi,
        signer
      );

      let addCheckpointTx = await contract.resetEverything();
      const receipt = await addCheckpointTx.wait();

      // Log the transaction receipt
      console.log("Transaction Receipt:", receipt);

      toast("Reset everything successfully!");
      setIsLoading(false);
    } catch (err) {
      toast(err.message);
      console.log(err.message);
      setIsLoading(false);
    }
  };
  const handleCompleteDelivery = async (e) => {
    e.preventDefault();
    try {
      setIsLoading(true);

      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();

      const contract = new ethers.Contract(
        "0x4A2daBF66f5f6ec37e6c2598722Ad39Dee6762D0",
        contractAbi,
        signer
      );

      let addCheckpointTx = await contract.complete();
      const receipt = await addCheckpointTx.wait();

      // Log the transaction receipt
      console.log("Transaction Receipt:", receipt);

      toast("Delivery completed successfully! Funds have been transferred");
      setIsLoading(false);
    } catch (err) {
      toast(err.message);
      console.log(err.message);
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchCheckpoints();
    fetchState();
    fetchCompliances();
    fetchNonCompliances();
  }, []);

  return (
    <div className="min-h-screen p-20 text-white bg-gradient-to-r from-green-400 to-blue-500">
      <div className="max-w-4xl m-auto bg-white rounded-md">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0">
            <CardTitle>Admin Dashboard</CardTitle>
            <div className="flex items-center gap-2">
              <Button
                className="rounded-full"
                variant="outline"
                onClick={() => {
                  return navigate("/addCheckpoint");
                }}
              >
                <PlusIcon className="w-4 h-4 mr-2" />
                Add a checkpoint
              </Button>
              <Button
                className="rounded-full"
                variant="destructive"
                onClick={handleResetEverything}
              >
                <RefreshCwIcon className="w-4 h-4 mr-2" />
                {isLoading ? "Resetting" : "Reset everything"}
              </Button>
            </div>
          </CardHeader>
          <CardContent className="flex items-center gap-4">
            <TruckIcon className="w-10 h-10 " />
            <div className="flex flex-col space-y-1">
              <div className="font-semibold">{stateType}</div>
              <div className="text-sm text-gray-500 dark:text-gray-400">
                {stateType == "Created"
                  ? "Contract has been created"
                  : stateType == "In-Transit"
                  ? "Your package is on the way"
                  : "Your package has been delivered"}
              </div>
            </div>
          </CardContent>
          <div className="w-full border-t"></div>
          <CardHeader>
            <CardTitle>Checkpoints</CardTitle>
          </CardHeader>
          <CardContent>
            {checkpoints.map((checkpoint) => {
              return (
                <div
                  key={checkpoint.id}
                  className="flex items-center gap-2 p-4 m-3 border rounded-sm border-sky-500"
                >
                  <MapPinIcon className="w-4 h-4" />
                  <div className="flex ">
                    <div>
                      <p>
                        {" "}
                        <span className="font-semibold"> Latitude:</span>{" "}
                        {checkpoint.lat}
                      </p>
                      <p>
                        <span className="font-semibold">Longitude:</span>{" "}
                        {checkpoint.lng}
                      </p>
                    </div>
                    <div className="ml-80">
                      <p>
                        <span className="font-semibold">Distance:</span>{" "}
                        {checkpoint.distance}
                      </p>
                      <p>
                        <span className="font-semibold">Timestamp:</span>{" "}
                        {checkpoint.timestamp}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </CardContent>
          <div className="w-full border-t"></div>

          <CardHeader>
            <CardTitle>Compliances</CardTitle>
          </CardHeader>

          <CardContent>
            {compliances.length == 0
              ? "There are no compliances."
              : compliances.map((compliance) => {
                  return (
                    <div key={compliance.id} className="grid gap-2">
                      <div className="flex items-center gap-2">
                        <CheckCircleIcon className="w-4 h-4 text-white bg-green-400 rounded-xl" />
                        <div>Checkpoint {compliance.id}</div>
                        <div className="ml-auto text-sm text-gray-500 dark:text-gray-400">
                          Cleared
                        </div>
                      </div>
                    </div>
                  );
                })}
          </CardContent>
          <div className="w-full border-t"></div>
          <CardHeader>
            <CardTitle>Non Compliances</CardTitle>
          </CardHeader>

          <CardContent>
            {nonCompliances.length == 0
              ? "There are no non-compliances."
              : nonCompliances.map((nonCompliance) => {
                  return (
                    <div key={nonCompliance.id} className="grid gap-2">
                      <div className="flex items-center gap-2">
                        <XCircleIcon className="w-4 h-4 text-white bg-red-400 rounded-xl" />
                        <div>Checkpoint {nonCompliance.id}</div>
                        <div className="ml-auto text-sm text-gray-500 dark:text-gray-400">
                          Not Cleared
                        </div>
                      </div>
                    </div>
                  );
                })}
          </CardContent>
        </Card>
        <div className="flex justify-center mt-10">
          <Button
            className="mb-10 bg-green-600"
            onClick={handleCompleteDelivery}
          >
            {isLoading ? "Completing" : "Complete Delivery"}
          </Button>
        </div>
      </div>
      <ToastContainer />
    </div>
  );
}

function CheckCircleIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
      <polyline points="22 4 12 14.01 9 11.01" />
    </svg>
  );
}

function MapPinIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
      <circle cx="12" cy="10" r="3" />
    </svg>
  );
}

function PlusIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M5 12h14" />
      <path d="M12 5v14" />
    </svg>
  );
}

function RefreshCwIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
      <path d="M21 3v5h-5" />
      <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
      <path d="M8 16H3v5" />
    </svg>
  );
}

function TruckIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M5 18H3c-.6 0-1-.4-1-1V7c0-.6.4-1 1-1h10c.6 0 1 .4 1 1v11" />
      <path d="M14 9h4l4 4v4c0 .6-.4 1-1 1h-2" />
      <circle cx="7" cy="18" r="2" />
      <path d="M15 18H9" />
      <circle cx="17" cy="18" r="2" />
    </svg>
  );
}

function XCircleIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="12" cy="12" r="10" />
      <path d="m15 9-6 6" />
      <path d="m9 9 6 6" />
    </svg>
  );
}
