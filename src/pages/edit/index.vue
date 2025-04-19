<template>
	<div class="flex flex-col w-full h-full">
		<uni-nav-bar left-icon="left" title="编辑令牌" status-bar :border="false" @click-left="navigateBack" />

		<div class="flex-1 h-0 p-3 overflow-y-auto">
			<div class="bg-white rounded-lg px-3 py-4">
				<div class="pb-1">账号名</div>
				<uni-easyinput v-model="editForm.label" placeholder="输入账号名"></uni-easyinput>
				<div class="pt-4 pb-1">提供商</div>
				<uni-easyinput v-model="editForm.issuer" placeholder="输入提供商（可选）"></uni-easyinput>
				<div class="h-4"></div>
				<button class="bg-primary text-white text-base py-2" @click="handleEdit">编辑完成</button>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
	import { useStorage, type TotpItem } from "@/utils/storage";
	import { reactive } from "vue";
	import { onLoad } from "@dcloudio/uni-app";

	let editItem = $ref<TotpItem | null>(null);
	onLoad((o) => {
		const index = Number(o?.index);
		editItem = list[index];
		if (!editItem) {
			navigateBack();
			return;
		}

		editForm.label = editItem.totp.label;
		editForm.issuer = editItem.totp.issuer;
	});

	function navigateBack() {
		uni.navigateBack();
	}

	const editForm = reactive({
		label: "",
		issuer: "",
	});

	const { list, save } = useStorage();

	function handleEdit() {
		if (!editItem) return;

		if (!editForm.label) {
			uni.showModal({
				title: "添加失败",
				content: "请输入账号名",
				showCancel: false,
			});
			return;
		}

		editItem.totp.label = editForm.label;
		editItem.totp.issuer = editForm.issuer;
		save();
		uni.navigateBack();
	}
</script>
