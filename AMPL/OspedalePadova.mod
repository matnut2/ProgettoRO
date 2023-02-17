# ==============================
#         Modello AMPL
#      Ricerca operativa
#        Solda' Matteo
#           (2022)
# ==============================

### INSIEMI ###
set Giorni ordered;     				 # Giorni della settimana
set Fornitori							 # Fornitori di ambulanze
set FornitoriA within Fornitori;         # Fornitori di ambulanze di tipo A
set FornitoriB within Fornitori;         # Fornitori di ambulanze di tipo B

### PARAMETRI ###
# Fabbisogno Giornaliero di Ambulanze
param bisognoA { Giorni } >= 0 integer default 0;           
param bisognoB { Giorni } >= 0 integer default 0;

# Ambulanze "di Scorta"
param surplusA { Giorni } >= 2 integer default 2;           
param surplusB { Giorni } >= 1 integer default 1;

# Numero Massimo Giornaliero di Ambulanze Attiviabili da un Fornitore 
param maxA { FornitoriA } >= 0 integer default 15;
param maxB { FornitoriB } >= 0 integer default 5;

# Costo per l'Attivazione Settimanale di un Fornitore (2.1)
param costoAttivazioneFornitore

# Costo per l'Attivazione Giornaliero di una Ambulanza
param costoGiornalieroA { FornitoriA } > 0 default 10;
param costoGiornalieroB { FornitoriB } > 0 default 5;

# Numero Massimo di Giorni nei quali un Fornitore può Intervenire (1)
param MaxGiorni { Fornitori } >= 0 integer default 3;

# Costo per l'Attivazione Settimanale di una Ambulanza (da pagare una sola volta in caso di attivazione del fornitore per la determinata settimana)
param costoAttivazioneA { FornitoriA } >= 0 default 100;
param costoAttivazioneB { FornitoriB } >= 0 default 75;

# BigM per vincoli di tipo logico
param BigM >= 0 integer default 500;

### VARIABILI ###
var ambulanzeA { fa in FornitoriA, ga in Giorni } integer >= 0;     # Numero di ambulanze di tipo A fornite dal fornitore fa il giorno ga 
var ambulanzeB { fb in FornitoriB, gb in Giorni } integer >= 0;     # Numero di ambulanze di tipo B fornite dal fornitore fb il giorno gb
var attivazioneSettimanaleFornitore { f in Fornitori } binary		# Variabile binaria per l'attivazione settimanale di un determinato fornitore (2.1)
var attivazioneSettimanaleA { f in FornitoriA }   binary;           # Varaibile logica per l'attivazione settimanale delle ambulanze di tipo A di un certo fornitore
var attivazioneSettimanaleB { f in FornitoriB }	  binary;           # Variabile logica per l'attivazione settimanale delle ambulanze di tipo B di un certo fornitore

### FUNZIONE OBIETTIVO ###
minimize costo: 
    (sum { f in FornitoriA, g in Giorni } ambulanzeA[f, g] * costoGiornalieroA[f]) + 			# COSTO SETTIMANALE AMBULANZE TIPO A
    (sum { f in FornitoriB, g in Giorni } ambulanzeB[f, g] * costoGiornalieroB[f]) +			# COSTO SETTIMANALE AMBULANZE TIPO B
    (sum { f in FornitoriA } attivazioneSettimanaleA[f] * costoAttivazioneA[f])	   +			# ATTIVAZIONE SETTIMANALE AMBULANZE TIPO B
    (sum { f in FornitoriB } attivazioneSettimanaleB[f] * costoAttivazioneB[f])	    			# ATTIVAZIONE SETTIMANALE AMBULANZE TIPO B
    ; # AGGIUNGERE COSTO DI ATTIVAZIONE DEL FORNITORE INIPENDENTE DAL TIPO DI AMBULANZA (2.1)

### VINCOLI ###
# Vincoli Necessita' Giornaliera
subject to necessitaGiornalieraA {g in Giorni} : sum { f in FornitoriA } ambulanzeA[f, g] >=  bisognoA[g] + surplusA[g];
subject to necessitaGiornalieraB {g in Giorni} : sum { f in FornitoriB } ambulanzeB[f, g] >=  bisognoB[g] + surplusB[g];

# Vincoli Disponibilita' Fornitori
subject to disponibilitaA { f in FornitoriA, g in Giorni } :  ambulanzeA[f, g] <= maxA[f];
subject to disponibilitaB { f in FornitoriB, g in Giorni } :  ambulanzeB[f, g] <= maxB[f]; 

# Vincolo Disponibilità Giorni di Attivazione
### conta dell'attivazione del fornitore che deve essere minore della disponibibilità massima

# Vincoli Logici
subject to ? ### ATTIVAZIONE DEL FORNITORE INDIPENDENTEMENTE DALL'AMBULANZA (2.1)
subject to attivazioneA { f in FornitoriA, g in Giorni } : ambulanzeA[f, g] <= BigM * attivazioneSettimanaleA[f];
subject to attivazioneB { f in FornitoriB, g in Giorni } : ambulanzeB[f, g] <= BigM * attivazioneSettimanaleB[f]; 
