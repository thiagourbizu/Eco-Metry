import random

# Función para leer las palabras desde el archivo palabras.txt
def leer_palabras():
    with open("palabras.txt", "r") as archivo:
        contenido = archivo.read()
        palabras = contenido.split(", ")  # Separar las palabras por comas y espacios
    return palabras

# Función para seleccionar la palabra secreta y los impostores
def seleccionar_palabra_y_impostores(jugadores, num_impostores):
    palabras = leer_palabras()  # Leer palabras desde el archivo
    palabra_secreta = random.choice(palabras)  # Seleccionar una palabra aleatoria
    impostores = random.sample(jugadores, num_impostores)  # Seleccionar impostores aleatorios
    return palabra_secreta, impostores

# Función principal del juego
def juego_spy():
    # Preguntar cuántos jugadores y cuántos impostores
    num_jugadores = int(input("Jugadores: "))
    num_impostores = int(input(f"Impostores: "))

    # Verificación básica para evitar que haya más impostores que jugadores
    if num_impostores >= num_jugadores:
        print("El número de impostores debe ser menor que el número de jugadores.")
        return

    # Crear lista de jugadores
    jugadores = [f"Jugador {i + 1}" for i in range(num_jugadores)]

    # Seleccionar palabra secreta e impostores
    palabra_secreta, impostores = seleccionar_palabra_y_impostores(jugadores, num_impostores)

    # Asignar roles e informar a los jugadores
    print("\n--- Roles asignados ---")
    for jugador in jugadores:
        if jugador in impostores:
            print(f"{jugador}, eres un IMPOSTOR.")
            input("Pulsa ENTER")
            for i in range(75):
                print("#")
        else:
            print(f"{jugador}, la palabra es: {palabra_secreta}")
            input("Pulsa ENTER")
            
            for i in range(75):
                print("#")

# Ejecutar el juego
juego_spy()
