import Vue from 'vue';
import Web3 from "web3";

let a = require('../assets/data/abis/Migrations.json');
console.log(a == undefined)

const connection = () => new Promise(async (resolve, reject) => {
  try {
    if (Vue.prototype.$web3) {
      resolve(Vue.prototype.$web3);
    }

    var web3 = undefined,
      httpProvider = undefined,
      provider = 'https://http-mainnet.hoosmartchain.com';

    if (window.ethereum) {
      web3 = new Web3(window.ethereum);

      try {
        await window.ethereum.enable();
      } catch (error) {
        reject(error);
      }
    } else if (window.web3) {
      web3 = window.web3;
    } else {
      httpProvider = new Web3.providers.HttpProvider(
        provider
      );

      web3 = new Web3(httpProvider);
    }

    await web3.eth.net.getId().then(res => {
      Vue.prototype.$chainId = res;
    });

    await window.ethereum.request({
      method: "eth_requestAccounts"
    }).then(res => {
      Vue.prototype.$account = res[0];
    });

    Vue.prototype.$web3 = web3;

    resolve(Vue.prototype.$web3);
  } catch (e) {
    reject(e);
  }
});

const init = (name) => new Promise(async (resolve, reject) => {
  try {
    let contracts = Vue.prototype.$contract,
      src = '../assets/data/abis/Migrations.json';

    if (contracts.hasOwnProperty(name)) {
      resolve(contracts[name]);
    }

    let abi = import(src + name + '.json'),
      chainId = Vue.prototype.$chainId,
      web3 = Vue.prototype.$web3;

    if (!Vue.prototype.$web3) {
      await connection().then(async res => {
        Vue.prototype.$web3 = res;
      }).catch(e => reject(e));
    }

    if (!Vue.prototype.$chainId) {
      chainId = await web3.eth.net.getId();
      Vue.prototype.$chainId = chainId;
    }

    const contract = new web3.eth.Contract(
      abi, abi.networks[chainId].address
    );

    Vue.prototype.$contract[name] = contract;
    resolve(contract, chainId, abi);
  } catch (e) {
    reject(e);
  }
});

const transaction = (config, callback) => new Promise(
  (resolve, reject) => {
    init(config.name).then(async (contract, chainId, abi) => {
      try {
        if (!Vue.prototype.$account) {
          await window.ethereum.request({
            method: "eth_requestAccounts"
          }).then(res => {
            Vue.prototype.$account = res[0];
          });
        }

        let data = {
          from: Vue.prototype.$account,
          to: abi.networks[chainId].address,
          input: callback(contract.methods[config.method]),
          value: config.value || 0
        };

        if (!config.gas) {
          Vue.prototype.$web3.eth.estimateGas(data).then(res => {
            data.gas = res;
          });
        } else {
          data.gas = config.gas;
        }

        Vue.prototype.$web3.eth.sendTransaction({
          from: Vue.prototype.$account,
          to: abi.networks[chainId].address,
          input: callback(res.methods[method]),
          value: value || 0
        }).then(res => {
          resolve(res);
        }).catch(e => reject(e));
      } catch (e) {
        reject(e);
      }
    });
  });

export default {
  connection,
  init,
  transaction
};
