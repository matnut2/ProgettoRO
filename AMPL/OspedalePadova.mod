# ==============================
#         Modello AMPL
#      Ricerca operativa
#        Soldà Matteo
#           (2022)
# ==============================

### INSIEMI ###
set Giorni ordered;                                                                             # Giorni della settimana
set FornitoriA;                                                                                 # Fornitori di ambulanze di tipo A
set FornitoriB;                                                                                 # Fornitori di ambulanze di tipo B

### PARAMETRI ###
param bisognoA { Giorni } >= 0 integer default 0;                                               # Fabbisogno giornaliero di ambulanze di tipo A (escluso surplus arbitrario)
param bisognoB { Giorni } >= 0 integer default 0;                                               # Fabbisogno giornaliero di ambulanze di tipo B (escluso surplus arbitrario)
param surplusA { Giorni } >= 2 integer default 2;
param surplusB { Giorni } >= 1 integer default 1;
param maxA { FornitoriA } >= 0 integer default 15;                                              # Numero massimo di ambulanze di tipo A che un fornitore può fornire
param maxB { FornitoriB } >= 0 integer default 5;                                               # Numero massimo di ambulanze di tipo B che un fornitore può fornire
param costoGiornalieroA { FornitoriA } > 0 default 10;				                            # Costo per l'attivazione giornaliera di una ambulanza di tipo A in base al fornitore
param costoGiornalieroB { FornitoriB } > 0 default 5;				                            # Costo per l'attivazione giornaliera di una ambulanza di tipo B in base al fornitore
param costoAttivazioneA { FornitoriA } >= 0 default 100;				                        # Costo per l'attivazione settimanale di una ambulanza di tipo A in base al fornitore (da pagare una sola volta a settimana in caso di attivazione del fornitore)
param costoAttivazioneB { FornitoriB } >= 0 default 75;				                            # Costo per l'attivazione settimanale di una ambulanza di tipo B in base al fornitore (da pagare una sola volta a settimana in caso di attivazione del fornitore)
param BigM >= 0 integer default 500;								                            # BigM per vincoli di tipo logico

### VARIABILI ###
var ambulanzeA { fa in FornitoriA, ga in Giorni } integer >= 0;                                 # Numero di ambulanze di tipo A fornite dal fornitore fa il giorno ga 
var ambulanzeB { fb in FornitoriB, gb in Giorni } integer >= 0;                                 # Numero di ambulanze di tipo B fornite dal fornitore fb il giorno gb
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
# Vincoli Necessità Giornaliera
subject to necessitaGiornalieraA {g in Giorni} : sum { f in FornitoriA } ambulanzeA[f, g] >=  bisognoA[g] + surplusA[g];
subject to necessitaGiornalieraB {g in Giorni} : sum { f in FornitoriB } ambulanzeB[f, g] >=  bisognoB[g] + surplusB[g];

# Vincoli Disponibilità Fornitori
subject to disponibilitaA { f in FornitoriA, g in Giorni } :  ambulanzeA[f, g] <= maxA[f];
subject to disponibilitaB { f in FornitoriB, g in Giorni } :  ambulanzeB[f, g] <= maxB[f]; 

# Vincoli Logici
subject to attivazioneA { f in FornitoriA, g in Giorni } : ambulanzeA[f, g] <= BigM * attivazioneSettimanaleA[f];
subject to attivazioneB { f in FornitoriB, g in Giorni } : ambulanzeB[f, g] <= BigM * attivazioneSettimanaleB[f]; 
