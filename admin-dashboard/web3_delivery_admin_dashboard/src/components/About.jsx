import React from "react";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { useNavigate } from "react-router-dom";

export default function About() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen p-6 bg-gradient-to-r from-green-400 to-blue-500">
      <nav className="flex justify-between items-center mb-6">
        <h1 className="text-white text-xl font-bold">GeoLogix DApp</h1>
        <div className="space-x-4">
          <Button variant="default" onClick={() => navigate("/")}>
            Dashboard
          </Button>
        </div>
      </nav>

      <div className="max-w-4xl mx-auto bg-white rounded-lg shadow p-6">
        <Card>
          <CardHeader>
            <CardTitle>About GeoLogix DApp</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 text-gray-800">
            {/* New Coursework Intro */}
            <p>
              In this coursework for Mobile and Distributed Systems I have
              contributed to an open source DApp (Decentralized Application)
              repository on GitHub (
              <a
                href="https://github.com/abdimussa87/web3-mobile-app-for-delivery-payments"
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                abdimussa87/web3-mobile-app-for-delivery-payments
              </a>
              ). The open source project is called <strong>GeoLogix Solutions</strong>
               and its use case is to improve the logistics of the supply chain
              using innovative GPS and blockchain technologies to ensure timely
              deliveries. The DApp is Ethereum-based and uses a location-based
              smart contract to incentivize drivers for adhering to geographic
              compliance. This works with the use of smartphones transmitting
              live GPS data and feeding it to the smart contract. Drivers are
              paid with cryptocurrency upon meeting the conditions of the smart
              contract. The smart contract also punishes non-compliant behavior
              by affecting the drivers’ rating. My contribution to this project
              was to enhance the frontend and backend implementations as well
              as contribute to the blockchain functionalities, ensuring
              interaction with a blockchain test network.
            </p>

            {/* Original about copy */}
            
            <p className="text-sm text-gray-500">
              Tiana Stanley - Mobile & Distributed Systems - CN6035
            </p>

            <div className="flex space-x-2">
              <Button
                variant="primary"
                as="a"
                href="https://github.com/abdimussa87/web3-mobile-app-for-delivery-payments"
                target="_blank"
                rel="noopener noreferrer"
              >
                Contribute on GitHub
              </Button>
              <Button variant="outline" onClick={() => navigate("/")}>
                ← Back to Dashboard
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
