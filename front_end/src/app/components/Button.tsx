import React, { useEffect, useState } from "react";

export default function Button({ label }: any) {
  return (
    <button
      type="button"
      className=" text-white bg-gradient-to-r from-[#FAA3BB] to-pink-500 hover:bg-gradient-to-l focus:right-4 focus:outline-none focus:ring-purple-200 dark:focus:ring-purple-800 font-bold rounded-lg text-sm px-8 py-2 text-center "
    >
      {label}
    </button>
  );
}
