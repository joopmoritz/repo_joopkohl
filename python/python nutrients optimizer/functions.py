'''

===================================================================================================
'''

def ref_value(path): 
    #pandas für Datenauswertung von xlsx Dateien.
    import pandas as pd
    
    alter   = 28
    gender  = 'm'
    ref     = pd.read_excel(path + '/references.xlsx' )

    #Eingabe verarbeiten, String zuweisen für Tabellensuche
    match alter: 
        case alter if alter < 4:    group = '1 bis unter 4 Jahre'
        case alter if alter < 7:    group = '4 bis unter 7 Jahre'
        case alter if alter < 10:   group = '7 bis unter 10 Jahre'
        case alter if alter < 13:   group = '10 bis unter 13 Jahre'
        case alter if alter < 15:   group = '13 bis unter 15 Jahre'
        case alter if alter < 19:   group = '15 bis unter 19 Jahre'
        case alter if alter < 25:   group = '19 bis unter 25 Jahre'
        case alter if alter < 51:   group = '25 bis unter 51 Jahre'
        case alter if alter < 65:   group = '51 bis unter 65 Jahre'
        case alter if alter >= 65:  group = '65 Jahre und älter'

    if gender == 'm': 
        geschlecht  = 'Männlich' 
    else: 
        geschlecht  = 'Weiblich'


    #Tabelle nach Personeigenschaften und in weitere Tabelle schreiben
    ref_filt        = ref[(ref['Bevölkerungsgruppe']== group) & (ref['Geschlecht'] == geschlecht)]
    
    #Kontrollausgabe
    nutri_filt      = list(ref_filt['Nährstoff'])

    reference_val   = {}

    for i in nutri_filt: 
        zeile       = ref_filt[(ref_filt['Nährstoff']== i )]

        #Zugriff auf das erste element über iloc, das zeile serie ist 
        reference_val[i]=  (zeile['Referenzwert'].iloc[0],zeile['Einheit'].iloc[0]) 
        

    find        =   ['Kilokalorien','Fett','Kohlenhydrate','Protein','Ballaststoffe']
    makro_name  =   ['ENERCC Energie (Kilokalorien) [kcal/100g]','PROT625 Protein (Nx6,25) [g/100g]',
                    'FAT Fett [g/100g]', 'CHO Kohlenhydrate, verfügbar [g/100g]','FIBT Ballaststoffe, gesamt [g/100g]']
    
    for i in range(len(find)): 
        reference_val.pop(find[i],None)
        reference_val[makro_name[i]] =   ('-',)

    
    return reference_val

'''
#Funktion zur Eingabekontrolle der Nutzereingabe
===================================================================================================
'''

def user_input(output= 'Bitte Nutzereingabe : ',data_type= int,min= float('-inf'), max = float('inf')): 
    while True: 
        inp= input(output)
        try: 
            out = data_type(inp)
            
            # ob bei zahlen wert zahl zwischen grenzen
            if data_type == int or data_type == float: 
                if out >= min and out <= max:
                    return out
                else: 
                    print('Wert liegt aushalb der gültigen Grenzen')
                    continue

        except:  
            print('Falsche Eingabe! Erneut versuchen!')
            continue 
       
'''
#Funktion zum laden der DataFrame / Serie mittels panda aus der excel Tabelle
===================================================================================================
'''

def load_meal(references, meal,path,list_meal,gewicht, makros):
    import pandas as pd

    #Lebensmitteldatenladen
    nutri_ref   = pd.read_excel(path + '/nutritients_ref.xlsx' )
    #Zähler für Gewichtanwahl
    m           = 0
  
    for j in meal.keys():
    
        #Leeres Dic um Nutris je Lebensmittel zu speichern
        nutri_meal  = {}
        makro_meal  = {}
        #Suchen nach zeilen mitteln contains, die 
        zeile       = nutri_ref[nutri_ref['Lebensmittelbezeichnung'].astype(str).str.contains( j, case=False)]
        
        print(zeile['Lebensmittelbezeichnung']) 

        #Abfrage, mehrere Lebensmittel gefunden werden --> nutzer auswahl, welcher berücksichtig werden soll
        if len(zeile) > 1 and meal[j][1] != '': 
            zeile       = zeile[zeile['Lebensmittelbezeichnung'].astype(str).str.contains(j + " " + meal[j][1])]
        elif len(zeile) > 1: 
            #Ausgabe der mehreren einträge und Nutzerabfrage und -Auswahl
            zeile_liste = zeile['Lebensmittelbezeichnung'].tolist()

            print('Mehrere Lebensmittel gefunden, bitte wählen Sie eins aus:')

            for i in range(len(zeile_liste)): 
                print(i, zeile_liste[i])
          
            index= user_input('Index eingeben : [0-'+ str(i) + "]", int, 0, i)
            

            #Index aus Liste löschen, um Liste als löschschablone zu nutzen
            zeile_liste.pop(index)
            #Nicht ausgewählte Einträge entfernen aus Serie
            zeile = zeile[~zeile['Lebensmittelbezeichnung'].isin(zeile_liste)].iloc[0]
            
            key_idx= get_key(references, zeile)

            for key in makros:
                for col in zeile.index: 
                    if key in col: 
                        makro_meal[key] = zeile[col]
        

        #Position und Länge der Lebensmittel bestimmten, der selben Kategorie
        list_meal.append([])
        index_list  = load_nutrients(zeile, references, gewicht,m, nutri_ref,list_meal, nutri_meal)

        #Dictionary belegene und ausgebenen
        meal[j]     = meal[j] + (zeile['BLS Code'],)+ (index_list,) + (makro_meal,) + (nutri_meal,)
        m           += 1
        
    return (meal,key_idx)

'''
#Encoder-Funktion, relevant um aus den Solution-Daten Lebensmittel abzuleiten
===================================================================================================
'''

def encoder(solution,meal_list):
    #Liste definieren, encodierte Lebensmittel aus zugeben
    
    #Zuweisung über Index
    food    = []
    for i in range(len(solution)):
        food.append(meal_list[i].iloc[solution[i]]) 
    
    #Ausgabe der Liste
    return food

'''
#Funktion, um Key/Index des DataFrames auszulesen, um Key-Suche zu vermeiden -> Zeiteffizienter
===================================================================================================
'''

def get_key(ref_data, nutri_data):
    
    # Leere Listen erstellen
    key_nutri   = []
    key_ref     = []
    idx_key     = 0
    find_idx    = []
   
    # Key Suche in durchführen, abgleich reference namen mit Spaltennamen aus datenbank
    for key in ref_data.keys(): 
        #Flag dient, dass nicht doppelt geschrieben wird zb vitamin D würde auch vitamin d2, d3 etc finden
        finding     = False
        key_ref.append(key)
        for col in nutri_data.index: 
            if key in col: 
                key_nutri.append(col)
                finding = True 
                break

        if finding == False: find_idx.append(idx_key)
        idx_key += 1

    #Ref-Namen löschen, die nicht in Datenbank enthalten
    key_ref_sort= [element for i, element in enumerate(key_ref) if i not in find_idx]    
    
    print(len(key_ref))
    print(len(key_ref_sort))
    print(len(key_nutri))

    #Spaltennamen als Liste speichern und zurückgeben
    key_idx     = [key_ref_sort, key_nutri] 
    print(key_idx)
    return key_idx

'''
#Filterfunktion: User kann Makro/Mikro prio einstellen und Beziehungen festlegen
===================================================================================================
'''
def filter_nutri(): 
    pass 


'''
#Funktion zum laden der Nährstoffe
===================================================================================================
'''
def load_nutrients(data_series, references, gewicht, z, nutri_reference= None, data_frame= [], nutri_meal= None): 

    if nutri_meal != None: #!!! Eventuell rauslöschen, wird nicht benötigt.
        #Referenznährstoffe aus Data Frame ziehen und dictionary adden
        for i in references.keys(): 
            #Spaltenweise durchsuchen
            for col in data_series.index: 
                if i in col: 
                    try: 
                        nutri_meal[col] = references[i] + (float(data_series[col]) * gewicht[z]/100,)
                    except ValueError: 
                        nutri_meal[col] = references[i] + (data_series[col],)


    if data_frame[z] == []: 
        #Gruppe ausleiten bzw Index für Mutation später
        idx             = nutri_reference[nutri_reference['BLS Code'].astype(str).str[0] == data_series['BLS Code'][0]]
        #Gruppen in Liste schreiben, je elemente ein Data Frame
        data_frame[z]   = idx

        #Indexe bestimmen, relevant um die solution (Zahlen) mittels encoder in Lebensmittel umzuwandeln
        idx             = idx['BLS Code'].tolist()
        idx_this        = idx.index(data_series['BLS Code'])
        #Grenzen für die Mutation
        idx_min         = 1 
        idx_max         = len(idx)   
        
        #Max-Wert minus 1, da aktueller Index rausgelöscht wird
        return          (idx_this,idx_min,idx_max-1)    
    else : 
        return          True  

'''
#Bewertungs-Funktion
===================================================================================================
'''
#ToDo: filter, 
def evaluation(data_series, references, gewicht, makro, key_idx): 
    
    score       = [0 for i in range(len(data_series))]

    key_ref     = key_idx[0]
    key_nutri   = key_idx[1]


    for i in range(len(data_series)):
        deviation_nutri = deviation_makro  = 0

        for j in range(len(key_idx[0])):
            if key_nutri[j] not in makro[i].keys(): 
                try: 
                    actual          = float(data_series[i][key_nutri[j]])*gewicht[i]/100
                    ref             = float(references[key_ref[j]][0])
                    diff            = actual - ref
                    
                    if diff < 0: 
                        deviation_nutri   += (abs(diff)/ref)**2 

                except ValueError:
                    continue


            #Makrodifferenzen berechnen 
            else: 
                try: 
                    actual_makro        = float(data_series[i][key_nutri[j]])
                    ref_first           = float(makro[i][key_ref[j]])
                    diff_makro          = actual_makro - ref_first
        
                    if abs(diff_makro)  > ref_first*0.05 :
                        
                        deviation_makro  += (abs(diff_makro)/ref_first)**2                      
                except : 
                    continue
    
        score[i]    += 1/(1+deviation_nutri*0.3 + deviation_makro*.7) 

    #Score als Summe ausgeben, da GA über eine Ganzzahl optimiert und nicht über komplette Solutionlist 
    # Todo: Gewichtung über filter 
    return sum(score)/len(score)


'''
#Funktion zur Ausgabe der Ergebnisse: ToDo ausgabe über Datei oder GUI 
===================================================================================================
'''
def compare_unit(reference_unit, key_nutri_label):
    reference_unit = str(reference_unit).split('/')
    try:
        if reference_unit[0] in key_nutri_label: 
            return True
    except: 
        return False
    
    return False


'''
#Funktion zur Ausgabe der Ergebnisse: ToDo ausgabe über Datei oder GUI 
===================================================================================================
'''
def print_erg(result, startpopulation,reference, key_idx, gewicht):
    
    key_ref     = key_idx[0]
    key_nutri   = key_idx[1]

    zw_erg_res  = {}
    zw_erg_pop  = {}
    erg         = []

    #Summe aller Nährstoffkategorie bilden: 
    for i in range(len(result)):
        for j in range(len(key_nutri)):
            if i == 0: 
                try:
                    zw_erg_res[key_nutri[j]]   =  float(result[i][key_nutri[j]])
                    zw_erg_pop[key_nutri[j]]   =  float(startpopulation[i][key_nutri[j]])
                except: 
                    zw_erg_res[key_nutri[j]]   =  0
                    zw_erg_pop[key_nutri[j]]   =  0
            else: 
                try:
                    zw_erg_res[key_nutri[j]]   +=  float(result[i][key_nutri[j]])
                    zw_erg_pop[key_nutri[j]]   +=  float(startpopulation[i][key_nutri[j]])
                except: 
                    zw_erg_res[key_nutri[j]]   +=  0
                    zw_erg_pop[key_nutri[j]]   +=  0

    for j in range(len(key_nutri)): 
                try: 
                    #If bedingung notwending, das float / zero wirft keinen fehler sonder ist gleich inf 
                    erg.append((key_nutri[j], 
                                (zw_erg_res[key_nutri[j]]-zw_erg_pop[key_nutri[j]])/zw_erg_pop[key_nutri[j]]* 100 
                                if startpopulation[i][key_nutri[j]] != 0 else 0))           
                except: 
                    erg.append((key_nutri[j], 0))

    #Zwischenergebnisse ins finales Dictonary schreiben und printen
    total_erg= {}
    for i in range(len(result)): 
        if i == 0: 
            total_erg['Ausgangs-Mahlzeit']      =   startpopulation[i]['Lebensmittelbezeichnung']
            total_erg['optimierte Mahlzeit']    =   result[i]['Lebensmittelbezeichnung']
        else: 
            total_erg['Ausgangs-Mahlzeit']      +=  ' ' + startpopulation[i]['Lebensmittelbezeichnung']
            total_erg['optimierte Mahlzeit']    +=  ' ' + result[i]['Lebensmittelbezeichnung']

    for i in range(len(erg)): 
            total_erg[erg[i][0]]                =   float(erg[i][1])
      
 
    print('\n================================================= \n')
    print(' Ausgangs-Mahlzeit    : ',    "\n", total_erg['Ausgangs-Mahlzeit'],   end= '\n\n')
    print(' Optimierte Mahlzeit  : ',    "\n", total_erg['optimierte Mahlzeit'], end= '\n\n')

    for key in total_erg: 
        if key != 'Ausgangs-Mahlzeit' and key != 'optimierte Mahlzeit':
            print( str(round(total_erg[key],2)) + " % " + "\t"*(len(str(round(total_erg[key],2)))<= 4), key,sep= '\t :')



    #Vergleich mit Referenzwerten erstellen
    value          = [{} for i in range(len(result))]
    abs_compare_ref2res = {}
    rel_compare_ref2res = {}

    #absolute Mikronährstoffmenge bestimmen
    for j in range(len(result)): 
        for i in range(len(key_nutri)):
            try: 
                value  = float(result[j][key_nutri[i]] * gewicht[j])/100
            except: 
                value  = 0
            
            if j == 0: 
                abs_compare_ref2res[key_ref[i]]   = value 
        
            else: 
                abs_compare_ref2res[key_ref[i]]  += value
                
    #relative Mikronährstoffabgedeckung bestimmen: 
    for i in range(len(key_nutri)):
        if key_ref[i] not in    [
                                'ENERCC Energie (Kilokalorien) [kcal/100g]',
                                'PROT625 Protein (Nx6,25) [g/100g]', 
                                'FAT Fett [g/100g]', 
                                'CHO Kohlenhydrate, verfügbar [g/100g]',
                                'FIBT Ballaststoffe, gesamt [g/100g]'
                                ]:

            value_ref   = str(reference[key_ref[i]][0]).replace(",", ".")
            value_abs   = abs_compare_ref2res[key_ref[i]]

            if compare_unit(reference[key_ref[i]][1],key_nutri[i]): 
                try: 
                    if '-' in value_ref:
                        split_value = value_ref.split('-')
                        value_ref   = split_value[1]

                    rel_compare_ref2res[key_ref[i]] = (((value_abs - float(value_ref))/float(value_ref))*100  if float(value_ref) != 0 else 0)
                    
                except: 
                    rel_compare_ref2res[key_ref[i]] = 0
            else: 
                rel_compare_ref2res[key_ref[i]] = float('nan')

    print('\n================================================= \n')
    #Ausgabe
    for i in range(len(key_ref)):
        if key_ref[i] not in    [
                                'ENERCC Energie (Kilokalorien) [kcal/100g]',
                                'PROT625 Protein (Nx6,25) [g/100g]', 
                                'FAT Fett [g/100g]', 
                                'CHO Kohlenhydrate, verfügbar [g/100g]',
                                'FIBT Ballaststoffe, gesamt [g/100g]'
                                ]:
            print(  f"{str(key_ref[i] ):<25}" + ' \t :',
                    'Referenzwert :' + f"{str(reference[key_ref[i]][0]):>10}" + "\t " + f"{str(reference[key_ref[i]][1]):<15}",
                    'Absolute Abdeckung :\t' + f"{str(round(abs_compare_ref2res[key_ref[i]],2)):<7}", 
                    ' Relative Abdeckung :' + '+' * (rel_compare_ref2res[key_ref[i]]>0) + str(round(rel_compare_ref2res[key_ref[i]],2)) + ' %'
                )
        
    