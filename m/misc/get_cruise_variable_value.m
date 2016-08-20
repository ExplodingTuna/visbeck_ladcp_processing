function val = get_cruise_variable_value(cruiseVars,fieldName)
% GET_CRUISE_VARIABLE_VALUE returns the value of a cruise variable.
% an nX2 cell matrix is passed along with a string denoting the field
% for the value needed.
% example.
%
% C = {{'apples','oranges','pears'}',{65,6,234}'}
% get_cruise_variable_value(C,'oranges')
% ans =
%      6

X = strfind(cruiseVars{1},fieldName);
i=find(~cellfun(@isempty,X),1);
val = cruiseVars{2}{i};