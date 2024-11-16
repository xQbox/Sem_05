import os
import csv
import random
from faker import Faker
import psycopg2

# Настройки базы данных
DB_CONFIG = {
    'dbname': 'medicine_center',
    'user': 'postgres',
    'password': 'your_password',
    'host': '127.0.0.1',
    'port': '5432'
}

# Создание папки для хранения CSV файлов
output_dir = './../data'
os.makedirs(output_dir, exist_ok=True)

# Инициализация Faker
faker = Faker('ru_RU')

# Генерация данных для каждой таблицы
def generate_patients(num=100):
    patients = []
    for i in range(1, num + 1):  # i будет инкрементироваться от 1 до num
        patients.append([
            i,  # patientId, добавляем уникальный идентификатор пациента
            faker.last_name()[:30],               # patientSurname
            faker.first_name()[:30],              # patientName
            faker.middle_name()[:30],             # patientSecondSurname
            faker.date_of_birth(minimum_age=1, maximum_age=100),  # patientDateOfBirthday
            faker.address()[:50],                 # patientAddress
            faker.job()[:30],                     # patientProfession
            random.choice(['М', 'Ж'])        # patientSex
        ])
    return patients


def generate_doctors(num=30):
    doctors = []
    tmp = 1
    for _ in range(num):
        doctors.append([
        tmp,
        faker.last_name()[:30],               # doctorSurname
        faker.first_name()[:30],              # doctorName
        faker.middle_name()[:30],             # doctorSecondSurname
        faker.date_of_birth(minimum_age=25, maximum_age=70),  # doctorDateOfBirthday
        random.choice([                       # doctorSpeciality
            "Хирург", "Терапевт", "Онколог", "Невропатолог", "Кардиолог", 
            "Офтальмолог", "Педиатр", "Гастроэнтеролог", "Дерматолог", "Эндокринолог",
            "ЛОР (отоларинголог)", "Ревматолог", "Пульмонолог", "Уролог", "Гинеколог", 
            "Нефролог", "Аллерголог", "Инфекционист", "Стоматолог", "Ортопед", 
            "Психиатр", "Психотерапевт", "Нарколог", "Гематолог", "Физиотерапевт",
            "Флеболог", "Травматолог", "Ангиолог", "Маммолог", "Иммунолог"
        ]),
        random.randint(1, 50)                # doctorExperience
        ])
        tmp += 1

    return doctors

def load_diseases_from_file(filename):
    diseases = []
    with open(filename, "r", encoding="utf-8") as file:
        reader = csv.reader(file)
        next(reader)  # Пропускаем заголовок
        for row in reader:
            if row:  # Проверяем, что строка не пустая
                diseases.append(row[0])
    return diseases

def generate_diseases(disease_file, num=20):
    # Загрузка болезней из файла
    disease_names = load_diseases_from_file(disease_file)
    
    diseases = []
    disease_id = 1  # Инициализация счетчика для diseaseId
    
    for _ in range(num):
        diseases.append([
            disease_id,  # diseaseId, инкрементируем идентификатор болезни
            random.choice(disease_names)[:30],              # diseaseName
            random.choice(['Инфекционные', 'Хронические', 'Острые']),  # diseaseClass
            random.choice(['Вирусное', 'Бактериальное', 'Грибковое']),  # diseaseType
            random.choice(['Медикаментозное', 'Физиотерапия', 'Оперативное'])  # diseaseTreatment
        ])
        disease_id += 1  # Инкрементируем идентификатор болезни
    
    return diseases


def generate_patients_cards(patients, doctors, diseases, num=20):
    patientsCards = []
    unique_combinations = set()  # Множество для хранения уникальных сочетаний
    
    # Извлекаем только ID для использования в качестве внешних ключей
    patient_ids = list(range(1, len(patients) + 1))
    doctor_ids = list(range(1, len(doctors) + 1))
    disease_ids = list(range(1, len(diseases) + 1))

    for _ in range(num):
        # Генерируем случайное сочетание из уже существующих ID
        patientId = random.choice(patient_ids)
        doctorId = random.choice(doctor_ids)
        diseaseId = random.choice(disease_ids)
        dataOfVisit = faker.date_between(start_date='-2y', end_date='today')
        
        # Проверяем уникальность сочетания
        while (patientId, doctorId, diseaseId, dataOfVisit) in unique_combinations:
            patientId = random.choice(patient_ids)
            doctorId = random.choice(doctor_ids)
            diseaseId = random.choice(disease_ids)
            dataOfVisit = faker.date_between(start_date='-2y', end_date='today')
        
        # Добавляем сочетание в уникальные
        unique_combinations.add((patientId, doctorId, diseaseId, dataOfVisit))
        
        # Добавляем запись в список
        patientsCards.append([
            patientId,                              # patientId
            doctorId,                               # doctorId
            diseaseId,                              # diseaseId
            dataOfVisit,                            # dataOfVisit
            faker.sentence(),                       # symptoms
            random.randint(1, 5)                    # degreeOfSeverity
        ])
    
    return patientsCards


def save_to_csv(data, headers, filename):
    filepath = os.path.join(output_dir, filename)
    with open(filepath, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        writer.writerows(data)
    print(f"Данные сохранены в {filepath}")
    return filepath

def load_csv_to_db(filepath, table_name, cursor):
    with open(filepath, 'r', encoding='utf-8') as file:
        next(file)  # Пропуск заголовков
        cursor.copy_from(file, table_name, sep=',')
    print(f"Данные из {filepath} загружены в таблицу {table_name}")

def main():
    # Генерация данных
    patients = generate_patients(1000)
    doctors = generate_doctors(1000)
    diseases = generate_diseases('diseasesName.csv', 1000)
    patietnsCard = generate_patients_cards(patients, doctors, diseases, 1000)
    # Сохранение данных в CSV
    patients_file = save_to_csv(patients, ['patientSurname', 'patientName', 'patientSecondSurname', 'patientDateOfBirthday', 'patientAddress', 'patientProfession', 'patientSex'], 'patients.csv')
    doctors_file = save_to_csv(doctors, ['doctorSurname', 'doctorName', 'doctorSecondSurname', 'doctorDateOfBirthday', 'doctorSpeciality', 'doctorExperience'], 'doctors.csv')
    diseases_file = save_to_csv(diseases, ['diseaseName', 'diseaseClass', 'diseaseType', 'diseaseTreatment'], 'diseases.csv')
    patients_file = save_to_csv(patietnsCard, 
    ["patientCard", "patientId", "doctorId", "diseaseId", 
    "dataOfVisit", "symptoms", "recommendations", "degreeOfSeverity"],
    'patientsCard.csv'
    )
     



if __name__ == "__main__":
    main()
