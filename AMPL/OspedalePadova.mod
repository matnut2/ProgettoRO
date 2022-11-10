# ==============================
#         Modello AMPL
#      Ricerca operativa
#        Soldà Matteo
#           (2022)
# ==============================

### INSIEMI ###
set Giorni ordered;                                                                             # Giorni di attivazione delle ambulanze
set FornitoriA;                                                                                 # Fornitori di ambulanze di tipo A
set FornitoriB;                                                                                 # Fornitori di ambulanze di tipo B

### PARAMETRI ###
param bisognoA { Giorni } integer default 0;                                                    # Fabbisogno giornaliero di ambulanze di tipo A
param bisognoB { Giorni } integer default 0;                                                    # Fabbisogno giornaliero di ambulanze di tipo B
param maxA { FornitoriA } integer >= 0 default 15;                                              # Numero massimo di ambulanze di tipo A che un fornitore pu� fornire
param maxB { FornitoriB } integer >= 0 default 5;                                               # Numero massimo di ambulanze di tipo B che un fornitore pu� fornire
param costoGiornalieroA { FornitoriA } default 10;				                                # Costo per l'attivazione giornaliera di una ambulanza di tipo A in base al fornitore
param costoGiornalieroB { FornitoriB } default 5;				                                # Costo per l'attivazione giornaliera di una ambulanza di tipo B in base al fornitore
param costoAttivazioneA { FornitoriA } default 100;				                                # Costo per l'attivazione settimanale di una ambulanza di tipo A in base al fornitore
param costoAttivazioneB { FornitoriB } default 75;				                                # Costo per l'attivazione settimanale di una ambulanza di tipo B in base al fornitore
param BigM := 9999999;								                                            # BigM per vincoli di tipo logico

### VARIABILI ###
var ambulanzeA { fa in FornitoriA, ga in Giorni } integer >= 0;                                 # Numero di ambulanze di tipo A fornite dal fornitore f il giorno g 
var ambulanzeB { fb in FornitoriB, gb in Giorni } integer >= 0;                                 # Numero di ambulanze di tipo B fornite dal fornitore f il giorno g
var attivazioneSettimanaleA { f in FornitoriA }   binary;		                                # Varaibile logica per l'attivazione settimanale delle ambulanze di tipo A di un certo fornitore
var attivazioneSettimanaleB { f in FornitoriB }	  binary;		                                # Variabile logica per l'attivazione settimanale delle ambulanze di tipo B di un certo fornitore

### FUNZIONE OBIETTIVO ###
minimize costo: 
    (sum { f in FornitoriA, g in Giorni } ambulanzeA[f, g] * costoGiornalieroA[f]) + 			# COSTO SETTIMANALE AMBULANZE TIPO A
    (sum { f in FornitoriB, g in Giorni } ambulanzeB[f, g] * costoGiornalieroB[f]) +			# COSTO SETTIMANALE AMBULANZE TIPO B
    (sum { f in FornitoriA } attivazioneSettimanaleA[f] * costoAttivazioneA[f])	   +			# ATTIVAZIONE SETTIMANALE AMBULANZE TIPO B
    (sum { f in FornitoriB } attivazioneSettimanaleB[f] * costoAttivazioneB[f])	    			# ATTIVAZIONE SETTIMANALE AMBULANZE TIPO B
    ;

### VINCOLI ###
# Vincoli Necessit� Giornaliera
subject to necessitaGiornalieraA {g in Giorni} : sum { f in FornitoriA } ambulanzeA[f, g] >=  bisognoA[g] + 3;
subject to necessitaGiornalieraB {g in Giorni} : sum { f in FornitoriB } ambulanzeB[f, g] >=  bisognoB[g] + 1;

# Vincoli Disponibilit� Fornitori
subject to disponibilitaA { f in FornitoriA, g in Giorni } :  ambulanzeA[f, g] <= maxA[f];
subject to disponibilitaB { f in FornitoriB, g in Giorni } :  ambulanzeB[f, g] <= maxB[f]; 

# Vincoli Logici
subject to attivazioneA { f in FornitoriA, g in Giorni } : ambulanzeA[f, g] <= BigM * attivazioneSettimanaleA[f];
subject to attivazioneB { f in FornitoriB, g in Giorni } : ambulanzeB[f, g] <= BigM * attivazioneSettimanaleB[f]; 
