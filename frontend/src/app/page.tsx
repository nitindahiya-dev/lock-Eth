"use client"
import { WagmiConfig, useAccount } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import LockEth from '../components/LockEth';
import { Account } from '../components/Account';
import { WalletOptions } from '../components/walletOptions';
import { config } from '../../next.config'

const queryClient = new QueryClient();

function ConnectWallet() {
  const { isConnected } = useAccount();

  if (isConnected) return <Account />;
  return <WalletOptions />;
}

function App() {
  return (
    <WagmiConfig config={config}>
      <QueryClientProvider client={queryClient}>
        
        <ConnectWallet />
        <LockEth />
      </QueryClientProvider>
    </WagmiConfig>
  );
}

export default App;
