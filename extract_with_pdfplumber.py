import pdfplumber

def extract_with_pdfplumber(pdf_path, output_md_path):
    print(f"Attempting extraction with pdfplumber: {pdf_path}")
    text_content = []
    
    try:
        with pdfplumber.open(pdf_path) as pdf:
            for i, page in enumerate(pdf.pages):
                print(f"Processing page {i+1}/{len(pdf.pages)}...")
                # Extract text
                page_text = page.extract_text()
                if page_text:
                    text_content.append(f"## Page {i+1}\n")
                    text_content.append(page_text)
                    text_content.append("\n\n")
                else:
                    print(f"Warning: No text found on page {i+1}")

                # Try to extract tables as well
                tables = page.extract_tables()
                if tables:
                    text_content.append(f"### Tables on Page {i+1}\n")
                    for table in tables:
                        text_content.append("| " + " | ".join([str(cell if cell is not None else "") for cell in table[0]]) + " |\n")
                        text_content.append("| " + " | ".join(["---"] * len(table[0])) + " |\n")
                        for row in table[1:]:
                            text_content.append("| " + " | ".join([str(cell if cell is not None else "") for cell in row]) + " |\n")
                        text_content.append("\n")

        if text_content:
            with open(output_md_path, 'w', encoding='utf-8') as f:
                f.write("".join(text_content))
            print(f"Successfully extracted to: {output_md_path}")
        else:
            print("Failed to extract any content.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    input_pdf = r"data\datenblatt\module\JAM54D41 430-455 LB_25-yr warranty.pdf"
    output_md = "data/datenblatt/module/JAM54D41_extracted.md"
    extract_with_pdfplumber(input_pdf, output_md)
