function retval = set_cruise_variable_value(cruiseVars,fieldName,val)
% SET_CRUISE_VARIABLE_VALUE modifies an nx2 cell matrix and returns it.
% An nX2 cell matrix is passed along with a string denoting the field and
% and a string as the value to set the field to.
% example.
%
%
% C = {{'apples','oranges','pears'}',{65,6,234}'}
% get_cruise_variable_value(C,'oranges')
% ans =
%      6
% C = set_cruise_variable_value(C,'oranges','22')
% get_cruise_variable_value(C,'oranges')
% ans =
%      22


X = strfind(cruiseVars{1},fieldName);
i=find(~cellfun(@isempty,X),1);
cruiseVars{2}{i} = val;
retval = cruiseVars;
end
