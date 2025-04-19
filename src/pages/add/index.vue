<template>
	<div class="p-3">
		<div class="bg-white rounded-lg">
			<uni-section title="扫描二维码" type="line" padding>
				<button class="bg-primary text-white text-base py-2 h-auto" @click="handleScan">
					<div class="flex items-center">
						<uni-icons type="scan" color="ffffff" />
						<div class="pl-2">开始扫描</div>
					</div>
				</button>
			</uni-section>
		</div>
		<div class="h-3"></div>
		<div class="bg-white rounded-lg">
			<uni-section title="手动输入密钥" type="line" padding>
				<uni-easyinput v-model="inputForm.label" placeholder="输入账号名"></uni-easyinput>
				<div class="h-2"></div>
				<uni-easyinput v-model="inputForm.secret" placeholder="输入密钥"></uni-easyinput>
				<div class="h-3"></div>
				<button class="bg-primary text-white text-base py-2" @click="handleInputSubmit">
					<uni-icons type="checkmarkempty" color="307af5 " />
					<div class="pl-2">输入完成</div>
				</button>
			</uni-section>
		</div>
	</div>
</template>

<script setup lang="ts">
	import { useStorage } from "@/utils/storage";
	import { reactive } from "vue";
	import * as OTPAuth from "otpauth";

	const inputForm = reactive({
		label: "",
		secret: "",
	});

	const { list, save } = useStorage();

	function handleScan() {
		uni.scanCode({
			success: (res) => {
				if (!res?.result?.startsWith("otpauth://")) {
					uni.showModal({
						title: "添加失败",
						content: "当前扫描的不是令牌二维码",
					});
					return;
				}

				list.splice(0, 0, {
					totp: OTPAuth.URI.parse(res.result),
					token: "",
					remaining: 0,
				});
				onAddFinished();
			},
		});
	}

	function handleInputSubmit() {
		if (!inputForm.label) {
			uni.showModal({
				title: "添加失败",
				content: "请输入账号名",
				showCancel: false,
			});
			return;
		}
		if (!inputForm.secret) {
			uni.showModal({
				title: "添加失败",
				content: "请输入密钥",
				showCancel: false,
			});
			return;
		}

		try {
			list.splice(0, 0, {
				totp: new OTPAuth.TOTP({
					label: inputForm.label,
					secret: inputForm.secret,
				}),
				token: "",
				remaining: 0,
			});
		} catch {
			uni.showModal({
				title: "添加失败",
				content: "密钥非法",
				showCancel: false,
			});
			return;
		}

		onAddFinished();
	}

	function onAddFinished() {
		save();
		uni.navigateBack();
	}
</script>
