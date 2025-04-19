<template>
	<div class="w-full h-full flex flex-col">
		<uni-nav-bar left-icon="plusempty" title="轻令牌" status-bar :border="false" @click-left="handleAdd" />
		<div class="flex-1 h-0 flex flex-col overflow-y-auto">
			<div v-for="(app, index) in list" :key="index" class="px-3 pt-3">
				<div class="flex items-center px-3 pt-3 pb-2 bg-white rounded-lg relative">
					<div class="flex-1 w-0 flex flex-col">
						<div class="text-lg truncate">{{ app.totp.label }}</div>
						<div v-if="app.totp.issuer" class="text-sm text-gray-400 truncate">{{ app.totp.issuer }}</div>
					</div>
					<div class="text-right font-bold text-3xl">
						{{ app.token }}
					</div>

					<div
						:style="{
							width: `${app.remaining / 300}%`,
						}"
						class="bg-primary absolute bottom-0 left-0 h-1 w-full rounded-b-lg"
					></div>
				</div>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
	import { useStorage } from "@/utils/storage";

	const { list } = useStorage();

	function handleAdd() {
		uni.navigateTo({
			url: "/pages/add/index",
		});
	}
</script>
