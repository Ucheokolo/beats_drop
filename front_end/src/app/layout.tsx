import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { StarknetProvider } from "@/components/starknet-provider";
import { WalletProvider } from "../context/WalletContext";
import "./globals.css";
import Navbar from "./components/Navbar";

export const metadata: Metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <StarknetProvider>
          <WalletProvider>
            <Navbar />
            {children}
          </WalletProvider>
        </StarknetProvider>
      </body>
    </html>
  );
}
