# ==============================
#         Modello AMPL
#      Ricerca operativa
#        Solda' Matteo
#           (2022)
# ==============================

### INSIEMI ###
set Giorni ordered;
set Fornitori ordered;
set Tipo;	# Vincolo 3

### PARAMETRI ###
# Numero di Ambulanze Necessarie
param bisogno{ Giorni, Tipo } >= 0 integer default 7;

# Numero di Ambulanze di Scorta
param surplus{ Giorni, Tipo } >= 0 integer default 2;

# Numero Massimo di Ambulanze di un Determinato tipo Fornibili da un Determinato Fornitore
param maxAmbulanze{ Tipo, Fornitori } >= 0 integer default 5;

# Numero Massimo di Giorni in cui un Determinato Fornitore puo' Essere Attivato (Separatamente per Tipo di Ambulanza)(Vincolo 1)
param maxGiorni{ Tipo, Fornitori } >= 0 <= 7 integer default 7;

# Costo Giornaliero per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoGiornaliero{ Tipo, Fornitori } >= 0 default 15; 

# Aumento Percentuale per Servizio in Surplus (Vincolo 2.2)
param addSurplus{ Fornitori } >= 0 default 0.50;

# Costo di Attivazione Settimanale per l'Attivazione di un Fornitore Indipendentemente dal Tipo di Ambulanza
param costoAttivazioneSettimanale{ Fornitori } >= 0 default 100;

# BigM per Vincoli di Tipo Logico (COSTANTE)
param BigM > 0 integer default 500;

# Numero Minimo di Fornitori da Attivare al Giorno (COSTANTE)(Vincolo 2.3)
param MIN_FORNITORI > 0 <= card(Fornitori) default (card(Fornitori)/2);

### VARIABILI ###
# Ambulanze di Tipo t del Fornitore f Attivate il Giorno g (+ Vincolo 2.2)
var ambulanze{ t in Tipo, f in Fornitori, g in Giorni } >= 0 integer; 
var ambulanzeSurplus{ t in Tipo, f in Fornitori, g in Giorni } >= 0 integer;

# Variabile Logica per l'Attivazione Settimanale del Fornitore f Indipendentemente dal Tipo di Ambulanza (Vincolo 2.1)
var attivazioneSettimanale{ f in Fornitori } binary;

# Variabile Logica per l'Attivazione Giornaliera di un Determinato Fornitore in un Determinato Giorno (Indistintamente dal Tipo di Ambulanza) (Vincolo 2.3)
var attivazioneGiornaliera{ t in Tipo,f in Fornitori, g in Giorni } binary;

### FUNZIONE OBIETTIVO ###
minimize costo:
	(sum{ t in Tipo, f in Fornitori, g in Giorni } ambulanze[t, f, g] * costoGiornaliero[t, f]) 			+
	(sum{ t in Tipo, f in Fornitori, g in Giorni } (ambulanzeSurplus[t, f, g] * costoGiornaliero[t, f] 		+ 
	(ambulanzeSurplus[t, f, g] * costoGiornaliero[t, f] * addSurplus[f]))) 	+
	(sum{ f in Fornitori } attivazioneSettimanale[f] * costoAttivazioneSettimanale[f])						+
	(sum{ t in Tipo, f in Fornitori, g in Giorni } attivazioneGiornaliera[t, f, g] * costoGiornaliero[t, f]) 		
	;

### VINCOLI ###
# Vincolo per la Necessita' Giornaliera (+ Vincolo 2.1)
subject to necessitaGiornaliera { t in Tipo, g in Giorni } : sum{ f in Fornitori } ambulanze[t, f, g] >= bisogno[g, t];
subject to necessitaGiornalieraSurplus {t in Tipo, g in Giorni} : sum{ f in Fornitori } ambulanzeSurplus[t, f, g] >= surplus[g, t];
subject to maxDisponibilita {t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] + ambulanzeSurplus[t, f, g] <= maxAmbulanze[t, f]; 

# Vincolo Logico per l'Attivazione Settimanale di un Fornitore Indipendentemente dal Tipo di Ambulanza Attivata (Vincolo 2.1)
subject to attivazioneSettimanaleFornitore { t in Tipo, f in Fornitori, g in Giorni } :  ambulanze[t, f, g] <= BigM * attivazioneSettimanale[f];

# Vincolo Logico per l'Attivazione di Almeno MIN_FORNITORI Fornitori in un Giorno (Considerando il Tipo di Ambulanza) (Vincolo 2.3) + Vincoli Derivanti
subject to attivazioneMinima {t in Tipo, g in Giorni } : sum{ f in Fornitori } attivazioneGiornaliera[t, f, g] >= MIN_FORNITORI;
subject to collegamento2 { t in Tipo, f in Fornitori, g in Giorni} : attivazioneGiornaliera[t, f, g] <= attivazioneSettimanale[f];
subject to attivazioniGiornaliere { t in Tipo, f in Fornitori, g in Giorni } :(ambulanze[t, f, g] + ambulanzeSurplus[t, f, g]) <= BigM * attivazioneGiornaliera[ t, f, g];

# Vincolo che Limita l'Attivazione dei Fornitori nell'Arco della Settimana (Considerando il Tipo di Ambulanza)(Vincolo 1)
subject to massimaAttivazione { t in Tipo, f in Fornitori} : sum{g in Giorni} attivazioneGiornaliera[t, f, g] <= maxGiorni[t, f];