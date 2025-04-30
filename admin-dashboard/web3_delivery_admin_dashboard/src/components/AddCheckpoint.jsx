import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useJsApiLoader, GoogleMap, Marker } from '@react-google-maps/api';
import dayjs from 'dayjs';

const containerStyle = {
  width: '100%',
  height: '400px',
};

export default function AddCheckpoint() {
  const navigate = useNavigate();
  const [lat, setLat] = useState(0);
  const [lng, setLng] = useState(0);
  const [distance, setDistance] = useState('');
  const [timestamp, setTimestamp] = useState(dayjs().format('YYYY-MM-DDTHH:mm'));
  //[CN6035 EDIT] 
  // load Google Maps API using env var VITE_GOOGLE_MAPS_API_KEY
  const { isLoaded } = useJsApiLoader({
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY
  });

  const handleMapClick = (event) => {
    setLat(event.latLng.lat());
    setLng(event.latLng.lng());
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    // invoke passed-in prop or navigate to actual add logic
    // e.g., addCheckpoint({ lat, lng, distance, timestamp: new Date(timestamp).getTime() });
    navigate('/');
  };
  //[CN6035 EDIT] 

  return (
    <div className="p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-xl font-semibold mb-4">Add Checkpoint</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium">Latitude</label>
            <Input
              type="number" step="0.000001"
              value={lat}
              onChange={(e) => setLat(parseFloat(e.target.value) || 0)}
              className="mt-1"
            />
          </div>
          <div>
            <label className="block text-sm font-medium">Longitude</label>
            <Input
              type="number" step="0.000001"
              value={lng}
              onChange={(e) => setLng(parseFloat(e.target.value) || 0)}
              className="mt-1"
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium">Distance (meters)</label>
            <Input
              type="number" step="1"
              value={distance}
              onChange={(e) => setDistance(e.target.value)}
              className="mt-1"
            />
          </div>
          <div>
            <label className="block text-sm font-medium">Timestamp</label>
            <Input
              type="datetime-local"
              value={timestamp}
              onChange={(e) => setTimestamp(e.target.value)}
              className="mt-1"
            />
          </div>
        </div>

        {isLoaded && (
          <GoogleMap
            mapContainerStyle={containerStyle}
            center={{ lat, lng }}
            zoom={12}
            onClick={handleMapClick}
          >
            <Marker position={{ lat, lng }} />
          </GoogleMap>
        )}

        <Button type="submit" className="w-full bg-blue-900 text-white py-2">
          Add Checkpoint
        </Button>
      </form>
    </div>
  );
}
