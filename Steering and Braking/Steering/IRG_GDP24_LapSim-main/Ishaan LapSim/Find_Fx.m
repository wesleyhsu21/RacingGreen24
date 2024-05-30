function [Fx] = Find_Fx(Fy, Fx_max, Fy_max)

    Fx = zeros(2,2);

    for i = 1:2
        for j = 1:2
            if (1 - (Fy(1,i,j)/Fy_max(1,i,j))^ 2) < 0 
                Fx(i,j) = 0;
            else
                Fx(i,j) = (1 - (Fy(1,i,j)/Fy_max(1,i,j))^2)^0.5 * Fx_max(1,i,j);        
            end
        end
    end
end