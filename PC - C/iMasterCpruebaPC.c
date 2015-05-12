#include <windows.h>
#include <stdio.h>
#include <strings.h>

// Declaraciones ----------------------------------

COMMTIMEOUTS touts;
HANDLE serial;

int bps;//para escoger la vel. de conexi�n
char nombrePuerto[10];
int totalChars, totalSnd, totalRcv;
unsigned char caracter; //char que se lee o recibe
unsigned char bufferRx;
unsigned char datoEnviar[100];
unsigned char Fila[6];
unsigned char campo[7];
 //-----------------------------------------------
 
 //*************************************************************************************
//Prototipos de funciones

HANDLE abre_y_configura_serial(char *nombrePuerto, int velocidad, COMMTIMEOUTS touts);
int envia_serial(HANDLE serial, unsigned char *buffer, int cantidad_a_enviar);
int recibe_serial(HANDLE serial, unsigned char *buffer, int cantidad_a_recibir);
int cierra_serial(HANDLE serial);
//*************************************************************************************

//*************************************************************************************
//Rutinas gen�ricas y de utiler�a del programa

HANDLE abre_y_configura_serial(char *nombrePuerto, int velocidad, COMMTIMEOUTS touts){
	DCB dcb;
	HANDLE handle;

	bps = 4800;
	sprintf(nombrePuerto,"COM8");
	touts.ReadTotalTimeoutConstant = 100;
	touts.WriteTotalTimeoutConstant = 100;

	handle = CreateFile((const char *)nombrePuerto,GENERIC_WRITE | GENERIC_READ,0,NULL,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL,NULL);
	//sin paridad, 8 bits de datos y un bit de stop.
	if (handle == NULL){
		printf("Error al abrir el HANDLE");
	}else{

	dcb.BaudRate= CBR_4800;
	dcb.ByteSize = 8;
	dcb.StopBits = ONESTOPBIT;
	dcb.Parity = NOPARITY;
	
	GetCommState(handle,&dcb);
	SetCommTimeouts(handle,&touts);
	SetCommState(handle,&dcb);
	}
	return handle;
}

int envia_serial(HANDLE serial, unsigned char *bufferTx, int cantidad_a_enviar){
	int state;
	int totalWritten;
	
	state=WriteFile(serial,(char *)bufferTx,(DWORD) cantidad_a_enviar, (PDWORD) &totalWritten,NULL);
	return totalWritten;
}

int recibe_serial(HANDLE serial, unsigned char *buffer, int cantidad_a_recibir){
	int state;
	int totalRead;

	state=ReadFile(serial,(char *)buffer,(DWORD) cantidad_a_recibir, (PDWORD) &totalRead,NULL);
	return totalRead;
}

int cierra_serial(HANDLE serial){
	int state = CloseHandle(serial);		//Cierra el "handle"
	return state;
}

int main(){
    unsigned char quest = 1;
    int datoTxId,datoTxC1,datoTxC2,datoTxC3,datoTxC4,aux,i;
    serial = abre_y_configura_serial(nombrePuerto,bps,touts);

    printf("PRUEBA DE INTERFAZ SPARTAN MAESTRO CON PC\n");
    
    while (quest){
    printf("Id: "); scanf( "%d", &datoTxId);
    printf("C1: "); scanf( "%d", &datoTxC1);
    printf("C2: "); scanf( "%d", &datoTxC2);
    printf("C3: "); scanf( "%d", &datoTxC3);
    printf("C4: "); scanf( "%d", &datoTxC4);
    printf("LISTO\n");
    campo[0]=0x55;
    campo[1]=datoTxId;
    campo[2]=datoTxC1;
    campo[3]=datoTxC2;
    campo[4]=datoTxC3;
    campo[5]=datoTxC4;
    campo[6]=0xAA;
    
    for (aux=0; aux<7; aux++){
        totalSnd=envia_serial(serial, &campo[aux],1); 
        Sleep(20);
        printf("Enviando campo[%d]= %X... \n",aux,campo[aux]);
    }//for 
    
    if (datoTxId>=17 && datoTxId<=19){
        for (aux=0; aux<7; aux++){
            totalRcv = 0;
            while (totalRcv == 0){
               totalRcv = recibe_serial(serial, &bufferRx, 1);
            }
    		Fila[0]=Fila[1];
    		Fila[1]=Fila[2];
    		Fila[2]=Fila[3];
    		Fila[3]=Fila[4];
    		Fila[4]=Fila[5];
    		Fila[5]=Fila[6];
    		Fila[6]=bufferRx;
        }//for
    
        for(i=0; i<7; i++) {printf("Dato Recibido[%d]= %X \n", i,Fila[i]);}//for
    }
    printf(" \nPresione [0] para salir u cualquiera para repetir: ");
    scanf( "%d", &quest);
    
    
    }//while quest
    cierra_serial(serial);
    



    
}
