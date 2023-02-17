### INSIEMI ###
set Giorni ordered;
set Fornitori ordered;
set Tipo;	# Vincolo 3

### PARAMETRI ###
# Numero di Ambulanze Necessarie
param bisogno{ Giorni, Tipo };

# Numero di Ambulanze di Scorta
param surplus{ Giorni, Tipo };

# Numero Massimo di Ambulanze di un Determinato tipo Fornibili da un Determinato Fornitore
param maxAmbulanze{ Tipo, Fornitori };

# Costo Giornaliero per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoGiornaliero{ Tipo, Fornitori }; 

# Aumento Percentuale per Servizio in Surplus (Vincolo 2.2)
param addSurplus{ Fornitori };

# Costo di Attivazione Settimanale per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoAttivazioneTipo{ Tipo, Fornitori };

# Costo di Attivazione Settimanale per l'Attivazione di un Fornitore Indipendentemente dal Tipo di Ambulanza
param costoAttivazioneSettimanale{ Fornitori };

# BigM per Vincoli di Tipo Logico (COSTANTE)
param BigM > 0 integer default 500;

### VARIABILI ###
# Ambulanze di Tipo t del Fornitore f Attivate il Giorno g (+ Vincolo 2.2)
var ambulanze{ t in Tipo, f in Fornitori, g in Giorni } >= 0 integer; 
var ambulanzeSurplus{ t in Tipo, f in Fornitori, g in Giorni } >= 0 integer;

# Variabile Logica per l'Attivazione Settimanale del Fornitore f per le Ambulanze di Tipo t
var attivazioneSettimanaleTipo{ t in Tipo, f in Fornitori } binary;

# Variabile Logica per l'Attivazione Settimanale del Fornitore f Indipendentemente dal Tipo di Ambulanza (Vincolo 2.1)
var attivazioneSettimanale{ f in Fornitori } binary;

### FUNZIONE OBIETTIVO ###
minimize costo:
	# Ambulanze Standard Attivate
	(sum{ t in Tipo, f in Fornitori, g in Giorni } ambulanze[t, f, g] * costoGiornaliero[t, f]) +
	# Ambulanze Surplus Attivate (Vincolo 2.2)
	(sum{ t in Tipo, f in Fornitori, g in Giorni } (ambulanze[t, f, g] * costoGiornaliero[t, f] + 
								  ambulanze[t, f, g] * costoGiornaliero[t, f] * addSurplus[f])) +
	# Costo di Attivazione Settimanale (Differente per Tipo di Ambulanza Attivata) 
	(sum{ t in Tipo, f in Fornitori } attivazioneSettimanaleTipo[t, f] * costoAttivazioneTipo[t, f]) +
	# Costo di Attivazione Settimanale (Indifferentemente dal Tipo di Ambulanza Attivata) (Vincolo 2.1)
	(sum{ f in Fornitori } attivazioneSettimanale[f] * costoAttivazioneSettimanale[f])		
	;

### VINCOLI ###
# Vincolo per la Necessita' Giornaliera (+ Vincolo 2.1)
subject to necessitaGiornaliera { t in Tipo, g in Giorni } : sum{ f in Fornitori } ambulanze[t, f, g] >= bisogno[g, t];
subject to necessitaGiornalieraSurplus {t in Tipo, g in Giorni} : sum{ f in Fornitori } ambulanzeSurplus[t, f, g] >= surplus[g, t];
subject to maxDisponibilita {t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] + ambulanzeSurplus[t, f, g] <= maxAmbulanze[t, f]; 

# Vincolo per la Disponibilita' dei Fornitori
subject to disponibilita { t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] <= maxAmbulanze[t, f];

# Vincolo Logico per l'Attivazione Settimanale di un Fornitore in Base al Tipo di Ambulanze Fornite
subject to attivazioneSettimanaleFornitoreTipo { t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] <= BigM * attivazioneSettimanaleTipo[t, f];

# Vincolo Logico per l'Attivazione Settimanale di un Fornitore Indipendentemente dal Tipo di Ambulanza Attivata (Vincolo 2.1)
subject to attivazioneSettimanaleFornitore { t in Tipo, f in Fornitori, g in Giorni } :  ambulanze[t, f, g] <= BigM * attivazioneSettimanale[f];

# Collegamento dei Due Vincoli Precedenti (if attivazioneSettimanale == 0 -> attivazioneSettimanale = 0) (Vincolo 2.1)
subject to collegamento { t in Tipo, f in Fornitori } : attivazioneSettimanaleTipo[t, f] <= attivazioneSettimanale[f];