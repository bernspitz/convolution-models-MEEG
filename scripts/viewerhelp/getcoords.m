function [X, Y] = getcoords(Labels);
load('coords_338_elecs.mat');

for n=1:length(Labels);
    actelec = cell2mat(Labels(n,:));
    ind     = strmatch(actelec, Layout.Labels, 'exact');
    X(n)    = Layout.Coords(ind,1);
    Y(n)    = Layout.Coords(ind,2);
end

