
'''
Pfade deklarieren
===================================================================================================
'''
#Pfad der "Datenbank"
path= '...'

'''
Bibliotheken laden
===================================================================================================
'''
#Optimierer laden
import pygad

#Funktionen laden
from functions  import ref_value, load_meal, encoder, evaluation, print_erg, get_key
from klasse     import Optimierer

'''
Objekt anlegen
===================================================================================================
'''
gen_optimierer= Optimierer([],[],ref_value(path),[],[])

#Leere liste im Lebensmittel als Gruppen in DataFrame zuspeichern, notwendig für die Population
startpopulation         =   []
gen_optimierer.meal_list=   []
gen_optimierer.gewicht  =   []
#Referfenz Daten laden
gen_optimierer.ref_data= ref_value(path)
print(gen_optimierer.ref_data)

'''
Nutzereingabe starten
===================================================================================================
'''
#Deklaration der Mahlzeit
meal=   {
        'Reis':(300,''), 
        'Tofu': (300,''),
        'Hühnerei': (300,''),
        'Salat': (300,'')
        }

'''
Datenverarbeitung
===================================================================================================
'''

makros= [
        'ENERCC Energie (Kilokalorien) [kcal/100g]',
        'PROT625 Protein (Nx6,25) [g/100g]',
        'FAT Fett [g/100g]', 
        'CHO Kohlenhydrate, verfügbar [g/100g]',
        'FIBT Ballaststoffe, gesamt [g/100g]'
        ]

#Erstellen List die Information über Menge beinhalten 
# -> vermeiden vom mitführen verschachtelter Daten
for key in meal.keys(): 
    gen_optimierer.gewicht.append(meal[key][0])

nutritients, gen_optimierer.key_idx = load_meal(
                                                gen_optimierer.ref_data,
                                                meal,
                                                path,
                                                gen_optimierer.meal_list,
                                                gen_optimierer.gewicht, 
                                                makros
                                                )

# Startpopulation als Series in Liste speichern 
i= 0
for key in meal.keys():
    startpopulation.append(gen_optimierer.meal_list[i].iloc[nutritients[key][3][0]])
    gen_optimierer.meal_list[i] = gen_optimierer.meal_list[i][~(gen_optimierer.meal_list[i]['BLS Code'] == (nutritients[key][2]))]
    i+=1

#Makronährstoffe von Startpopulation als Referenzwert speichern
for key in nutritients.keys(): 
    gen_optimierer.makro_nutri.append(nutritients[key][4]) 

print(gen_optimierer.makro_nutri)


#Erstellen der initialen Solution 
# -> wird durch fitness func bewertert 
# -> motiert -> wieder bewertet ...
solution = []
for key in meal.keys(): 
    solution.append((nutritients[key][3][0]))
print(solution)


'''
genetische Optimierung
===================================================================================================
'''
r= []
for k in nutritients.keys():
    r.append(nutritients[k][3][2])
print(r)

gene_space=[
    range(int(r[i])) for i in range(len(r))
    ]

print(gene_space)

#Genetischen Algo definieren
ga_instance = pygad.GA(
    #Anzahl der Generationen
    num_generations         =   15,
    #Anzahl der Individuen por Generation
    sol_per_pop             =   400,
    #Anzahl der Vermehrung der Besten
    num_parents_mating      =   50,
    #Mutationsrate
    mutation_percent_genes  =   20,
    #Fitnessfunktion, Bestimmung der Fitness
    fitness_func            =   gen_optimierer.fitness_func,
    #Range der Solution einzelner Gene in der Solution -> Wertegrenzen
    gene_space              =   gene_space,
    #Wieviele Gene bilden eine Solution 
    num_genes               =   len(gene_space),
    #Ganzzahlige Solutionwerte
    gene_type=int
)

#Aufruf Algo
ga_instance.run()
#Ergebnisse ausgeben
solution, fitness, index = ga_instance.best_solution()


'''
Ergebnis Vergleich Makros
===================================================================================================
'''

#Makros Startpopulation
for i in range(len(startpopulation)):
    print(
            startpopulation[i]['ENERCC Energie (Kilokalorien) [kcal/100g]'], 
            startpopulation[i]['PROT625 Protein (Nx6,25) [g/100g]'], 
            startpopulation[i]['FAT Fett [g/100g]'], 
            startpopulation[i]['CHO Kohlenhydrate, verfügbar [g/100g]']
        )
result= encoder(solution, gen_optimierer.meal_list)
#Makros Ergebnispopulation
for i in range(len(result)):
    print(  
            result[i]['ENERCC Energie (Kilokalorien) [kcal/100g]'], 
            result[i]['PROT625 Protein (Nx6,25) [g/100g]'], 
            result[i]['FAT Fett [g/100g]'], 
            result[i]['CHO Kohlenhydrate, verfügbar [g/100g]']
        )
#Finalen Score des Ergebnisses bestimmen
score= evaluation(  
                    result,
                    gen_optimierer.ref_data,
                    gen_optimierer.gewicht,
                    gen_optimierer.makro_nutri, 
                    gen_optimierer.key_idx
                 )
key = list(meal.keys())



'''
Ergebnisausgabe
===================================================================================================
'''
print('Ergebnis als Index \t:', solution)
print('Ergebnis in Fitness \t:', score)
for i in range(len(key)):
    print('Ergänze ' + key[i]     + ' durch \t: \t\t' + result[i]['Lebensmittelbezeichnung'], end= "\n")


print_erg(  
            result,
            startpopulation,
            gen_optimierer.ref_data,
            gen_optimierer.key_idx,
            gen_optimierer.gewicht
         )