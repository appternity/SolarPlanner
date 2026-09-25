import pdfplumber
from PIL import Image
import pytesseract
import os

# --- UPDATE THIS PATH AFTER INSTALLING TESSERACT ---
# I am trying common installation paths. If yours is different, please update this.
TESSERACT_PATH = r'C:\Program Files\Tesseract-OCR\tesseract.exe' 
# ---------------------------------------------------

pytesseract.pytesseract.tesseract_cmd = TESSERACT_PATH

def ocr_pdf(pdf_path, output_md_path):
    print(f"Starting OCR process for: {pdf_path}")
    full_text = []

    try:
        # Verify if tesseract exists at the specified path first
        if not os.path.exists(TESSERACT_PATH):
            raise FileNotFoundError(f"Tesseract executable not found at: {TESSERACT_PATH}. Please check your installation path.")

        with pdfplumber.open(pdf_path) as pdf:
            for i, page in enumerate(pdf.pages):
                print(f"Processing Page {i+1}...")
                # Convert page to image (high resolution for better OCR)
                im = page.to_image(resolution=300)
                img_path = f"temp_page_{i}.png"
                im.save(img_path)

                # Perform OCR (trying English and German)
                text = pytesseract.image_to_string(Image.open(img_path), lang='eng+deu')
                full_text.append(f"## Page {i+1}\n")
                full_text.append(text)
                full_text.append("\n\n")

                # Clean up temp image
                os.remove(img_path)

        if full_text:
            with open(output_md_path, 'w', encoding='utf-8') as f:
                f.write("".join(full_text))
            print(f"OCR successful! Saved to: {output_md_path}")
        else:
            print("No text extracted.")

    except Exception as e:
        print(f"Error during OCR: {e}")

if __name__ == "__main__":
    input_pdf = r"data\datenblatt\module\JAM54D41 430-455 LB_25-yr warranty.pdf"
    output_md = "data/datenblatt/module/JAM54D41_ocr_result.md"
    ocr_pdf(input_pdf, output_md)
