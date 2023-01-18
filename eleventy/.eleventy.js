const htmlmin = require('html-minifier');
const { DateTime, Zone } = require("luxon");
const markdownIt = require("markdown-it");
const { EleventyHtmlBasePlugin } = require("@11ty/eleventy");

function eleventyConfig(config) {
	// Passthroughs
	config.addPassthroughCopy("src/img");

	config.addFilter("postDate", (dateObj) => {
		return DateTime.fromJSDate(dateObj).toISODate();
	  });

	// Layout aliases
	config.addLayoutAlias("base", "layouts/base.njk");
	config.addPlugin(EleventyHtmlBasePlugin);

	// Minify HTML
	const isProduction = process.env.ELEVENTY_ENV === "production";

	var htmlMinify = function(value, outputPath) {
		if (outputPath && outputPath.indexOf('.html') > -1) {
			return htmlmin.minify(value, {
				useShortDoctype: true,
				removeComments: true,
				collapseWhitespace: true,
				minifyCSS: true
			});
		}
	}

	// html min only in production
	if (isProduction) {
		config.addTransform("htmlmin", htmlMinify);
		
	}

	let options = {
		html: true,
		breaks: true,
		linkify: true
	  };
	
	config.setLibrary("md", markdownIt(options));

	// Configuration
	return {
		dir: {
			input: "src",
			output: "dist",
			includes: "includes",
			data: "data",
		},
		templateFormats: ["html", "njk", "md", "11ty.js"],
		htmlTemplateEngine: "njk",
		markdownTemplateEngine: "njk",
	};
};

module.exports = eleventyConfig;
