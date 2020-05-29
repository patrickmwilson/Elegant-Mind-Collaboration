function subjects = cleanTable(table)
    table.Var1 = [];
    table.Var2 = [];
    table.Var4 = [];
    table.Var8 = [];
    table.Var12 = [];
    table.Var16 = [];
    table.Var20 = [];
    table.Var24 = [];
    table.Var28 = [];
    table.T1_1 = [];
    table.CP_1 = [];
    table.CPO_1 = [];
    table.CC9x9_1 = [];
    table.CC3x3_1 = [];
    table.IC_1 = [];
    table.CP9x9_1 = [];
    
    table.Properties.VariableNames = {'name' 'fc_slope' 'fc_error' 'cp_slope' 'cp_error' 'cpo_slope' 'cpo_error' 'cc9_slope' 'cc9_error' 'cc3_slope' 'cc3_error' 'ic_slope' 'ic_error' 'cp9_slope' 'cp9_error'};
    
    subjects = table2struct(table);

end