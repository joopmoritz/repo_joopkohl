JOOP MORITZ KOHL - Engineering- und Simulationsprojekte
=======================================================

Numerische Modellierung, Simulation und Optimierung (Python, MATLAB).
Dieses Repository enthaelt Code aus meiner Weiterbildung (Python), meiner
Masterarbeit (MSc) und meiner Bachelorarbeit (BSc).

    python/   Weiterbildung   Naehrstoff-Optimierer mit genetischem Algorithmus
    msc/      Masterarbeit    Tuberkel-Schaufeln fuer Axialverdichter (CFD + GA)
    bsc/      Bachelorarbeit  Kinematik eines Rotationsverdichters

Repo-Ordner: python/ | matlab/msc/ | matlab/bsc/


-------------------------------------------------------------------------------
1) PYTHON - Naehrstoff-Optimierer (Weiterbildung Python / C++ Qt)
-------------------------------------------------------------------------------
Pfad: python/python nutrients optimizer/
Stack: Python, pandas, pygad (genetischer Algorithmus)

Aufgabe
  Eine Mahlzeit (z. B. Reis, Tofu, Ei, Salat) wird durch Lebensmittel
  derselben Gruppe ersetzt, sodass die Naehrstoffabdeckung steigt, die
  Makronaehrstoffe aber nahe an der Ausgangsmahlzeit bleiben.

Grundprinzip (genetischer Algorithmus)
  - Individuum: Vektor mit einem Gen je Lebensmittel. Das Gen ist der Index
    eines Alternativ-Lebensmittels aus derselben Hauptgruppe der
    BLS-Datenbank (ca. 7.100 Lebensmittel, rund 400 Naehrwertspalten).
  - Fitness = 1 / (1 + 0,3 * Mikro-Defizit + 0,7 * Makro-Abweichung)
      Mikro-Defizit:     nur Unterdeckung gegenueber dem Referenzwert zaehlt,
                         relativ und quadratisch gewichtet
      Makro-Abweichung:  Energie, Protein, Fett, Kohlenhydrate, Ballaststoffe,
                         bestraft ab 5 % Abweichung von der Ausgangsmahlzeit
  - Selektion, Kreuzung und Mutation uebernimmt pygad
    (400 Individuen, 15 Generationen, 50 Eltern, 20 % Mutation).

Funktionsweise
  1. functions.py (ref_value): Referenzwerte nach Alter und Geschlecht laden
  2. functions.py (load_meal): Lebensmittel suchen, Gruppe bestimmen
  3. main.py: genetischen Algorithmus starten
  4. klasse.py / functions.py (evaluation): Fitness je Individuum berechnen
  5. functions.py (print_erg): Ausgangs- und optimierte Mahlzeit vergleichen
     (Aenderung der Naehrstoffe in %, Abdeckung gegenueber Referenzwert)

Status: Prototyp. Offene Punkte stehen in todo.txt (z. B. Filterfunktion,
Benutzereingabe fuer Alter und Geschlecht).


-------------------------------------------------------------------------------
2) MSC - Tuberkel-Schaufeln fuer einen transsonischen Axialverdichter
-------------------------------------------------------------------------------
Pfad: matlab/msc/Matlab-Skripte/
Stack: MATLAB (Global Optimization Toolbox, Curve Fitting), ANSYS CFX/Workbench
Thema: Numerische CFD-Untersuchung von Tuberkel-Schaufeln (wellenfoermige
       Vorderkante) fuer die Aufladung von Wasserstoffmotoren.

a) Parametrisches Software-Programm/
   Erzeugt aus einer Schaufelgeometrie eine Schaufel mit Tuberkeln.
   Eingaben: Amplitude A und Anzahl der Tuberkel.
   Funktionsweise:
     1. Profilschnitte einlesen und per Spline verfeinern
     2. Vorderkante bestimmen und von 3D in 2D transformieren
        (Abstand zur Verbindungsgeraden Nabe-Gehaeuse, normiert)
     3. Vorderkante per Polynom annaehern und mit einer Sinuswelle
        ueberlagern:  A * sin(2*pi/lambda * x)
     4. Zurueck in 3D transformieren und auf die Profiloberflaeche projizieren
     5. Uebergang zur Saug- und Druckseite mit einem Polynom glaetten
     6. Neue Profildatei schreiben (blade.txt) fuer Vernetzung und CFD
   Je eine Variante fuer Rotor (rt) und Stator (st), zwei Skripte waren gefordert.

b) Genetische Optimierung/
   Optimiert Amplitude (0,3 bis 3 mm) und Tuberkelanzahl (1 bis 15).
   Grundprinzip: Der genetische Algorithmus (MATLAB ga, ganzzahlige
   Variablen) erzeugt Parameterpaare. Die Fitnessfunktion ist eine komplette
   Simulationskette:
     Geometrie erzeugen -> ANSYS (Netz, Setup) im Batch-Modus ->
     CFX-Rechnung (lokal bzw. per SSH/SLURM auf dem Uni-Cluster) ->
     Druckverhaeltnis und Wirkungsgrad einlesen
   Zielfunktion: Summe aus Wirkungsgrad und Druckverhaeltnis, jeweils auf die
   Basisgeometrie normiert (Minimierung des negativen Werts). Abgebrochene
   Rechnungen werden mit einem Strafwert bewertet. Alle Laeufe werden in
   Excel protokolliert. populationsize.m untersucht den Einfluss der
   Populationsgroesse.

c) Auswertung/
   Stellt die CFD-Ergebnisse dar: Kennlinien (Druckverhaeltnis ueber
   Massenstrom mit Fehlerbalken) und Geschwindigkeitsverlaeufe entlang der
   Schaufel, jeweils Tuberkel-Schaufel gegen Basisgeometrie.

Hinweis: Die Skripte benoetigen ANSYS und Zugriff auf den Cluster. Pfade
sind lokal und die CFD-Rohdaten nicht enthalten. Der Code dokumentiert
das Vorgehen und ist nicht ohne Weiteres lauffaehig.
Veroeffentlichung: Y. Schulz, J. M. Kohl, C. Kuestner, J. R. Seume (2024),
"Design and optimization of leading-edge tubercles for a transonic axial
compressor", ASME Turbo Expo.


-------------------------------------------------------------------------------
3) BSC - Kinematik eines Schukey-Rotationsverdichters
-------------------------------------------------------------------------------
Pfad: matlab/bsc/Kinematische Untersuchung/
Stack: MATLAB (Symbolic Math Toolbox, Curve Fitting)
Thema: Kinematische und stroemungstechnische Analyse (CFD) eines
       Rotationsverdichters mit Exzentergetriebe. Hier: der kinematische Teil.

Grundprinzip
  Exzentrisch gelagerte Zahnraeder (Exzentrizitaet e = 2,1 mm, halber
  Achsabstand L = 30 mm) erzeugen eine periodisch schwankende Uebersetzung
      i21 = R1 / R2,   R1 = sqrt(L^2 - e^2 sin^2(phi)) - e cos(phi),  R2 = 2L - R1.
  Dadurch drehen die Rotoren ungleichfoermig. Aus der Differenz der
  Rotorwinkel folgt der Kammerwinkel und damit der Verlauf des
  Kammervolumens.

Funktionsweise (Skripte in dieser Reihenfolge)
  Verschiebungsgleichung.m   Uebersetzung aus dem Radienverhaeltnis, Drehwinkel
                             durch Integration
  Parametergleichung.m       Verzahnung ueber Eingriffswinkel und Parameter
                             eta, Drehwinkel der Getriebestufen
  Abtriebsfunktionen.m       Fourier-Naeherungen der Winkel, Winkelgeschwindigkeit
                             und -beschleunigung beider Rotoren,
                             Vergleich der Phasenversaetze (90 und 180 Grad),
                             Verifizierungsrechnung
  Kammerwinkel_...m          Kammerwinkel, Extremstellen, akkumulierter Winkel
  Rotor1.txt, Rotor2.txt, phi1.txt, koeff.txt   Zwischenergebnisse
  Verifizierungsrechnung.xlsx                  Gegenrechnung der Ergebnisse
