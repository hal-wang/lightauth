import globals from "globals";
import pluginJs from "@eslint/js";
import tseslint from "typescript-eslint";
import pluginVue from "eslint-plugin-vue";
import pluginPrettierRecommendedConfigs from "eslint-plugin-prettier/recommended";
import parserVue from "vue-eslint-parser";

export default [
	// eslint 默认推荐规则
	pluginJs.configs.recommended,
	// ts 默认推荐规则
	...tseslint.configs.recommended,
	// vue3 基础推荐规则
	...pluginVue.configs["flat/recommended"],
	// prettier 默认推荐规则
	pluginPrettierRecommendedConfigs,
	{
		languageOptions: {
			globals: {
				...globals.browser,
				...globals.es2020,
				...globals.node,
			},
			ecmaVersion: 2020,
			parser: parserVue,
			parserOptions: {
				parser: tseslint.parser,
			},
		},
		ignores: ["*.d.ts"],
		rules: {
			"@typescript-eslint/no-explicit-any": 0,
			"@typescript-eslint/no-empty-object-type": 0,
			"no-unused-expressions": 0,
			"@typescript-eslint/no-unused-expressions": 0,
			"no-undef": 0,
			"no-unused-vars": "off",
			"@typescript-eslint/no-unused-vars": ["error", { varsIgnorePattern: "^_", argsIgnorePattern: "^_" }],
			"vue/multi-word-component-names": "off",
		},
	},
];
