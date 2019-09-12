<template>
  <v-app>
    <v-app-bar app color="indianred" dark>
      <v-toolbar-title class="headline text-uppercase">Words over time</v-toolbar-title>
    </v-app-bar>

    <v-content>
      <Main />
    </v-content>
  </v-app>
</template>

<script lang="ts">
import Vue from "vue";
import Main from "./components/Main.vue";
import Component from "vue-class-component";

@Component({
  components: { Main }
})
export default class extends Vue {}
</script>
