<script setup lang="ts">
import { useFavicon } from '@vueuse/core';
import { computed, onMounted, useCssModule, useTemplateRef } from 'vue';

import CollapsedLogo from './collapsed.svg';
import IntegremeLogo from './logo.svg';

const props = defineProps<
	(
		| {
				size: 'large';
		  }
		| {
				size: 'small';
				collapsed: boolean;
		  }
	) & {
		releaseChannel: 'stable' | 'beta' | 'nightly' | 'dev';
	}
>();

const { size, releaseChannel } = props;

const $style = useCssModule();
const containerClasses = computed(() => {
	if (size === 'large') {
		return [$style.logoContainer, $style.large];
	}
	return [
		$style.logoContainer,
		$style.sidebar,
		props.collapsed ? $style.sidebarCollapsed : $style.sidebarExpanded,
	];
});

const svg = useTemplateRef<{ $el: Element }>('logo');
onMounted(() => {
	if (releaseChannel === 'stable' || !('createObjectURL' in URL)) return;

	const logoEl = svg.value!.$el;

	// Reuse the SVG as favicon
	const blob = new Blob([logoEl.outerHTML], { type: 'image/svg+xml' });
	useFavicon(URL.createObjectURL(blob));
});

const shouldShowCollapsedLogo = computed(() => {
	return size === 'small' && props.collapsed;
});
</script>

<template>
	<div :class="containerClasses" data-test-id="n8n-logo">
		<CollapsedLogo v-if="shouldShowCollapsedLogo" ref="logo" :class="$style.logo" />
		<IntegremeLogo v-else ref="logo" :class="$style.logo" />
	</div>
</template>

<style lang="scss" module>
.logoContainer {
	display: flex;
	justify-content: center;
	align-items: center;
}

.logoText {
	margin-left: var(--spacing--5xs);
	path {
		fill: var(--color--text--shade-1);
	}
}

.large {
	transform: scale(2);
	margin-bottom: var(--spacing--xl);

	.logo,
	.logoText {
		transform: scale(1.3) translateY(-2px);
	}

	.logoText {
		margin-left: var(--spacing--xs);
		margin-right: var(--spacing--3xs);
	}
}

.sidebarExpanded .logo {
	width: 100%;
	max-width: 200px;
	height: auto;
	margin-left: var(--spacing--2xs);
}

.sidebarCollapsed .logo {
	width: 40px;
	height: auto;
	margin-left: var(--spacing--2xs);
	padding: 0 var(--spacing--4xs);
}

.logo {
	display: block;
	width: 100%;
	height: auto;
}
</style>
