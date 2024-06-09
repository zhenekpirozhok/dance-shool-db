import pandas as pd
import psycopg2
import re
from dotenv import load_dotenv
import os

# Функция для очистки данных
def clean_data(df):
    # Удаление ненужных символов, пробелов и кавычек
    df = df.map(lambda x: re.sub(r'\s+', ' ', str(x)).strip(' "\'') if isinstance(x, str) else x)
    # Замена null на пустые строки
    df = df.fillna('')
    return df

# Функция для загрузки данных
def load_data_to_db(conn, df, table_name, unique_key):
    cursor = conn.cursor()
    
    for index, row in df.iterrows():
        # Проверка существования записи по уникальному ключу
        cursor.execute(f"SELECT 1 FROM {table_name} WHERE {unique_key} = %s", (row[unique_key],))
        if cursor.fetchone() is None:
            # Формирование запроса для вставки данных
            columns = ', '.join(row.index)
            values = ', '.join(['%s'] * len(row))
            insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"
            try:
                cursor.execute(insert_query, tuple(row))
                conn.commit()  # Подтверждение транзакции после каждой вставки
            except Exception as e:
                print(f"Ошибка при вставке данных в таблицу {table_name}: {e}")
        else:
            print(f"Запись с {unique_key} = {row[unique_key]} уже существует, пропускаем.")
    
    cursor.close()

load_dotenv()

# Параметры подключения к базе данных
conn_params = {
    'dbname': 'dance_school',
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': 'localhost',  # или '127.0.0.1'
    'port': '5432'
}

# Список таблиц и соответствующих файлов CSV
tables = [
    {'name': 'Customers', 'file': 'customers.csv', 'unique_key': 'CustomerID'},
    {'name': 'Instructors', 'file': 'instructors.csv', 'unique_key': 'InstructorID'},
    {'name': 'Classes', 'file': 'classes.csv', 'unique_key': 'ClassID'},
    {'name': 'Subscriptions', 'file': 'subscriptions.csv', 'unique_key': 'SubscriptionID'},
    {'name': 'CustomerSubscriptions', 'file': 'customer_subscriptions.csv', 'unique_key': 'CustomerSubscriptionID'},
    {'name': 'Rooms', 'file': 'rooms.csv', 'unique_key': 'RoomID'},
    {'name': 'RoomRentals', 'file': 'room_rentals.csv', 'unique_key': 'RoomRentalID'},
    {'name': 'ClassSchedules', 'file': 'class_schedules.csv', 'unique_key': 'ClassScheduleID'}
]

# Подключение к базе данных
conn = psycopg2.connect(**conn_params)

try:
    for table in tables:
        # Проверка наличия файла перед чтением
        file_path = os.path.join(os.getcwd(), 'data', table['file'])
        if os.path.exists(file_path):
            # Чтение данных из CSV
            df = pd.read_csv(file_path)
            
            # Очистка данных
            df = clean_data(df)
            
            # Загрузка данных в базу
            load_data_to_db(conn, df, table['name'], table['unique_key'])
        else:
            print(f"Файл {file_path} не найден.")

finally:
    conn.close()



