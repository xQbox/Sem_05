import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta

# Настройки подключения к базе данных
DB_CONFIG = {
    'dbname': 'medicine_center',
    'user': 'postgres',
    'password': 'your_password',
    'host': '127.0.0.1',
    'port': '5432'
}

# Генерация данных с помощью Faker
faker = Faker('ru_RU')  # Генерация данных на русском

def generate_patients(cursor, num=10):
    for _ in range(num):
        surname = faker.last_name()[:30]
        name = faker.first_name()[:30]
        second_surname = faker.middle_name() if random.random() > 0.5 else None
        birthday = faker.date_of_birth(minimum_age=0, maximum_age=100)
        address = faker.address()[:50]
        profession = faker.job()[:30]
        sex = random.choice(['М', 'Ж'])
        
        cursor.execute("""
            INSERT INTO nsMed.Patients (patientSurname, patientName, patientSecondSurname, 
                                        patientDateOfBirthday, patientAddress, patientProfession, patientSex)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (surname, name, second_surname, birthday, address, profession, sex))

def generate_doctors(cursor, num=5):
    for _ in range(num):
        surname = faker.last_name()[:30]
        name = faker.first_name()[:30]
        second_surname = faker.middle_name() if random.random() > 0.5 else None
        birthday = faker.date_of_birth(minimum_age=25, maximum_age=70)
        speciality = faker.job()[:30]
        experience = random.randint(1, 40)
        
        cursor.execute("""
            INSERT INTO nsMed.Doctors (doctorSurname, doctorName, doctorSecondSurname, 
                                       doctorDateOfBirthday, doctorSpeciality, doctorExperience)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (surname, name, second_surname, birthday, speciality, experience))

def generate_diseases(cursor, num=10):
    for _ in range(num):
        name = faker.word()[:30]
        disease_class = random.choice(['Инфекционные', 'Хронические', 'Острые'])
        disease_type = random.choice(['Вирусное', 'Бактериальное', 'Грибковое'])
        treatment = random.choice(['Медикаментозное', 'Физиотерапия', 'Оперативное'])
        
        cursor.execute("""
            INSERT INTO nsMed.Disease (diseaseName, diseaseClass, diseaseType, diseaseTreatment)
            VALUES (%s, %s, %s, %s)
        """, (name, disease_class, disease_type, treatment))

def generate_patients_cards(cursor, num=15):
    cursor.execute("SELECT patientId FROM nsMed.Patients")
    patient_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT doctorId FROM nsMed.Doctors")
    doctor_ids = [row[0] for row in cursor.fetchall()]
    cursor.execute("SELECT diseaseId FROM nsMed.Disease")
    disease_ids = [row[0] for row in cursor.fetchall()]
    
    for _ in range(num):
        patient_id = random.choice(patient_ids)
        doctor_id = random.choice(doctor_ids)  # Одиночное значение
        disease_id = random.choice(disease_ids)  # Одиночное значение
        date_of_visit = faker.date_between(start_date='-2y', end_date='today')
        symptoms = faker.sentence()
        recommendations = faker.sentence()
        degree_of_severity = random.randint(1, 5)
        
        cursor.execute("""
            INSERT INTO nsMed.patientsCard (patientId, doctorId, diseaseId, dataOfVisit, symptoms, recommendations, degreeOfSeverity)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (patient_id, doctor_id, disease_id, date_of_visit, symptoms, recommendations, degree_of_severity))

def main():
    try:
        # Подключение к базе данных
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Генерация данных
        generate_patients(cursor, num=1000)
        generate_doctors(cursor, num=1000)
        generate_diseases(cursor, num=1000)
        generate_patients_cards(cursor, num=1000)
        
        conn.commit()  # Сохранение изменений
        print("Данные успешно добавлены!")
        
        # Чтение данных
        cursor.execute("SELECT * FROM nsMed.Patients LIMIT 10")
        for row in cursor.fetchall():
            print(row)
        
    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()
