function h = TrackViz(x,y,c)

x(end+1) = NaN;
y(end+1) = NaN;
c(end+1) = NaN;


h = patch(x,y,c, EdgeColor = 'interp');
h.LineWidth = 6;
colorbar;
colormap hot;

end