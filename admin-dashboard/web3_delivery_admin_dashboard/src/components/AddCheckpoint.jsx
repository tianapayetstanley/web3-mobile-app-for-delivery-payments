// src/components/AddCheckpoint.jsx
import React, { useState, useCallback } from "react";
import { Link, useNavigate } from "react-router-dom";
import { ethers } from "ethers";
import { 
  GoogleMap,
  useJsApiLoader,
  Marker
} from "@react-google-maps/api";                       // ← map components
import contractAbi from "@/assets/GeoLogix.json";
import { toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

const CONTRACT_ADDRESS = "0x3D07934564C66C0f619041E6e16466796328d1";
const MAP_CONTAINER_STYLE = { width: "100%", height: "300px" };
const DEFAULT_CENTER = { lat: 0, lng: 0 };             // start centered at (0,0)

export default function AddCheckpoint() {
  const navigate = useNavigate();
  const [lat, setLat] = useState("");
  const [lng, setLng] = useState("");
  const [distance, setDistance] = useState("");
  const [timestamp, setTimestamp] = useState("");
  const [marker, setMarker] = useState(null);

  // load Google Maps
  const { isLoaded } = useJsApiLoader({
    id: "google-map-script",
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY
  });

  // place marker & update lat/lng inputs
  const onMapClick = useCallback((e) => {
    const newLat = e.latLng.lat();
    const newLng = e.latLng.lng();
    setMarker({ lat: newLat, lng: newLng });
    setLat(newLat.toString());
    setLng(newLng.toString());
  }, []);

  // form submit: on‐chain addCheckpoint
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!window.ethereum) {
      toast.error("MetaMask not detected");
      return;
    }
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        CONTRACT_ADDRESS,
        contractAbi.abi ?? contractAbi,
        signer
      );
      const parsedDistance = ethers.BigNumber.from(distance);
      const tsMillis = new Date(timestamp).getTime();
      const tx = await contract.addCheckpoint(
        ethers.BigNumber.from(lat),
        ethers.BigNumber.from(lng),
        parsedDistance,
        tsMillis
      );
      toast.info("Submitting transaction…");
      await tx.wait();
      toast.success("Checkpoint added on-chain!");
      navigate("/");
    } catch (err) {
      console.error("AddCheckpoint error:", err);
      toast.error("Failed to add checkpoint");
    }
  };

  return (
    <div className="min-h-screen p-10 bg-gradient-to-r from-green-400 to-blue-500">
      <div className="max-w-3xl mx-auto flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-white">Add Checkpoint</h1>
        <Link
          to="/"
          className="bg-white text-gray-800 px-4 py-2 rounded hover:bg-gray-100 transition"
        >
          ← Back to Dashboard
        </Link>
      </div>

      <div className="max-w-3xl mx-auto bg-white rounded-lg shadow p-6 space-y-6">
        {/* GOOGLE MAP */}
        {isLoaded ? (
          <GoogleMap
            mapContainerStyle={MAP_CONTAINER_STYLE}
            center={marker || DEFAULT_CENTER}
            zoom={marker ? 12 : 2}
            onClick={onMapClick}
          >
            {marker && <Marker position={marker} />}
          </GoogleMap>
        ) : (
          <div className="h-72 flex items-center justify-center text-gray-500">
            Loading map…
          </div>
        )}

        {/* FORM */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block mb-1 font-medium">Latitude</label>
            <input
              type="text"
              value={lat}
              onChange={(e) => setLat(e.target.value)}
              className="w-full border rounded px-3 py-2"
              placeholder="Click on map or enter manually"
              required
            />
          </div>

          <div>
            <label className="block mb-1 font-medium">Longitude</label>
            <input
              type="text"
              value={lng}
              onChange={(e) => setLng(e.target.value)}
              className="w-full border rounded px-3 py-2"
              placeholder="Click on map or enter manually"
              required
            />
          </div>

          <div>
            <label className="block mb-1 font-medium">Distance (meters)</label>
            <input
              type="number"
              value={distance}
              onChange={(e) => setDistance(e.target.value)}
              className="w-full border rounded px-3 py-2"
              required
            />
          </div>

          <div>
            <label className="block mb-1 font-medium">Timestamp</label>
            <input
              type="datetime-local"
              value={timestamp}
              onChange={(e) => setTimestamp(e.target.value)}
              className="w-full border rounded px-3 py-2"
              required
            />
          </div>

          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 transition"
          >
            Add Checkpoint on-chain
          </button>
        </form>
      </div>

      <div className="max-w-3xl mx-auto mt-4 text-center text-white opacity-75">
        {/* [CN6035 CONTRIBUTION] Google Map + form by Abdi Mussa */}
        <small>
          Contribute or view source on{" "}
          <a
            href="https://github.com/abdimussa87/web3-mobile-app-for-delivery-payments"
            target="_blank"
            rel="noopener noreferrer"
            className="underline"
          >
            GitHub
          </a>
        </small>
      </div>
    </div>
  );
}
