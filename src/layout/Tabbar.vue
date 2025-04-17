<template>
	<!--eslint-disable-next-line vue/attribute-hyphenation-->
	<uv-tabbar :value="indexInternal" activeColor="#b22f33" @change="onChange">
		<uv-tabbar-item text="赛事主页" icon="home" />
		<uv-tabbar-item text="个人中心" icon="account" />
	</uv-tabbar>
</template>

<script setup lang="ts">
	const emits = defineEmits(["update:index"]);

	const props = defineProps({
		index: {
			type: Number,
			required: true,
		},
	});

	let indexInternal = $computed({
		get: () => props.index,
		set: (val) => emits("update:index", val),
	});

	function onChange(index: number) {
		indexInternal = index;
		switch (index) {
			case 1:
				uni.switchTab({
					url: "/pages/user/index",
				});
				break;
			default:
				uni.switchTab({
					url: "/pages/game/index",
				});
				break;
		}
	}
</script>
