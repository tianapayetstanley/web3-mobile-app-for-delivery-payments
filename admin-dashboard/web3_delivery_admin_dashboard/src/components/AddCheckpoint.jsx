import {
  CardTitle,
  CardDescription,
  CardHeader,
  CardContent,
  Card,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useState } from "react";
import contractAbi from "../assets/GeoLogix.json";
import { ethers } from "ethers";
import { Link } from "react-router-dom";

import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
export default function AddCheckpoint() {
  const [latitude, setLatitude] = useState();
  const [longitude, setLongitude] = useState();
  const [distance, setDistance] = useState();
  const [timestamp, setTimestamp] = useState();
  const [isLoading, setIsLoading] = useState(false);

  const handleAddCheckpoint = async (e) => {
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

      let addCheckpointTx = await contract.addCheckpoint(
        Math.floor(latitude * 100000),
        Math.floor(longitude * 100000),
        distance,
        timestamp
      );
      const receipt = await addCheckpointTx.wait();

      // Log the transaction receipt
      console.log("Transaction Receipt:", receipt);

      toast("Checkpoint added successfully!");
      setIsLoading(false);
      setLatitude();
      setLongitude();
      setDistance();
      setTimestamp();
    } catch (err) {
      toast(err.message);
      console.log(err.message);
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen p-20 text-white bg-gradient-to-r from-green-400 to-blue-500">
      <h1 className="max-w-4xl m-auto ">
        <Link to="/" className="text-3xl">
          Admin Dashboard
        </Link>
      </h1>
      <Card className="flex flex-col max-w-4xl m-auto mt-5">
        <CardHeader>
          <CardTitle className="text-xl">Add Checkpoint</CardTitle>
          <CardDescription>Enter the details below</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label
                className="block text-sm font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                htmlFor="latitude"
              >
                Latitude
              </label>
              <Input
                id="latitude"
                placeholder="0.000"
                value={latitude}
                onChange={(e) => setLatitude(e.target.value)}
              />
            </div>
            <div>
              <label
                className="block text-sm font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                htmlFor="longitude"
              >
                Longitude
              </label>
              <Input
                id="longitude"
                placeholder="0.000"
                value={longitude}
                onChange={(e) => setLongitude(e.target.value)}
              />
            </div>
            <div>
              <label
                className="block text-sm font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                htmlFor="distance"
              >
                Distance
              </label>
              <Input
                id="distance"
                placeholder="meters"
                value={distance}
                onChange={(e) => setDistance(e.target.value)}
              />
            </div>
            <div>
              <label
                className="block text-sm font-medium peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                htmlFor="timestamp"
              >
                Timestamp
              </label>
              <Input
                id="timestamp"
                type="datetime-local"
                onChange={(e) => {
                  return setTimestamp(Date.parse(e.target.value));
                }}
              />
            </div>
          </div>
          <div className="grid gap-4 pt-4">
            <Button size="sm" onClick={handleAddCheckpoint}>
              {isLoading ? "Loading..." : "Add Checkpoint"}
            </Button>
          </div>
        </CardContent>
      </Card>
      <ToastContainer />
    </div>
  );
}
