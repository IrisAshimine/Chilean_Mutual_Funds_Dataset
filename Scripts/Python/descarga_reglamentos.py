import os
import time
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
from webdriver_manager.chrome import ChromeDriverManager

# Create a folder to save PDFs
os.makedirs("cmf_funds_ri", exist_ok=True)

# Function to start WebDriver with retries
def start_driver(retries=3):
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")  # Run in background mode
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920,1080")

    for attempt in range(retries):
        try:
            service = Service(ChromeDriverManager().install())
            driver = webdriver.Chrome(service=service, options=options)
            time.sleep(3)  # Allow time for WebDriver to fully start
            return driver
        except Exception as e:
            print(f"Error starting WebDriver (attempt {attempt+1}): {e}")
            time.sleep(3)  # Wait before retrying
    
    raise Exception("Failed to start WebDriver after multiple attempts")

# Function to download a PDF file
def download_pdf(pdf_url, save_path):
    try:
        response = requests.get(pdf_url, stream=True)
        with open(save_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=1024):
                file.write(chunk)
        print(f"✅ Downloaded: {save_path}")
    except Exception as e:
        print(f"Error downloading {pdf_url}: {e}")

# Step 1: Extract mutual fund links from the main page
def get_fund_links():
    base_url = "https://www.cmfchile.cl/portal/principal/613/w3-propertyvalue-18585.html"
    driver = start_driver()
    driver.get(base_url)
    time.sleep(3)  # Allow time for page to load

    fund_links = []
    try:
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "table")))
        soup = BeautifulSoup(driver.page_source, "html.parser")
        fund_table = soup.find("table")  # Find the table containing fund names

        for row in fund_table.find_all("tr")[1:]:  # Skip header row
            link = row.find("a")
            if link and 'href' in link.attrs:
                fund_links.append("https://www.cmfchile.cl" + link["href"])

    except Exception as e:
        print(f"Error extracting fund links: {e}")

    driver.quit()
    return fund_links

# Step 2: Process each mutual fund to extract and download PDFs
def process_funds(fund_links):
    for fund_url in fund_links:
        driver = start_driver()  # Start a fresh session for each fund
        try:
            driver.get(fund_url)
            time.sleep(2)

            # Click the "Reglamento Interno" button
            reg_button = WebDriverWait(driver, 5).until(
                EC.element_to_be_clickable((By.PARTIAL_LINK_TEXT, "Reglamento Interno"))
            )
            reg_button.click()
            time.sleep(2)

            # Switch to the "Reglamento Interno" page
            driver.switch_to.window(driver.window_handles[-1])
            soup = BeautifulSoup(driver.page_source, "html.parser")
            pdf_links = []

            # Extract all PDF download links
            for a in soup.find_all("a", href=True):
                if "descarga" in a["href"].lower():
                    pdf_links.append("https://www.cmfchile.cl" + a["href"])

            # Download each PDF
            for pdf_link in pdf_links:
                pdf_name = pdf_link.split("/")[-1]
                save_path = os.path.join("cmf_fund_pdfs", pdf_name)
                download_pdf(pdf_link, save_path)

            driver.quit()  # Close browser session

        except Exception as e:
            print(f"Error processing fund {fund_url}: {e}")
            driver.quit()

# Main execution
if __name__ == "__main__":
    print("🔍 Extracting fund links...")
    fund_links = get_fund_links()
    print(f"🔗 Found {len(fund_links)} mutual funds.")

    if fund_links:
        print("Processing")
        process_funds(fund_links)
        print("All PDFs downloaded")
    else:
        print("No fund links found.")

