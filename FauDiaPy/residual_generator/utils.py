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
        self.variable_aliases = []
        self.var_ids_assigning = []
        self.var_aliases_assigning = []
        self.expressions = []
        self.values = None

        # Gather the matched equations and variables
        for assignment in scc:
            self.equation_ids.append(assignment[0])
            if len(assignment) > 1:  # This is not a residual
                self.var_ids_assigning.append(assignment[1])

        self.__logger.debug('Created Evaluator for equations {}'.format(self.equation_ids))

        # Gather all involved variable ids
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

        # Initialize the values dictionary
        variable_aliases = [variable.alias for variable in var_array if variable.id in self.variable_ids]
        self.values = dict.fromkeys(variable_aliases)

    def set_inputs(self, values_dict):
        """
        Register known inputs
        :param values_dict:
        :return: N/A
        """

        for key in self.values:
            try:
                self.values[key] = values_dict[key]
            except KeyError as e:
                self.__logger.exception('Input dictionary did not contain requested key')
                raise e

    def clear_values(self):
        """
        Empty the values dictionary to prepare for a new evaluation iteration
        :return: N/A
        """
        for key in self.values:
            self.values[key] = None

    def evaluate(self):

        if not self.expressions:
            self.__logger.error('Symbolic expressions not available')
            raise ValueError

        unassigned_values = []
        for key, value in self.values:
            if value is None:
                unassigned_values.append(key)

        if len(self.var_ids_assigning) != len(unassigned_values):
            self.__logger.error('# of unknown variables is not equal to # of assigning variables ({})'.format(unassigned_values))
            raise AssertionError

        # TODO: more work needed here


class Differentiator(Evaluator):
    """
    Special Evaluator for integrations and differetiations
    """

    __logger = logging.getLogger('Differentiator')

    state = None
    _prev_state = None
    dt = None

    def __init__(self, scc, eqn_array, var_array, relations):

        if len(scc) != 1:
            self.__logger.error('Differentiator initialized with more than one equation')
            raise AssertionError

        Evaluator.__init__(self, scc, eqn_array, var_array, relations)

        if len(self.variable_ids) != 2:
            self.__logger.error('Differentiation included more than 2 variables')
            raise AssertionError

        if self.expressions[0] != 'differentiator':
            self.__logger.error('Given expression does not correspond to a differentiator')
            raise AssertionError

    def set_state(self, value):
        self.state = value

    def set_dt(self, dt_in):
        self.dt = dt_in

    def get_derivative(self, dt_in):
        if self._prev_state is None:
            self._prev_state = 0

        answer = (self.state - self._prev_state)/dt_in
        self._prev_state = self.state

        return answer

    def get_integral(self, dt_in):
        if self._prev_state is None:
            self._prev_state = 0

        answer = self._prev_state + self.state*dt_in
        self._prev_state = self.state

        return answer

    def evaluate(self):
        known_variable = None
        for key in self.values:
            if self.values[key] is not None:
                known_variable = key
        if known_variable is None:
            self.__logger.error("Couldn't find any unknown variables")
            raise TypeError

        if 'dot' in known_variable:  # We know the derivative
            self.state = self.values[known_variable]
            return self.get_integral(self.dt)
        else:  # We known the integral
            self.state = self.values[known_variable]
            return self.get_derivative(self.dt)


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
