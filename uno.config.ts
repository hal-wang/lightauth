import { defineConfig } from "unocss";
import transformerDirectives from "@unocss/transformer-directives";

import { presetApplet, presetRemRpx, transformerAttributify } from "unocss-applet";

export default defineConfig({
	presets: [presetApplet(), presetRemRpx()],
	transformers: [transformerAttributify({ ignoreAttributes: ["block"] }), transformerDirectives()],
	theme: {
		colors: {
			primary: "#307af5",
			warning: "#f9ae3d",
			success: "#5ac725",
			error: "#f56c6c",
			info: "#909399",
			rank1: "#FCBF44",
			rank2: "#ABAFC6",
			rank3: "#DB9076",
		},
	},
});
