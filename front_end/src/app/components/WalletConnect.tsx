"use client";
import React from "react";
import { useWallet } from "@/context/WalletContext";
import { useState, useEffect } from "react";
import Image from "next/image";
import wallet from "../images/wallet.png";

export default function WalletConnect({ label }: any) {
  const { connection, address, provider, connectWallet, disconnectWallet } =
    useWallet();

  const [addr, setAddr] = useState<any>();

  const shorten_address = (address: any): String => {
    let addressLenght: number = address?.length;
    let lastFive: number = addressLenght - 4;
    let appUser: string = address;
    let slicedAddress1 = appUser?.slice(0, 4);
    let slicedAddress2 = appUser?.slice(lastFive, addressLenght);
    let displayAddress = slicedAddress1 + "....." + slicedAddress2;
    return displayAddress;
  };

  useEffect(() => {
    let new_addr = shorten_address(address);
    setAddr(new_addr);
  }, [address]);

  return connection && connection ? (
    <button
      type="button"
      onClick={disconnectWallet}
      className=" flex text-black bg-[#FAA3BB] focus:outline-none focus:ring-purple-200 dark:focus:ring-purple-800 font-bold rounded-lg text-sm px-8 py-2 text-center items-center"
    >
      <Image src={wallet} alt="wallet icon" className=" mr-2" />
      {addr}
    </button>
  ) : (
    <button
      type="button"
      onClick={connectWallet}
      className=" flex text-black bg-[#FAA3BB] focus:outline-none focus:ring-purple-200 dark:focus:ring-purple-800 font-bold rounded-lg text-sm px-8 py-2 text-center items-center"
    >
      <Image src={wallet} alt="wallet icon" className=" mr-2" />
      {label}
    </button>
  );
}
