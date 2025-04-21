<template>
	<div class="options">
		<!-- <button class="text-primary" @click="handleExport">
			<div class="flex items-center">
				<uni-icons type="redo" color="307af5 " />
				<div class="pl-2">导出</div>
			</div>
		</button> -->
		<button class="text-red" @click="handleDelete">
			<div class="flex items-center">
				<uni-icons type="trash" color="f87171" />
				<div class="pl-2">删除</div>
			</div>
		</button>
	</div>
	<div class="p-3">
		<div class="bg-white rounded-lg px-3 py-4">
			<div class="pb-1">账号名</div>
			<uni-easyinput v-model="editForm.label" placeholder="输入账号名"></uni-easyinput>
			<div class="pt-5 pb-1">提供商</div>
			<uni-easyinput v-model="editForm.issuer" placeholder="输入提供商（可选）"></uni-easyinput>
			<div class="h-5"></div>
			<button class="bg-primary text-white text-base py-2" @click="handleEdit">
				<uni-icons type="checkmarkempty" color="307af5 " />
				<div class="pl-2">编辑完成</div>
			</button>
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

	function handleDelete() {
		if (!editItem) return;

		uni.showModal({
			title: "确认删除",
			content: `即将删除令牌 ${editItem.totp.label}，该操作不可恢复，确认继续？`,
			success: (res) => {
				if (!res.confirm) return;

				list.splice(list.indexOf(editItem!), 1);
				navigateBack();
			},
		});
	}

	// function handleExport() {
	// 	if (!editItem) return;

	// 	const fs = uni.getFileSystemManager();
	// 	fs.writeFileSync("/test.la", editItem.totp.toString());
	// 	fs.saveFileSync("/test.la");
	// 	uni.showToast({
	// 		title: "2fs: " + !!fs,
	// 	});
	// }
</script>

<style lang="scss" scoped>
	.options {
		@apply flex flex-wrap justify-end;

		button {
			@apply bg-white rounded-full text-base py-2 px-5 h-auto mr-3 mt-3;
		}
	}
</style>
