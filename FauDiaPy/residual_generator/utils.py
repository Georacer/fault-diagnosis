# title           : utils.py
# description     : Utilities for residual_generator module
# author          : George Zogopoulos-Papaliakos
# date            : 23/1/2018
# version         :
# notes           :
# licence         : Apache 2.0  
#==============================================================================

import logging
import graph.graph_utils as gu


class Evaluator:

    __logger = logging.getLogger('Evaluator')

    def __init__(self, scc, eqn_array, var_array, relations):

        self.equation_ids = []
        self.variable_ids = []
        self.var_ids_assigning = []
        self.expressions = []
        self.values = dict()

        # Gather the matched equations and variables
        for assignment in scc:
            self.equation_ids.append(assignment[0])
            if len(assignment) > 1:  # This is not a residual
                self.var_ids_assigning.append(assignment[1])

        self.__logger.debug('Created Evaluator for equations {}'.format(self.equation_ids))

        # Gather all involved variables
        for equ_id in self.equation_ids:
            new_variables = [temp_tuple[1] for temp_tuple in relations if temp_tuple[0] == equ_id]
            if len(new_variables) > 1:
                self.__logger.error('Found more than one assignment with the requested equation id {}'.format(equ_id))
            if len(new_variables) < 1:
                self.__logger.error('Found no assignment with the requested equation id {}'.format(equ_id))
            self.variable_ids += new_variables[0]

        self.variable_ids = list(set(self.variable_ids))  # Make list unique
        self.__logger.debug('Added variables {} to the evaluator'.format(self.variable_ids))

        # Gather all expressions, in the same order as equation_ids
        for equ_id in self.equation_ids:
            try:
                new_expression = next(equation.expression for equation in eqn_array if equation.id == equ_id)
            except StopIteration as e:
                self.__logger.error('Did not find equation {} in eqn_array'.format(equ_id))
                raise e
            self.expressions.append(new_expression)


    # def get_inputs(self, evaluator_list):

    # def evaluate(self):


def create_evaluators(solution_order, equations, variables, relations):
    '''
    Convert the solution order into Evaluator objects
    :param solution_order: list of SCCs
    :param equations: list of all equations
    :param variables: list of all variables
    :param relations: list of all equation-relation variables
    :return: list of Evaluator objects
    '''

    evaluator_list = []

    for scc in solution_order:
        new_evaluator = Evaluator(scc, equations, variables, relations)
        evaluator_list.append(new_evaluator)

    return evaluator_list
