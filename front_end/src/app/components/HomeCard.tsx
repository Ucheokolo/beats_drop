import React from "react";
import Image from "next/image";
import cardImage from "../images/jcole.png";

export default function HomeCard() {
  return (
    <div className=" w-64 rounded ">
      <div className="overflow-hidden bg-lime-100 opacity-40">
        <Image src={cardImage} alt="artist" className=" m-auto" />
      </div>
      <p className="text-white text-center">How Are you</p>
    </div>
  );
}
