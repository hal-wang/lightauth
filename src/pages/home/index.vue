<template>
	<div class="relative">
		<div class="absolute -top-8">
			<uni-icons type="plusempty" />
		</div>
		<div class="pr-3 pt-3 flex justify-end">
			<button class="bg-primary text-white text-base py-2 px-6 h-auto" @click="handleAdd">
				<div class="flex items-center">
					<uni-icons type="plusempty" color="ffffff" />
					<div class="pl-2">新增令牌</div>
				</div>
			</button>
		</div>
		<div v-for="(app, index) in list" :key="index" class="px-3 pt-3" @click="() => handleEdit(app)">
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
</template>

<script setup lang="ts">
	import { useStorage, type TotpItem } from "@/utils/storage";

	const { list } = useStorage();

	function handleAdd() {
		uni.navigateTo({
			url: "/pages/add/index",
		});
	}

	function handleEdit(item: TotpItem) {
		const index = list.indexOf(item);
		uni.navigateTo({
			url: `/pages/edit/index?index=${index}`,
		});
	}
</script>
