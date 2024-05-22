function latexCode = generateSymmetricLayupLatex(layup)
    % Function to generate LaTeX code for a symmetric layup
    % Input: layup - string in the format '[0 0 90 0 0 -45 45 0 0 -45 45 90]_S'
    
    % Remove the brackets and '_S' from the input string
    layup = strrep(layup, '[', '');
    layup = strrep(layup, ']', '');
    layup = strrep(layup, '_S', '');
    
    % Split the layup string into individual layer orientations
    layers = strsplit(layup);
    
    % Find the midpoint index for symmetric layup
    midIndex = length(layers) / 2;
    
    % Generate the LaTeX code for the symmetric layup
    latexCode = '\\begin{array}{c}\n';
    
    % Add the top layers
    for i = 1:midIndex
        latexCode = [latexCode, layers{i}, ' \\\\ '];
    end
    
    % Add the symmetry line
    latexCode = [latexCode, '\\hline\n'];
    
    % Add the bottom layers
    for i = midIndex:-1:1
        latexCode = [latexCode, layers{i}, ' \\\\ '];
    end
    
    latexCode = [latexCode, '\\end{array}'];
    
    % Display the generated LaTeX code
    disp(latexCode);
end