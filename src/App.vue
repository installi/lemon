<template>
  <section class="vbox" id="app">
    <Header></Header>
    <section class="hbox stretch" @click="test()">
      <section id="content">
        <section class="vbox">
          <router-view />
        </section>
      </section>
    </section>
  </section>
</template>

<script>
import Header from "@/components/assembly/Header.vue";

export default {
  name: "App",
  components: { Header },
  mounted() {},
  methods: {
    test() {
      this.$trans({
          name: "Test",
          method: "setCompleted",
        },
        function (method) {
          return method(1).encodeABI();
        }
      ).then((res) => {
        console.log(res);
      });
    },
  },
};
</script>
