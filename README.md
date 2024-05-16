# ReadMe for the Collection Floor Strategy Application

## Overview

The Collection Floor Strategy Application is designed for NFT (Non-Fungible Token) traders and collectors operating on blockchain networks. This Elixir module automates the decision-making process for buying or selling NFTs based on the collection floor prices, bids, and personal holdings, maximizing profit opportunities in a dynamic marketplace.

## Features

- **Trade Data Collection**: Fetches and organizes trade data from the blockchain, including NFTs owned, current bids, collection statistics, and more, for a specified wallet and collection.
- **State Matching**: Assesses the current state of the wallet with respect to a given NFT collection to decide the most profitable action.
- **Action Decision**: Determines whether to place new bids, list NFTs for sale, or retract bids based on profitability calculations.
- **SDK Integration**: Seamlessly performs actions (e.g., creating bids, listing NFTs) by calling appropriate functions in the TradePort SDK.

## Getting Started

To run the Collection Floor Strategy Application, ensure you have Elixir installed on your system. This application is designed to work with Elixir projects, specifically leveraging the power of pattern matching and asynchronous processing provided by the language.

### Prerequisites

- Elixir 1.10 or later
- Access to TradePort.xyz APIs for fetching NFT data
- An initialized Elixir project

### Installation

1. Clone this repository into your project or directly copy the code into your module.
2. Ensure you have dependencies for HTTP requests and any specific blockchain SDKs you plan to interact with in your `mix.exs` file.
3. Run `mix deps.get` to fetch the required dependencies.
4. Implement or ensure the implementation of required functions in the specified `Sdk` module(s) for your blockchain of choice.

## Usage

After integrating this module into your project, you can trigger the pipeline with a simple function call:

```elixir
%{
  chain: "blockchain_name",
  collection_id: "unique_collection_identifier",
  wallet: "your_wallet_address"
}
|> Strategy.CollectionFloor.Pipeline.pipeline()
```

Replace `"blockchain_name"`, `"unique_collection_identifier"`, and `"your_wallet_address"` with the actual values relevant to your scenario.

## Contributing

Contributions are welcome to enhance the application's functionality, extend compatibility with more blockchains, or improve the decision algorithms. Please feel free to fork the repository, make your changes, and submit a pull request.

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Disclaimer

This application is provided as-is, and users should engage with NFT trading with the understanding of the market risks. The creators are not responsible for any financial losses incurred using this tool.

## Contact

For support or contributions, please open an issue in the GitHub repository linked with this application.
