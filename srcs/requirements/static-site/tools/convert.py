#!/usr/bin/env python3
import os
import re
import sys

import markdown


def convert_md_to_html(md_file, output_file):
    with open(md_file, "r", encoding="utf-8") as f:
        md_content = f.read()

    html_content = markdown.markdown(
        md_content, extensions=["extra", "codehilite", "toc"]
    )
    html_content = re.sub(r'href="([^"]+)\.md"', r'href="\1.html"', html_content)
    html_content = re.sub(r"href='([^']+)\.md'", r"href='\1.html'", html_content)
    html_content = re.sub(
        r'href="([^":#/]+)"(?![^<]*\.html")', r'href="\1.html"', html_content
    )
    html_content = re.sub(
        r"href='([^':#/]+)'(?![^<]*\.html')", r"href='\1.html'", html_content
    )

    full_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>miniRT Wiki</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: #f6f8fa;
        }}
        .container {{
            background: white;
            padding: 30px;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }}
        h1, h2, h3 {{ color: #24292e; }}
        code {{
            background: #f6f8fa;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Monaco', 'Courier New', monospace;
        }}
        pre {{
            background: #f6f8fa;
            padding: 16px;
            border-radius: 6px;
            overflow-x: auto;
        }}
        pre code {{
            background: none;
            padding: 0;
        }}
        a {{ color: #0366d6; text-decoration: none; }}
        a:hover {{ text-decoration: underline; }}
        table {{
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }}
        th, td {{
            border: 1px solid #dfe2e5;
            padding: 8px 12px;
            text-align: left;
        }}
        th {{ background: #f6f8fa; }}
        img {{ max-width: 100%; }}
        .nav {{
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/static/">Home</a> | <a href="/static/all-pages.html">All Pages</a>
        </div>
        {html_content}
    </div>
</body>
</html>"""

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(full_html)


def create_index(wiki_dir, output_dir):
    files = []
    for root, dirs, filenames in os.walk(wiki_dir):
        for filename in filenames:
            if filename.endswith(".md"):
                rel_path = os.path.relpath(os.path.join(root, filename), wiki_dir)
                files.append(rel_path)

    home_page = None
    for file in files:
        filename = os.path.basename(file)
        if filename in ["Home.md", "Home-FR.md"]:
            home_page = filename.replace(".md", ".html")
            break

    if home_page:
        index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url={home_page}">
    <title>Redirecting to miniRT Wiki...</title>
</head>
<body>
    <p>Redirecting to <a href="{home_page}">Home</a>...</p>
</body>
</html>"""
    else:
        index_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>miniRT Wiki</title>
</head>
<body>
    <h1>miniRT Wiki</h1>
    <p><a href="all-pages.html">View All Pages</a></p>
</body>
</html>"""

    with open(os.path.join(output_dir, "index.html"), "w", encoding="utf-8") as f:
        f.write(index_html)
    all_pages_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All Pages - miniRT Wiki</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: #f6f8fa;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }
        h1 { color: #24292e; }
        ul { list-style: none; padding: 0; }
        li { padding: 8px 0; border-bottom: 1px solid #eee; }
        a { color: #0366d6; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .nav {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav">
            <a href="/static/">Home</a>
        </div>
        <h1>All Pages</h1>
        <p>Complete list of all wiki pages:</p>
        <ul>
"""

    for file in sorted(files):
        html_file = os.path.basename(file).replace(".md", ".html")
        title = os.path.basename(file).replace(".md", "").replace("-", " ")
        all_pages_html += f'            <li><a href="{html_file}">{title}</a></li>\n'

    all_pages_html += """        </ul>
    </div>
</body>
</html>"""

    with open(os.path.join(output_dir, "all-pages.html"), "w", encoding="utf-8") as f:
        f.write(all_pages_html)


if __name__ == "__main__":
    wiki_dir = "/app/wiki"
    output_dir = "/usr/share/nginx/html"

    for root, dirs, files in os.walk(wiki_dir):
        for file in files:
            if file.endswith(".md"):
                md_path = os.path.join(root, file)
                rel_path = os.path.relpath(md_path, wiki_dir)

                html_filename = os.path.basename(file).replace(".md", ".html")
                html_path = os.path.join(output_dir, html_filename)

                print(f"Converting {rel_path} -> {html_filename}...")
                convert_md_to_html(md_path, html_path)

    create_index(wiki_dir, output_dir)
    print("Conversion complete!")
