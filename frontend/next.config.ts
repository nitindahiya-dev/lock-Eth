import { http, createConfig } from 'wagmi'
import { injected, metaMask } from 'wagmi/connectors'
import { mainnet } from 'wagmi/chains'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
};

export default nextConfig;



export const config = createConfig({
  chains: [mainnet],
  connectors: [
    injected(),
    metaMask(),
  ],
	  transports: {
	    [mainnet.id]: http("https://eth-sepolia.g.alchemy.com/v2/ia-tpPc2_RWxXKXjSjweJ0pqKbv1K5XH"),
  },
})