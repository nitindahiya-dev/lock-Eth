import { useConnect } from 'wagmi';

export function WalletOptions() {
  const { connectors, connect } = useConnect();

  return (
    <div>
      {connectors.map((connector) => (
        <button
          key={connector.id}
          onClick={() => connect({connector})} // Updated to use the connector directly
          disabled={!connector.ready}
          className="m-2 px-4 py-2 text-white rounded hover:bg-blue-600"
        >
          {connector.name}
        </button>
      ))}
    </div>
  );
}
