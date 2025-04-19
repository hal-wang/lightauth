import { reactive } from "vue";
import * as OTPAuth from "otpauth";

export interface TotpItem {
	totp: OTPAuth.HOTP | OTPAuth.TOTP;
	token: string;
	remaining: number;
}

const key = "STORAGE_KEY_1";
const appItems = reactive<TotpItem[]>([]);
let inited = false;

export function useStorage() {
	function load() {
		let urls = uni.getStorageSync<string[]>(key);
		if (!urls) {
			urls = [];
		}
		appItems.splice(
			0,
			appItems.length,
			...urls.map((x) => ({
				totp: OTPAuth.URI.parse(x),
				token: "",
				remaining: 0,
			})),
		);
		inited = true;
	}

	function startInterval() {
		setInterval(() => {
			appItems.forEach((x) => {
				x.token = x.totp.generate();
				x.remaining = "remaining" in x.totp ? x.totp.remaining() : 0;
			});
		}, 200);
	}

	function save() {
		uni.setStorageSync(
			key,
			appItems.map((x) => x.totp.toString()),
		);
	}

	if (!inited) {
		load();
		startInterval();
	}

	return {
		list: appItems,
		save,
		refresh: load,
	};
}
