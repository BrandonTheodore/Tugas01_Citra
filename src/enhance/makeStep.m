function s = makeStep(id, params, colorMode)
%MAKESTEP Membuat struct satu langkah pipeline enhancement.
%   s = MAKESTEP('gamma', [0.6 1], 'ratio')
    if nargin < 2, params = []; end
    if nargin < 3 || isempty(colorMode), colorMode = 'auto'; end
    s = struct('id', id, 'params', params, 'colorMode', colorMode);
end
