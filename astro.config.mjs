// @ts-check
import { defineConfig } from 'astro/config';
import { typst } from "astro-typst";
import sitemap from "@astrojs/sitemap";

// https://astro.build/config
export default defineConfig({
  site: 'https://ahxt.github.io',
  base: '/',
  
  integrations: [
    sitemap({
      // Customize sitemap generation
      changefreq: 'weekly',
      priority: 0.7,
      lastmod: new Date(),
      // Custom entry point for specific pages
      customPages: [
        'https://ahxt.github.io/',
        'https://ahxt.github.io/blog',
      ],
    }),
    typst({
      target: (id) => {
        return "html";
      }
    }),
  ],
  
  // Build optimizations for better performance and SEO
  build: {
    // Inline stylesheets smaller than this limit (in bytes)
    inlineStylesheets: 'auto',
  },
  
  // Vite configuration for better optimization
  vite: {
    build: {
      // Enable CSS code splitting for better performance
      cssCodeSplit: true,
      // Minify for production
      minify: 'esbuild',
      // Enable source maps for debugging
      sourcemap: false,
    },
  },
  
  // Output configuration
  output: 'static',
  
  // Markdown configuration for blog posts
  markdown: {
    // Shiki for syntax highlighting
    shikiConfig: {
      theme: 'github-light',
      wrap: true,
    },
  },
  
  // Security headers and other performance optimizations
  server: {
    headers: {
      'Cache-Control': 'public, max-age=31536000, immutable',
    },
  },
});
