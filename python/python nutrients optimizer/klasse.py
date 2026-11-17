from functions import encoder, evaluation

class Optimierer: 
    def __init__(self, meal_list, references, gewicht, makro_nutri, key_idx):
        #Attribute/Eigenschaften definieren, damit diese in den Methoden aufgerufen werden können, genetischer Algo akzeptiert
        #eigentlich nur 3
        self.meal_list      = meal_list
        self.ref_data       = references
        self.gewicht        = gewicht
        self.makro_nutri    = makro_nutri
        self.key_idx        = key_idx

    #Fitnessfunktion, Kernfunktion des Algorithmuses
    def fitness_func(self, ga_instances, solution, solution_idx):
        
        
        data_series= encoder(solution, self.meal_list)
        return evaluation(data_series, self.ref_data, self.gewicht, self.makro_nutri, self.key_idx)
