#!/usr/bin/env python

# title           :graphUtils.py
# description     :
# author          :George Zogopoulos-Papaliakos
# date            :19/1/2018
# version         :
# notes           :
# licence         :Apache 2.0
# ==============================================================================


class GraphElement:

    def __init__(self, input_id):

        self.is_matched = False
        self.id = 0
        self.__debug = False

        if input_id is None:
            self.id = input_id
            if self.__debug:
                print('Acquired ID %d from provider' % input_id)
            else:
                raise TypeError('ID should be a positive integer')

    def set_mathed(self, tf_value):
        self.is_matched = tf_value

    # TODO implement getProperties


class Vertex(GraphElement):

    def __init__(self, input_id):
        GraphElement.__init__(self, input_id)

        self.alias = None
        self.name = None
        self.description = None
        self.matched_to = None
        self.edge_id_array = None
        self.neighbour_id_array = None


class Variable(Vertex):

    def __init__(self, input_id, alias=None, description=None):
        Vertex.__init__(self, input_id)

        self.is_known = False
        self.is_measured = False
        self.is_input = False
        self.is_output = False
        self.is_residual = False

        if alias is not None:
            self.alias = alias

        if description is not None:
            self.description = description

    def __str__(self):
        output = 'Variable object\n'
        output += 'id = {}\n'.format(self.id)
        output += 'alias = {}\n'.format(self.alias)
        output += 'description = {}'.format(self.description)
        return output

    # TODO write dispDetailed mehtod

    def set_known(self, tf_value):
        self.is_known = tf_value

    def set_measured(self, tf_value):
        self.is_measured = tf_value

    def set_input(self, tf_value):
        self.is_input = tf_value

    def set_output(self, tf_value):
        self.is_output = tf_value

    def set_residual(self, tf_value):
        self.is_residual = tf_value


class Equation(Vertex):

    def __init__(self, input_id, alias=None, expression_str=None, description=None):
        Vertex.__init__(self, input_id)

        self.is_static = False
        self.is_dynamic = False
        self.is_nonlinear = False
        self.is_res_generator = False
        self.is_faultable = False
        self.expression_str = ""
        self.subsystem = ""

        if alias is not None:
            self.alias = alias
        else:
            self.alias = 'con'

        if expression_str is not None:
            self.expression_str = expression_str

        if description is not None:
            self.description = description

    def set_static(self, tf_value):
        self.is_static = tf_value
        self.is_dynamic = not tf_value

    def set_dynamic(self, tf_value):
        self.is_dynamic = tf_value
        self.is_static = not tf_value

    def set_nonlinear(self, tf_value):
        self.is_nonlinear = tf_value

    def set_res_generator(self, tf_value):
        self.is_res_generator = tf_value

    def set_faultable(self, tf_value):
        self.is_faultable = tf_value

    def set_subsystem(self, ss_name):
        self.subsystem = ss_name

    def __str__(self):
        output = 'Equation object\n'
        output += 'ID = {}\n'.format(self.id)
        output += 'name = {}\n'.format(self.alias)
        output += 'subsystem = {}\n'.format(self.subsystem)
        return output
