function [numcycles,cycles] = find_elem_circuits(A)

if ~issparse(A)
    A = sparse(A);
end

n = size(A,1);

Blist = cell(n,1);

blocked = false(1,n);

s = 1;
cycles = {};
stack=[];

    function unblock(u)
        blocked(u) = false;
        for w=Blist{u}
            if blocked(w)
                unblock(w)
            end
        end
        Blist{u} = [];
    end

    function f = circuit(v, s, C)
        f = false;
        
        stack(end+1) = v;
        blocked(v) = true;
        
        for w=find(C(v,:))
            if w == s
                cycles{end+1} = [stack s];
                f = true;
            elseif ~blocked(w)
                if circuit(w, s, C)
                    f = true;
                end
            end
        end
        
        if f
            unblock(v)
        else
            for w = find(C(v,:))
                if ~ismember(v, Blist{w})
                    Bnode = Blist{w};
                    Blist{w} = [Bnode v];
                end
            end
        end
        
        stack(end) = [];
    end


while s < n
    
    % Subgraph of G induced by {s, s+1, ..., n}
    F = A;
    F(1:s-1,:) = 0;
    F(:,1:s-1) = 0;
    
    % components computes the strongly connected components of 
    % a graph. This function is implemented in Matlab BGL 
    % http://dgleich.github.com/matlab-bgl/
    [ci, sizec] = components(F);
    
    if any(sizec >= 2)
        
        cycle_components = find(sizec >= 2);
        least_node = find(ismember(ci, cycle_components),1);
        comp_nodes = find(ci == ci(least_node));
        
        Ak = sparse(n,n);
        Ak(comp_nodes,comp_nodes) = F(comp_nodes,comp_nodes);        
    
        s = comp_nodes(1);
        blocked(comp_nodes) = false;
        Blist(comp_nodes) = cell(length(comp_nodes),1);
        circuit(s, s, Ak);
        s = s + 1;
    
    else
        break;        
    end
end

numcycles = length(cycles);

end