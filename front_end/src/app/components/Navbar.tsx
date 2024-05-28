"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { AiOutlineMenu, AiOutlineClose } from "react-icons/ai";
import logo from "../images/logo.png";
import Button from "./Button";
import rocket from "../images/whiterocket.png";
import WalletConnect from "./WalletConnect";

export default function Navbar() {
  const [menuIcon, setMenuIcon] = useState(false);

  const handleSmallerScreenNavigation = () => {
    setMenuIcon(!menuIcon);
  };

  return (
    <header className=" bg-[#1B0536] text-[#FFFFFF] w-full ease-in duration-300 fixed top-0 left-0 z-1 border-b-[0.5px] border-[#EE3366]">
      <nav className=" mx-auto h-[100px] flex justify-between items-center py-4 px-8">
        <div>
          <Link
            rel="stylesheet"
            href="/"
            onClick={handleSmallerScreenNavigation}
          >
            <Image
              src={logo}
              alt="logo"
              width={120}
              sizes="100vw"
              style={{ width: "40%", height: "auto" }}
            />
          </Link>
        </div>
        <ul className=" hidden md:flex uppercase font-semibold text-xl lg:text-[15px]">
          <li className=" mr-4 lg:mr-16 hover:text-[#FAA3BB]">
            <Link href="/">Home</Link>
          </li>
          <li className=" mr-4 lg:mr-16 hover:text-[#FAA3BB]">
            <Link href="/about">About Us</Link>
          </li>
          <li className=" mr-4 lg:mr-16 hover:text-[#FAA3BB]">
            <Link href="/explore">Explore</Link>
          </li>

          <li className=" mr-4 lg:mr-16 hover:text-[#FAA3BB]"></li>
        </ul>
        <div className=" hidden md:flex">
          <div className="flex">
            <Link href="/explore">
              <button className=" flex text-white bg-[#EE3366] focus:right-4 focus:outline-none focus:ring-purple-200 dark:focus:ring-purple-800 font-bold rounded-lg text-sm px-5 py-2 text-center items-center mr-5 ">
                <Image src={rocket} alt="wallet icon" className=" mr-2 " />
                Launch App
              </button>
            </Link>
            <WalletConnect label="Connect Wallet" />
          </div>
        </div>
        <div
          onClick={handleSmallerScreenNavigation}
          className=" flex md:hidden"
        >
          {menuIcon ? (
            <AiOutlineClose size={25} className="text-[#ffff]" />
          ) : (
            <AiOutlineMenu size={25} className=" text-[#ffff]" />
          )}
        </div>
        <div
          className={
            menuIcon
              ? "md:hidden absolute top-[100px] right-0 bottom-0 left-0 flex justify-center items-center w-full h-screen bg-[#1B0536] text-center ease-in duration-300"
              : "md:hidden absolute top-[100px] right-0 left-[-100%] flex justify-center items-center w-full h-screen bg-[#1B0536] text-center ease-in duration-300"
          }
        >
          <div className=" w-full">
            <ul className=" uppercase font-bold text-2xl">
              <li
                onClick={handleSmallerScreenNavigation}
                className=" py-5 hover:text-[#FAA3BB] cursor-pointer"
              >
                <Link href="/">Home</Link>
              </li>
              <li
                onClick={handleSmallerScreenNavigation}
                className=" py-5 hover:text-[#FAA3BB] cursor-pointer"
              >
                <Link href="/about">About Us</Link>
              </li>
              <li
                onClick={handleSmallerScreenNavigation}
                className=" py-5 hover:text-[#FAA3BB] cursor-pointer"
              >
                <Link href="/explore">Explore</Link>
              </li>
            </ul>
            <div className=" flex flex-col justify-center items-center mt-16">
              <Link href="/explore" onClick={handleSmallerScreenNavigation}>
                <button className=" flex text-white bg-[#EE3366] focus:right-4 focus:outline-none focus:ring-purple-200 dark:focus:ring-purple-800 font-bold rounded-lg text-sm px-5 py-2 text-center items-center mb-5 w-auto">
                  <Image src={rocket} alt="wallet icon" className=" mr-2" />
                  Launch App
                </button>
              </Link>
              {/* <Button label="Connect Wallet" /> */}
              <WalletConnect label="Connect Wallet" />
            </div>
          </div>
        </div>
      </nav>
    </header>
  );
}
