import json
import os
import glob
from datetime import datetime

def get_file_date(filepath):
    return datetime.fromtimestamp(os.path.getmtime(filepath))

# Get all markdown files
markdown_files = glob.glob('markdown/*.md')

# Sort files by modification time (newest first)
markdown_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)

# Read content of each file
posts = []
for file_path in markdown_files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            posts.append({
                'file': os.path.basename(file_path),
                'content': content,
                'date': get_file_date(file_path).isoformat()
            })
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

# Write to posts.json
with open('posts.json', 'w', encoding='utf-8') as f:
    json.dump(posts, f, ensure_ascii=False, indent=2)

print(f"Successfully generated posts.json with {len(posts)} posts")
