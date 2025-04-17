import { createSSRApp } from "vue";
import App from "./App.vue";

import "/@/assets/iconfont.css";

import "virtual:uno.css";
import "@unocss-applet/reset/uni-app/tailwind.css";
import "virtual:svg-icons-register";

export function createApp() {
	const app = createSSRApp(App);

	return {
		app,
	};
}
