# Eventide Funds Transfer Benchmark Utility

## Summary

This benchmark measures the throughput of funds transfers using Eventide's [funds transfer](https://github.com/eventide-examples/funds-transfer-component) and [account](https://github.com/eventide-examples/account-component) components. By exercising two components that interact with one another, the benchmarks also measure the performance of pub/sub, which cannot be measured by exercising a single component by itself.

## Settings

Most of the scripts in this project can be controlled with a settings file, `settings/benchmark.json`

| Setting             | Description                                                            | Default Value        |
| ------------------- | ---------------------------------------------------------------------- | -------------------- |
| `operations`        | Number of funds transfers to perform                                   | `1000`               |
| `entities`          | Number of accounts to cycle transfers through                          | Same as `operations` |
| `throughputLimit`   | Maximum number of transfers to issue during the run                    | `100`                |
| `force`             | `./initiate.sh` always starts a new run, even if MessageDB isn't reset | `false`              |
| `writePartitions`   | Number of advisory locks per-category when writing messages            | `1`                  |
| `readPartitions`    | Size of consumer groups                                                | `1`                  |
| `recreateMessageDB` | Whether to fully recreate message-db when preparing the benchmark      | `true`               |

## Procedure

###### Account & Funds Transfer Components

Ensure `./get-projects.sh` from the [Eventide Contributor Assets project](https://github.com/eventide-project/contributor-assets) has run successfully. Then clone [Account Component](https://github.com/eventide-examples/account-component) and [Funds Transfer Component](https://github.com/eventide-examples/account-component) in `PROJECTS_HOME`:

``` sh
pushd $PROJECTS_HOME

git clone git@github.com:eventide-examples/account-component.git
git clone git@github.com:eventide-examples/funds-transfer-component.git
```

Return to this project directory afterwards:

``` sh
popd
```

###### Gem Installation

Install the necessary Ruby gems locally:

``` sh
./install-gems.sh
```

###### Prepare Benchmark

Enqueue a batch of funds transfers that will be performed during the benchmark:

``` sh
./prepare.sh
```

###### Start Components

In separate terminals, start an instance of the AccountComponent for every consumer group member. Consumer group size is controlled via the `readPartitions` setting in `settings/benchmark.json`, and the default is 1. The consumer group member is set via the `CONSUMER_GROUP_MEMBER` environment variable, and is a number between one and the consumer group size.

``` sh
CONSUMER_GROUP_MEMBER=1 ./start-account-component.sh
```

Also start FundsTransferComponent:

``` sh
CONSUMER_GROUP_MEMBER=1 ./start-funds-transfer-component.sh
```

###### Wait For Initial Deposits To Be Processed

The `./prepare.sh` script added funds into every account with a Deposit command message. Wait for a Deposited event to be recorded for each deposit by visually inspecting the terminals running AccountComponent.

###### Initiate Benchmark Run

Issue the transfers that will be measured by the benchmark:

``` sh
./initiate.sh
```
###### Inspect Results

The results are calculated from the messages written to MessageDB. To print them:

``` sh
./print-results.sh
```
