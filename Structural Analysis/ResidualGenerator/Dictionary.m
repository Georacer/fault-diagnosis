classdef Dictionary < handle
    %DICTIONARY Keep variable values
    %   Detailed explanation goes here
    
    properties
        ids_array = [];
        aliases_cell = {};
        values_array = [];
        id_2_index_array = [];
    end
    
    properties (Dependent)
        numEls
    end
    
    methods
        
        function [ obj ] = Dictionary(ids, aliases, values)
            % Constructor
            if isempty(ids)
                return;
            else
                obj.ids_array = ids;
            end
            
            if ~isempty(aliases)
                assert(length(obj.ids_array)==length(aliases));
                obj.aliases_cell = aliases;
            end
            
            if ~isempty(values)
                assert(length(obj.ids_array)==length(values));
                obj.values_array = values;
            else
                obj.values_array = inf*ones(size(obj.ids_array));
            end
            
            % Create a id->index reverse search registry
            obj.id_2_index_array = zeros(1,max(ids));
            for i=1:length(ids)
                obj.id_2_index_array(ids(i)) = i;
            end
        end
        
        function [ ] = setValue( obj, ids, aliases, values )
            %SETVALUE Set a variable value in the dictionary
            %   Detailed explanation goes here
            
            if ~isempty(ids)
                assert(length(ids)==length(values));
                id_indices = obj.getIdIndex(ids);
                obj.values_array(id_indices) = values;
            elseif ~isempty(aliases)
                assert(length(aliases)==length(values));
                alias_indices = obj.getAliasIndex(aliases);
                obj.values_array(alias_indices) = values;
            else
                error('Must provide either id or alias');
            end
        end
        
        function [ value ] = getValue( obj, ids, aliases )
            %SETVALUE Set a variable value in the dictionary
            %   Detailed explanation goes here
            
            if nargin<3
                aliases = {};
            end
            
            if ~isempty(ids)
                id_indices = obj.getIdIndex(ids);
                value = obj.values_array(id_indices);
            elseif ~isempty(aliases)
                alias_indices = obj.getAliasIndex(aliases);
                value = obj.values_array(alias_indices);
            else
                error('Must provide either id or alias');
            end            
        end
        
        function [ alias ] = getAlias( obj, ids)
            alias = cell(size(ids));
            for i=1:length(ids)
                index = obj.getIdIndex(ids(i));
                alias{i} = obj.aliases_cell{index};
            end
        end
        
        function [ index ] = getIdIndex(obj, ids)

            index = obj.id_2_index_array(ids);
%             Old implementation
%             index = zeros(size(ids));
%             for i=1:length(ids)
%                 index(i) = find(obj.ids_array==ids(i));
%             end
            assert(length(index)==length(ids));
        end
        
        function [ index ] = getAliasIndex(obj, aliases)
            index = zeros(size(aliases));
            for j=1:length(aliases)
                for i=1:length(obj.aliases_cell)
                    if strcmp(obj.aliases_cell{i},aliases{j})
                        index(j) = i;
                        break;
                    end
                end
            end
            assert(length(index)==length(aliases));
        end
        
        function [ lexicon ] = create_lexicon(obj, ids)
            % Create a lexicon structur for passing to a symbolic solver
            if nargin<2
                ids = obj.ids_array;
            end
            lexicon = struct();
            for i=1:length(ids)
                id = ids(i);
                alias = obj.getAlias(id);
                value = obj.getValue(id);
                lexicon.(alias{1}) = value;
            end
        end
        
        function [] = parse_lexicon(obj, lexicon)
            % Read a values structure from a symbolic solver
            fieldNames = fieldnames(lexicon);
            for i=1:length(fieldNames)
                fieldName = fieldNames(i);
                value = double(lexicon.(fieldName{1}));
                obj.setValue([], fieldName, value);
            end
        end
        
        function [ var_ids ] = get_known_ids(obj)
            % Return the variables whose value is known (not inf)
            var_ids = obj.ids_array(~isinf(obj.values_array));
        end
        
        function [ resp ] = get.numEls(obj)
            resp = length(obj.ids_array);
        end
        
        function [ ] = disp(obj)
            % Override the default print
            
            % Find the maximum column length
            alias_length = max(cellfun('length', obj.aliases_cell));
            if alias_length < 5
                column_length = 6;
            else
                column_length = alias_length+3;
            end
            
            integer_format = sprintf('%%%dd',column_length);
            string_format = sprintf('%%%ds', column_length);
            float_format = sprintf('%%%d.3g', column_length);
            
            % Set the ids
            fprintf('IDs    : ');
            for i=1:obj.numEls
                fprintf(integer_format, obj.ids_array(i));
            end
            fprintf('\n');
            fprintf('Aliases: ');
            % Set the aliases
            for i=1:obj.numEls
                fprintf(string_format, obj.aliases_cell{i});
            end
            fprintf('\n');
            fprintf('Values : ');
            % Set the ids
            for i=1:obj.numEls
                fprintf(float_format, obj.values_array(i));
            end
            fprintf('\n');
        end
        
    end
    
end

