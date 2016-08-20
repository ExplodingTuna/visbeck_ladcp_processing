function val = get_cruise_variable_value(cruiseVars,fieldName)

X = strfind(cruiseVars{1},fieldName);
i=find(~cellfun(@isempty,X),1);
val = cruiseVars{2}{i};