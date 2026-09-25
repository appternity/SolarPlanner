import os
from markitdown import MarkItDown

def process_all_pdfs(root_dir):
    mid = MarkItDown()
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith(".pdf"):
                input_path = os.path.join(root, file)
                # Create output filename: replace .pdf with _raw.md and prepare for correction
                base_name = os.path.splitext(file)[0]
                raw_output_path = os.path.join(root, f"{base_name}_raw.md")
                
                print(f"--- Processing: {file} ---")
                try:
                    result = mid.convert(input_path)
                    with open(raw_output_path, 'w', encoding='utf-8') as f:
                        f.write(result.text_content)
                    print(f"Successfully created raw markdown: {raw_output_path}")
                except Exception as e:
                    print(f"Error converting {file}: {e}")

if __name__ == "__main__":
    process_all_pdfs("data/datenblatt")
