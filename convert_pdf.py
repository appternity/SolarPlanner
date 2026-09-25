from markitdown import MarkItDown

def convert_pdf_to_md(input_path, output_path):
    mid = MarkItDown()
    print(f"Converting {input_path} to markdown...")
    try:
        result = mid.convert(input_path)
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(result.text_content)
        print(f"Successfully converted to {output_path}")
    except Exception as e:
        print(f"Error during conversion: {e}")

if __name__ == "__main__":
    input_pdf = r"data\datenblatt\module\Datenblatt-Tiger_Neo_54HL4R-V_JKM435-460N-54HL4R-V-F8-EU.pdf"
    output_md = "datenblatt_tiger_neo_converted.md"
    convert_pdf_to_md(input_pdf, output_md)
