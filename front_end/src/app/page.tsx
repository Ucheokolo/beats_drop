"use client";
import WalletBar from "@/components/WalletBar";
import styles from "./styles.module.css";
import HomeCard from "./components/HomeCard";

export default function Home() {
  return (
    <main className={styles.homebg}>
      <HomeCard />
      <div className={styles.blurbox}></div>
    </main>
  );
}
