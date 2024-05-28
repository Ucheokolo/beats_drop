"use client";

import { useContext, createContext, useState } from "react";
import { connect, disconnect } from "starknetkit";

const WalletContext = createContext();

export const WalletProvider = ({ children }) => {
  const [connection, setConnection] = useState();
  const [address, setAddress] = useState();
  const [provider, setProvider] = useState();

  const connectWallet = async () => {
    const { wallet } = await connect();
    if (wallet && wallet.isConnected) {
      setConnection(wallet);
      setProvider(wallet.account);
      setAddress(wallet.selectedAddress);
    }
  };

  const disconnectWallet = async () => {
    await disconnect();

    setConnection(undefined);
    setProvider(undefined);
    setAddress("");
  };

  return (
    <WalletContext.Provider
      value={{ connection, address, provider, connectWallet, disconnectWallet }}
    >
      {children}
    </WalletContext.Provider>
  );
};

export const useWallet = () => {
  const context = useContext(WalletContext);
  if (!context) {
    throw new Error("useWallet must be used within a WalletProvider");
  }
  return context;
};
