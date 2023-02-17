### INSIEMI ###
set Giorni ordered;
set Fornitori ordered;
set Tipo;

### PARAMETRI ###
# Numero di Ambulanze Necessarie
param bisogno{ Giorni, Tipo };

# Numero di Ambulanze di Scorta
param surplus{ Giorni, Tipo };

# Numero Massimo di Ambulanze di un Determinato tipo Fornibili da un Determinato Fornitore
param maxAmbulanze{ Tipo, Fornitori };

# Costo Giornaliero per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoGiornaliero{ Tipo, Fornitori }; 

# Costo di Attivazione Settimanale per una Ambulanza di un Determinato Tipo di un Determinato Fornitore
param costoAttivazione{ Tipo, Fornitori };

# BigM per Vincoli di Tipo Logico (COSTANTE)
param BigM > 0 integer default 500;

### VARIABILI ###
# Ambulanze di Tipo t del Fornitore f Attivate il Giorno g
var ambulanze{ t in Tipo, f in Fornitori, g in Giorni } >= 0 integer; 

# Variabile Logica per l'Attivazione Settimanale del Fornitore F per le Ambulanze di Tipo t
var attivazioneSettimanale{t in Tipo, f in Fornitori} binary;

### FUNZIONE OBIETTIVO ###
minimize costo:
	(sum{ t in Tipo, f in Fornitori, g in Giorni } ambulanze[t, f, g] * costoGiornaliero[t, f]) + 
	(sum{ t in Tipo, f in Fornitori} attivazioneSettimanale[t, f] * costoAttivazione[t, f])		
	;

### VINCOLI ###
# Vincolo per la Necessita' Giornaliera
subject to necessitaGiornaliera { t in Tipo, g in Giorni } : sum{ f in Fornitori } ambulanze[t, f, g] >= bisogno[g, t] + surplus[g, t];

# Vincolo per la Disponibilita' dei Fornitori
subject to disponibilita { t in Tipo, f in Fornitori, g in Giorni } : ambulanze[t, f, g] <= maxAmbulanze[t, f];