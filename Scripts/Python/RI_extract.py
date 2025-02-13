import os
import pdfplumber
import pandas as pd

# Ruta de la carpeta donde se guardan los PDFs descargados
pdf_folder = "Reglamentos_internos"
output_csv = "fund_series.csv"

# Función para extraer tablas de los PDFs
def extract_series_table(pdf_path):
    extracted_data = []
    fund_name = None

    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            
            # Extraer el nombre del fondo de la primera página
            if i == 0 and "Nombre del Fondo" in text:
                for line in text.split("\n"):
                    if "Nombre del Fondo" in line:
                        fund_name = line.split(":")[-1].strip()
                        break
            
            # Buscar la sección "Series" y extraer las tablas
            if "SERIES, REMUNERACIONES, COMISIONES Y GASTOS" in text:
                tables = page.extract_tables()
                for table in tables:
                    for row in table:
                        if len(row) >= 6:  # Asegurar que la fila es válida
                            extracted_data.append([fund_name] + row)

    return extracted_data

# Procesar todos los PDFs en la carpeta
def process_pdfs(pdf_folder):
    all_data = []
    
    for pdf_file in os.listdir(pdf_folder):
        if pdf_file.endswith(".pdf"):
            pdf_path = os.path.join(pdf_folder, pdf_file)
            extracted_data = extract_series_table(pdf_path)
            all_data.extend(extracted_data)

    return all_data

# Ejecutar la extracción
data = process_pdfs(pdf_folder)

# Definir nombres de columnas
columns = ["Nombre del Fondo", "Denominación", "Requisitos de Ingreso", "Valor cuota inicial",
           "Moneda en que se recibirán los aportes", "Moneda en que se pagarán los rescates", "Otra característica relevante"]

# Convertir a DataFrame
df = pd.DataFrame(data, columns=columns)

# Guardar datos en CSV
df.to_csv(output_csv, index=False, encoding='utf-8-sig')

