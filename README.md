# iScore

En colaboración con:
* Alejandro Domínguez Medina
* Daniel Arturo Nuñez González
* Daniel Magaña

==Sistema electrónico que controla la proyección de un marcador de anotación de baloncesto emitido a través de un proyector VGA.==

El sistema está compuesto por tres grandes partes:

1. La primera consiste en un panel inalámbrico en donde un operador llevara el seguimiento del partido tomando en cuenta el siguiente grupo de estadísticas: Numero de jugador, puntos por jugador, tiros Libres, dobles, triples, asistencias, rebotes, faltas y minutos jugados. El panel envia información y la procesa por medio de un Spartan 3 utilizando como medio de comunicación el dispositivo Xbee en modo de transmisión transparente, es decir, emulando una comunicación serial normal. Además, el operador manipula remotamente los relojes de disparo y de tiempo total teniendo la opción de detener, reiniciar y retroceder para ajustar.

2. La segunda parte consiste en el dispositivo encargado de proyectar el marcador a través del VGA. El dispositivo está comunicado inalámbricamente con el panel del operador, el cuál le está enviando constantemente los datos a proyectar. Este dispositivo también procesa la información de manera que lleve una cuenta del reloj, cuarto y reloj de tiro. También se encarga de almacenar las imágenes de publicidad a mostrar y proyectarlas. 

3. Finalmente se tiene un sistema de monitoreo y control elaborado con Labview por medio del cual se pueden guardar los datos de cada partido al finalizarlo, corregir datos en el tablero en caso de error, obtener todas las estadísticas del partido y verificar el historial de juegos jugados por medio de un sistema de archivos. Este sistema también envia datos vía serial para poder corregirlos y obtenerlos. Todos los datos de transmisión serial se harán por medio de una máscara de envío para asegurar la integridad de los mensajes a transmitir y al recibirlos.
