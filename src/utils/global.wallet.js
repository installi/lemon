import Vue from "vue";
import Web3 from "web3";

// import Migrations from "../assets/data/abis/Migrations.json";

// const abis = {
//   Migrations: Migrations,
//   Test: Migrations
// }



// const a = function() {
//   console.log(45998765)
//   import("../assets/data/abis/Migrations.json").then(res => {
//     console.log(res)
//   });
// }

const connection = () => new Promise((resolve, reject) => {
  try {
    if (Vue.prototype.$web3) {
      return resolve(Vue.prototype.$web3);
    }

    var web3 = undefined,
      httpProvider = undefined,
      provider = "https://http-mainnet.hoosmartchain.com";

    if (window.ethereum) {
      web3 = new Web3(window.ethereum);

      try {
        window.ethereum.enable();
      } catch (error) {
        return reject(error);
      }
    } else if (window.web3) {
      web3 = window.web3;
    } else {
      httpProvider = new Web3.providers.HttpProvider(
        provider
      );

      web3 = new Web3(httpProvider);
    }

    web3.eth.net.getId().then(res => {
      Vue.prototype.$chainId = res;
    });

    window.ethereum.request({
      method: "eth_requestAccounts"
    }).then(res => {
      Vue.prototype.$account = res[0];
    });

    Vue.prototype.$web3 = web3;

    return resolve(Vue.prototype.$web3);
  } catch (e) {
    return reject(e);
  }
});

const init = (name) => new Promise((resolve, reject) => {
  try {
    let abis = Vue.prototype.$abis,
      contracts = Vue.prototype.$contracts,
      chainId = Vue.prototype.$chainId,
      web3 = Vue.prototype.$web3;

    if (
      contracts.hasOwnProperty(name) &&
      abis.hasOwnProperty(name)
    ) {
      return resolve([contracts[name], chainId, abis[name]]);
    }

    if (!chainId || !web3) {
      return reject("Please connect your wallet first");
    }

    import(
      "../assets/data/abis/" + name + ".json"
    ).then(abi => {
      Vue.prototype.$abis[name] = abi;

      if (!abi.networks.hasOwnProperty(chainId)) {
        return reject("The network is not supported");
      }

      const contract = new web3.eth.Contract(
        abi.abi, abi.networks[chainId].address
      );

      Vue.prototype.$contracts[name] = contract;
      console.log("FIRST INIT CONTRACT")
      return resolve([contract, chainId, abi]);
    });
  } catch (e) {
    return reject(e);
  }
});

const transaction = (config, callback) => new Promise(
  (resolve, reject) => {
    init(config.name).then((arr) => {
      try {
        if (
          !Vue.prototype.$account ||
          !Vue.prototype.$web3
        ) {
          return reject("Please connect your wallet first");
        }

        let web3 = Vue.prototype.$web3,
          data = {
            from: Vue.prototype.$account,
            to: arr[2].networks[arr[1]].address,
            input: callback(arr[0].methods[config.method]),
            value: config.value || 0
          };

        web3.eth.estimateGas(data).then(gas => {
          data.gas = config.gas ? config.gas : gas;

          console.log(gas, 'gas')
          web3.eth.sendTransaction(data).then(res => {
            return resolve(res);
          }).catch(e => reject(e));
        });
      } catch (e) {
        return reject(e);
      }
    });
  });

export default {
  connection,
  init,
  transaction
};
