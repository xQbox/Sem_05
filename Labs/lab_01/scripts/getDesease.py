import requests
from bs4 import BeautifulSoup
import string
import csv

# Генерируем список ссылок
BASE_URL = "https://en.wikipedia.org/wiki/List_of_diseases_"
links = [f"{BASE_URL}({letter})" for letter in string.ascii_uppercase]

# Список для сохранения болезней
all_diseases = []

for link in links:
    print(f"Парсинг страницы: {link}")
    response = requests.get(link)
    
    if response.status_code == 200:
        # Парсим HTML-контент
        soup = BeautifulSoup(response.text, "html.parser")
        
        # Находим список болезней (обычно в элементах <li>)
        for item in soup.find_all('li'):
            disease_name = item.get_text(strip=True)
            # Фильтруем только названия болезней
            if disease_name and not disease_name.startswith(('List of diseases', 'Jump to', 'Navigation', 'Wikipedia')):
                all_diseases.append(disease_name)
    else:
        print(f"Не удалось загрузить страницу: {link}")

# Убираем дубликаты (если есть)
all_diseases = list(set(all_diseases))

# Сохраняем болезни в CSV
csv_file = "diseasesName.csv"
with open(csv_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["diseaseName"])  # Заголовок
    for disease in all_diseases:
        writer.writerow([disease])

print(f"Найдено {len(all_diseases)} болезней")
print(f"Список болезней сохранён в файл: {csv_file}")
