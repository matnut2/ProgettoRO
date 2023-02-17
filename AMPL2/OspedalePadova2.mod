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

# Costo Giornaliero per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoGiornaliero{ Tipo, Fornitori } >= 0 default 15; 

# Aumento Percentuale per Servizio in Surplus (Vincolo 2.2)
param addSurplus{ Fornitori } >= 0 default 0.50;

# Costo di Attivazione Settimanale per l'Attivazione di un Fornitore Indipendentemente dal Tipo di Ambulanza
param costoAttivazioneSettimanale{ Fornitori } >= 0 default 100;

# BigM per Vincoli di Tipo Logico (COSTANTE)
param BigM > 0 integer default 500;

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
	# Ambulanze Standard Attivate
	(sum{ t in Tipo, f in Fornitori, g in Giorni } ambulanze[t, f, g] * costoGiornaliero[t, f]) +
	# Ambulanze Surplus Attivate (Vincolo 2.2)
	(sum{ t in Tipo, f in Fornitori, g in Giorni } (ambulanze[t, f, g] * costoGiornaliero[t, f] + 
								  (ambulanze[t, f, g] * costoGiornaliero[t, f] * addSurplus[f]))) +
	# Costo di Attivazione Settimanale (Indifferentemente dal Tipo di Ambulanza Attivata) (Vincolo 2.1)
	(sum{ f in Fornitori } attivazioneSettimanale[f] * costoAttivazioneSettimanale[f])		
	;

### VINCOLI ###
# Vincolo per la Necessita' Giornaliera (+ Vincolo 2.1)
subject to necessitaGiornaliera { t in Tipo, g in Giorni } : sum{ f in Fornitori } ambulanze[t, f, g] = bisogno[g, t];
subject to necessitaGiornalieraSurplus {t in Tipo, g in Giorni} : sum{ f in Fornitori } ambulanzeSurplus[t, f, g] = surplus[g, t];
subject to maxDisponibilita {t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] + ambulanzeSurplus[t, f, g] <= maxAmbulanze[t, f]; 

# Vincolo per la Disponibilita' dei Fornitori
subject to disponibilita { t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] <= maxAmbulanze[t, f];

# Vincolo Logico per l'Attivazione Settimanale di un Fornitore Indipendentemente dal Tipo di Ambulanza Attivata (Vincolo 2.1)
subject to attivazioneSettimanaleFornitore { t in Tipo, f in Fornitori, g in Giorni } :  ambulanze[t, f, g] <= BigM * attivazioneSettimanale[f];

# Vincolo Logico per l'Attivazione di Almeno 3 Fornitori in un Giorno (Indipendentemente dal Tipo di Ambulanza) (Vincolo 2.3) + Vincoli Derivanti
#subject to attivazioneMinima { g in Giorni } : sum{ f in Fornitori } attivazioneGiornaliera[f, g] >= 4;
#subject to collegamento2 {f in Fornitori, g in Giorni} : attivazioneGiornaliera[f, g] <= attivazioneSettimanale[f];
#subject to attivazioniGiornaliere { f in Fornitori, g in Giorni } : sum{ t in Tipo} (ambulanze[t, f, g] + ambulanzeSurplus[t, f, g]) <= BigM * attivazioneGiornaliera[f, g];
#subject to attivazioneMinima_attivazione { f in Fornitori, g in Giorni } : sum{ t in Tipo}( ambulanze[t, f, g] + ambulanzeSurplus[t, f, g]) >= attivazioneGiornaliera[f, g];

subject to attivazioneMinima {t in Tipo, g in Giorni } : sum{ f in Fornitori } attivazioneGiornaliera[t, f, g] >= 3;
subject to collegamento2 { t in Tipo, f in Fornitori, g in Giorni} : attivazioneGiornaliera[t, f, g] <= attivazioneSettimanale[f];
subject to attivazioniGiornaliere { t in Tipo, f in Fornitori, g in Giorni } :(ambulanze[t, f, g] + ambulanzeSurplus[t, f, g]) <= BigM * attivazioneGiornaliera[ t, f, g];
#subject to attivazioneMinima_attivazione { t in Tipo, f in Fornitori, g in Giorni } : ( ambulanze[t, f, g] + ambulanzeSurplus[t, f, g]) >= attivazioneGiornaliera[t, f, g];