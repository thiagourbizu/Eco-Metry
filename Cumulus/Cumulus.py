from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time
import json

# Ruta del archivo de entrada y salida
input_file_path = "C:\\Cumulus\\realtime.txt"
output_file_path = "C:\\Cumulus\\actual.json"

# Lista de etiquetas en español para cada dato
labels = [
    "Fecha",  # Date
    "Hora",  # Time
    "Temperatura exterior",  # Outside temperature
    "Humedad exterior",  # Relative humidity
    "Punto de rocío",  # Dewpoint
    "Velocidad del viento (promedio)",  # Wind speed (average)
    "Última lectura Velocidad del viento",  # Latest wind speed reading
    "Dirección del viento (grados)",  # Wind bearing (degrees)
    "Tasa actual de lluvia (p/h)",  # Current rain rate (per hour)
    "Lluvia hoy",  # Rain today
    "Barómetro",  # Barometer (The sea level pressure)
    "Dirección del viento actual",  # Current wind direction (compass point)
    "Velocidad del viento (beaufort)",  # Wind speed as in 6 converted to force number (beaufort)
    "Unidades de velocidad del viento",  # Wind units - m/s, mph, km/h, kts
    "Unidades de temperatura",  # Temperature units - degree C, degree F
    "Unidades de presión",  # Pressure units - mb, hPa, in
    "Unidades de lluvia",  # Rain units - mm, in
    "Recorrido del viento (hoy)",  # Wind run (today)
    "Valor de tendencia de presión",  # Pressure trend value (The average rate of pressure change over the last three hours)
    "Lluvia mensual",  # Monthly rainfall
    "Lluvia anual",  # Yearly rainfall
    "Lluvia de ayer",  # Yesterday's rainfall
    "Temperatura interior",  # Inside temperature
    "Humedad interior",  # Inside humidity
    "Sensación térmica",  # Wind chill
    "Tendencia de temperatura",  # Temperature trend value (The average rate of change in temperature over the last three hours)
    "Temperatura máxima",  # Today's high temp
    "Horario Temperatura máxima",  # Time of today's high temp (hh:mm)
    "Temperatura mínima",  # Today's low temp
    "Horario temperatura mínima",  # Time of today's low temp (hh:mm)
    "Velocidad máxima del viento",  # Today's high wind speed (of average as per choice)
    "Horario Velocidad máxima del viento",  # Time of today's high wind speed (average) (hh:mm)
    "Ráfaga máxima del viento",  # Today's high wind gust
    "Horario Ráfaga máxima del viento",  # Time of today's high wind gust (hh:mm)
    "Presión máxima de hoy",  # Today's high pressure
    "Horario Presión máxima",  # Time of today's high pressure (hh:mm)
    "Presión mínima de hoy",  # Today's low pressure
    "Horario de la presión mínima",  # Time of today's low pressure (hh:mm)
    "Versión de Cumulus",  # Cumulus Versions (the specific version in use)
    "Número de compilación de Cumulus",  # Cumulus build number
    "Ráfaga máxima de 10 minutos",  # 10-minute high gust
    "Índice de calor",  # Heat index
    "Humidex",  # Humidex
    "Índice UV",  # UV Index
    "Evapotranspiración",  # Evapotranspiration today
    "Radiación solar(W/m2)",  # Solar radiation W/m2
    "Promedio dirección del viento(10m)",  # 10-minute average wind bearing (degrees)
    "Lluvia en la última hora",  # Rainfall last hour
    "Número de pronóstico (Zambretti)",  # The number of the current (Zambretti) forecast as per Strings.ini.
    "Luz diurna",  # Flag to indicate that the location of the station is currently in daylight (1 = yes, 0 = no)
    "Pérdida de contacto con sensores remotos",  # If the station has lost contact with its remote sensors "Fine Offset only", a Flag number is given (1 = Yes, 0 = No)
    "Dirección promedio del viento",  # Average wind direction
    "Base de nubes",  # Cloud base
    "Unidades de base de nubes",  # Cloud base units
    "Temperatura aparente",  # Apparent temperature
    "Horas de sol",  # Sunshine hours so far today
    "Radiación solar teórica máxima actual",  # Current theoretical max solar radiation
    "¿Está soleado?",  # Is it sunny? 1 if the sun is shining, otherwise 0 (above or below threshold)
    "Temperatura de sensación",  # Feels Like Temperature
]

# Etiquetas cuyos valores queremos ignorar
ignore_labels = {
    "Unidades de velocidad del viento",
    "Unidades de temperatura",
    "Unidades de presión",
    "Unidades de lluvia",
    "Punto de rocío",
    "Sensación térmica",
    "Versión de Cumulus",
    "Índice de calor",
    "Número de pronóstico (Zambretti)",
    "Unidades de base de nubes",
    "Radiación solar teórica máxima actual",
    "Temperatura de sensación"
}

def process_file():
    """Función para procesar el archivo y guardar los datos etiquetados en actual.json"""
    try:
        # Leer la línea de datos desde el archivo de entrada
        with open(input_file_path, 'r') as file:
            data_line = file.readline().strip()

        # Separar los datos de la línea en una lista
        data_values = data_line.split()

        # Filtrar las etiquetas y valores a ignorar
        filtered_labels_values = [(label, value) for label, value in zip(labels, data_values) if label not in ignore_labels]

        # Crear un diccionario con los datos etiquetados
        data_labeled = {label: value for label, value in filtered_labels_values}

        # Escribir los datos etiquetados en el archivo de salida en formato JSON
        with open(output_file_path, 'w') as file:
            json.dump(data_labeled, file, indent=4, ensure_ascii=False)

        #print("Datos procesados y guardados en actual.json.")

    except Exception as e:
        print(f"Ocurrió un error al procesar el archivo: {e}")

class RealtimeFileHandler(FileSystemEventHandler):
    """Clase para manejar eventos de archivos"""

    def on_modified(self, event):
        if event.src_path == input_file_path:
            print(f"Detectada modificación en {input_file_path}. Procesando...")
            process_file()

if __name__ == "__main__":
    # Inicializar el observador
    observer = Observer()
    event_handler = RealtimeFileHandler()
    observer.schedule(event_handler, path='C:\\Cumulus', recursive=False)

    # Iniciar el observador
    observer.start()
    print("Monitorizando cambios en 'realtime.txt'...")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()
