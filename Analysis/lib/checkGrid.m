function [slope_range,int_range,complete] = checkGrid(chi_grid,slope_range,int_range,target)
    slope_min = slope_range(1); slope_max = slope_range(2);
    int_min = int_range(1); int_max = int_range(2);
    complete = true;
        
    if(min(chi_grid(:,1)) < target)
        slope_min = slope_min - 0.005;
        complete = false;
    end
    if(min(chi_grid(:,100)) < target)
        slope_max = slope_max + 0.005;
        complete = false;
    end
    if(min(chi_grid(1,:)) < target)
        int_min = int_min - 0.005;
        complete = false;
    end
    if(min(chi_grid(100,:)) < target)
        int_max = int_max + 0.005;
        complete = false;
    end

    slope_range = [slope_min slope_max];
    int_range = [int_min int_max];
end