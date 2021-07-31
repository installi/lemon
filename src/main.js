// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'

Vue.config.productionTip = false

import wallet from './utils/global.wallet.js';

Vue.prototype.$abis = new Object();
Vue.prototype.$contracts = new Object();
Vue.prototype.$web3 = undefined;
Vue.prototype.$chainId = undefined;
Vue.prototype.$account = undefined;

console.log(wallet.transaction)
Vue.prototype.$connection = wallet.connection;
Vue.prototype.$trans = wallet.transaction;

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
