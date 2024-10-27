# zirpo's blog

This repository contains both the local development environment and the GitHub Pages static site for zirpo's blog.

## Project Structure

- `*.php` files - Local development environment for content creation
- `*.sh` files - Shell scripts for local content processing
- `index.html` - Static site entry point for GitHub Pages
- `style.css` - Shared styling
- `markdown/` - Blog post content in markdown format
- `images/` - Image assets for blog posts
- `generate_posts_json.py` - Script to generate posts.json for the static site

## Workflow

1. Create and edit content locally using the PHP environment
2. Use the shell scripts to process images and content as needed
3. Run `python3 generate_posts_json.py` to update the static site content
4. Commit and push changes to update the GitHub Pages site

## Local Development

Use the PHP environment to create and preview content:
```bash
php -S localhost:8000
```

## GitHub Pages

The static version of the site is served through GitHub Pages using:
- index.html - Main entry point
- posts.json - Generated content from markdown files
- style.css - Styling
- markdown/ - Content directory
- images/ - Image assets
