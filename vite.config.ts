import uni from "@dcloudio/vite-plugin-uni";
import AutoImport from "unplugin-auto-import/vite";
import path from "path";
import { createSvgIconsPlugin } from "vite-plugin-svg-icons";
import VueMacros from "unplugin-vue-macros/vite";
import UnoCSS from "unocss/vite";
import { defineConfig } from "vite";

export default defineConfig({
	plugins: [
		// eslint-disable-next-line @typescript-eslint/ban-ts-comment
		// @ts-ignore
		uni.default(),
		AutoImport({
			imports: ["vue", "uni-app"],
			eslintrc: {
				enabled: true,
			},
		}),
		createSvgIconsPlugin({
			iconDirs: [path.resolve(process.cwd(), "src/assets/icons")],
			symbolId: "icon-[dir]-[name]",
			svgoOptions: true,
		}),
		VueMacros({
			plugins: {},
		}),
		UnoCSS(),
	],
	resolve: {
		alias: [
			{
				find: /\/?@\//,
				replacement: path.resolve("src") + "/",
			},
			{
				find: /\/?#\//,
				replacement: path.resolve("types") + "/",
			},
		],
	},
});
