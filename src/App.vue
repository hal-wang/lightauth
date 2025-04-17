<template>
	<div></div>
</template>

<script setup lang="ts">
	import { onLaunch, onShow, onHide } from "@dcloudio/uni-app";
	// import { useUserStore } from "./store";

	// const userStore = useUserStore();

	onLaunch(() => {
		console.log("App Launch");
		// if (!userStore.userInfo) {
		// 	userStore.afterLoginAction();
		// }

		uni.hideTabBar().catch();
	});
	onShow(() => {
		console.log("App Show");
	});
	onHide(() => {
		console.log("App Hide");
	});
</script>

<style lang="scss">
	page {
		@apply w-full h-full bg-gray-100;
	}
</style>
